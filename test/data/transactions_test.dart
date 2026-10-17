import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/app/presentation/cubits/process_lookups_cubit.dart';
import 'package:baseet/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:baseet/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:baseet/features/debt_ledger/data/repositories/debt_repository_impl.dart';
import 'package:baseet/features/debt_ledger/domain/usecases/get_customers_usecase.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/core/error/exceptions.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:baseet/features/catalog/data/datasources/catalog_local_datasource.dart';
import 'package:baseet/features/debt_ledger/data/datasources/debt_local_datasource.dart';
import 'package:baseet/features/pos/data/datasources/pos_local_datasource.dart';
import 'package:baseet/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';
import 'package:baseet/features/pos/domain/usecases/process_checkout_usecase.dart';
import 'package:baseet/features/reports/data/datasources/reports_local_datasource.dart';
import 'package:baseet/features/reports/domain/entities/report_period.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../domain/checkout_test.dart' show FixedContext, product;

void main() {
  sqfliteFfiInit();
  late Database db;
  late AppDatabase database;
  late ProcessCheckoutUseCase checkout;
  late DebtLocalDataSourceImpl debt;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await AppDatabase.createSchema(db);
    database = AppDatabase.forTesting(db);
    checkout = ProcessCheckoutUseCase(
        PosRepositoryImpl(PosLocalDataSourceImpl(
            database: database, context: FixedContext())),
        FixedContext());
    debt = DebtLocalDataSourceImpl(database: database, context: FixedContext());
    await db
        .insert('categories', {'id': 'c1', 'name': 'Food', 'iconName': 'grid'});
    await db.insert('products', {
      'id': 'p1',
      'name': 'Milk',
      'barcode': '123',
      'categoryId': 'c1',
      'categoryName': 'Food',
      'buyPrice': 3,
      'sellPrice': 10,
      'stockQuantity': 5
    });
    await db.insert('customers', {
      'id': 'customer',
      'name': 'Customer',
      'phone': '123',
      'totalDebt': 20,
      'creditLimit': 100,
      'status': 'regular'
    });
  });
  tearDown(() => db.close());

  Future<void> assertNoCheckoutWrites() async {
    expect(await db.query('orders'), isEmpty);
    expect(await db.query('order_items'), isEmpty);
    expect(await db.query('debt_transactions'), isEmpty);
    expect((await db.query('products')).single['stockQuantity'], 5);
    expect((await db.query('customers')).single['totalDebt'], 20);
  }

  test('insufficient stock rolls back the order and line inserts', () async {
    final result = await checkout(ProcessCheckoutParams(
        items: [CartItemEntity(product: product, quantity: 6)],
        paymentMethod: PaymentMethod.cash));
    expect(result.isLeft(), isTrue);
    await assertNoCheckoutWrites();
  });

  test('missing customer rolls back order, lines and stock', () async {
    final result = await checkout(ProcessCheckoutParams(
        items: [CartItemEntity(product: product)],
        paymentMethod: PaymentMethod.debt,
        customerId: 'missing'));
    expect(result.isLeft(), isTrue);
    await assertNoCheckoutWrites();
  });

  test('credit limit failure rolls back checkout', () async {
    await db.update('customers', {'creditLimit': 25});
    final result = await checkout(ProcessCheckoutParams(
        items: [CartItemEntity(product: product)],
        paymentMethod: PaymentMethod.debt,
        customerId: 'customer'));
    expect(result.isLeft(), isTrue);
    await assertNoCheckoutWrites();
  });

  test(
      'successful partial credit sale commits stock, invoice and balance together',
      () async {
    final result = await checkout(ProcessCheckoutParams(
        items: [CartItemEntity(product: product, quantity: 2)],
        paymentMethod: PaymentMethod.debt,
        customerId: 'customer',
        paidAmount: 5));
    expect(result.isRight(), isTrue);
    expect((await db.query('products')).single['stockQuantity'], 3);
    expect((await db.query('customers')).single['totalDebt'], 35);
    expect((await db.query('debt_transactions')).single['amount'], 15);
    expect((await db.query('orders')).single['totalAmount'], 20);
    // Duplicate invoice must fail without decrementing stock twice.
    expect(
        (await checkout(ProcessCheckoutParams(
                items: [CartItemEntity(product: product)],
                paymentMethod: PaymentMethod.cash)))
            .isLeft(),
        isTrue);
    expect((await db.query('products')).single['stockQuantity'], 3);
  });

  test('overpayment leaves balance and transactions unchanged', () async {
    await expectLater(
        debt.addPaymentVoucher(customerId: 'customer', amount: 21, notes: null),
        throwsA(isA<ValidationException>()));
    expect((await db.query('customers')).single['totalDebt'], 20);
    expect(await db.query('debt_transactions'), isEmpty);
  });

  test('failed voucher insert rolls back balance update', () async {
    await debt.addPaymentVoucher(
        customerId: 'customer', amount: 5, notes: null);
    // Fixed IDs force a constraint error on the second insert.
    await expectLater(
        debt.addPaymentVoucher(customerId: 'customer', amount: 5, notes: null),
        throwsA(isA<DatabaseException>()));
    expect((await db.query('customers')).single['totalDebt'], 15);
    expect(await db.query('debt_transactions'), hasLength(1));
  });

  test('clearing data yields empty live lookups and real zero reports',
      () async {
    await database.clearAllData();
    expect(await CatalogLocalDataSource(database).getCategories(), isEmpty);
    expect(await debt.getCustomers(), isEmpty);
    final report = await ReportsLocalDataSourceImpl(
            database: database, context: FixedContext())
        .getReportSummary(ReportPeriod.today);
    expect(report.totalSales, 0);
    expect(report.netProfit, 0);
    expect(report.topProducts, isEmpty);
  });

  test('data exception mapper preserves validation and cache failures',
      () async {
    final validation = await repositoryCall<void>(() async =>
        throw const ValidationException(message: 'validation.invalid_payment'));
    expect(validation.fold((failure) => failure, (_) => null),
        isA<ValidationFailure>());
    final cache = await repositoryCall<void>(
        () async => throw const CacheException(message: 'cache'));
    expect(cache.fold((failure) => failure, (_) => null), isA<CacheFailure>());
  });

  test('lookup state reads newly added categories and customers', () async {
    final lookups = ProcessLookupsCubit(
      GetCategoriesUseCase(
          CatalogRepositoryImpl(CatalogLocalDataSource(database))),
      GetCustomersUseCase(DebtRepositoryImpl(debt)),
    );
    addTearDown(lookups.close);
    await lookups.load(categories: true, customers: true);
    expect(lookups.state.categories.map((c) => c.id), ['c1']);
    await db.insert('categories',
        {'id': 'new_category', 'name': 'New category', 'iconName': 'grid'});
    await db.insert('customers', {
      'id': 'new_customer',
      'name': 'New customer',
      'phone': '456',
      'status': 'regular'
    });
    await lookups.load(categories: true, customers: true);
    expect(lookups.state.categories.map((c) => c.id), contains('new_category'));
    expect(lookups.state.customers.map((c) => c.id), contains('new_customer'));
    expect(lookups.state.error, isNull);
  });

  test('failed demo restore preserves all pre-existing records', () async {
    await db.execute(
        "CREATE TRIGGER reject_demo BEFORE INSERT ON products BEGIN SELECT RAISE(ABORT, 'seed failed'); END");
    await expectLater(
        database.reseedDemoData(), throwsA(isA<DatabaseException>()));
    expect((await db.query('categories')).single['id'], 'c1');
    expect((await db.query('products')).single['stockQuantity'], 5);
    expect((await db.query('customers')).single['totalDebt'], 20);
  });
}
