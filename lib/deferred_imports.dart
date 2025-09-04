// Deferred imports to reduce main.dart.js bundle size
// These pages will be loaded on-demand instead of at startup
import 'package:flutter/material.dart';

// Admin and agency management (heavy features)
import '/pages/admin_upload/admin_upload_widget.dart' deferred as admin_upload;
import '/pages/agency_dashboard/agency_dashboard_widget.dart' deferred as agency_dashboard;
import '/pages/agency_csv_upload/agency_csv_upload_widget.dart' deferred as agency_csv;
import '/pages/create_trip/create_trip_widget.dart' deferred as create_trip;
import '/pages/edit_trip/edit_trip_widget.dart' deferred as edit_trip;
import '/pages/admin_dashboard/admin_dashboard_widget.dart' deferred as admin_dashboard;

// User profile management
import '/pages/edit_profile/edit_profile_widget.dart' deferred as edit_profile;
import '/pages/national_id_upload/national_id_upload_page.dart' deferred as national_id;

// Payment and booking (heavy features)
import '/pages/payment/payment_widget.dart' deferred as payment;
import '/pages/book_trip/book_trip_widget.dart' deferred as book_trip;

// Reviews and loyalty (less frequently used)
import '/pages/reviews/reviews_widget.dart' deferred as reviews;
import '/pages/loyalty_page/loyalty_page_widget.dart' deferred as loyalty;

// Helper function to load a deferred library
Future<void> loadDeferredLibrary(Future<void> Function() loader) async {
  try {
    await loader();
  } catch (e) {
    print('Error loading deferred library: $e');
    rethrow;
  }
}

// Factory functions for creating widgets after loading
class DeferredWidgets {
  static Future<Widget> adminUpload() async {
    await loadDeferredLibrary(() => admin_upload.loadLibrary());
    return admin_upload.AdminUploadWidget();
  }

  static Future<Widget> agencyDashboard() async {
    await loadDeferredLibrary(() => agency_dashboard.loadLibrary());
    return agency_dashboard.AgencyDashboardWidget();
  }

  static Future<Widget> agencyCsv() async {
    await loadDeferredLibrary(() => agency_csv.loadLibrary());
    return agency_csv.AgencyCsvUploadWidget();
  }

  static Future<Widget> createTrip() async {
    await loadDeferredLibrary(() => create_trip.loadLibrary());
    return create_trip.CreateTripWidget();
  }

  static Future<Widget> editTrip() async {
    await loadDeferredLibrary(() => edit_trip.loadLibrary());
    return edit_trip.EditTripWidget();
  }

  static Future<Widget> editProfile() async {
    await loadDeferredLibrary(() => edit_profile.loadLibrary());
    return edit_profile.EditProfileWidget();
  }

  static Future<Widget> nationalId() async {
    await loadDeferredLibrary(() => national_id.loadLibrary());
    return national_id.NationalIdUploadPage();
  }

  static Future<Widget> payment() async {
    await loadDeferredLibrary(() => payment.loadLibrary());
    return payment.PaymentWidget();
  }

  static Future<Widget> bookTrip() async {
    await loadDeferredLibrary(() => book_trip.loadLibrary());
    return book_trip.BookTripWidget();
  }

  static Future<Widget> reviews() async {
    await loadDeferredLibrary(() => reviews.loadLibrary());
    return reviews.ReviewsWidget();
  }

  static Future<Widget> loyalty() async {
    await loadDeferredLibrary(() => loyalty.loadLibrary());
    return loyalty.LoyaltyPageWidget();
  }
}