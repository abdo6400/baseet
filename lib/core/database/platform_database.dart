import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<String> configureDatabase() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final directory = await getApplicationSupportDirectory();
  await directory.create(recursive: true);
  final destination = p.join(directory.path, 'baseet.db');
  // Preserve databases created by previous mobile versions.
  if (!Platform.isWindows &&
      !Platform.isLinux &&
      !await File(destination).exists()) {
    final previous = p.join(await getDatabasesPath(), 'baseet.db');
    if (await File(previous).exists()) {
      // SQLite backup is performed while the old connection is closed at startup.
      await File(previous).copy(destination);
      for (final suffix in ['-wal', '-shm']) {
        if (await File('$previous$suffix').exists()) {
          await File('$previous$suffix').copy('$destination$suffix');
        }
      }
    }
  }
  return destination;
}
