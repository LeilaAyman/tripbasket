import '/flutter_flow/flutter_flow_util.dart';
import '/utils/loyalty_redemption.dart';
import '/utils/loyalty_utils.dart';
import 'cart_widget.dart' show CartWidget;
import 'package:flutter/material.dart';

class CartModel extends FlutterFlowModel<CartWidget> {
  // Loyalty redemption state
  String? selectedTripIdForRedemption;
  Map<String, CartItemRedemption> cartItemRedemptions = {};
  bool loyaltyRedeemed = false;
  
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
  
  // Select trip for redemption (only one allowed)
  void selectTripForRedemption(String cartItemId, String tripId, double tripPrice) {
    // Clear any existing redemption
    cartItemRedemptions.clear();
    selectedTripIdForRedemption = tripId;
    
    // Create redemption for this trip
    cartItemRedemptions[cartItemId] = CartItemRedemption(
      cartItemId: cartItemId,
      tripId: tripId,
      originalPrice: tripPrice,
      discountAmount: Loyalty.calculateRedemptionAmount(tripPrice),
    );
  }
  
  // Clear redemption
  void clearRedemption() {
    selectedTripIdForRedemption = null;
    cartItemRedemptions.clear();
  }
  
  // Get redemption for specific cart item
  CartItemRedemption? getRedemptionForItem(String cartItemId) {
    return cartItemRedemptions[cartItemId];
  }
  
  // Check if any redemption is active
  bool get hasActiveRedemption => selectedTripIdForRedemption != null;
  
  // Get total discount amount
  double get totalRedemptionDiscount {
    return cartItemRedemptions.values
        .fold(0.0, (sum, redemption) => sum + redemption.discountAmount);
  }
}
