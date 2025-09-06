import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/users_record.dart';
import '/backend/schema/agencies_record.dart';
import '/backend/schema/trips_record.dart';
import '/backend/schema/reviews_record.dart';

/// Safe wrapper for Firestore operations that handles Firebase 11.x breaking changes
class FirestoreSafeFetch {
  
  /// Safe user document fetch with error handling
  static Future<UsersRecord?> getUser(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return UsersRecord.fromSnapshot(doc);
      }
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🔥 Firestore user fetch error: $e");
        print("Stack trace: $stackTrace");
      }
      return null;
    }
  }
  
  /// Safe agencies stream with error handling
  static Stream<List<AgenciesRecord>> getAgenciesStream() {
    try {
      return FirebaseFirestore.instance
          .collection('agencies')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return AgenciesRecord.fromSnapshot(doc);
              } catch (e) {
                if (kDebugMode) {
                  print("🔥 Error parsing agency document ${doc.id}: $e");
                }
                return null;
              }
            })
            .where((agency) => agency != null)
            .cast<AgenciesRecord>()
            .toList();
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🔥 Firestore agencies stream error: $e");
        print("Stack trace: $stackTrace");
      }
      // Return empty stream instead of throwing
      return Stream.value(<AgenciesRecord>[]);
    }
  }
  
  /// Safe trips fetch for agency
  static Future<List<TripsRecord>> getTripsForAgency(String agencyId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('agencyId', isEqualTo: agencyId)
          .get();
      
      return querySnapshot.docs
          .map((doc) {
            try {
              return TripsRecord.fromSnapshot(doc);
            } catch (e) {
              if (kDebugMode) {
                print("🔥 Error parsing trip document ${doc.id}: $e");
              }
              return null;
            }
          })
          .where((trip) => trip != null)
          .cast<TripsRecord>()
          .toList();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🔥 Firestore trips fetch error: $e");
        print("Stack trace: $stackTrace");
      }
      return <TripsRecord>[];
    }
  }
  
  /// Safe reviews stream with error handling
  static Stream<List<ReviewsRecord>> getReviewsStream() {
    try {
      return FirebaseFirestore.instance
          .collection('reviews')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return ReviewsRecord.fromSnapshot(doc);
              } catch (e) {
                if (kDebugMode) {
                  print("🔥 Error parsing review document ${doc.id}: $e");
                }
                return null;
              }
            })
            .where((review) => review != null)
            .cast<ReviewsRecord>()
            .toList();
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🔥 Firestore reviews stream error: $e");
        print("Stack trace: $stackTrace");
      }
      // Return empty stream instead of throwing
      return Stream.value(<ReviewsRecord>[]);
    }
  }
  
  /// Generic safe document fetch
  static Future<T?> getDocument<T>(
    String collection,
    String documentId,
    T Function(DocumentSnapshot) fromSnapshot,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return fromSnapshot(doc);
      }
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🔥 Firestore document fetch error ($collection/$documentId): $e");
        print("Stack trace: $stackTrace");
      }
      return null;
    }
  }
  
  /// Generic safe collection stream
  static Stream<List<T>> getCollectionStream<T>(
    String collection,
    T Function(DocumentSnapshot) fromSnapshot,
    {Query Function(Query)? queryBuilder}
  ) {
    try {
      Query query = FirebaseFirestore.instance.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return fromSnapshot(doc);
              } catch (e) {
                if (kDebugMode) {
                  print("🔥 Error parsing document ${doc.id} in $collection: $e");
                }
                return null;
              }
            })
            .where((item) => item != null)
            .cast<T>()
            .toList();
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("🔥 Firestore collection stream error ($collection): $e");
        print("Stack trace: $stackTrace");
      }
      // Return empty stream instead of throwing
      return Stream.value(<T>[]);
    }
  }
}