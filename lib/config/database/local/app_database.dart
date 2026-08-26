import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'mock_data.dart';

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

  Future<Database> init({bool seedIfEmpty = true}) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'baseet.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
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

  Future<void> _seedInitialData(Database db) async {
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

    // Seed Suppliers
    for (final sup in BaseetMockData.initialSuppliers) {
      batch.insert(
        'suppliers',
        {
          'id': sup.id,
          'name': sup.name,
          'companyName': sup.companyName,
          'phone': sup.phone,
          'totalDebt': sup.totalDebt,
          'address': sup.address,
          'lastTransactionDate': sup.lastTransactionDate?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Seed Supplier Invoices & Items
    for (final inv in BaseetMockData.initialSupplierInvoices) {
      batch.insert(
        'supplier_invoices',
        {
          'id': inv.id,
          'supplierId': inv.supplierId,
          'supplierName': inv.supplierName,
          'date': inv.date.toIso8601String(),
          'totalAmount': inv.totalAmount,
          'paidAmount': inv.paidAmount,
          'remainingAmount': inv.remainingAmount,
          'notes': inv.notes,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (int i = 0; i < inv.items.length; i++) {
        final item = inv.items[i];
        batch.insert(
          'supplier_invoice_items',
          {
            'id': 'sii_${inv.id}_$i',
            'invoiceId': inv.id,
            'productName': item.productName,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'subtotal': item.subtotal,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
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

  Future<void> reseedDemoData() async {
    await clearAllData();
    final db = await database;
    await _seedInitialData(db);
  }
}
