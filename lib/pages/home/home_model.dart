import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for search fields
  FocusNode? destinationFocusNode;
  TextEditingController? destinationController;
  String? Function(BuildContext, String?)? destinationControllerValidator;
  
  FocusNode? monthFocusNode;
  TextEditingController? monthController;
  String? Function(BuildContext, String?)? monthControllerValidator;
  DateTime? selectedDate;
  
  FocusNode? travelersFocusNode;
  TextEditingController? travelersController;
  String? Function(BuildContext, String?)? travelersControllerValidator;
  int travelers = 1;
  
  FocusNode? budgetFocusNode;
  TextEditingController? budgetController;
  String? Function(BuildContext, String?)? budgetControllerValidator;
  String selectedBudget = 'Any Budget';

  // State field(s) for TextField widget (keeping for compatibility)
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {
    destinationController ??= TextEditingController();
    monthController ??= TextEditingController(text: 'Any Month');
    travelersController ??= TextEditingController(text: '1 Traveler');
    budgetController ??= TextEditingController(text: 'Any Budget');
  }

  @override
  void dispose() {
    destinationFocusNode?.dispose();
    destinationController?.dispose();
    monthFocusNode?.dispose();
    monthController?.dispose();
    travelersFocusNode?.dispose();
    travelersController?.dispose();
    budgetFocusNode?.dispose();
    budgetController?.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
