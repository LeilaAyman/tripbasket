import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'create_trip_widget.dart' show CreateTripWidget;
import 'package:flutter/material.dart';

class CreateTripModel extends FlutterFlowModel<CreateTripWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for title widget.
  FocusNode? titleFocusNode;
  TextEditingController? titleTextController;
  String? Function(BuildContext, String?)? titleTextControllerValidator;

  // State field(s) for location widget.
  FocusNode? locationFocusNode;
  TextEditingController? locationTextController;
  String? Function(BuildContext, String?)? locationTextControllerValidator;

  // State field(s) for price widget.
  FocusNode? priceFocusNode;
  TextEditingController? priceTextController;
  String? Function(BuildContext, String?)? priceTextControllerValidator;

  // State field(s) for availableSeats widget.
  FocusNode? availableSeatsFocusNode;
  TextEditingController? availableSeatsTextController;
  String? Function(BuildContext, String?)? availableSeatsTextControllerValidator;

  // State field(s) for imageUrl widget.
  FocusNode? imageUrlFocusNode;
  TextEditingController? imageUrlTextController;
  String? Function(BuildContext, String?)? imageUrlTextControllerValidator;

  // State field(s) for description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;

  // State field(s) for itinerary widget.
  FocusNode? itineraryFocusNode;
  TextEditingController? itineraryTextController;
  String? Function(BuildContext, String?)? itineraryTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    titleFocusNode?.dispose();
    titleTextController?.dispose();

    locationFocusNode?.dispose();
    locationTextController?.dispose();

    priceFocusNode?.dispose();
    priceTextController?.dispose();

    availableSeatsFocusNode?.dispose();
    availableSeatsTextController?.dispose();

    imageUrlFocusNode?.dispose();
    imageUrlTextController?.dispose();

    descriptionFocusNode?.dispose();
    descriptionTextController?.dispose();

    itineraryFocusNode?.dispose();
    itineraryTextController?.dispose();
  }
}
