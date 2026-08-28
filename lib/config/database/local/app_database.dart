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

  Future<void> seedDummyData() async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Categories
      final categories = [
        {'id': 'cat_beverages', 'name': 'مشروبات وعصائر', 'iconName': 'drink', 'colorHex': '#3B82F6'},
        {'id': 'cat_dairy', 'name': 'ألبان وأجبان', 'iconName': 'dairy', 'colorHex': '#10B981'},
        {'id': 'cat_snacks', 'name': 'مقرمشات وشيبس', 'iconName': 'snack', 'colorHex': '#F59E0B'},
        {'id': 'cat_sweets', 'name': 'حلويات وشوكولاتة', 'iconName': 'sweet', 'colorHex': '#EC4899'},
        {'id': 'cat_canned', 'name': 'معلبات ومواد غذائية', 'iconName': 'can', 'colorHex': '#8B5CF6'},
      ];
      for (final cat in categories) {
        await txn.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 2. Products
      final products = [
        {
          'id': 'prod_1',
          'name': 'بيبسي كانز 330 مل',
          'barcode': '6281007010011',
          'categoryId': 'cat_beverages',
          'categoryName': 'مشروبات وعصائر',
          'buyPrice': 10.0,
          'sellPrice': 12.0,
          'stockQuantity': 48,
          'minStockLimit': 10,
          'imageUrl': null,
        },
        {
          'id': 'prod_2',
          'name': 'مياه معدنية 600 مل',
          'barcode': '6281007010028',
          'categoryId': 'cat_beverages',
          'categoryName': 'مشروبات وعصائر',
          'buyPrice': 5.0,
          'sellPrice': 7.0,
          'stockQuantity': 60,
          'minStockLimit': 12,
          'imageUrl': null,
        },
        {
          'id': 'prod_3',
          'name': 'حليب جهينة 1 لتر',
          'barcode': '6281007010035',
          'categoryId': 'cat_dairy',
          'categoryName': 'ألبان وأجبان',
          'buyPrice': 38.0,
          'sellPrice': 44.0,
          'stockQuantity': 24,
          'minStockLimit': 5,
          'imageUrl': null,
        },
        {
          'id': 'prod_4',
          'name': 'جبنة دومتي فيتا 500 جم',
          'barcode': '6281007010042',
          'categoryId': 'cat_dairy',
          'categoryName': 'ألبان وأجبان',
          'buyPrice': 28.0,
          'sellPrice': 34.0,
          'stockQuantity': 18,
          'minStockLimit': 5,
          'imageUrl': null,
        },
        {
          'id': 'prod_5',
          'name': 'شيبسي عائلي بالملح',
          'barcode': '6281007010059',
          'categoryId': 'cat_snacks',
          'categoryName': 'مقرمشات وشيبس',
          'buyPrice': 15.0,
          'sellPrice': 20.0,
          'stockQuantity': 35,
          'minStockLimit': 8,
          'imageUrl': null,
        },
        {
          'id': 'prod_6',
          'name': 'شوكولاتة كادبوري ديري ميلك',
          'barcode': '6281007010066',
          'categoryId': 'cat_sweets',
          'categoryName': 'حلويات وشوكولاتة',
          'buyPrice': 22.0,
          'sellPrice': 28.0,
          'stockQuantity': 30,
          'minStockLimit': 6,
          'imageUrl': null,
        },
        {
          'id': 'prod_7',
          'name': 'تونة صن شاين قطع 185 جم',
          'barcode': '6281007010073',
          'categoryId': 'cat_canned',
          'categoryName': 'معلبات ومواد غذائية',
          'buyPrice': 42.0,
          'sellPrice': 50.0,
          'stockQuantity': 20,
          'minStockLimit': 5,
          'imageUrl': null,
        },
        {
          'id': 'prod_8',
          'name': 'فول مدمس حدائق كاليفورنيا',
          'barcode': '6281007010080',
          'categoryId': 'cat_canned',
          'categoryName': 'معلبات ومواد غذائية',
          'buyPrice': 18.0,
          'sellPrice': 24.0,
          'stockQuantity': 25,
          'minStockLimit': 6,
          'imageUrl': null,
        },
      ];
      for (final prod in products) {
        await txn.insert('products', prod, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 3. Customers & Transactions
      final customers = [
        {
          'id': 'cust_1',
          'name': 'أحمد محمود',
          'phone': '01012345678',
          'totalDebt': 350.0,
          'creditLimit': 2000.0,
          'lastPaymentDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'address': 'شارع الجمهورية - عمارة 5',
          'notes': 'عميل منتظم',
          'status': 'active',
        },
        {
          'id': 'cust_2',
          'name': 'محمد علي',
          'phone': '01123456789',
          'totalDebt': 680.0,
          'creditLimit': 1500.0,
          'lastPaymentDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'address': 'حي النور - بجوار المسجد',
          'notes': '',
          'status': 'active',
        },
        {
          'id': 'cust_3',
          'name': 'سارة حسن',
          'phone': '01234567890',
          'totalDebt': 0.0,
          'creditLimit': 3000.0,
          'lastPaymentDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'address': 'وسط البلد',
          'notes': 'سددت كامل المديونية',
          'status': 'settled',
        },
      ];
      for (final cust in customers) {
        await txn.insert('customers', cust, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      final transactions = [
        {
          'id': 'tx_1',
          'customerId': 'cust_1',
          'type': 'debt',
          'amount': 350.0,
          'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'notes': 'مشتريات بالآجل',
          'remainingBalance': 350.0,
          'receiptPath': null,
        },
        {
          'id': 'tx_2',
          'customerId': 'cust_2',
          'type': 'debt',
          'amount': 680.0,
          'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'notes': 'بضاعة آجلة',
          'remainingBalance': 680.0,
          'receiptPath': null,
        },
      ];
      for (final tx in transactions) {
        await txn.insert('debt_transactions', tx, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 4. Suppliers
      final suppliers = [
        {
          'id': 'sup_1',
          'name': 'شركة الأهرام للتوزيع',
          'companyName': 'الأهرام للمشروبات والأغذية',
          'phone': '01099887766',
          'totalDebt': 2500.0,
          'address': 'المنطقة الصناعية - 6 أكتوبر',
          'lastTransactionDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        },
        {
          'id': 'sup_2',
          'name': 'مؤسسة النور لتجارة الجملة',
          'companyName': 'النور ماركت بالجملة',
          'phone': '01188776655',
          'totalDebt': 0.0,
          'address': 'سوق الجملة',
          'lastTransactionDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        },
      ];
      for (final sup in suppliers) {
        await txn.insert('suppliers', sup, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
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
