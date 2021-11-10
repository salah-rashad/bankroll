import 'package:intl/intl.dart';

mixin ext_CustomExtensions {}

extension IntExtension on int {
  String toCurrencyString() =>
      NumberFormat.currency(symbol: "\$", decimalDigits: 0).format(this);

  int get nearest {
    int rem = this % 10;
    if (rem > 7)
      return (this - rem + 10);
    else if (rem < 3)
      return (this - rem);
    else
      return (this - rem + 5);
  }
}
