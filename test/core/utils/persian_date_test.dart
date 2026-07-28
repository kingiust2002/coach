import 'package:coach_app/core/utils/persian_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() {
  test('formats Gregorian date as Persian Jalali date', () {
    expect(PersianDate.format(DateTime.utc(2026, 3, 21)), '۱۴۰۵/۰۱/۰۱');
  });

  test('converts selected Jalali date back to UTC calendar date', () {
    expect(
      PersianDate.toUtcDate(Jalali(1405, 1, 1)),
      DateTime.utc(2026, 3, 21),
    );
  });
}
