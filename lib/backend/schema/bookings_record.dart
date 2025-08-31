import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BookingsRecord extends FirestoreRecord {
  BookingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_reference" field.
  DocumentReference? _userReference;
  DocumentReference? get userReference => _userReference;
  bool hasUserReference() => _userReference != null;

  // "trip_reference" field.
  DocumentReference? _tripReference;
  DocumentReference? get tripReference => _tripReference;
  bool hasTripReference() => _tripReference != null;

  // "agency_reference" field.
  DocumentReference? _agencyReference;
  DocumentReference? get agencyReference => _agencyReference;
  bool hasAgencyReference() => _agencyReference != null;

  // "trip_title" field.
  String? _tripTitle;
  String get tripTitle => _tripTitle ?? '';
  bool hasTripTitle() => _tripTitle != null;

  // "trip_price" field.
  double? _tripPrice;
  double get tripPrice => _tripPrice ?? 0.0;
  bool hasTripPrice() => _tripPrice != null;

  // "total_amount" field.
  double? _totalAmount;
  double get totalAmount => _totalAmount ?? 0.0;
  bool hasTotalAmount() => _totalAmount != null;

  // EGP price fields for currency consistency
  double? _unitPriceEGP;
  double get unitPriceEGP => _unitPriceEGP ?? _tripPrice ?? 0.0;
  bool hasUnitPriceEGP() => _unitPriceEGP != null;

  double? _lineTotalEGP;
  double get lineTotalEGP => _lineTotalEGP ?? _totalAmount ?? 0.0;
  bool hasLineTotalEGP() => _lineTotalEGP != null;

  // "booking_date" field.
  DateTime? _bookingDate;
  DateTime? get bookingDate => _bookingDate;
  bool hasBookingDate() => _bookingDate != null;

  // "payment_status" field.
  String? _paymentStatus;
  String get paymentStatus => _paymentStatus ?? '';
  bool hasPaymentStatus() => _paymentStatus != null;

  // "payment_method" field.
  String? _paymentMethod;
  String get paymentMethod => _paymentMethod ?? '';
  bool hasPaymentMethod() => _paymentMethod != null;

  // "booking_status" field.
  String? _bookingStatus;
  String get bookingStatus => _bookingStatus ?? '';
  bool hasBookingStatus() => _bookingStatus != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "payment_transaction_id" field.
  String? _paymentTransactionId;
  String get paymentTransactionId => _paymentTransactionId ?? '';
  bool hasPaymentTransactionId() => _paymentTransactionId != null;

  // "merchant_order_id" field.
  String? _merchantOrderId;
  String get merchantOrderId => _merchantOrderId ?? '';
  bool hasMerchantOrderId() => _merchantOrderId != null;

  // "traveler_count" field.
  int? _travelerCount;
  int get travelerCount => _travelerCount ?? 1;
  bool hasTravelerCount() => _travelerCount != null;

  // "traveler_names" field.
  List<String>? _travelerNames;
  List<String> get travelerNames => _travelerNames ?? const [];
  bool hasTravelerNames() => _travelerNames != null;

  // "special_requests" field.
  String? _specialRequests;
  String get specialRequests => _specialRequests ?? '';
  bool hasSpecialRequests() => _specialRequests != null;

  void _initializeFields() {
    _userReference = snapshotData['user_reference'] as DocumentReference?;
    _tripReference = snapshotData['trip_reference'] as DocumentReference?;
    _agencyReference = snapshotData['agency_reference'] as DocumentReference?;
    _tripTitle = snapshotData['trip_title'] as String?;
    _tripPrice = castToType<double>(snapshotData['trip_price']);
    _totalAmount = castToType<double>(snapshotData['total_amount']);
    _bookingDate = snapshotData['booking_date'] as DateTime?;
    _paymentStatus = snapshotData['payment_status'] as String?;
    _paymentMethod = snapshotData['payment_method'] as String?;
    _bookingStatus = snapshotData['booking_status'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _paymentTransactionId = snapshotData['payment_transaction_id'] as String?;
    _merchantOrderId = snapshotData['merchant_order_id'] as String?;
    _travelerCount = castToType<int>(snapshotData['traveler_count']);
    _travelerNames = getDataList(snapshotData['traveler_names']);
    _specialRequests = snapshotData['special_requests'] as String?;
    _unitPriceEGP = castToType<double>(snapshotData['unitPriceEGP']);
    _lineTotalEGP = castToType<double>(snapshotData['lineTotalEGP']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('bookings');

  static Stream<BookingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => BookingsRecord.fromSnapshot(s));

  static Future<BookingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => BookingsRecord.fromSnapshot(s));

  static BookingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      BookingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static BookingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      BookingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'BookingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is BookingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createBookingsRecordData({
  DocumentReference? userReference,
  DocumentReference? tripReference,
  DocumentReference? agencyReference,
  String? tripTitle,
  double? tripPrice,
  double? totalAmount,
  DateTime? bookingDate,
  String? paymentStatus,
  String? paymentMethod,
  String? bookingStatus,
  DateTime? createdAt,
  String? paymentTransactionId,
  String? merchantOrderId,
  int? travelerCount,
  String? specialRequests,
  double? unitPriceEGP,
  double? lineTotalEGP,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_reference': userReference,
      'trip_reference': tripReference,
      'agency_reference': agencyReference,
      'trip_title': tripTitle,
      'trip_price': tripPrice,
      'total_amount': totalAmount,
      'booking_date': bookingDate,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'booking_status': bookingStatus,
      'created_at': createdAt,
      'payment_transaction_id': paymentTransactionId,
      'merchant_order_id': merchantOrderId,
      'traveler_count': travelerCount,
      'special_requests': specialRequests,
      'unitPriceEGP': unitPriceEGP,
      'lineTotalEGP': lineTotalEGP,
    }.withoutNulls,
  );

  return firestoreData;
}

class BookingsRecordDocumentEquality implements Equality<BookingsRecord> {
  const BookingsRecordDocumentEquality();

  @override
  bool equals(BookingsRecord? e1, BookingsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userReference == e2?.userReference &&
        e1?.tripReference == e2?.tripReference &&
        e1?.agencyReference == e2?.agencyReference &&
        e1?.tripTitle == e2?.tripTitle &&
        e1?.tripPrice == e2?.tripPrice &&
        e1?.totalAmount == e2?.totalAmount &&
        e1?.bookingDate == e2?.bookingDate &&
        e1?.paymentStatus == e2?.paymentStatus &&
        e1?.paymentMethod == e2?.paymentMethod &&
        e1?.bookingStatus == e2?.bookingStatus &&
        e1?.createdAt == e2?.createdAt &&
        e1?.paymentTransactionId == e2?.paymentTransactionId &&
        e1?.merchantOrderId == e2?.merchantOrderId &&
        e1?.travelerCount == e2?.travelerCount &&
        listEquality.equals(e1?.travelerNames, e2?.travelerNames) &&
        e1?.specialRequests == e2?.specialRequests;
  }

  @override
  int hash(BookingsRecord? e) => const ListEquality().hash([
        e?.userReference,
        e?.tripReference,
        e?.agencyReference,
        e?.tripTitle,
        e?.tripPrice,
        e?.totalAmount,
        e?.bookingDate,
        e?.paymentStatus,
        e?.paymentMethod,
        e?.bookingStatus,
        e?.createdAt,
        e?.paymentTransactionId,
        e?.merchantOrderId,
        e?.travelerCount,
        e?.travelerNames,
        e?.specialRequests
      ]);

  @override
  bool isValidKey(Object? o) => o is BookingsRecord;
}
