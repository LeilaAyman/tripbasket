import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'edit_trip_widget.dart' show EditTripWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditTripModel extends FlutterFlowModel<EditTripWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  // State field(s) for TitleTextField widget.
  FocusNode? titleFocusNode;
  TextEditingController? titleTextController;
  String? Function(BuildContext, String?)? titleTextControllerValidator;

  // State field(s) for LocationTextField widget.
  FocusNode? locationFocusNode;
  TextEditingController? locationTextController;
  String? Function(BuildContext, String?)? locationTextControllerValidator;

  // State field(s) for PriceTextField widget.
  FocusNode? priceFocusNode;
  TextEditingController? priceTextController;
  String? Function(BuildContext, String?)? priceTextControllerValidator;

  // State field(s) for AvailableSeatsTextField widget.
  FocusNode? availableSeatsFocusNode;
  TextEditingController? availableSeatsTextController;
  String? Function(BuildContext, String?)? availableSeatsTextControllerValidator;

  // State field(s) for ImageUrlTextField widget.
  FocusNode? imageUrlFocusNode;
  TextEditingController? imageUrlTextController;
  String? Function(BuildContext, String?)? imageUrlTextControllerValidator;

  // State field(s) for DescriptionTextField widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionTextController;
  String? Function(BuildContext, String?)? descriptionTextControllerValidator;

  // State field(s) for ItineraryTextField widget.
  FocusNode? itineraryFocusNode;
  TextEditingController? itineraryTextController;
  String? Function(BuildContext, String?)? itineraryTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
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
