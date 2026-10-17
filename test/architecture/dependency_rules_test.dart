import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain stays independent of Flutter, persistence and app composition',
      () {
    final files = Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
            f.path.replaceAll('\\', '/').contains('/domain/') &&
            f.path.endsWith('.dart'));
    for (final file in files) {
      for (final match
          in RegExp(r"import '([^']+)'").allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        expect(uri, isNot(contains('/data/')), reason: file.path);
        expect(uri, isNot(contains('package:flutter')), reason: file.path);
        expect(uri, isNot(contains('sqflite')), reason: file.path);
        expect(uri, isNot(contains('baseet/app/')), reason: file.path);
        expect(uri, isNot(contains('baseet/core/database/')),
            reason: file.path);
      }
    }
  });

  test('presentation never accesses database or data implementations', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
            f.path.replaceAll('\\', '/').contains('/presentation/') &&
            f.path.endsWith('.dart'));
    for (final file in files) {
      for (final match
          in RegExp(r"import '([^']+)'").allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        expect(uri, isNot(contains('/data/')), reason: file.path);
        expect(uri, isNot(contains('baseet/core/database/')),
            reason: file.path);
      }
    }
  });
}
