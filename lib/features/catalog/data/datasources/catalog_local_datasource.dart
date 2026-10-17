import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/features/catalog/data/models/category_model.dart';

class CatalogLocalDataSource {
  final AppDatabase database;
  CatalogLocalDataSource(this.database);
  Future<List<CategoryModel>> getCategories() async {
    final db = await database.database;
    final rows = await db.query('categories',
        where: 'id != ?', whereArgs: ['cat_0'], orderBy: 'name ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }
}
