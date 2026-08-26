import 'dart:math';

abstract class UuidGenerator {
  static String generate([String prefix = '']) {
    final rand = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = rand.nextInt(9999).toString().padLeft(4, '0');
    return prefix.isNotEmpty ? '${prefix}_${timestamp}_$randomSuffix' : '${timestamp}_$randomSuffix';
  }
}
