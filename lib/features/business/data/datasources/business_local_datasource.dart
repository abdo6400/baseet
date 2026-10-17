import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/core/services/operation_context.dart';
import 'package:baseet/core/error/exceptions.dart';
import 'package:baseet/features/catalog/data/models/product_model.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/features/debt_ledger/data/models/customer_model.dart';
import '../../domain/entities/business_data.dart';

class BusinessLocalDataSource {
  final AppDatabase database;
  final OperationContext clock;
  BusinessLocalDataSource(this.database, this.clock);
  Future<BusinessData> load() async {
    final db = await database.database;
    return db.transaction((txn) async {
      final settings = await txn
          .query('store_settings', where: 'key = ?', whereArgs: ['name']);
      final products = (await txn.query('products', orderBy: 'name'))
          .map(ProductModel.fromMap)
          .toList();
      final customers = (await txn.query('customers', orderBy: 'name'))
          .map(CustomerModel.fromMap)
          .toList();
      final orders =
          await txn.query('orders', orderBy: 'createdAt DESC', limit: 200);
      final sales = <SaleRecord>[];
      for (final row in orders) {
        final items = await txn
            .query('order_items', where: 'orderId = ?', whereArgs: [row['id']]);
        sales.add(SaleRecord(
            id: row['id'] as String,
            number: row['invoiceNumber'] as String,
            date: DateTime.parse(row['createdAt'] as String),
            total: (row['totalAmount'] as num).toDouble(),
            paid: (row['paidAmount'] as num).toDouble(),
            remaining: (row['remainingAmount'] as num).toDouble(),
            paymentMethod: row['paymentMethod'] as String,
            customer: row['customerName'] as String?,
            lines: items
                .map((item) => SaleLine(
                    item['productName'] as String,
                    item['quantity'] as int,
                    (item['customPrice'] as num).toDouble()))
                .toList()));
      }
      final now = clock.now();
      final totals = (await txn.rawQuery(
              'SELECT COALESCE(SUM(totalAmount),0) AS total, COUNT(*) AS count FROM orders WHERE createdAt >= ? AND createdAt < ?',
              [
            DateTime(now.year, now.month, now.day).toIso8601String(),
            DateTime(now.year, now.month, now.day + 1).toIso8601String()
          ]))
          .single;
      return BusinessData(
          storeName: settings.isEmpty ? '' : settings.single['value'] as String,
          todaySales: (totals['total'] as num).toDouble(),
          todayInvoices: totals['count'] as int,
          totalDebt:
              customers.fold(0.0, (sum, customer) => sum + customer.totalDebt),
          lowStock: products.where((p) => p.isLowStock).length,
          products: products,
          customers: customers,
          sales: sales);
    });
  }

  Future<void> saveProduct(ProductEntity product) async {
    final db = await database.database;
    await db.transaction((txn) async {
      final matches = await txn.query('products',
          columns: ['id'], where: 'id = ?', whereArgs: [product.id]);
      if (matches.isEmpty) {
        throw const ValidationException(message: 'simple.product_missing');
      }
      final values = ProductModel.fromEntity(product).toMap()..remove('id');
      await txn
          .update('products', values, where: 'id = ?', whereArgs: [product.id]);
    });
  }

  Future<void> saveStore(String name) async {
    final db = await database.database;
    await db.rawInsert(
        'INSERT OR REPLACE INTO store_settings(key,value) VALUES(?,?)',
        ['name', name]);
  }
}
