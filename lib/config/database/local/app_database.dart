import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

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
        await _createTables(db);
      },
    );

    _db = db;
    return db;
  }

  Future<void> _createTables(Database db) async {
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

    // 7. Suppliers
    await db.execute('''
      CREATE TABLE IF NOT EXISTS suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        companyName TEXT NOT NULL,
        phone TEXT NOT NULL,
        totalDebt REAL NOT NULL DEFAULT 0.0,
        address TEXT,
        lastTransactionDate TEXT
      )
    ''');

    // 8. Supplier Invoices
    await db.execute('''
      CREATE TABLE IF NOT EXISTS supplier_invoices (
        id TEXT PRIMARY KEY,
        supplierId TEXT NOT NULL,
        supplierName TEXT NOT NULL,
        date TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        paidAmount REAL NOT NULL,
        remainingAmount REAL NOT NULL,
        notes TEXT
      )
    ''');

    // 9. Supplier Invoice Items
    await db.execute('''
      CREATE TABLE IF NOT EXISTS supplier_invoice_items (
        id TEXT PRIMARY KEY,
        invoiceId TEXT NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        subtotal REAL NOT NULL
      )
    ''');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('supplier_invoice_items');
      await txn.delete('supplier_invoices');
      await txn.delete('suppliers');
      await txn.delete('order_items');
      await txn.delete('orders');
      await txn.delete('debt_transactions');
      await txn.delete('customers');
      await txn.delete('products');
      await txn.delete('categories');
    });
  }
}
