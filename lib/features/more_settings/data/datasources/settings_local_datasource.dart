import 'package:baseet/core/database/app_database.dart';

class SettingsLocalDataSource {
  final AppDatabase database;
  SettingsLocalDataSource(this.database);
  Future<void> clearData() => database.clearAllData();
  Future<void> restoreDemoData() => database.reseedDemoData();
}
