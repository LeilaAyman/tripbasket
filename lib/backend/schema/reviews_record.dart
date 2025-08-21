import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReviewsRecord extends FirestoreRecord {
  ReviewsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "trip_reference" field.
  DocumentReference? _tripReference;
  DocumentReference? get tripReference => _tripReference;
  bool hasTripReference() => _tripReference != null;

  // "user_reference" field.
  DocumentReference? _userReference;
  DocumentReference? get userReference => _userReference;
  bool hasUserReference() => _userReference != null;

  // "user_name" field.
  String? _userName;
  String get userName => _userName ?? '';
  bool hasUserName() => _userName != null;

  // "user_photo" field.
  String? _userPhoto;
  String get userPhoto => _userPhoto ?? '';
  bool hasUserPhoto() => _userPhoto != null;

  // "rating" field.
  double? _rating;
  double get rating => _rating ?? 0.0;
  bool hasRating() => _rating != null;

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  bool hasComment() => _comment != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "helpful_count" field.
  int? _helpfulCount;
  int get helpfulCount => _helpfulCount ?? 0;
  bool hasHelpfulCount() => _helpfulCount != null;

  // "trip_title" field.
  String? _tripTitle;
  String get tripTitle => _tripTitle ?? '';
  bool hasTripTitle() => _tripTitle != null;

  void _initializeFields() {
    _tripReference = snapshotData['trip_reference'] as DocumentReference?;
    _userReference = snapshotData['user_reference'] as DocumentReference?;
    _userName = snapshotData['user_name'] as String?;
    _userPhoto = snapshotData['user_photo'] as String?;
    _rating = castToType<double>(snapshotData['rating']);
    _comment = snapshotData['comment'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _helpfulCount = castToType<int>(snapshotData['helpful_count']);
    _tripTitle = snapshotData['trip_title'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('reviews');

  static Stream<ReviewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ReviewsRecord.fromSnapshot(s));

  static Future<ReviewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ReviewsRecord.fromSnapshot(s));

  static ReviewsRecord fromSnapshot(DocumentSnapshot snapshot) => ReviewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ReviewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ReviewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ReviewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ReviewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createReviewsRecordData({
  DocumentReference? tripReference,
  DocumentReference? userReference,
  String? userName,
  String? userPhoto,
  double? rating,
  String? comment,
  DateTime? createdAt,
  int? helpfulCount,
  String? tripTitle,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'trip_reference': tripReference,
      'user_reference': userReference,
      'user_name': userName,
      'user_photo': userPhoto,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'helpful_count': helpfulCount,
      'trip_title': tripTitle,
    }.withoutNulls,
  );

  return firestoreData;
}

class ReviewsRecordDocumentEquality implements Equality<ReviewsRecord> {
  const ReviewsRecordDocumentEquality();

  @override
  bool equals(ReviewsRecord? e1, ReviewsRecord? e2) {
    return e1?.tripReference == e2?.tripReference &&
        e1?.userReference == e2?.userReference &&
        e1?.userName == e2?.userName &&
        e1?.userPhoto == e2?.userPhoto &&
        e1?.rating == e2?.rating &&
        e1?.comment == e2?.comment &&
        e1?.createdAt == e2?.createdAt &&
        e1?.helpfulCount == e2?.helpfulCount &&
        e1?.tripTitle == e2?.tripTitle;
  }

  @override
  int hash(ReviewsRecord? e) => const ListEquality().hash([
        e?.tripReference,
        e?.userReference,
        e?.userName,
        e?.userPhoto,
        e?.rating,
        e?.comment,
        e?.createdAt,
        e?.helpfulCount,
        e?.tripTitle
      ]);

  @override
  bool isValidKey(Object? o) => o is ReviewsRecord;
}
