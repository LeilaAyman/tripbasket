import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyRedemptionRequest {
  final String tripId;
  final double percent;
  
  LoyaltyRedemptionRequest({
    required this.tripId,
    this.percent = 0.10,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'percent': percent,
    };
  }
}

class LoyaltyRedemption {
  final String tripId;
  final double percent;
  final double discountAmount;
  final int pointsBefore;
  final DateTime timestamp;
  
  LoyaltyRedemption({
    required this.tripId,
    required this.percent,
    required this.discountAmount,
    required this.pointsBefore,
    required this.timestamp,
  });
  
  factory LoyaltyRedemption.fromJson(Map<String, dynamic> json) {
    return LoyaltyRedemption(
      tripId: json['tripId'] ?? '',
      percent: (json['percent'] ?? 0.0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
      pointsBefore: json['pointsBefore'] ?? 0,
      timestamp: (json['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'percent': percent,
      'discountAmount': discountAmount,
      'pointsBefore': pointsBefore,
      'at': Timestamp.fromDate(timestamp),
    };
  }
}

class CartItemRedemption {
  final String cartItemId;
  final String tripId;
  final double originalPrice;
  final double discountAmount;
  final bool isRedeemed;
  
  CartItemRedemption({
    required this.cartItemId,
    required this.tripId,
    required this.originalPrice,
    required this.discountAmount,
    this.isRedeemed = false,
  });
  
  double get finalPrice => originalPrice - discountAmount;
  
  CartItemRedemption copyWith({
    String? cartItemId,
    String? tripId,
    double? originalPrice,
    double? discountAmount,
    bool? isRedeemed,
  }) {
    return CartItemRedemption(
      cartItemId: cartItemId ?? this.cartItemId,
      tripId: tripId ?? this.tripId,
      originalPrice: originalPrice ?? this.originalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      isRedeemed: isRedeemed ?? this.isRedeemed,
    );
  }
}