import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'signup_widget.dart' show SignupWidget;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignupModel extends FlutterFlowModel<SignupWidget> {
  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for Phone Number TextField widget.
  FocusNode? phoneNumberFocusNode;
  TextEditingController? phoneNumberController;
  String? Function(BuildContext, String?)? phoneNumberControllerValidator;
  // State field(s) for Role DropDown widget
  String? roleValue;
  // State field(s) for Agency Reference DropDown widget
  DocumentReference? agencyReferenceValue;
  // State field(s) for Admin Key TextField widget
  FocusNode? adminKeyFocusNode;
  TextEditingController? adminKeyController;
  String? Function(BuildContext, String?)? adminKeyControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? passwordTextController;
  late bool passwordVisibility1;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? confirmPasswordTextController;
  late bool passwordVisibility2;
  String? Function(BuildContext, String?)?
      confirmPasswordTextControllerValidator;

    @override
  void initState(BuildContext context) {
    passwordVisibility1 = false;
    passwordVisibility2 = false;
    emailTextControllerValidator = _emailTextControllerValidator;
    phoneNumberControllerValidator = _phoneNumberControllerValidator;
    adminKeyControllerValidator = _adminKeyControllerValidator;
    passwordTextControllerValidator = _passwordTextControllerValidator;
    confirmPasswordTextControllerValidator =
        _confirmPasswordTextControllerValidator;
  }
  
  // Add validator functions
  String? _emailTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _phoneNumberControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Phone number is required';
    } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(val)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Password is required';
    } else if (val.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _confirmPasswordTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Please confirm your password';
    } else if (val != passwordTextController?.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _adminKeyControllerValidator(BuildContext context, String? val) {
    if (roleValue == 'admin') {
      if (val == null || val.isEmpty) {
        return 'Admin key is required for admin accounts';
      } else if (val != 'TRIPBASKET_ADMIN_2024') {
        return 'Invalid admin key';
      }
    }
    return null;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    emailTextController?.dispose();
    
    phoneNumberFocusNode?.dispose();
    phoneNumberController?.dispose();

    adminKeyFocusNode?.dispose();
    adminKeyController?.dispose();

    textFieldFocusNode3?.dispose();
    passwordTextController?.dispose();

    textFieldFocusNode4?.dispose();
    confirmPasswordTextController?.dispose();
  }
}
