import 'dart:convert';
import 'dart:io';
import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/core/error/exceptions.dart';
import 'package:baseet/features/business/data/datasources/business_local_datasource.dart';
import 'package:baseet/features/device_transfer/data/datasources/backup_datasource.dart';
import 'package:baseet/features/device_transfer/data/datasources/local_transfer.dart';
import 'package:baseet/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:baseet/features/catalog/data/models/product_model.dart';
import 'package:baseet/features/debt_ledger/data/datasources/debt_local_datasource.dart';
import 'package:baseet/features/debt_ledger/data/models/customer_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../domain/checkout_test.dart' show FixedContext, product;

void main() {
  sqfliteFfiInit();
  late Database db;
  late Directory folder;
  late AppDatabase database;
  late BackupDataSource backup;
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await AppDatabase.createSchema(db);
    database = AppDatabase.forTesting(db);
    folder = await Directory.systemTemp.createTemp('baseet-transfer-test-');
    backup = BackupDataSource(database, folder);
  });
  tearDown(() async {
    await db.close();
    // This test owns the directory returned by createTemp; no user data exists here.
    await folder.delete(recursive: true);
  });

  test('backup roundtrip restores data and store name atomically', () async {
    await db
        .insert('categories', {'id': 'c1', 'name': 'Food', 'iconName': 'grid'});
    final inventory = InventoryLocalDataSourceImpl(database: database);
    await inventory.addProduct(ProductModel.fromEntity(product));
    final business = BusinessLocalDataSource(database, FixedContext());
    await business.saveStore('My shop');
    final snapshot = await backup.export();
    expect(snapshot.products, 1);
    await business
        .saveProduct(product.copyWith(stockQuantity: 2, sellPrice: 11));
    await backup.restore(snapshot);
    final loaded = await business.load();
    expect(loaded.storeName, 'My shop');
    expect(loaded.products.single.stockQuantity, 5);
    expect(loaded.products.single.sellPrice, 10);
    expect(
        await File('${folder.path}/before-transfer.baseet').exists(), isTrue);
  });

  test('receipt bytes move to a local managed path on restore', () async {
    final receipt = File('${folder.path}/original.png');
    await receipt.writeAsBytes([137, 80, 78, 71]);
    await db.insert('orders', {
      'id': 'o1',
      'invoiceNumber': 'INV1',
      'totalAmount': 0,
      'paidAmount': 0,
      'remainingAmount': 0,
      'paymentMethod': 'cash',
      'createdAt': '2026-10-17T12:00:00',
      'receiptPath': receipt.path
    });
    final snapshot = await backup.export();
    expect(snapshot.contents,
        isNot(contains(receipt.path.replaceAll('\\', '\\\\'))));
    await backup.restore(snapshot);
    final restored = (await db.query('orders')).single['receiptPath'] as String;
    expect(restored, isNot(receipt.path));
    expect(await File(restored).readAsBytes(), [137, 80, 78, 71]);
  });

  test('invalid schema and orphaned records are rejected without changes',
      () async {
    final snapshot = await backup.export();
    final data = jsonDecode(snapshot.contents) as Map<String, dynamic>;
    data['tables']['products'] = [
      {'id': 'bad', 'categoryId': 'missing'}
    ];
    expect(() => backup.inspect(jsonEncode(data)),
        throwsA(isA<ValidationException>()));
    expect(await db.query('products'), isEmpty);
    data['version'] = 900;
    expect(() => backup.inspect(jsonEncode(data)),
        throwsA(isA<ValidationException>()));
  });

  test('unknown columns trigger rollback and preserve current records',
      () async {
    final business = BusinessLocalDataSource(database, FixedContext());
    await business.saveStore('Keep me');
    final data =
        jsonDecode((await backup.export()).contents) as Map<String, dynamic>;
    data['tables']['store_settings'][0]['unknown'] = 'bad';
    final snapshot = backup.inspect(jsonEncode(data));
    await expectLater(
        backup.restore(snapshot), throwsA(isA<ValidationException>()));
    expect((await business.load()).storeName, 'Keep me');
  });

  test('first product creates its default category without setup', () async {
    final inventory = InventoryLocalDataSourceImpl(database: database);
    await inventory.addProduct(ProductModel.fromEntity(
        product.copyWith(categoryId: 'general', categoryName: 'general')));
    expect((await db.query('categories')).single['id'], 'general');
    expect((await backup.export()).products, 1);
  });

  test('previous customer debt is saved with an opening ledger entry',
      () async {
    final debt =
        DebtLocalDataSourceImpl(database: database, context: FixedContext());
    await debt.addCustomer(const CustomerModel(
        id: 'customer', name: 'Customer', phone: '', totalDebt: 25));
    final transactions = await debt.getCustomerTransactions('customer');
    expect(transactions.single.amount, 25);
    expect(transactions.single.remainingBalance, 25);
    expect((await debt.getCustomerById('customer')).totalDebt, 25);
  });

  test('version one migration preserves products and adds store settings',
      () async {
    await db.execute('DROP TABLE store_settings');
    await db.insert(
        'categories', {'id': 'keep', 'name': 'Keep', 'iconName': 'grid'});
    await AppDatabase.upgradeSchema(db, 1, 2);
    expect((await db.query('categories')).single['id'], 'keep');
    expect(await db.query('store_settings'), isEmpty);
  });

  test('QR session transfers encrypted data over real local HTTP', () async {
    final server = LocalTransfer();
    final receiver = LocalTransfer();
    addTearDown(server.stop);
    addTearDown(receiver.stop);
    const contents = '{"private":"customer details"}';
    final session = await server.start(contents, testHost: '127.0.0.1');
    final code = Uri.parse(session.code);
    expect(session.expiresAt.isAfter(DateTime.now()), isTrue);
    expect(await receiver.receive(session.code, allowLoopbackForTesting: true),
        contents);
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    final request = await client.getUrl(Uri(
        scheme: 'http',
        host: '127.0.0.1',
        port: int.parse(code.queryParameters['port']!),
        path: '/${code.queryParameters['id']}'));
    final response = await request.close();
    expect(response.statusCode, HttpStatus.forbidden);
    expect(await utf8.decoder.bind(response).join(),
        isNot(contains('customer details')));
    await server.stop();
    await expectLater(
        receiver.receive(session.code, allowLoopbackForTesting: true),
        throwsA(isA<SocketException>()));
  });

  test('connection parser rejects arbitrary external hosts and malformed codes',
      () async {
    final transfer = LocalTransfer();
    expect(LocalTransfer.privateHost('192.168.1.10'), isTrue);
    expect(LocalTransfer.privateHost('8.8.8.8'), isFalse);
    await expectLater(transfer.receive('https://example.com'),
        throwsA(isA<ValidationException>()));
    await expectLater(
        transfer.receive('baseet://transfer?host=8.8.8.8&port=80&id=123'),
        throwsA(isA<ValidationException>()));
  });
}
