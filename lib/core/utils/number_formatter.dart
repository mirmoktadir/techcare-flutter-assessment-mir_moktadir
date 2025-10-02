import 'package:intl/intl.dart';

class NumberFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String format(double value) => _formatter.format(value);
}
