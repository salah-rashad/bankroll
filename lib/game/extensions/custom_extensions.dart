import 'package:intl/intl.dart';

mixin ext_CustomExtensions {}

extension IntExtension on int {
  String toCurrencyString() =>
      NumberFormat.currency(symbol: "\$", decimalDigits: 0).format(this);
}
