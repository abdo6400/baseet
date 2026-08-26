import 'package:sqflite/sqflite.dart';
import '../../../../config/database/local/app_database.dart';
import '../models/supplier_model.dart';
import '../models/supplier_invoice_model.dart';

abstract class SupplierLocalDataSource {
  Future<List<SupplierModel>> getSuppliers({String? searchQuery});
  Future<SupplierModel> getSupplierById(String id);
  Future<SupplierModel> addSupplier(SupplierModel supplier);
  Future<List<SupplierInvoiceModel>> getSupplierInvoices(String supplierId);
  Future<SupplierInvoiceModel> addSupplierInvoice(SupplierInvoiceModel invoice);
  Future<double> getTotalSupplierDebt();
}

class SupplierLocalDataSourceImpl implements SupplierLocalDataSource {
  final AppDatabase appDatabase;

  SupplierLocalDataSourceImpl({AppDatabase? database})
      : appDatabase = database ?? AppDatabase();

  @override
  Future<List<SupplierModel>> getSuppliers({String? searchQuery}) async {
    final db = await appDatabase.database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      whereClause = 'name LIKE ? OR companyName LIKE ? OR phone LIKE ?';
      whereArgs = [q, q, q];
    }

    final maps = await db.query(
      'suppliers',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'totalDebt DESC, name ASC',
    );

    return maps.map((m) => SupplierModel.fromMap(m)).toList();
  }

  @override
  Future<SupplierModel> getSupplierById(String id) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'suppliers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      throw Exception('المورد غير موجود');
    }

    return SupplierModel.fromMap(maps.first);
  }

  @override
  Future<SupplierModel> addSupplier(SupplierModel supplier) async {
    final db = await appDatabase.database;

    await db.insert(
      'suppliers',
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return supplier;
  }

  @override
  Future<List<SupplierInvoiceModel>> getSupplierInvoices(String supplierId) async {
    final db = await appDatabase.database;

    final invoiceMaps = await db.query(
      'supplier_invoices',
      where: 'supplierId = ?',
      whereArgs: [supplierId],
      orderBy: 'date DESC',
    );

    final List<SupplierInvoiceModel> invoices = [];

    for (final invMap in invoiceMaps) {
      final invId = invMap['id'] as String;
      final itemMaps = await db.query(
        'supplier_invoice_items',
        where: 'invoiceId = ?',
        whereArgs: [invId],
      );

      final items = itemMaps.map((im) => SupplierInvoiceItemModel.fromMap(im)).toList();
      invoices.add(SupplierInvoiceModel.fromMap(invMap, items));
    }

    return invoices;
  }

  @override
  Future<SupplierInvoiceModel> addSupplierInvoice(SupplierInvoiceModel invoice) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      // 1. Insert invoice header
      await txn.insert(
        'supplier_invoices',
        invoice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insert items
      for (int i = 0; i < invoice.items.length; i++) {
        final item = invoice.items[i];
        final itemModel = SupplierInvoiceItemModel.fromEntity(item);
        await txn.insert(
          'supplier_invoice_items',
          itemModel.toMap(invoice.id, i),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 3. Update supplier's debt balance and last transaction date
      final supMaps = await txn.query(
        'suppliers',
        where: 'id = ?',
        whereArgs: [invoice.supplierId],
        limit: 1,
      );

      if (supMaps.isNotEmpty) {
        final currentDebt = (supMaps.first['totalDebt'] as num?)?.toDouble() ?? 0.0;
        final newDebt = currentDebt + invoice.remainingAmount;

        await txn.update(
          'suppliers',
          {
            'totalDebt': newDebt,
            'lastTransactionDate': invoice.date.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [invoice.supplierId],
        );
      }
    });

    return invoice;
  }

  @override
  Future<double> getTotalSupplierDebt() async {
    final db = await appDatabase.database;
    final result = await db.rawQuery('SELECT SUM(totalDebt) as total FROM suppliers');

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
