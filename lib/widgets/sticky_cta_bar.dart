import 'package:flutter/material.dart';
import '../utils/formatting.dart';

class StickyCtaBar extends StatelessWidget {
  final num price;
  final VoidCallback? onPressed;
  final String buttonText;
  final String currencyCode;
  final String? symbol;
  final bool isLoading;
  final IconData? icon;
  
  const StickyCtaBar({
    super.key,
    required this.price,
    required this.onPressed,
    required this.buttonText,
    this.currencyCode = 'USD',
    this.symbol,
    this.isLoading = false,
    this.icon = Icons.lock,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black12)],
        ),
        child: Row(
          children: [
            Expanded(child: Text(
              formatMoney(price, currencyCode: currencyCode, symbol: symbol),
              style: tabular(t.textTheme.titleLarge!),
            )),
            FilledButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}