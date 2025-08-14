import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CartRecord extends FirestoreRecord {
  CartRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "tripReference" field.
  DocumentReference? _tripReference;
  DocumentReference? get tripReference => _tripReference;
  bool hasTripReference() => _tripReference != null;

  // "userReference" field.
  DocumentReference? _userReference;
  DocumentReference? get userReference => _userReference;
  bool hasUserReference() => _userReference != null;

  // "addedAt" field.
  DateTime? _addedAt;
  DateTime? get addedAt => _addedAt;
  bool hasAddedAt() => _addedAt != null;

  // "status" field.
  String? _status;
  String get status => _status ?? 'pending';
  bool hasStatus() => _status != null;

  // "travelers" field.
  int? _travelers;
  int get travelers => _travelers ?? 1;
  bool hasTravelers() => _travelers != null;

  // "totalPrice" field.
  double? _totalPrice;
  double get totalPrice => _totalPrice ?? 0.0;
  bool hasTotalPrice() => _totalPrice != null;

  // "requiresAdditionalPaperwork" field.
  bool? _requiresAdditionalPaperwork;
  bool get requiresAdditionalPaperwork => _requiresAdditionalPaperwork ?? false;
  bool hasRequiresAdditionalPaperwork() => _requiresAdditionalPaperwork != null;

  // "tripName" field.
  String? _tripName;
  String get tripName => _tripName ?? '';
  bool hasTripName() => _tripName != null;

  // "tripImage" field.
  String? _tripImage;
  String get tripImage => _tripImage ?? '';
  bool hasTripImage() => _tripImage != null;

  void _initializeFields() {
    _tripReference = snapshotData['tripReference'] as DocumentReference?;
    _userReference = snapshotData['userReference'] as DocumentReference?;
    _addedAt = snapshotData['addedAt'] as DateTime?;
    _status = snapshotData['status'] as String?;
    _travelers = castToType<int>(snapshotData['travelers']);
    _totalPrice = castToType<double>(snapshotData['totalPrice']);
    _requiresAdditionalPaperwork = snapshotData['requiresAdditionalPaperwork'] as bool?;
    _tripName = snapshotData['tripName'] as String?;
    _tripImage = snapshotData['tripImage'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('cart');

  static Stream<CartRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => CartRecord.fromSnapshot(s));

  static Future<CartRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => CartRecord.fromSnapshot(s));

  static CartRecord fromSnapshot(DocumentSnapshot snapshot) => CartRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static CartRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      CartRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'CartRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is CartRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createCartRecordData({
  DocumentReference? tripReference,
  DocumentReference? userReference,
  DateTime? addedAt,
  String? status,
  int? travelers,
  double? totalPrice,
  bool? requiresAdditionalPaperwork,
  String? tripName,
  String? tripImage,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'tripReference': tripReference,
      'userReference': userReference,
      'addedAt': addedAt,
      'status': status,
      'travelers': travelers,
      'totalPrice': totalPrice,
      'requiresAdditionalPaperwork': requiresAdditionalPaperwork,
      'tripName': tripName,
      'tripImage': tripImage,
    }.withoutNulls,
  );

  return firestoreData;
}

class CartRecordDocumentEquality implements Equality<CartRecord> {
  const CartRecordDocumentEquality();

  @override
  bool equals(CartRecord? e1, CartRecord? e2) {
    return e1?.tripReference == e2?.tripReference &&
        e1?.userReference == e2?.userReference &&
        e1?.addedAt == e2?.addedAt &&
        e1?.status == e2?.status &&
        e1?.travelers == e2?.travelers &&
        e1?.totalPrice == e2?.totalPrice &&
        e1?.requiresAdditionalPaperwork == e2?.requiresAdditionalPaperwork &&
        e1?.tripName == e2?.tripName &&
        e1?.tripImage == e2?.tripImage;
  }

  @override
  int hash(CartRecord? e) => const ListEquality().hash([
        e?.tripReference,
        e?.userReference,
        e?.addedAt,
        e?.status,
        e?.travelers,
        e?.totalPrice,
        e?.requiresAdditionalPaperwork,
        e?.tripName,
        e?.tripImage
      ]);

  @override
  bool isValidKey(Object? o) => o is CartRecord;
}
