// utils/formatters.dart

class Formatters {
  //!Con .00
  static String formatCurrency(double amount, {String symbol = '₡'}) {
    return '$symbol${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Opcional: Formato abreviado para números grandes
  static String formatCurrencyCompact(double amount, {String symbol = '₡'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatCurrency(amount, symbol: symbol);
  }

  // Opcional: Formato sin decimales
  //!Sin .00
  static String formatCurrencyNoDecimals(double amount, {String symbol = '₡'}) {
    return '$symbol${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}



// utils/extensions/currency_extension.dart
//!Ma elegante
// extension CurrencyFormatter on double {
//   String toCurrency({String symbol = '₡', bool withDecimals = true}) {
//     if (withDecimals) {
//       return '$symbol${toStringAsFixed(2).replaceAllMapped(
//         RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
//         (Match m) => '${m[1]},'
//       )}';
//     } else {
//       return '$symbol${toInt().toString().replaceAllMapped(
//         RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
//         (Match m) => '${m[1]},'
//       )}';
//     }
//   }

//   String toCompactCurrency({String symbol = '₡'}) {
//     if (this >= 1000000) {
//       return '$symbol${(this / 1000000).toStringAsFixed(1)}M';
//     } else if (this >= 1000) {
//       return '$symbol${(this / 1000).toStringAsFixed(1)}K';
//     }
//     return toCurrency(symbol: symbol);
//   }
// }