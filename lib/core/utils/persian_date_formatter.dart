import 'package:shamsi_date/shamsi_date.dart';

abstract final class PersianDateFormatter {
  static String date(DateTime value) {
    final Jalali jalali = Jalali.fromDateTime(value.toLocal());
    return _toPersianDigits(
      '${jalali.year}/${_two(jalali.month)}/${_two(jalali.day)}',
    );
  }

  static String dateTime(DateTime value) {
    final DateTime local = value.toLocal();
    return '${date(local)}، ${_toPersianDigits('${_two(local.hour)}:${_two(local.minute)}')}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _toPersianDigits(String value) {
    const String latin = '0123456789';
    const String persian = '۰۱۲۳۴۵۶۷۸۹';
    String result = value;
    for (int index = 0; index < latin.length; index++) {
      result = result.replaceAll(latin[index], persian[index]);
    }
    return result;
  }
}
