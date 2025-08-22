import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

TextStyle tabular(TextStyle base) => base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

String formatMoney(num amount, {String? locale, String? symbol, String? currencyCode}) {
  final fmt = NumberFormat.currency(
    locale: locale ?? Intl.defaultLocale ?? 'en_US',
    symbol: symbol, // if null, NumberFormat will infer from currencyCode or locale
    name: currencyCode,
  );
  return fmt.format(amount);
}