import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  static final _col = FirebaseFirestore.instance.collection('favorites');

  static String docIdFor(DocumentReference userRef, DocumentReference tripRef) =>
      '${userRef.id}_${tripRef.id}';

  static DocumentReference<Map<String, dynamic>> docFor(
    DocumentReference userRef,
    DocumentReference tripRef,
  ) => _col.doc(docIdFor(userRef, tripRef));

  static Stream<bool> isFavoriteStream(
    DocumentReference userRef,
    DocumentReference tripRef,
  ) => docFor(userRef, tripRef).snapshots().map((s) => s.exists);

  static Future<void> add(
    DocumentReference userRef,
    DocumentReference tripRef,
  ) async {
    final docId = docIdFor(userRef, tripRef);
    print('🔍 Adding favorite - Doc ID: $docId');
    print('🔍 Adding favorite - User: ${userRef.path}');
    print('🔍 Adding favorite - Trip: ${tripRef.path}');
    
    await docFor(userRef, tripRef).set({
      'user_reference': userRef,
      'trip_reference': tripRef,
      'created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    print('✅ Favorite added successfully');
  }

  static Future<void> remove(
    DocumentReference userRef,
    DocumentReference tripRef,
  ) async {
    await docFor(userRef, tripRef).delete();
  }

  static Query<Map<String, dynamic>> queryForUser(DocumentReference userRef) {
    print('🔍 Querying favorites for user: ${userRef.path}');
    return _col.where('user_reference', isEqualTo: userRef);
  }
}