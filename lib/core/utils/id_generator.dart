import 'dart:math';

abstract final class IdGenerator {
  static final Random _random = Random.secure();

  static String create(String prefix) {
    final int timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final int entropy = _random.nextInt(0x7fffffff);
    return '$prefix-$timestamp-${entropy.toRadixString(16)}';
  }
}
