import '/flutter_flow/flutter_flow_util.dart';
import 'book_trip_widget.dart' show BookTripWidget;
import 'package:flutter/material.dart';

class BookTripModel extends FlutterFlowModel<BookTripWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for travelerCount widget.
  FocusNode? travelerCountFocusNode;
  TextEditingController? travelerCountTextController;

  // State field(s) for travelerNames widget.
  FocusNode? travelerNamesFocusNode;
  TextEditingController? travelerNamesTextController;

  // State field(s) for specialRequests widget.
  FocusNode? specialRequestsFocusNode;
  TextEditingController? specialRequestsTextController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    travelerCountFocusNode?.dispose();
    travelerCountTextController?.dispose();

    travelerNamesFocusNode?.dispose();
    travelerNamesTextController?.dispose();

    specialRequestsFocusNode?.dispose();
    specialRequestsTextController?.dispose();
  }
}
