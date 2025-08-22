class Loyalty {
  /// Extract loyalty points from user document with null safety
  static int pointsOf(dynamic userDoc) =>
      (userDoc?.loyaltyPoints ?? 0) as int;

  /// Check if user can redeem loyalty points (400+ points required)
  static bool canRedeem(int points) {
    return points >= 400;
  }

  /// Calculate redemption discount for a single trip (10% only)
  static double redeemableDiscountFor(double tripPrice) {
    return tripPrice * 0.10; // Fixed 10% for redemption
  }

  /// Calculate discount percentage based on loyalty points (DEPRECATED - use redemption instead)
  /// Tiers: 400+ = 10%, 800+ = 15%, 1000+ = 20%
  @deprecated
  static double discountFor(int points) {
    if (points >= 1000) return 0.20;
    if (points >= 800) return 0.15;
    if (points >= 400) return 0.10;
    return 0.0;
  }

  /// Get human-readable tier label with discount info
  static String tierLabel(int points) {
    if (points >= 1000) return "Gold (20% off)";
    if (points >= 800) return "Silver (15% off)";
    if (points >= 400) return "Bronze (10% off)";
    return "No discount yet";
  }

  /// Get the next milestone point threshold
  static int nextMilestone(int points) {
    if (points < 400) return 400;
    if (points < 800) return 800;
    if (points < 1000) return 1000;
    return 1000; // Max tier reached
  }

  /// Get tier name only (without discount info)
  static String tierName(int points) {
    if (points >= 1000) return "Gold";
    if (points >= 800) return "Silver";
    if (points >= 400) return "Bronze";
    return "Standard";
  }

  /// Calculate points needed to reach next tier
  static int pointsToNextTier(int points) {
    final next = nextMilestone(points);
    return (next - points).clamp(0, next);
  }

  /// Get progress percentage to next tier (0.0 to 1.0)
  static double progressToNextTier(int points) {
    if (points >= 1000) {
      return 1.0;
    }
    
    int currentTierMin = 0;
    if (points >= 800) {
      currentTierMin = 800;
    } else if (points >= 400) {
      currentTierMin = 400;
    }
    
    final next = nextMilestone(points);
    final tierRange = next - currentTierMin;
    final progress = points - currentTierMin;
    
    return tierRange > 0 ? (progress / tierRange).clamp(0.0, 1.0) : 0.0;
  }

  /// Format discount as percentage string
  static String formatDiscount(double discount) {
    return "${(discount * 100).toStringAsFixed(0)}%";
  }

  /// Calculate redemption discount amount for a specific trip
  static double calculateRedemptionAmount(double tripPrice) {
    return redeemableDiscountFor(tripPrice);
  }

  /// Calculate discount amount for a given subtotal (DEPRECATED)
  @deprecated
  static double calculateDiscountAmount(double subtotal, int points) {
    final discountRate = discountFor(points);
    return subtotal * discountRate;
  }

  /// Calculate final total after applying loyalty discount (DEPRECATED)
  @deprecated
  static double calculateFinalTotal(double subtotal, int points) {
    final discountAmount = calculateDiscountAmount(subtotal, points);
    return subtotal - discountAmount;
  }

  /// Check if user has any discount available
  static bool hasDiscount(int points) {
    return points >= 400;
  }

  /// Get color for tier badge
  static String getTierColor(int points) {
    if (points >= 1000) return "#FFD700"; // Gold
    if (points >= 800) return "#C0C0C0"; // Silver
    if (points >= 400) return "#CD7F32"; // Bronze
    return "#9E9E9E"; // Standard (Grey)
  }
}