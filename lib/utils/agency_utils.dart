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
  
  /// Calculate total revenue from actual bookings
  static Future<double> calculateRealTotalRevenue(DocumentReference? agencyRef, bool isAdmin) async {
    try {
      Query query;
      if (isAdmin) {
        query = FirebaseFirestore.instance.collection('bookings');
      } else if (agencyRef != null) {
        query = FirebaseFirestore.instance.collection('bookings')
            .where('agency_reference', isEqualTo: agencyRef);
      } else {
        return 0.0;
      }
      
      final snapshot = await query.get();
      final bookings = snapshot.docs;
      
      double totalRevenue = 0.0;
      for (final booking in bookings) {
        final data = booking.data() as Map<String, dynamic>;
        final amount = data['total_amount'] ?? data['lineTotalEGP'] ?? 0.0;
        totalRevenue += (amount is int) ? amount.toDouble() : (amount as double? ?? 0.0);
      }
      
      return totalRevenue;
    } catch (e) {
      return 0.0;
    }
  }

  /// Calculate total revenue from trips with proper data validation - legacy method
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

  /// Calculate booking rate from actual bookings data
  static Future<double> calculateRealBookingRate(List<TripsRecord> trips, DocumentReference? agencyRef, bool isAdmin) async {
    if (trips.isEmpty) return 0.0;
    
    try {
      // Query actual bookings
      Query query;
      if (isAdmin) {
        query = FirebaseFirestore.instance.collection('bookings');
      } else if (agencyRef != null) {
        query = FirebaseFirestore.instance.collection('bookings')
            .where('agency_reference', isEqualTo: agencyRef);
      } else {
        return 0.0;
      }
      
      final snapshot = await query.get();
      final bookings = snapshot.docs;
      
      // Count total bookings per trip
      Map<String, int> tripBookingCounts = {};
      for (final booking in bookings) {
        final data = booking.data() as Map<String, dynamic>;
        final tripRef = data['trip_reference'] as DocumentReference?;
        if (tripRef != null) {
          final travelerCount = (data['traveler_count'] ?? 1) as int;
          tripBookingCounts[tripRef.id] = (tripBookingCounts[tripRef.id] ?? 0) + travelerCount;
        }
      }
      
      int totalSeats = trips.fold<int>(0, (sum, trip) => sum + trip.quantity);
      int bookedSeats = 0;
      
      for (final trip in trips) {
        final bookedForTrip = tripBookingCounts[trip.reference.id] ?? 0;
        bookedSeats += bookedForTrip;
      }
      
      if (totalSeats == 0) return 0.0;
      return (bookedSeats / totalSeats) * 100;
    } catch (e) {
      // Fallback to original calculation if booking query fails
      return calculateBookingRateFromTrips(trips);
    }
  }

  /// Calculate booking rate (sold seats vs total seats) - legacy method
  static double calculateBookingRateFromTrips(List<TripsRecord> trips) {
    if (trips.isEmpty) return 0.0;
    
    int totalSeats = trips.fold<int>(0, (sum, trip) => sum + trip.quantity);
    int soldSeats = trips.fold<int>(0, (sum, trip) => sum + (trip.quantity - trip.availableSeats).clamp(0, trip.quantity));
    
    if (totalSeats == 0) return 0.0;
    return (soldSeats / totalSeats) * 100;
  }
  
  /// Calculate booking rate (sold seats vs total seats) - maintains compatibility
  static double calculateBookingRate(List<TripsRecord> trips) {
    return calculateBookingRateFromTrips(trips);
  }

  /// Get monthly revenue data for charts
  static Map<String, int> getMonthlyRevenue(List<TripsRecord> trips) {
    Map<String, int> monthlyRevenue = {};
    
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = "${month.year}-${month.month.toString().padLeft(2, '0')}";
      monthlyRevenue[monthKey] = 0;
    }
    
    for (final trip in trips) {
      if (trip.createdAt != null) {
        final tripDate = trip.createdAt!;
        final monthKey = "${tripDate.year}-${tripDate.month.toString().padLeft(2, '0')}";
        
        if (monthlyRevenue.containsKey(monthKey)) {
          final soldSeats = (trip.quantity - trip.availableSeats).clamp(0, trip.quantity);
          monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + (trip.price * soldSeats);
        }
      }
    }
    
    return monthlyRevenue;
  }

  /// Get top performing destinations
  static List<Map<String, dynamic>> getTopDestinations(List<TripsRecord> trips, {int limit = 5}) {
    Map<String, Map<String, dynamic>> destinationStats = {};
    
    for (final trip in trips) {
      final location = trip.location.isNotEmpty ? trip.location : 'Unknown';
      final soldSeats = (trip.quantity - trip.availableSeats).clamp(0, trip.quantity);
      final revenue = trip.price * soldSeats;
      
      if (destinationStats.containsKey(location)) {
        destinationStats[location]!['bookings'] += soldSeats;
        destinationStats[location]!['revenue'] += revenue;
        destinationStats[location]!['trips'] += 1;
      } else {
        destinationStats[location] = {
          'location': location,
          'bookings': soldSeats,
          'revenue': revenue,
          'trips': 1,
        };
      }
    }
    
    final sortedDestinations = destinationStats.values.toList();
    sortedDestinations.sort((a, b) => (b['revenue'] as int).compareTo(a['revenue'] as int));
    
    return sortedDestinations.take(limit).toList();
  }

  /// Calculate customer activity metrics from actual bookings
  static Future<Map<String, dynamic>> getCustomerActivityStatsFromBookings(DocumentReference? agencyRef, bool isAdmin) async {
    try {
      // Query actual bookings
      Query query;
      if (isAdmin) {
        query = FirebaseFirestore.instance.collection('bookings');
      } else if (agencyRef != null) {
        query = FirebaseFirestore.instance.collection('bookings')
            .where('agency_reference', isEqualTo: agencyRef);
      } else {
        return {
          'totalCustomers': 0,
          'totalBookings': 0,
          'averageBookingsPerCustomer': 0.0,
          'customerRetentionRate': 0.0,
        };
      }
      
      final snapshot = await query.get();
      final bookings = snapshot.docs;
      
      Set<String> uniqueCustomers = {};
      Map<String, int> customerBookingCount = {};
      Map<String, double> customerRevenueTotal = {};
      double totalRevenue = 0.0;
      
      for (final booking in bookings) {
        final data = booking.data() as Map<String, dynamic>;
        final customerEmail = data['customer_email'] ?? '';
        final userRef = data['user_reference'] as DocumentReference?;
        final amount = data['total_amount'] ?? data['lineTotalEGP'] ?? 0.0;
        final revenue = (amount is int) ? amount.toDouble() : (amount as double? ?? 0.0);
        
        // Use customer email as unique identifier, fallback to user reference
        final customerId = customerEmail.isNotEmpty 
            ? customerEmail 
            : (userRef?.id ?? booking.id);
        
        uniqueCustomers.add(customerId);
        customerBookingCount[customerId] = (customerBookingCount[customerId] ?? 0) + 1;
        customerRevenueTotal[customerId] = (customerRevenueTotal[customerId] ?? 0.0) + revenue;
        totalRevenue += revenue;
      }
      
      final repeatCustomers = customerBookingCount.values.where((count) => count > 1).length;
      final retentionRate = uniqueCustomers.isEmpty ? 0.0 : (repeatCustomers / uniqueCustomers.length) * 100;
      
      return {
        'totalCustomers': uniqueCustomers.length,
        'totalBookings': bookings.length,
        'averageBookingsPerCustomer': uniqueCustomers.isEmpty ? 0.0 : bookings.length / uniqueCustomers.length,
        'averageRevenuePerCustomer': uniqueCustomers.isEmpty ? 0.0 : totalRevenue / uniqueCustomers.length,
        'customerRetentionRate': retentionRate,
      };
    } catch (e) {
      print('Error fetching booking stats: $e');
      return {
        'totalCustomers': 0,
        'totalBookings': 0,
        'averageBookingsPerCustomer': 0.0,
        'averageRevenuePerCustomer': 0.0,
        'customerRetentionRate': 0.0,
      };
    }
  }

  /// Calculate customer activity metrics (legacy method - now uses actual bookings)
  static Map<String, dynamic> getCustomerActivityStats(List<TripsRecord> trips) {
    Set<String> uniqueCustomers = {};
    int totalBookings = 0;
    int repeatCustomers = 0;
    Map<String, int> customerBookingCount = {};
    
    // This would require booking records, but for now we'll estimate based on sold seats
    for (final trip in trips) {
      final soldSeats = (trip.quantity - trip.availableSeats).clamp(0, trip.quantity);
      totalBookings += soldSeats;
      // For demonstration, we'll assume each sold seat represents a unique booking
      uniqueCustomers.add(trip.reference.id + '_booking_' + soldSeats.toString());
    }
    
    return {
      'totalCustomers': uniqueCustomers.length,
      'totalBookings': totalBookings,
      'averageBookingsPerCustomer': uniqueCustomers.isEmpty ? 0.0 : totalBookings / uniqueCustomers.length,
      'customerRetentionRate': 0.0, // Would need booking history to calculate properly
    };
  }

  /// Get performance trends from real booking data (comparing current vs previous period)
  static Future<Map<String, dynamic>> getRealPerformanceTrends(DocumentReference? agencyRef, bool isAdmin) async {
    try {
      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);
      final previousMonthStart = DateTime(now.year, now.month - 1, 1);
      
      // Query bookings for current and previous month
      Query baseQuery;
      if (isAdmin) {
        baseQuery = FirebaseFirestore.instance.collection('bookings');
      } else if (agencyRef != null) {
        baseQuery = FirebaseFirestore.instance.collection('bookings')
            .where('agency_reference', isEqualTo: agencyRef);
      } else {
        return _getDefaultTrends();
      }
      
      final snapshot = await baseQuery.get();
      final allBookings = snapshot.docs;
      
      double currentRevenue = 0.0;
      double previousRevenue = 0.0;
      int currentBookings = 0;
      int previousBookings = 0;
      
      for (final booking in allBookings) {
        final data = booking.data() as Map<String, dynamic>;
        final bookingDate = (data['booking_date'] ?? data['created_at']) as Timestamp?;
        
        if (bookingDate != null) {
          final date = bookingDate.toDate();
          final amount = data['total_amount'] ?? data['lineTotalEGP'] ?? 0.0;
          final revenue = (amount is int) ? amount.toDouble() : (amount as double? ?? 0.0);
          
          if (date.isAfter(currentMonthStart)) {
            currentRevenue += revenue;
            currentBookings++;
          } else if (date.isAfter(previousMonthStart) && date.isBefore(currentMonthStart)) {
            previousRevenue += revenue;
            previousBookings++;
          }
        }
      }
      
      final revenueGrowth = previousRevenue == 0 ? 0.0 : ((currentRevenue - previousRevenue) / previousRevenue) * 100;
      final bookingGrowth = previousBookings == 0 ? 0.0 : ((currentBookings - previousBookings) / previousBookings) * 100;
      
      return {
        'revenueGrowth': revenueGrowth,
        'bookingGrowth': bookingGrowth,
        'currentMonthRevenue': currentRevenue.toInt(),
        'previousMonthRevenue': previousRevenue.toInt(),
        'currentMonthBookings': currentBookings,
        'previousMonthBookings': previousBookings,
      };
    } catch (e) {
      return _getDefaultTrends();
    }
  }
  
  static Map<String, dynamic> _getDefaultTrends() {
    return {
      'revenueGrowth': 0.0,
      'bookingGrowth': 0.0,
      'currentMonthRevenue': 0,
      'previousMonthRevenue': 0,
      'currentMonthBookings': 0,
      'previousMonthBookings': 0,
    };
  }

  /// Get performance trends (comparing current vs previous period) - legacy method
  static Map<String, dynamic> getPerformanceTrends(List<TripsRecord> trips) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    
    final currentMonthTrips = trips.where((trip) => 
        trip.createdAt != null && trip.createdAt!.isAfter(currentMonthStart)).toList();
    final previousMonthTrips = trips.where((trip) => 
        trip.createdAt != null && 
        trip.createdAt!.isAfter(previousMonthStart) && 
        trip.createdAt!.isBefore(currentMonthStart)).toList();
    
    final currentRevenue = calculateTotalRevenue(currentMonthTrips);
    final previousRevenue = calculateTotalRevenue(previousMonthTrips);
    final revenueGrowth = previousRevenue == 0 ? 0.0 : ((currentRevenue - previousRevenue) / previousRevenue) * 100;
    
    final currentBookings = currentMonthTrips.fold<int>(0, (sum, trip) => 
        sum + (trip.quantity - trip.availableSeats).clamp(0, trip.quantity));
    final previousBookings = previousMonthTrips.fold<int>(0, (sum, trip) => 
        sum + (trip.quantity - trip.availableSeats).clamp(0, trip.quantity));
    final bookingGrowth = previousBookings == 0 ? 0.0 : ((currentBookings - previousBookings) / previousBookings) * 100;
    
    return {
      'revenueGrowth': revenueGrowth,
      'bookingGrowth': bookingGrowth,
      'currentMonthRevenue': currentRevenue,
      'previousMonthRevenue': previousRevenue,
      'currentMonthBookings': currentBookings,
      'previousMonthBookings': previousBookings,
    };
  }
}