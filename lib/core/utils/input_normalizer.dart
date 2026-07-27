abstract final class InputNormalizer {
  static const Map<String, String> _digits = <String, String>{
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  static String digits(String value) {
    final StringBuffer buffer = StringBuffer();
    for (final int rune in value.runes) {
      final String character = String.fromCharCode(rune);
      buffer.write(_digits[character] ?? character);
    }
    return buffer.toString();
  }

  static int? integer(String value) {
    return int.tryParse(digits(value).trim());
  }

  static String phone(String value) {
    final String normalized = digits(value).trim();
    final bool hasLeadingPlus = normalized.startsWith('+');
    final String numbersOnly = normalized.replaceAll(RegExp('[^0-9]'), '');
    return hasLeadingPlus && numbersOnly.isNotEmpty
        ? '+$numbersOnly'
        : numbersOnly;
  }

  static String singleLine(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String multiLine(String value) {
    return value
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .join('\n');
  }
}
