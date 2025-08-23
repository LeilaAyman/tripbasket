import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/utils/money.dart';

class CurrencyProvider extends ChangeNotifier {
  AppCurrency _selected = AppCurrency.EGP;
  FxRates _rates = const FxRates(egpToUsd: 0.020, egpToEur: 0.018); // fallback

  AppCurrency get selected => _selected;
  FxRates get rates => _rates;

  Future<void> init() async {
    // load user pref
    final ref = currentUserReference;
    if (ref != null) {
      final snap = await ref.get();
      final cur = ((snap.data() as Map<String, dynamic>?)?['currency'] as String?) ?? 'EGP';
      _selected = AppCurrency.values.firstWhere((c)=>c.name==cur, orElse:()=>AppCurrency.EGP);
    }
    // load fx rates from Firestore (optional): settings/exchangeRates
    // Only attempt to load rates if user is authenticated
    if (ref != null) {
      try {
        final fx = await FirebaseFirestore.instance.doc('settings/exchangeRates').get();
        if (fx.exists && fx.data() != null) {
          final d = fx.data()!;
          _rates = FxRates(
            egpToUsd: (d['egpToUsd'] ?? _rates.egpToUsd).toDouble(),
            egpToEur: (d['egpToEur'] ?? _rates.egpToEur).toDouble(),
          );
        }
      } catch (e) {
        // Silently use fallback rates if fetching fails
        // This is normal if the settings document doesn't exist or user lacks permissions
      }
    }
    notifyListeners();
  }

  Future<void> setCurrency(AppCurrency c) async {
    _selected = c;
    final ref = currentUserReference;
    if (ref != null) { 
      await ref.set({'currency': c.name}, SetOptions(merge: true)); 
    }
    notifyListeners();
  }

  String priceFromEGP(num egp, TextStyle style, {String? locale}) {
    final converted = rates.convertFromEGP(egp, _selected);
    return formatMoney(converted, _selected, locale: locale);
  }
}