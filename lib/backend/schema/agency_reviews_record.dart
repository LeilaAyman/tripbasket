import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AgencyReviewsRecord extends FirestoreRecord {
  AgencyReviewsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "agency_reference" field.
  DocumentReference? _agencyReference;
  DocumentReference? get agencyReference => _agencyReference;
  bool hasAgencyReference() => _agencyReference != null;

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

  // "agency_name" field.
  String? _agencyName;
  String get agencyName => _agencyName ?? '';
  bool hasAgencyName() => _agencyName != null;

  // "service_quality" field.
  double? _serviceQuality;
  double get serviceQuality => _serviceQuality ?? 0.0;
  bool hasServiceQuality() => _serviceQuality != null;

  // "communication" field.
  double? _communication;
  double get communication => _communication ?? 0.0;
  bool hasCommunication() => _communication != null;

  // "value_for_money" field.
  double? _valueForMoney;
  double get valueForMoney => _valueForMoney ?? 0.0;
  bool hasValueForMoney() => _valueForMoney != null;

  void _initializeFields() {
    _agencyReference = snapshotData['agency_reference'] as DocumentReference?;
    _userReference = snapshotData['user_reference'] as DocumentReference?;
    _userName = snapshotData['user_name'] as String?;
    _userPhoto = snapshotData['user_photo'] as String?;
    _rating = castToType<double>(snapshotData['rating']);
    _comment = snapshotData['comment'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _helpfulCount = castToType<int>(snapshotData['helpful_count']);
    _agencyName = snapshotData['agency_name'] as String?;
    _serviceQuality = castToType<double>(snapshotData['service_quality']);
    _communication = castToType<double>(snapshotData['communication']);
    _valueForMoney = castToType<double>(snapshotData['value_for_money']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('agency_reviews');

  static Stream<AgencyReviewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AgencyReviewsRecord.fromSnapshot(s));

  static Future<AgencyReviewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AgencyReviewsRecord.fromSnapshot(s));

  static AgencyReviewsRecord fromSnapshot(DocumentSnapshot snapshot) => AgencyReviewsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AgencyReviewsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AgencyReviewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AgencyReviewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AgencyReviewsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAgencyReviewsRecordData({
  DocumentReference? agencyReference,
  DocumentReference? userReference,
  String? userName,
  String? userPhoto,
  double? rating,
  String? comment,
  DateTime? createdAt,
  int? helpfulCount,
  String? agencyName,
  double? serviceQuality,
  double? communication,
  double? valueForMoney,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'agency_reference': agencyReference,
      'user_reference': userReference,
      'user_name': userName,
      'user_photo': userPhoto,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'helpful_count': helpfulCount,
      'agency_name': agencyName,
      'service_quality': serviceQuality,
      'communication': communication,
      'value_for_money': valueForMoney,
    }.withoutNulls,
  );

  return firestoreData;
}

class AgencyReviewsRecordDocumentEquality implements Equality<AgencyReviewsRecord> {
  const AgencyReviewsRecordDocumentEquality();

  @override
  bool equals(AgencyReviewsRecord? e1, AgencyReviewsRecord? e2) {
    return e1?.agencyReference == e2?.agencyReference &&
        e1?.userReference == e2?.userReference &&
        e1?.userName == e2?.userName &&
        e1?.userPhoto == e2?.userPhoto &&
        e1?.rating == e2?.rating &&
        e1?.comment == e2?.comment &&
        e1?.createdAt == e2?.createdAt &&
        e1?.helpfulCount == e2?.helpfulCount &&
        e1?.agencyName == e2?.agencyName &&
        e1?.serviceQuality == e2?.serviceQuality &&
        e1?.communication == e2?.communication &&
        e1?.valueForMoney == e2?.valueForMoney;
  }

  @override
  int hash(AgencyReviewsRecord? e) => const ListEquality().hash([
        e?.agencyReference,
        e?.userReference,
        e?.userName,
        e?.userPhoto,
        e?.rating,
        e?.comment,
        e?.createdAt,
        e?.helpfulCount,
        e?.agencyName,
        e?.serviceQuality,
        e?.communication,
        e?.valueForMoney
      ]);

  @override
  bool isValidKey(Object? o) => o is AgencyReviewsRecord;
}
