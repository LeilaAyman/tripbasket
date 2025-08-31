import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MessagesRecord extends FirestoreRecord {
  MessagesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "from" field.
  DocumentReference? _from;
  DocumentReference? get from => _from;
  bool hasFrom() => _from != null;

  // "to" field.
  DocumentReference? _to;
  DocumentReference? get to => _to;
  bool hasTo() => _to != null;

  // "trip_reference" field.
  DocumentReference? _tripReference;
  DocumentReference? get tripReference => _tripReference;
  bool hasTripReference() => _tripReference != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "message_type" field (customer_to_agency, agency_to_customer, customer_to_admin, admin_to_customer)
  String? _messageType;
  String get messageType => _messageType ?? '';
  bool hasMessageType() => _messageType != null;

  // "read_status" field.
  bool? _readStatus;
  bool get readStatus => _readStatus ?? false;
  bool hasReadStatus() => _readStatus != null;

  // "agency_reference" field - for routing messages to specific agencies
  DocumentReference? _agencyReference;
  DocumentReference? get agencyReference => _agencyReference;
  bool hasAgencyReference() => _agencyReference != null;

  void _initializeFields() {
    _from = snapshotData['from'] as DocumentReference?;
    _to = snapshotData['to'] as DocumentReference?;
    _tripReference = snapshotData['trip_reference'] as DocumentReference?;
    _content = snapshotData['content'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _messageType = snapshotData['message_type'] as String?;
    _readStatus = snapshotData['read_status'] as bool?;
    _agencyReference = snapshotData['agency_reference'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('messages');

  static Stream<MessagesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MessagesRecord.fromSnapshot(s));

  static Future<MessagesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MessagesRecord.fromSnapshot(s));

  static MessagesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MessagesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MessagesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MessagesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MessagesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MessagesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMessagesRecordData({
  DocumentReference? from,
  DocumentReference? to,
  DocumentReference? tripReference,
  String? content,
  DateTime? timestamp,
  String? messageType,
  bool? readStatus,
  DocumentReference? agencyReference,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'from': from,
      'to': to,
      'trip_reference': tripReference,
      'content': content,
      'timestamp': timestamp,
      'message_type': messageType,
      'read_status': readStatus,
      'agency_reference': agencyReference,
    }.withoutNulls,
  );

  return firestoreData;
}

class MessagesRecordDocumentEquality implements Equality<MessagesRecord> {
  const MessagesRecordDocumentEquality();

  @override
  bool equals(MessagesRecord? e1, MessagesRecord? e2) {
    return e1?.from == e2?.from &&
        e1?.to == e2?.to &&
        e1?.tripReference == e2?.tripReference &&
        e1?.content == e2?.content &&
        e1?.timestamp == e2?.timestamp &&
        e1?.messageType == e2?.messageType &&
        e1?.readStatus == e2?.readStatus &&
        e1?.agencyReference == e2?.agencyReference;
  }

  @override
  int hash(MessagesRecord? e) => const ListEquality().hash([
        e?.from,
        e?.to,
        e?.tripReference,
        e?.content,
        e?.timestamp,
        e?.messageType,
        e?.readStatus,
        e?.agencyReference,
      ]);

  @override
  bool isValidKey(Object? o) => o is MessagesRecord;
}