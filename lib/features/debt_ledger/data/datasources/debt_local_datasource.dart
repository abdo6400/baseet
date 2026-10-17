import 'package:baseet/features/debt_ledger/domain/entities/debt_policy.dart';
import 'package:baseet/core/error/exceptions.dart';
import 'package:baseet/core/services/operation_context.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_stats.dart';
import 'package:sqflite/sqflite.dart';
import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/features/debt_ledger/data/models/customer_model.dart';
import 'package:baseet/features/debt_ledger/data/models/debt_transaction_model.dart';

abstract class DebtLocalDataSource {
  Future<List<CustomerModel>> getCustomers(
      {String? searchQuery,
      DebtStatus? statusFilter,
      bool sortByHighest = false});
  Future<CustomerModel> getCustomerById(String id);
  Future<List<DebtTransactionModel>> getCustomerTransactions(String customerId);
  Future<CustomerModel> addCustomer(CustomerModel customer);
  Future<DebtTransactionModel> addPaymentVoucher({
    required String customerId,
    required double amount,
    required String? notes,
    String? receiptPath,
  });
  Future<DebtStats> getDebtStats();
}

class DebtLocalDataSourceImpl implements DebtLocalDataSource {
  final AppDatabase appDatabase;
  final OperationContext context;

  DebtLocalDataSourceImpl(
      {required AppDatabase database, required this.context})
      : appDatabase = database;

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
      whereClause = whereClause.isEmpty
          ? statusCondition
          : '$whereClause AND $statusCondition';
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
      throw Exception('Ø§Ù„Ø¹Ù…ÙŠÙ„ ØºÙŠØ± Ù…ÙˆØ¬ÙˆØ¯');
    }

    return CustomerModel.fromMap(maps.first);
  }

  @override
  Future<List<DebtTransactionModel>> getCustomerTransactions(
      String customerId) async {
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

    await db.transaction((txn) async {
      await txn.insert('customers', customer.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
      if (customer.totalDebt > 0) {
        await txn.insert('debt_transactions', {
          'id': context.newId('opening'),
          'customerId': customer.id,
          'type': TransactionType.saleCredit.name,
          'amount': customer.totalDebt,
          'date': context.now().toIso8601String(),
          'notes': 'simple.opening_debt',
          'remainingBalance': customer.totalDebt
        });
      }
    });

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
        throw Exception('Ø§Ù„Ø¹Ù…ÙŠÙ„ ØºÙŠØ± Ù…ÙˆØ¬ÙˆØ¯');
      }

      final cust = CustomerModel.fromMap(custMaps.first);
      final newDebt = DebtPolicy.receivePayment(cust.totalDebt, amount).fold(
          (failure) => throw ValidationException(message: failure.message),
          (balance) => balance);
      final now = context.now();

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

      final txId = context.newId('tx');
      createdTx = DebtTransactionModel(
        id: txId,
        customerId: customerId,
        type: TransactionType.paymentVoucher,
        amount: amount,
        date: now,
        notes: notes ?? 'Ø³Ù†Ø¯ Ù‚Ø¨Ø¶ Ù†Ù‚Ø¯ÙŠ',
        remainingBalance: newDebt,
        receiptPath: receiptPath,
      );

      await txn.insert('debt_transactions', createdTx!.toMap());
    });

    return createdTx!;
  }

  @override
  Future<DebtStats> getDebtStats() async {
    final db = await appDatabase.database;

    final totalResult =
        await db.rawQuery('SELECT SUM(totalDebt) as total FROM customers');
    final overdueResult = await db.rawQuery(
      "SELECT SUM(totalDebt) as overdue FROM customers WHERE status = 'overdue'",
    );

    final now = context.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    final todayCollectionsResult = await db.rawQuery('''
      SELECT SUM(amount) as todayCollections
      FROM debt_transactions
      WHERE type = 'paymentVoucher' AND date >= ?
    ''', [startOfDay]);

    final double total =
        (totalResult.isNotEmpty && totalResult.first['total'] != null)
            ? (totalResult.first['total'] as num).toDouble()
            : 0.0;

    final double overdue =
        (overdueResult.isNotEmpty && overdueResult.first['overdue'] != null)
            ? (overdueResult.first['overdue'] as num).toDouble()
            : 0.0;

    final double todayCollections = (todayCollectionsResult.isNotEmpty &&
            todayCollectionsResult.first['todayCollections'] != null)
        ? (todayCollectionsResult.first['todayCollections'] as num).toDouble()
        : 0.0;

    return DebtStats(
        total: total, overdue: overdue, todayCollections: todayCollections);
  }
}
