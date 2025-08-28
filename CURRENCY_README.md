# Currency System Implementation

## Overview

This implementation provides a single source of truth for currency management across the TripsBasket app, with EGP as the base currency and support for USD and EUR conversions.

## Architecture

### Core Components

1. **`lib/utils/money.dart`** - Currency utilities and formatting
2. **`lib/state/currency_provider.dart`** - Global currency state management
3. **`lib/widgets/price_text.dart`** - Consistent price display component

### Data Storage

- **Base Currency**: All prices are stored in EGP in Firestore
- **User Preference**: Stored in `users/{uid}.currency` (values: EGP|USD|EUR)
- **Exchange Rates**: Optional `settings/exchangeRates` document for dynamic rates

## CurrencyProvider Initialization

The CurrencyProvider is initialized in `main.dart` and automatically loads:

1. **User Currency Preference**: From `users/{uid}.currency`
2. **Exchange Rates**: From `settings/exchangeRates` document (optional)

```dart
// Initialization happens automatically when user logs in
userStream = tripbasketFirebaseUserStream()
  ..listen((user) {
    _appStateNotifier.update(user);
    if (user.loggedIn) {
      _currencyProvider.init(); // Auto-initialization
    }
  });
```

## Exchange Rates Document

Create a document at `settings/exchangeRates` with the following structure:

```json
{
  "egpToUsd": 0.020,
  "egpToEur": 0.018
}
```

These rates are used to convert from EGP (base currency) to other currencies. If the document doesn't exist, fallback rates are used.

## Usage Examples

### Displaying Prices

```dart
// Use PriceText widget for consistent formatting
PriceText(trip.priceEGP) // Automatically converts and formats

// Manual formatting
final currencyProvider = context.read<CurrencyProvider>();
final formattedPrice = currencyProvider.priceFromEGP(egpAmount, textStyle);
```

### Currency Selection

The Profile page includes a working currency selector that:
- Shows current selected currency
- Allows switching between EGP, USD, EUR  
- Saves preference to Firestore
- Shows confirmation snackbar

### Price Storage

**Trips**: Use `trip.priceEGP` (backward compatible with existing `price` field)

**Bookings**: Store both legacy and EGP fields:
```dart
await BookingsRecord.collection.add({
  'trip_price': widget.tripRecord.price,     // Legacy
  'total_amount': widget.totalAmount,        // Legacy
  'unitPriceEGP': widget.tripRecord.priceEGP, // New canonical
  'lineTotalEGP': widget.totalAmount,        // New canonical
  // ... other fields
});
```

## Benefits

1. **Consistency**: All prices display in user's preferred currency
2. **Accuracy**: Bookings store exact EGP amounts at time of purchase
3. **Performance**: Currency conversion happens client-side
4. **Flexibility**: Exchange rates can be updated via Firestore document
5. **Backward Compatibility**: Existing price fields continue to work

## Admin Features (Optional)

Add exchange rate management to admin panel:
- Read/write `settings/exchangeRates` document
- Update `egpToUsd` and `egpToEur` fields
- Rates will automatically propagate to all clients on next app launch