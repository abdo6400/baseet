import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> dartFilesUnder(String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) {
    return const Iterable<File>.empty();
  }

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

Iterable<String> directivesOf(File file) {
  final source = file.readAsStringSync();
  return RegExp(r'''(?:import|export)\s+['\"]([^'\"]+)['\"]''')
      .allMatches(source)
      .map((match) => match.group(1)!);
}

void expectNoDirective(File file, List<String> forbiddenFragments) {
  for (final uri in directivesOf(file)) {
    for (final fragment in forbiddenFragments) {
      expect(uri, isNot(contains(fragment)), reason: '${file.path}: $uri');
    }
  }
}

void main() {
  test('every feature with Dart code has all three clean architecture layers',
      () {
    final featureRoot = Directory('lib/features');
    if (!featureRoot.existsSync()) {
      return;
    }

    final features = featureRoot.listSync().whereType<Directory>();
    for (final feature in features) {
      if (dartFilesUnder(feature.path).isEmpty) {
        continue;
      }

      for (final layer in ['data', 'domain', 'presentation']) {
        expect(
          Directory('${feature.path}${Platform.pathSeparator}$layer')
              .existsSync(),
          isTrue,
          reason: '${feature.path} is missing its $layer layer',
        );
      }
    }
  });

  test('domain stays independent of UI, IO and app composition', () {
    final files = dartFilesUnder('lib/features').where(
      (file) => file.path.replaceAll('\\', '/').contains('/domain/'),
    );

    for (final file in files) {
      expectNoDirective(file, [
        '/data/',
        'package:flutter',
        'dart:io',
        'sqflite',
        'drift',
        'dio',
        'http',
        'baseet/app/',
        'baseet/core/database/',
      ]);
    }
  });

  test('presentation cannot access data implementations or persistence', () {
    final files = dartFilesUnder('lib').where(
      (file) => file.path.replaceAll('\\', '/').contains('/presentation/'),
    );

    for (final file in files) {
      expectNoDirective(file, [
        '/data/',
        'sqflite',
        'drift',
        'baseet/core/database/',
      ]);
    }
  });

  test('features never import another feature data layer', () {
    for (final file in dartFilesUnder('lib/features')) {
      final normalizedPath = file.path.replaceAll('\\', '/');
      final ownFeature =
          RegExp(r'lib/features/([^/]+)/').firstMatch(normalizedPath)?.group(1);

      for (final uri in directivesOf(file)) {
        final importedFeature =
            RegExp(r'baseet/features/([^/]+)/data/').firstMatch(uri)?.group(1);
        if (importedFeature != null) {
          expect(importedFeature, ownFeature, reason: '${file.path}: $uri');
        }
      }
    }
  });
}
