import 'package:sqflite/sqflite.dart';
import 'package:baseet/config/database/local/app_database.dart';
import 'package:baseet/features/inventory/data/models/category_model.dart';
import 'package:baseet/features/pos/data/models/product_model.dart';

abstract class InventoryLocalDataSource {
  Future<List<ProductModel>> getInventory({String? categoryId, String? searchQuery, bool onlyLowStock = false});
  Future<List<CategoryModel>> getCategories();
  Future<ProductModel> addProduct(ProductModel product);
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<Map<String, dynamic>> getInventoryStats();
}

class InventoryLocalDataSourceImpl implements InventoryLocalDataSource {
  final AppDatabase appDatabase;

  InventoryLocalDataSourceImpl({AppDatabase? database})
      : appDatabase = database ?? AppDatabase();

  @override
  Future<List<ProductModel>> getInventory({
    String? categoryId,
    String? searchQuery,
    bool onlyLowStock = false,
  }) async {
    final db = await appDatabase.database;

    String whereClause = '';
    final List<dynamic> whereArgs = [];

    if (categoryId != null && categoryId != 'cat_0' && categoryId.isNotEmpty) {
      whereClause = 'categoryId = ?';
      whereArgs.add(categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      final searchCondition = '(name LIKE ? OR barcode LIKE ? OR categoryName LIKE ?)';
      whereClause = whereClause.isEmpty ? searchCondition : '$whereClause AND $searchCondition';
      whereArgs.addAll([q, q, q]);
    }

    if (onlyLowStock) {
      final lowStockCondition = 'stockQuantity <= minStockLimit';
      whereClause = whereClause.isEmpty ? lowStockCondition : '$whereClause AND $lowStockCondition';
    }

    final maps = await db.query(
      'products',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name ASC',
    );

    return maps.map((map) => ProductModel.fromMap(map)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await appDatabase.database;
    final maps = await db.query('categories', orderBy: 'name ASC');

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    final db = await appDatabase.database;

    await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return product;
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    final db = await appDatabase.database;

    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await appDatabase.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Map<String, dynamic>> getInventoryStats() async {
    final db = await appDatabase.database;

    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    final lowStockResult = await db.rawQuery(
      'SELECT COUNT(*) as lowCount FROM products WHERE stockQuantity <= minStockLimit',
    );
    final valueResult = await db.rawQuery(
      'SELECT SUM(buyPrice * stockQuantity) as valuation FROM products',
    );

    final int totalProducts = Sqflite.firstIntValue(countResult) ?? 0;
    final int lowStockCount = Sqflite.firstIntValue(lowStockResult) ?? 0;
    final double stockValue = (valueResult.isNotEmpty && valueResult.first['valuation'] != null)
        ? (valueResult.first['valuation'] as num).toDouble()
        : 0.0;

    return {
      'totalProducts': totalProducts,
      'lowStockCount': lowStockCount,
      'stockValue': stockValue,
    };
  }
}
