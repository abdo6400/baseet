import 'package:sqflite/sqflite.dart';
import 'package:baseet/config/database/local/app_database.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/debt_ledger/data/models/customer_model.dart';
import 'package:baseet/features/debt_ledger/data/models/debt_transaction_model.dart';

abstract class DebtLocalDataSource {
  Future<List<CustomerModel>> getCustomers({String? searchQuery, DebtStatus? statusFilter, bool sortByHighest = false});
  Future<CustomerModel> getCustomerById(String id);
  Future<List<DebtTransactionModel>> getCustomerTransactions(String customerId);
  Future<CustomerModel> addCustomer(CustomerModel customer);
  Future<DebtTransactionModel> addPaymentVoucher({
    required String customerId,
    required double amount,
    required String? notes,
    String? receiptPath,
  });
  Future<Map<String, double>> getDebtStats();
}

class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  final AppDatabase appDatabase;

  DebtLocalDataSourceImpl({AppDatabase? database})
      : appDatabase = database ?? AppDatabase();

  @override
  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    DebtStatus? statusFilter,
    bool sortByHighest = false,
  }) async {
    final db = await appDatabase.database;

    String whereClause = '';
    final List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      whereClause = '(name LIKE ? OR phone LIKE ?)';
      whereArgs.addAll([q, q]);
    }

    if (statusFilter != null) {
      final statusCondition = 'status = ?';
      whereClause = whereClause.isEmpty ? statusCondition : '$whereClause AND $statusCondition';
      whereArgs.add(statusFilter.name);
    }

    final orderBy = sortByHighest ? 'totalDebt DESC' : 'name ASC';

    final maps = await db.query(
      'customers',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
    );

    return maps.map((map) => CustomerModel.fromMap(map)).toList();
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      throw Exception('العميل غير موجود');
    }

    return CustomerModel.fromMap(maps.first);
  }

  @override
  Future<List<DebtTransactionModel>> getCustomerTransactions(String customerId) async {
    final db = await appDatabase.database;
    final maps = await db.query(
      'debt_transactions',
      where: 'customerId = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => DebtTransactionModel.fromMap(map)).toList();
  }

  @override
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final db = await appDatabase.database;

    await db.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return customer;
  }

  @override
  Future<DebtTransactionModel> addPaymentVoucher({
    required String customerId,
    required double amount,
    required String? notes,
    String? receiptPath,
  }) async {
    final db = await appDatabase.database;

    DebtTransactionModel? createdTx;

    await db.transaction((txn) async {
      final custMaps = await txn.query(
        'customers',
        where: 'id = ?',
        whereArgs: [customerId],
        limit: 1,
      );

      if (custMaps.isEmpty) {
        throw Exception('العميل غير موجود');
      }

      final cust = CustomerModel.fromMap(custMaps.first);
      final double newDebt = (cust.totalDebt - amount).clamp(0.0, 999999.0);
      final now = DateTime.now();

      final newStatus = newDebt == 0 ? DebtStatus.regular : cust.status;

      await txn.update(
        'customers',
        {
          'totalDebt': newDebt,
          'lastPaymentDate': now.toIso8601String(),
          'status': newStatus.name,
        },
        where: 'id = ?',
        whereArgs: [customerId],
      );

      final txId = 'tx_${now.millisecondsSinceEpoch}';
      createdTx = DebtTransactionModel(
        id: txId,
        customerId: customerId,
        type: TransactionType.paymentVoucher,
        amount: amount,
        date: now,
        notes: notes ?? 'سند قبض نقدي',
        remainingBalance: newDebt,
        receiptPath: receiptPath,
      );

      await txn.insert('debt_transactions', createdTx!.toMap());
    });

    return createdTx!;
  }

  @override
  Future<Map<String, double>> getDebtStats() async {
    final db = await appDatabase.database;

    final totalResult = await db.rawQuery('SELECT SUM(totalDebt) as total FROM customers');
    final overdueResult = await db.rawQuery(
      "SELECT SUM(totalDebt) as overdue FROM customers WHERE status = 'overdue'",
    );

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    final todayCollectionsResult = await db.rawQuery('''
      SELECT SUM(amount) as todayCollections
      FROM debt_transactions
      WHERE type = 'paymentVoucher' AND date >= ?
    ''', [startOfDay]);

    final double total = (totalResult.isNotEmpty && totalResult.first['total'] != null)
        ? (totalResult.first['total'] as num).toDouble()
        : 0.0;

    final double overdue = (overdueResult.isNotEmpty && overdueResult.first['overdue'] != null)
        ? (overdueResult.first['overdue'] as num).toDouble()
        : 0.0;

    final double todayCollections = (todayCollectionsResult.isNotEmpty &&
            todayCollectionsResult.first['todayCollections'] != null)
        ? (todayCollectionsResult.first['todayCollections'] as num).toDouble()
        : 0.0;

    return {
      'total': total,
      'overdue': overdue,
      'todayCollections': todayCollections,
    };
  }
}
