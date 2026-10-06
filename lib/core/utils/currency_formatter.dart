import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// [amount] is an integer in the backend's minor unit.
  /// For IDR the backend uses 0 decimals (whole rupiah), so the value
  /// is formatted as-is. Do NOT divide by 100 here.
  /// Returns 'Rp 10.000.000' style string.
  static String idr(int amount) {
    final NumberFormat fmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return fmt.format(amount);
  }

  static String compact(int amount) {
    final NumberFormat fmt = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 1,
    );
    return fmt.format(amount);
  }
}
