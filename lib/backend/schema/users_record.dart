import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "role" field.
  List<String>? _role;
  List<String> get role => _role ?? const [];
  bool hasRole() => _role != null;

  // "agency_reference" field.
  DocumentReference? _agencyReference;
  DocumentReference? get agencyReference => _agencyReference;
  bool hasAgencyReference() => _agencyReference != null;

  // "loyaltyPoints" field.
  int? _loyaltyPoints;
  int get loyaltyPoints => _loyaltyPoints ?? 0;
  bool hasLoyaltyPoints() => _loyaltyPoints != null;

  // "nationalIdUrl" field.
  String? _nationalIdUrl;
  String get nationalIdUrl => _nationalIdUrl ?? '';
  bool hasNationalIdUrl() => _nationalIdUrl != null;

  // "nationalIdUploadedAt" field.
  DateTime? _nationalIdUploadedAt;
  DateTime? get nationalIdUploadedAt => _nationalIdUploadedAt;
  bool hasNationalIdUploadedAt() => _nationalIdUploadedAt != null;

  // "nationalIdStatus" field.
  String? _nationalIdStatus;
  String get nationalIdStatus => _nationalIdStatus ?? 'missing';
  bool hasNationalIdStatus() => _nationalIdStatus != null;

  void _initializeFields() {
    _createdAt = snapshotData['created_at'] as DateTime?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _email = snapshotData['email'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _name = snapshotData['name'] as String?;
    _role = getDataList(snapshotData['role']);
    // Handle both string and DocumentReference formats for agency_reference
    final agencyRefData = snapshotData['agency_reference'];
    if (agencyRefData is String && agencyRefData.isNotEmpty) {
      // Convert string path to DocumentReference
      _agencyReference = FirebaseFirestore.instance.doc(agencyRefData);
    } else if (agencyRefData is DocumentReference) {
      // Already a DocumentReference
      _agencyReference = agencyRefData;
    } else {
      _agencyReference = null;
    }
    _loyaltyPoints = castToType<int>(snapshotData['loyaltyPoints']);
    _nationalIdUrl = snapshotData['nationalIdUrl'] as String?;
    _nationalIdUploadedAt = snapshotData['nationalIdUploadedAt'] as DateTime?;
    _nationalIdStatus = snapshotData['nationalIdStatus'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  DateTime? createdAt,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? email,
  String? phoneNumber,
  String? name,
  DocumentReference? agencyReference,
  int? loyaltyPoints,
  String? nationalIdUrl,
  DateTime? nationalIdUploadedAt,
  String? nationalIdStatus,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'created_at': createdAt,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'email': email,
      'phone_number': phoneNumber,
      'name': name,
      'agency_reference': agencyReference,
      'loyaltyPoints': loyaltyPoints,
      'nationalIdUrl': nationalIdUrl,
      'nationalIdUploadedAt': nationalIdUploadedAt,
      'nationalIdStatus': nationalIdStatus,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.createdAt == e2?.createdAt &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.email == e2?.email &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.name == e2?.name &&
        listEquality.equals(e1?.role, e2?.role) &&
        e1?.agencyReference == e2?.agencyReference &&
        e1?.loyaltyPoints == e2?.loyaltyPoints &&
        e1?.nationalIdUrl == e2?.nationalIdUrl &&
        e1?.nationalIdUploadedAt == e2?.nationalIdUploadedAt &&
        e1?.nationalIdStatus == e2?.nationalIdStatus;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.createdAt,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.email,
        e?.phoneNumber,
        e?.name,
        e?.role,
        e?.agencyReference,
        e?.loyaltyPoints,
        e?.nationalIdUrl,
        e?.nationalIdUploadedAt,
        e?.nationalIdStatus
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
