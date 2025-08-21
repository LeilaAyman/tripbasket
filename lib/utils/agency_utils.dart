import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/trips_record.dart';
import '/backend/schema/agencies_record.dart';
import '/backend/schema/users_record.dart';
import '/auth/firebase_auth/auth_util.dart';

class AgencyUtils {
  // Constants
  static const double kFeaturedMinRating = 4.0;

  /// Helper to safely lowercase strings
  static String lc(String? s) => (s ?? '').toLowerCase();

  /// Get the current user's agency reference
  static DocumentReference? getCurrentAgencyRef() {
    final user = currentUser;
    if (user == null) {
      print('DEBUG AgencyUtils: No current user found');
      return null;
    }
    
    // Get the current user document to access agency reference
    final userDoc = currentUserDocument;
    if (userDoc == null) {
      print('DEBUG AgencyUtils: No current user document found for user: ${user.uid}');
      return null;
    }
    
    final agencyRef = userDoc.agencyReference;
    
    if (agencyRef == null) {
      print('DEBUG AgencyUtils: No agency reference found for user: ${user.uid}, roles: ${userDoc.role}');
    } else {
      print('DEBUG AgencyUtils: ✅ Found agency reference: ${agencyRef.path}');
    }
    
    return agencyRef;
  }
  
  /// Filter trips based on search query and status with null-safe text handling
  static List<TripsRecord> filterTrips(
    List<TripsRecord> trips,
    String searchQuery,
    String filterStatus,
  ) {
    List<TripsRecord> filteredTrips = trips;
    
    // Apply search filter with null-safe text handling
    if (searchQuery.isNotEmpty) {
      filteredTrips = filteredTrips.where((trip) {
        final query = lc(searchQuery);
        return lc(trip.title).contains(query) ||
               lc(trip.location).contains(query) ||
               lc(trip.description).contains(query);
      }).toList();
    }
    
    // Apply status filter
    switch (filterStatus) {
      case 'active':
        filteredTrips = filteredTrips.where((trip) => trip.availableSeats > 0).toList();
        break;
      case 'inactive':
        filteredTrips = filteredTrips.where((trip) => trip.availableSeats <= 0).toList();
        break;
      case 'featured':
        filteredTrips = filteredTrips.where((trip) => (trip.rating ?? 0) > kFeaturedMinRating).toList();
        break;
      case 'all':
      default:
        // No additional filtering needed
        break;
    }
    
    return filteredTrips;
  }
  
  /// Get count of active trips
  static int getActiveTripsCount(List<TripsRecord> trips) {
    return trips.where((trip) => trip.availableSeats > 0).length;
  }
  
  /// Calculate total revenue from trips with proper data validation
  static int calculateTotalRevenue(List<TripsRecord> trips) {
    return trips.fold<int>(0, (sum, trip) {
      final rawSold = (trip.quantity - trip.availableSeats);
      final soldSeats = rawSold.clamp(0, trip.quantity);
      return sum + (trip.price * soldSeats);
    });
  }
  
  /// Calculate average rating
  static double calculateAverageRating(List<TripsRecord> trips) {
    if (trips.isEmpty) return 0.0;
    
    final totalRating = trips.fold<double>(0.0, (sum, trip) => sum + (trip.rating ?? 0.0));
    return totalRating / trips.length;
  }
  
  /// Generate a unique agency ID
  static String generateAgencyId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'AGY_${timestamp}_$random';
  }
  
  /// Check if current user is an agency (case-insensitive)
  static bool isCurrentUserAgency() {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    
    final role = lc(userDoc.role.join(' '));
    return role.contains('agency') || userDoc.agencyReference != null;
  }
  
  /// Check if current user can access CSV upload
  static bool canAccessCSVUpload() {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    
    final role = lc(userDoc.role.join(' '));
    return role.contains('admin') || role.contains('agency') || userDoc.agencyReference != null;
  }

  /// Validate trip ownership for agency users
  static bool validateTripOwnership(TripsRecord trip) {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    
    // Admin can access any trip
    final role = lc(userDoc.role.join(' '));
    if (role.contains('admin')) return true;
    
    // Agency users can only access their own trips
    final userAgencyRef = getCurrentAgencyRef();
    return trip.agencyReference == userAgencyRef;
  }

  /// Check if user is admin (case-insensitive)
  static bool isCurrentUserAdmin() {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    
    final role = lc(userDoc.role.join(' '));
    return role.contains('admin');
  }

  /// Verify ownership before performing trip actions
  static bool verifyTripAccess(TripsRecord trip) {
    final isAdmin = isCurrentUserAdmin();
    if (isAdmin) return true;
    
    final userAgencyRef = getCurrentAgencyRef();
    return trip.agencyReference == userAgencyRef;
  }
}