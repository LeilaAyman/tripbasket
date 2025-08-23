import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

enum AppCurrency { EGP, USD, EUR }

String currencySymbol(AppCurrency c) => switch (c) {
  AppCurrency.EGP => 'EGP ',
  AppCurrency.USD => '\$',
  AppCurrency.EUR => '€',
};

// Rates are relative to 1 EGP; will be overridden by backend doc if present.
class FxRates {
  final double egpToUsd;
  final double egpToEur;
  const FxRates({required this.egpToUsd, required this.egpToEur});
  
  double convertFromEGP(num amountEgp, AppCurrency to) {
    switch (to) {
      case AppCurrency.EGP: return amountEgp.toDouble();
      case AppCurrency.USD: return amountEgp * egpToUsd;
      case AppCurrency.EUR: return amountEgp * egpToEur;
    }
  }
}

TextStyle tabular(TextStyle base) =>
  base.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

String formatMoney(num amount, AppCurrency c, {String? locale}) {
  final symbol = currencySymbol(c);
  final fmt = NumberFormat.currency(
    locale: locale ?? 'en_EG',
    symbol: symbol,
    decimalDigits: 2,
  );
  return fmt.format(amount);
}