import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AgenciesRecord extends FirestoreRecord {
  AgenciesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "logo" field.
  String? _logo;
  String get logo => _logo ?? '';
  bool hasLogo() => _logo != null;

  // "contact_email" field.
  String? _contactEmail;
  String get contactEmail => _contactEmail ?? '';
  bool hasContactEmail() => _contactEmail != null;

  // "contact_phone" field.
  String? _contactPhone;
  String get contactPhone => _contactPhone ?? '';
  bool hasContactPhone() => _contactPhone != null;

  // "website" field.
  String? _website;
  String get website => _website ?? '';
  bool hasWebsite() => _website != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "rating" field.
  double? _rating;
  double get rating => _rating ?? 0.0;
  bool hasRating() => _rating != null;

  // "total_trips" field.
  int? _totalTrips;
  int get totalTrips => _totalTrips ?? 0;
  bool hasTotalTrips() => _totalTrips != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _description = snapshotData['description'] as String?;
    _logo = snapshotData['logo'] as String?;
    _contactEmail = snapshotData['contact_email'] as String?;
    _contactPhone = snapshotData['contact_phone'] as String?;
    _website = snapshotData['website'] as String?;
    _location = snapshotData['location'] as String?;
    _rating = castToType<double>(snapshotData['rating']);
    _totalTrips = castToType<int>(snapshotData['total_trips']);
    _createdAt = snapshotData['created_at'] is Timestamp
        ? (snapshotData['created_at'] as Timestamp).toDate()
        : snapshotData['created_at'] as DateTime?;
    _status = snapshotData['status'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('agency');

  static Stream<AgenciesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AgenciesRecord.fromSnapshot(s));

  static Future<AgenciesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AgenciesRecord.fromSnapshot(s));

  static AgenciesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AgenciesRecord._(
        snapshot.reference,
        snapshot.data() as Map<String, dynamic>,
      );

  static AgenciesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AgenciesRecord._(reference, data);

  @override
  String toString() =>
      'AgenciesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AgenciesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAgenciesRecordData({
  String? name,
  String? description,
  String? logo,
  String? contactEmail,
  String? contactPhone,
  String? website,
  String? location,
  double? rating,
  int? totalTrips,
  DateTime? createdAt,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'description': description,
      'logo': logo,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'website': website,
      'location': location,
      'rating': rating,
      'total_trips': totalTrips,
      'created_at': createdAt,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class AgenciesRecordDocumentEquality implements Equality<AgenciesRecord> {
  const AgenciesRecordDocumentEquality();

  @override
  bool equals(AgenciesRecord? e1, AgenciesRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.description == e2?.description &&
        e1?.logo == e2?.logo &&
        e1?.contactEmail == e2?.contactEmail &&
        e1?.contactPhone == e2?.contactPhone &&
        e1?.website == e2?.website &&
        e1?.location == e2?.location &&
        e1?.rating == e2?.rating &&
        e1?.totalTrips == e2?.totalTrips &&
        e1?.createdAt == e2?.createdAt &&
        e1?.status == e2?.status;
  }

  @override
  int hash(AgenciesRecord? e) => const ListEquality().hash([
        e?.name,
        e?.description,
        e?.logo,
        e?.contactEmail,
        e?.contactPhone,
        e?.website,
        e?.location,
        e?.rating,
        e?.totalTrips,
        e?.createdAt,
        e?.status
      ]);

  @override
  bool isValidKey(Object? o) => o is AgenciesRecord;
}
