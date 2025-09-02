import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TripsRecord extends FirestoreRecord {
  TripsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "specifications" field.
  String? _specifications;
  String get specifications => _specifications ?? '';
  bool hasSpecifications() => _specifications != null;

  // "itenarary" field.
  List<String>? _itenarary;
  List<String> get itenarary => _itenarary ?? const [];
  bool hasItenarary() => _itenarary != null;

  // "price" field.
  int? _price;
  int get price => _price ?? 0;
  bool hasPrice() => _price != null;
  
  // Canonical EGP price - backward compatible
  double get priceEGP => (_price ?? 0).toDouble();

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "modified_at" field.
  DateTime? _modifiedAt;
  DateTime? get modifiedAt => _modifiedAt;
  bool hasModifiedAt() => _modifiedAt != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "start_date" field.
  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  bool hasStartDate() => _startDate != null;

  // "end_date" field.
  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  bool hasEndDate() => _endDate != null;

  // "available_seats" field.
  int? _availableSeats;
  int get availableSeats => _availableSeats ?? 0;
  bool hasAvailableSeats() => _availableSeats != null;

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  bool hasImage() => _image != null;
  
  // "imageUrl" field.
  String get imageUrl => _image ?? '';
  
  // "gallery" field.
  List<String>? _gallery;
  List<String> get gallery => _gallery ?? const [];
  bool hasGallery() => _gallery != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "location" field.
  String? _location;
  String get location => _location ?? '';
  bool hasLocation() => _location != null;

  // "agency_reference" field.
  DocumentReference? _agencyReference;
  DocumentReference? get agencyReference => _agencyReference;
  bool hasAgencyReference() => _agencyReference != null;

  // "rating" field.
  double? _rating;
  double get rating => _rating ?? 0.0;
  bool hasRating() => _rating != null;

  // "rating_avg" field.
  double? _ratingAvg;
  double get ratingAvg => _ratingAvg ?? 0.0;
  bool hasRatingAvg() => _ratingAvg != null;

  // "rating_count" field.
  int? _ratingCount;
  int get ratingCount => _ratingCount ?? 0;
  bool hasRatingCount() => _ratingCount != null;

  // "payment_instructions" field.
  String? _paymentInstructions;
  String get paymentInstructions => _paymentInstructions ?? '';
  bool hasPaymentInstructions() => _paymentInstructions != null;

  // "itinerary_pdf" field.
  String? _itineraryPdf;
  String get itineraryPdf => _itineraryPdf ?? '';
  bool hasItineraryPdf() => _itineraryPdf != null;

  void _initializeFields() {
    _specifications = snapshotData['specifications'] as String?;
    _itenarary = getDataList(snapshotData['itenarary']);
    _price = castToType<int>(snapshotData['price']);
    _createdAt = snapshotData['created_at'] as DateTime?;
    _modifiedAt = snapshotData['modified_at'] as DateTime?;
    _quantity = castToType<int>(snapshotData['quantity']);
    _startDate = snapshotData['start_date'] as DateTime?;
    _endDate = snapshotData['end_date'] as DateTime?;
    _availableSeats = castToType<int>(snapshotData['available_seats']);
    _image = snapshotData['image'] as String?;
    _gallery = getDataList(snapshotData['gallery']);
    _description = snapshotData['description'] as String?;
    _title = snapshotData['title'] as String?;
    _location = snapshotData['location'] as String?;
    _agencyReference = snapshotData['agency_reference'] as DocumentReference?;
    _rating = castToType<double>(snapshotData['rating']);
    _ratingAvg = castToType<double>(snapshotData['rating_avg']);
    _ratingCount = castToType<int>(snapshotData['rating_count']);
    _paymentInstructions = snapshotData['payment_instructions'] as String?;
    _itineraryPdf = snapshotData['itinerary_pdf'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('trips');

  static Stream<TripsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TripsRecord.fromSnapshot(s));

  static Future<TripsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TripsRecord.fromSnapshot(s));

  static TripsRecord fromSnapshot(DocumentSnapshot snapshot) => TripsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TripsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TripsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TripsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TripsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTripsRecordData({
  String? name,
  String? specifications,
  List<String>? itenarary,
  int? price,
  DateTime? createdAt,
  DateTime? modifiedAt,
  bool? onSale,
  double? salePrice,
  int? quantity,
  DateTime? startDate,
  DateTime? endDate,
  int? availableSeats,
  String? image,
  List<String>? gallery,
  String? description,
  String? title,
  String? location,
  DocumentReference? agencyReference,
  double? rating,
  double? ratingAvg,
  int? ratingCount,
  String? paymentInstructions,
  String? itineraryPdf,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'specifications': specifications,
      'itenarary': itenarary,
      'price': price,
      'created_at': createdAt,
      'modified_at': modifiedAt,
      'on_sale': onSale,
      'sale_price': salePrice,
      'quantity': quantity,
      'start_date': startDate,
      'end_date': endDate,
      'available_seats': availableSeats,
      'image': image,
      'gallery': gallery,
      'description': description,
      'title': title,
      'location': location,
      'agency_reference': agencyReference,
      'rating': rating,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
      'payment_instructions': paymentInstructions,
      'itinerary_pdf': itineraryPdf,
    }.withoutNulls,
  );

  return firestoreData;
}

class TripsRecordDocumentEquality implements Equality<TripsRecord> {
  const TripsRecordDocumentEquality();

  @override
  bool equals(TripsRecord? e1, TripsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.specifications == e2?.specifications &&
        listEquality.equals(e1?.itenarary, e2?.itenarary) &&
        e1?.price == e2?.price &&
        e1?.createdAt == e2?.createdAt &&
        e1?.modifiedAt == e2?.modifiedAt &&
        e1?.quantity == e2?.quantity &&
        e1?.startDate == e2?.startDate &&
        e1?.endDate == e2?.endDate &&
        e1?.availableSeats == e2?.availableSeats &&
        e1?.image == e2?.image &&
        listEquality.equals(e1?.gallery, e2?.gallery) &&
        e1?.description == e2?.description &&
        e1?.title == e2?.title &&
        e1?.location == e2?.location &&
        e1?.agencyReference == e2?.agencyReference &&
        e1?.rating == e2?.rating &&
        e1?.ratingAvg == e2?.ratingAvg &&
        e1?.ratingCount == e2?.ratingCount &&
        e1?.paymentInstructions == e2?.paymentInstructions &&
        e1?.itineraryPdf == e2?.itineraryPdf;
  }

  @override
  int hash(TripsRecord? e) => const ListEquality().hash([
        e?.specifications,
        e?.itenarary,
        e?.price,
        e?.createdAt,
        e?.modifiedAt,
        e?.quantity,
        e?.startDate,
        e?.endDate,
        e?.availableSeats,
        e?.image,
        e?.gallery,
        e?.description,
        e?.title,
        e?.location,
        e?.agencyReference,
        e?.rating,
        e?.ratingAvg,
        e?.ratingCount,
        e?.paymentInstructions,
        e?.itineraryPdf
      ]);

  @override
  bool isValidKey(Object? o) => o is TripsRecord;
}
