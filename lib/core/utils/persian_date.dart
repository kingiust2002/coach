import 'package:shamsi_date/shamsi_date.dart';

abstract final class PersianDate {
  static Jalali toJalali(DateTime value) => Jalali.fromDateTime(value.toLocal());

  static DateTime toUtcDate(Jalali value) {
    final Gregorian gregorian = value.toGregorian();
    return DateTime.utc(gregorian.year, gregorian.month, gregorian.day);
  }

  static String format(DateTime? value, {bool persianDigits = true}) {
    if (value == null) {
      return 'ثبت نشده';
    }
    final Jalali jalali = toJalali(value);
    final String result =
        '${jalali.year.toString().padLeft(4, '0')}/'
        '${jalali.month.toString().padLeft(2, '0')}/'
        '${jalali.day.toString().padLeft(2, '0')}';
    return persianDigits ? _toPersianDigits(result) : result;
  }

  static String formatDateTime(DateTime value, {bool persianDigits = true}) {
    final DateTime local = value.toLocal();
    final String date = format(local, persianDigits: false);
    final String time =
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
    final String result = '$date، $time';
    return persianDigits ? _toPersianDigits(result) : result;
  }

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
