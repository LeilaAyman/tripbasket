import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'signup_model.dart';
export 'signup_model.dart';

// String helpers
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String toTitleCase() {
    if (trim().isEmpty) return this;
    return split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : "${w[0].toUpperCase()}${w.substring(1).toLowerCase()}")
        .join(' ');
  }
}

/// sign up page
class SignupWidget extends StatefulWidget {
  const SignupWidget({super.key});

  static String routeName = 'signup';
  static String routePath = '/signup';

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  late SignupModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignupModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.emailTextController ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.phoneNumberController ??= TextEditingController();
    _model.phoneNumberFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.confirmPasswordTextController ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          title: Text(
            'Create Account',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                    child: Text(
                      'Join us today and start planning your dream travels',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: const Color(0xFF4B4B4B),
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                  ),
                  Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 4.0),
                                child: Text(
                                  'Full Name',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              TextFormField(
                                controller: _model.textController1,
                                focusNode: _model.textFieldFocusNode1,
                                autofocus: false,
                                autofillHints: const [AutofillHints.name],
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Enter your full name',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F8FF),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      
                                    ),
                                minLines: 1,
                                keyboardType: TextInputType.name,
                                cursorColor: const Color(0xFFFFD700),
                                validator: _model.textController1Validator
                                    .asValidator(context),
                                inputFormatters: [
                                  // Capitalize words on desktop/web (FlutterFlow pattern)
                                  if (!isAndroid && !isiOS)
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      return TextEditingValue(
                                        selection: newValue.selection,
                                        text: newValue.text.toTitleCase(),
                                      );
                                    }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 4.0),
                                child: Text(
                                  'Email',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              TextFormField(
                                controller: _model.emailTextController,
                                focusNode: _model.textFieldFocusNode2,
                                autofocus: false,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Enter your email address',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F8FF),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      
                                    ),
                                minLines: 1,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: const Color(0xFFFFD700),
                                validator: _model.emailTextControllerValidator
                                    .asValidator(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 4.0),
                                child: Text(
                                  'Phone Number',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              TextFormField(
                                controller: _model.phoneNumberController,
                                focusNode: _model.phoneNumberFocusNode,
                                autofocus: false,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: 'Enter your phone number',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F8FF),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      
                                    ),
                                minLines: 1,
                                keyboardType: TextInputType.phone,
                                cursorColor: const Color(0xFFFFD700),
                                validator: _model.phoneNumberControllerValidator
                                    .asValidator(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 4.0),
                                child: Text(
                                  'Role',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F8FF),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      15.0, 0.0, 15.0, 0.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _model.roleValue,
                                      isExpanded: true,
                                      elevation: 2,
                                      dropdownColor: Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            
                                          ),
                                      hint: const Text('Select your role'),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _model.roleValue = newValue!;
                                        });
                                      },
                                      items: <String>['user', 'admin', 'agency']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value.capitalize()),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 4.0),
                                child: Text(
                                  'Password',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              TextFormField(
                                controller: _model.passwordTextController,
                                focusNode: _model.textFieldFocusNode3,
                                autofocus: false,
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.next,
                                obscureText: !_model.passwordVisibility1,
                                decoration: InputDecoration(
                                  hintText: 'Create a strong password',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F8FF),
                                  suffixIcon: InkWell(
                                    onTap: () => safeSetState(
                                      () => _model.passwordVisibility1 =
                                          !_model.passwordVisibility1,
                                    ),
                                    focusNode:
                                        FocusNode(skipTraversal: true),
                                    child: Icon(
                                      _model.passwordVisibility1
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF4B4B4B),
                                      size: 18.0,
                                    ),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      
                                    ),
                                cursorColor: const Color(0xFFFFD700),
                                validator: _model
                                    .passwordTextControllerValidator
                                    .asValidator(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 18.0, 0.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 4.0),
                                child: Text(
                                  'Confirm Password',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              TextFormField(
                                controller:
                                    _model.confirmPasswordTextController,
                                focusNode: _model.textFieldFocusNode4,
                                autofocus: false,
                                textInputAction: TextInputAction.done,
                                obscureText: !_model.passwordVisibility2,
                                decoration: InputDecoration(
                                  hintText: 'Confirm your password',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF0F8FF),
                                  suffixIcon: InkWell(
                                    onTap: () => safeSetState(
                                      () => _model.passwordVisibility2 =
                                          !_model.passwordVisibility2,
                                    ),
                                    focusNode:
                                        FocusNode(skipTraversal: true),
                                    child: Icon(
                                      _model.passwordVisibility2
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF4B4B4B),
                                      size: 18.0,
                                    ),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      
                                    ),
                                cursorColor: const Color(0xFFFFD700),
                                validator: _model
                                    .confirmPasswordTextControllerValidator
                                    .asValidator(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Terms and Conditions
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 18.0, 0.0, 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 0.0),
                            child: Text(
                              'I agree to the Terms of Service and Privacy Policy',
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    fontFamily: 'Inter',
                                    color: const Color(0xFF4B4B4B),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Create Account Button
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 24.0, 0.0, 0.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        // Validate form
                        if (_model.formKey.currentState?.validate() ?? false) {
                          // Check if role is selected
                          if (_model.roleValue == null ||
                              _model.roleValue!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select your role!'),
                              ),
                            );
                            return;
                          }

                          GoRouter.of(context).prepareAuthEvent();
                          if (_model.passwordTextController.text !=
                              _model.confirmPasswordTextController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords don\'t match!'),
                              ),
                            );
                            return;
                          }

                          final user =
                              await authManager.createAccountWithEmail(
                            context,
                            _model.emailTextController.text.trim(),
                            _model.passwordTextController.text,
                          );
                          if (user == null) {
                            return;
                          }

                          // Save user data to Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .set({
                            'display_name': _model.textController1.text.trim(),
                            'email': _model.emailTextController.text.trim(),
                            'phone_number':
                                _model.phoneNumberController.text.trim(),
                            'role': [_model.roleValue], // Save as array
                            'created_time': FieldValue.serverTimestamp(),
                            'uid': user.uid,
                          });

                          if (!mounted) return;
                          context.goNamedAuth(HomeWidget.routeName, mounted);
                        }
                      },
                      text: 'Create Account',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50.0,
                        padding: const EdgeInsets.all(8.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: const Color(0xFFFFD700),
                        textStyle:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                        elevation: 2.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  // OR Divider
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 24.0, 0.0, 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0E68C),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          child: Text(
                            'OR',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF4B4B4B),
                                  fontSize: 13.0,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0E68C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Google Sign Up Button
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 16.0),
                    child: FFButtonWidget(
                      onPressed: () {
                        debugPrint('Google sign up pressed ...');
                      },
                      text: 'Sign up with Google',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50.0,
                        padding: const EdgeInsets.all(8.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: Colors.white,
                        textStyle:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Inter',
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                        elevation: 0.0,
                        borderSide: const BorderSide(
                          color: Color(0xFFF0E68C),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                  // Sign In Link
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 16.0, 0.0, 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter',
                                color: const Color(0xFF4B4B4B),
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(LoginWidget.routeName);
                          },
                          child: Text(
                            ' Sign In',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: const Color(0xFFFFD700),
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
