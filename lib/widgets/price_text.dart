import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/state/currency_provider.dart';
import '/utils/money.dart';

class PriceText extends StatelessWidget {
  final num egpAmount;
  final TextStyle? style;
  
  const PriceText(this.egpAmount, {super.key, this.style});
  
  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CurrencyProvider>();
    final t = style ?? Theme.of(context).textTheme.titleMedium!;
    final text = cp.priceFromEGP(egpAmount, t);
    return Text(text, style: tabular(t));
  }
}