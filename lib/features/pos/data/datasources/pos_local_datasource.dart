import 'package:sqflite/sqflite.dart';
import 'package:baseet/config/database/local/app_database.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/pos/data/models/order_model.dart';
import 'package:baseet/features/pos/data/models/product_model.dart';
import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

abstract class PosLocalDataSource {
  Future<List<ProductModel>> getCatalog({String? categoryId, String? searchQuery});
  Future<OrderModel> checkout(OrderModel order);
  Future<double> getTodaySalesTotal();
  Future<List<OrderModel>> getOrders({String? searchQuery, DateTime? startDate, DateTime? endDate});
  Future<OrderModel?> getOrderById(String orderId);
  Future<void> deleteOrder(String orderId);
  Future<void> updateOrder(OrderModel order);
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

  @override
  Future<List<OrderModel>> getOrders({
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await appDatabase.database;

    String whereClause = '';
    final List<dynamic> whereArgs = [];

    if (startDate != null) {
      final startIso = startDate.toIso8601String();
      whereClause = 'createdAt >= ?';
      whereArgs.add(startIso);
    }

    if (endDate != null) {
      final endIso = endDate.toIso8601String();
      whereClause = whereClause.isEmpty ? 'createdAt <= ?' : '$whereClause AND createdAt <= ?';
      whereArgs.add(endIso);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      final searchCondition =
          '(invoiceNumber LIKE ? OR customerName LIKE ? OR notes LIKE ? OR paymentMethod LIKE ?)';
      whereClause = whereClause.isEmpty ? searchCondition : '$whereClause AND $searchCondition';
      whereArgs.addAll([q, q, q, q]);
    }

    final orderMaps = await db.query(
      'orders',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'createdAt DESC',
    );

    final List<OrderModel> orders = [];

    for (final orderMap in orderMaps) {
      final orderId = orderMap['id'] as String;
      final itemMaps = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );

      final items = itemMaps.map((im) {
        final product = ProductEntity(
          id: im['productId'] as String,
          name: im['productName'] as String,
          barcode: '',
          categoryId: '',
          categoryName: im['categoryName'] as String? ?? '',
          buyPrice: (im['buyPrice'] as num?)?.toDouble() ?? 0.0,
          sellPrice: (im['sellPrice'] as num?)?.toDouble() ?? 0.0,
          stockQuantity: 0,
        );
        return CartItemEntity(
          product: product,
          quantity: im['quantity'] as int,
          customPrice: (im['customPrice'] as num?)?.toDouble() ?? product.sellPrice,
        );
      }).toList();

      orders.add(OrderModel.fromMap(orderMap, items));
    }

    return orders;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    final db = await appDatabase.database;
    final orderMaps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
      limit: 1,
    );

    if (orderMaps.isEmpty) return null;

    final itemMaps = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );

    final items = itemMaps.map((im) {
      final product = ProductEntity(
        id: im['productId'] as String,
        name: im['productName'] as String,
        barcode: '',
        categoryId: '',
        categoryName: im['categoryName'] as String? ?? '',
        buyPrice: (im['buyPrice'] as num?)?.toDouble() ?? 0.0,
        sellPrice: (im['sellPrice'] as num?)?.toDouble() ?? 0.0,
        stockQuantity: 0,
      );
      return CartItemEntity(
        product: product,
        quantity: im['quantity'] as int,
        customPrice: (im['customPrice'] as num?)?.toDouble() ?? product.sellPrice,
      );
    }).toList();

    return OrderModel.fromMap(orderMaps.first, items);
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      // 1. Get existing order and items
      final orderMaps = await txn.query('orders', where: 'id = ?', whereArgs: [orderId], limit: 1);
      if (orderMaps.isEmpty) return;

      final orderMap = orderMaps.first;
      final paymentMethod = orderMap['paymentMethod'] as String;
      final customerId = orderMap['customerId'] as String?;
      final remainingAmount = (orderMap['remainingAmount'] as num?)?.toDouble() ?? 0.0;
      final invoiceNumber = orderMap['invoiceNumber'] as String;

      final itemMaps = await txn.query('order_items', where: 'orderId = ?', whereArgs: [orderId]);

      // 2. Restore stock for all products in this order
      for (final item in itemMaps) {
        final productId = item['productId'] as String;
        final qty = item['quantity'] as int;

        await txn.rawUpdate('''
          UPDATE products
          SET stockQuantity = stockQuantity + ?
          WHERE id = ?
        ''', [qty, productId]);
      }

      // 3. Reverse customer debt if it was a debt transaction
      if (paymentMethod == PaymentMethod.debt.name && customerId != null && remainingAmount > 0) {
        final custMaps = await txn.query('customers', where: 'id = ?', whereArgs: [customerId], limit: 1);
        if (custMaps.isNotEmpty) {
          final currentDebt = (custMaps.first['totalDebt'] as num).toDouble();
          final newDebt = (currentDebt - remainingAmount).clamp(0.0, double.infinity);

          await txn.update(
            'customers',
            {
              'totalDebt': newDebt,
            },
            where: 'id = ?',
            whereArgs: [customerId],
          );

          await txn.delete(
            'debt_transactions',
            where: 'customerId = ? AND notes LIKE ?',
            whereArgs: [customerId, '%#$invoiceNumber%'],
          );
        }
      }

      // 4. Delete items and order
      await txn.delete('order_items', where: 'orderId = ?', whereArgs: [orderId]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [orderId]);
    });
  }

  @override
  Future<void> updateOrder(OrderModel updatedOrder) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      // 1. Get old items
      final oldItemMaps = await txn.query('order_items', where: 'orderId = ?', whereArgs: [updatedOrder.id]);

      // 2. Restore old items stock
      for (final item in oldItemMaps) {
        final productId = item['productId'] as String;
        final qty = item['quantity'] as int;

        await txn.rawUpdate('''
          UPDATE products
          SET stockQuantity = stockQuantity + ?
          WHERE id = ?
        ''', [qty, productId]);
      }

      // 3. Deduct new items stock
      for (final item in updatedOrder.items) {
        await txn.rawUpdate('''
          UPDATE products
          SET stockQuantity = MAX(0, stockQuantity - ?)
          WHERE id = ?
        ''', [item.quantity, item.product.id]);
      }

      // 4. Delete old items and insert updated items
      await txn.delete('order_items', where: 'orderId = ?', whereArgs: [updatedOrder.id]);
      for (final item in updatedOrder.items) {
        await txn.insert('order_items', {
          'id': '${updatedOrder.id}_${item.product.id}',
          'orderId': updatedOrder.id,
          'productId': item.product.id,
          'productName': item.product.name,
          'categoryName': item.product.categoryName,
          'buyPrice': item.product.buyPrice,
          'sellPrice': item.product.sellPrice,
          'quantity': item.quantity,
          'customPrice': item.customPrice,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 5. Update customer debt if debt payment
      final oldOrderMaps = await txn.query('orders', where: 'id = ?', whereArgs: [updatedOrder.id], limit: 1);
      if (oldOrderMaps.isNotEmpty) {
        final oldOrder = oldOrderMaps.first;
        final oldCustomerId = oldOrder['customerId'] as String?;
        final oldRemaining = (oldOrder['remainingAmount'] as num?)?.toDouble() ?? 0.0;

        if (updatedOrder.paymentMethod == PaymentMethod.debt && updatedOrder.customerId != null) {
          final custMaps = await txn.query('customers', where: 'id = ?', whereArgs: [updatedOrder.customerId], limit: 1);
          if (custMaps.isNotEmpty) {
            final currentDebt = (custMaps.first['totalDebt'] as num).toDouble();
            final debtDiff = updatedOrder.remainingAmount - (oldCustomerId == updatedOrder.customerId ? oldRemaining : 0.0);
            final newDebt = (currentDebt + debtDiff).clamp(0.0, double.infinity);

            await txn.update(
              'customers',
              {'totalDebt': newDebt},
              where: 'id = ?',
              whereArgs: [updatedOrder.customerId],
            );
          }
        }
      }

      // 6. Update order header
      await txn.update(
        'orders',
        updatedOrder.toMap(),
        where: 'id = ?',
        whereArgs: [updatedOrder.id],
      );
    });
  }
}
