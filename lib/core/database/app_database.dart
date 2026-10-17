import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:baseet/core/database/demo_data.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;
  AppDatabase._internal();

  /// Creates an isolated database wrapper for integration tests.
  AppDatabase.forTesting(Database database) : _db = database;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await init();
    return _db!;
  }

  Future<Database> init({bool seedIfEmpty = false}) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'baseet.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createSchema(db);
        if (seedIfEmpty) {
          await _seedInitialData(db);
        }
      },
    );

    if (seedIfEmpty) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM products'),
      );
      if (count == null || count == 0) {
        await _seedInitialData(db);
      }
    }

    _db = db;
    return db;
  }

  static Future<void> createSchema(Database db) async {
    // 1. Categories
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconName TEXT NOT NULL,
        colorHex TEXT
      )
    ''');

    // 2. Products
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        barcode TEXT NOT NULL UNIQUE,
        categoryId TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        buyPrice REAL NOT NULL,
        sellPrice REAL NOT NULL,
        stockQuantity INTEGER NOT NULL,
        minStockLimit INTEGER NOT NULL DEFAULT 3,
        imageUrl TEXT
      )
    ''');

    // 3. Customers
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        totalDebt REAL NOT NULL DEFAULT 0.0,
        creditLimit REAL NOT NULL DEFAULT 3000.0,
        lastPaymentDate TEXT,
        address TEXT,
        notes TEXT,
        status TEXT NOT NULL
      )
    ''');

    // 4. Debt Transactions
    await db.execute('''
      CREATE TABLE debt_transactions (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        remainingBalance REAL NOT NULL,
        receiptPath TEXT
      )
    ''');

    // 5. Orders
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        invoiceNumber TEXT NOT NULL UNIQUE,
        totalAmount REAL NOT NULL,
        paidAmount REAL NOT NULL,
        remainingAmount REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        customerId TEXT,
        customerName TEXT,
        createdAt TEXT NOT NULL,
        notes TEXT,
        receiptPath TEXT
      )
    ''');

    // 6. Order Items
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        orderId TEXT NOT NULL,
        productId TEXT NOT NULL,
        productName TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        buyPrice REAL NOT NULL,
        sellPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        customPrice REAL NOT NULL
      )
    ''');
  }

  Future<void> _seedInitialData(DatabaseExecutor db) async {
    final batch = db.batch();

    // Seed Categories
    for (final cat in BaseetMockData.initialCategories) {
      batch.insert(
          'categories',
          {
            'id': cat.id,
            'name': cat.name,
            'iconName': cat.iconName,
            'colorHex': cat.colorHex,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Products
    for (final prod in BaseetMockData.initialProducts) {
      batch.insert(
          'products',
          {
            'id': prod.id,
            'name': prod.name,
            'barcode': prod.barcode,
            'categoryId': prod.categoryId,
            'categoryName': prod.categoryName,
            'buyPrice': prod.buyPrice,
            'sellPrice': prod.sellPrice,
            'stockQuantity': prod.stockQuantity,
            'minStockLimit': prod.minStockLimit,
            'imageUrl': prod.imageUrl,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Customers
    for (final cust in BaseetMockData.initialCustomers) {
      batch.insert(
          'customers',
          {
            'id': cust.id,
            'name': cust.name,
            'phone': cust.phone,
            'totalDebt': cust.totalDebt,
            'creditLimit': cust.creditLimit,
            'lastPaymentDate': cust.lastPaymentDate?.toIso8601String(),
            'address': cust.address,
            'notes': cust.notes,
            'status': cust.status.name,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // Seed Transactions
    for (final tx in BaseetMockData.initialTransactions) {
      batch.insert(
          'debt_transactions',
          {
            'id': tx.id,
            'customerId': tx.customerId,
            'type': tx.type.name,
            'amount': tx.amount,
            'date': tx.date.toIso8601String(),
            'notes': tx.notes,
            'remainingBalance': tx.remainingBalance,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('order_items');
      await txn.delete('orders');
      await txn.delete('debt_transactions');
      await txn.delete('customers');
      await txn.delete('products');
      await txn.delete('categories');
    });
  }

  Future<void> reseedDemoData() async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in [
        'order_items',
        'orders',
        'debt_transactions',
        'customers',
        'products',
        'categories'
      ]) {
        await txn.delete(table);
      }
      await _seedInitialData(txn);
    });
  }
}
