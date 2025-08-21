import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'edit_trip_widget.dart' show EditTripWidget;
import 'package:flutter/material.dart';

class EditTripModel extends FlutterFlowModel<EditTripWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  // State field(s) for TextField widget.
  FocusNode? titleFocusNode;
  TextEditingController? titleController;
  String? Function(BuildContext, String?)? titleControllerValidator;

  // State field(s) for TextField widget.
  FocusNode? locationFocusNode;
  TextEditingController? locationController;
  String? Function(BuildContext, String?)? locationControllerValidator;

  // State field(s) for TextField widget.
  FocusNode? priceFocusNode;
  TextEditingController? priceController;
  String? Function(BuildContext, String?)? priceControllerValidator;

  // State field(s) for TextField widget.
  FocusNode? quantityFocusNode;
  TextEditingController? quantityController;
  String? Function(BuildContext, String?)? quantityControllerValidator;

  // State field(s) for TextField widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionController;
  String? Function(BuildContext, String?)? descriptionControllerValidator;

  // State field(s) for TextField widget.
  FocusNode? imageFocusNode;
  TextEditingController? imageController;
  String? Function(BuildContext, String?)? imageControllerValidator;

  // State field(s) for Itinerary (multiple days)
  List<TextEditingController> itineraryControllers = [];
  List<FocusNode> itineraryFocusNodes = [];

  // State field(s) for DateTime picker
  DateTime? startDatePicked;
  DateTime? endDatePicked;

  bool isLoading = false;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    titleFocusNode?.dispose();
    titleController?.dispose();

    locationFocusNode?.dispose();
    locationController?.dispose();

    priceFocusNode?.dispose();
    priceController?.dispose();

    quantityFocusNode?.dispose();
    quantityController?.dispose();

    descriptionFocusNode?.dispose();
    descriptionController?.dispose();

    imageFocusNode?.dispose();
    imageController?.dispose();

    // Dispose itinerary controllers and focus nodes
    for (var controller in itineraryControllers) {
      controller.dispose();
    }
    for (var focusNode in itineraryFocusNodes) {
      focusNode.dispose();
    }
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}