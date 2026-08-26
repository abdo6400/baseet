import 'package:sqflite/sqflite.dart';
import 'package:baseet/config/database/local/app_database.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/pos/data/models/order_model.dart';
import 'package:baseet/features/pos/data/models/product_model.dart';

abstract class PosLocalDataSource {
  Future<List<ProductModel>> getCatalog({String? categoryId, String? searchQuery});
  Future<OrderModel> checkout(OrderModel order);
  Future<double> getTodaySalesTotal();
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  final AppDatabase appDatabase;

  PosLocalDataSourceImpl({AppDatabase? database})
      : appDatabase = database ?? AppDatabase();

  @override
  Future<List<ProductModel>> getCatalog({String? categoryId, String? searchQuery}) async {
    final db = await appDatabase.database;

    String whereClause = '';
    final List<dynamic> whereArgs = [];

    if (categoryId != null && categoryId != 'cat_0' && categoryId.isNotEmpty) {
      whereClause = 'categoryId = ?';
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      final searchCondition = '(name LIKE ? OR barcode LIKE ? OR categoryName LIKE ?)';
      whereClause = whereClause.isEmpty ? searchCondition : '$whereClause AND $searchCondition';
      whereArgs.addAll([q, q, q]);
    }

    final maps = await db.query(
      'products',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name ASC',
    );

    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  @override
  Future<OrderModel> checkout(OrderModel order) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      // 1. Insert Order
      await txn.insert(
        'orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insert Order Items & Update Product Stock
      for (final item in order.items) {
        await txn.insert(
          'order_items',
          {
            'id': '${order.id}_${item.product.id}',
            'orderId': order.id,
            'productId': item.product.id,
            'productName': item.product.name,
            'categoryName': item.product.categoryName,
            'buyPrice': item.product.buyPrice,
            'sellPrice': item.product.sellPrice,
            'quantity': item.quantity,
            'customPrice': item.customPrice,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await txn.rawUpdate('''
          UPDATE products
          SET stockQuantity = MAX(0, stockQuantity - ?)
          WHERE id = ?
        ''', [item.quantity, item.product.id]);
      }

      // 3. Update Customer Debt if paymentMethod == debt
      if (order.paymentMethod == PaymentMethod.debt && order.customerId != null) {
        final custMaps = await txn.query(
          'customers',
          where: 'id = ?',
          whereArgs: [order.customerId],
          limit: 1,
        );

        if (custMaps.isNotEmpty) {
          final currentDebt = (custMaps.first['totalDebt'] as num).toDouble();
          final newDebt = currentDebt + order.remainingAmount;

          await txn.update(
            'customers',
            {
              'totalDebt': newDebt,
              'status': newDebt > 0 ? DebtStatus.regular.name : DebtStatus.regular.name,
            },
            where: 'id = ?',
            whereArgs: [order.customerId],
          );

          await txn.insert('debt_transactions', {
            'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
            'customerId': order.customerId!,
            'type': TransactionType.saleCredit.name,
            'amount': order.remainingAmount,
            'date': DateTime.now().toIso8601String(),
            'notes': 'فاتورة مبيعات آجل #${order.invoiceNumber}',
            'remainingBalance': newDebt,
          });
        }
      }
    });

    return order;
  }

  @override
  Future<double> getTodaySalesTotal() async {
    final db = await appDatabase.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(totalAmount) as totalSales
      FROM orders
      WHERE createdAt >= ? AND createdAt <= ?
    ''', [startOfDay, endOfDay]);

    if (result.isNotEmpty && result.first['totalSales'] != null) {
      return (result.first['totalSales'] as num).toDouble();
    }
    return 0.0;
  }
}
