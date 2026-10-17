import 'package:baseet/features/debt_ledger/domain/entities/debt_policy.dart';
import 'package:baseet/core/error/exceptions.dart';
import 'package:baseet/core/services/operation_context.dart';
import 'package:sqflite/sqflite.dart';
import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/pos/data/models/order_model.dart';
import 'package:baseet/features/catalog/data/models/product_model.dart';

abstract class PosLocalDataSource {
  Future<List<ProductModel>> getCatalog(
      {String? categoryId, String? searchQuery});
  Future<OrderModel> checkout(OrderModel order);
  Future<double> getTodaySalesTotal();
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  final AppDatabase appDatabase;
  final OperationContext context;

  PosLocalDataSourceImpl({required AppDatabase database, required this.context})
      : appDatabase = database;

  @override
  Future<List<ProductModel>> getCatalog(
      {String? categoryId, String? searchQuery}) async {
    final db = await appDatabase.database;

    String whereClause = '';
    final List<dynamic> whereArgs = [];

    if (categoryId != null && categoryId != 'cat_0' && categoryId.isNotEmpty) {
      whereClause = 'categoryId = ?';
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      final searchCondition =
          '(name LIKE ? OR barcode LIKE ? OR categoryName LIKE ?)';
      whereClause = whereClause.isEmpty
          ? searchCondition
          : '$whereClause AND $searchCondition';
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
        conflictAlgorithm: ConflictAlgorithm.abort,
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
          conflictAlgorithm: ConflictAlgorithm.abort,
        );

        final updated = await txn.rawUpdate('''
          UPDATE products SET stockQuantity = stockQuantity - ?
          WHERE id = ? AND stockQuantity >= ?
        ''', [item.quantity, item.product.id, item.quantity]);
        if (updated != 1) {
          throw const ValidationException(
              message: 'validation.insufficient_stock');
        }
      }

      // 3. Update Customer Debt if paymentMethod == debt
      if (order.paymentMethod == PaymentMethod.debt &&
          order.customerId != null) {
        final custMaps = await txn.query(
          'customers',
          where: 'id = ?',
          whereArgs: [order.customerId],
          limit: 1,
        );

        if (custMaps.isEmpty) {
          throw const ValidationException(
              message: 'validation.customer_missing');
        }
        {
          final currentDebt = (custMaps.first['totalDebt'] as num).toDouble();
          final newDebt = DebtPolicy.addCredit(
                  currentDebt,
                  order.remainingAmount,
                  (custMaps.first['creditLimit'] as num).toDouble())
              .fold(
                  (failure) =>
                      throw ValidationException(message: failure.message),
                  (balance) => balance);

          await txn.update(
            'customers',
            {
              'totalDebt': newDebt,
              'status': custMaps.first['status'],
            },
            where: 'id = ?',
            whereArgs: [order.customerId],
          );

          await txn.insert('debt_transactions', {
            'id': context.newId('tx'),
            'customerId': order.customerId!,
            'type': TransactionType.saleCredit.name,
            'amount': order.remainingAmount,
            'date': context.now().toIso8601String(),
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
    final now = context.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay =
        DateTime(now.year, now.month, now.day + 1).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(totalAmount) as totalSales
      FROM orders
      WHERE createdAt >= ? AND createdAt < ?
    ''', [startOfDay, endOfDay]);

    if (result.isNotEmpty && result.first['totalSales'] != null) {
      return (result.first['totalSales'] as num).toDouble();
    }
    return 0.0;
  }
}
