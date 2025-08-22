import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_model.dart';
export 'signup_model.dart';

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
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
    
    _model.adminKeyController ??= TextEditingController();
    _model.adminKeyFocusNode ??= FocusNode();

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
            child: Icon(
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
          actions: [],
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
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 16.0),
                          child: Text(
                            'Join us today and start planning your dream travels',
                            textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.normal,
                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: Color(0xFF4B4B4B),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Full Name',
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                              color: Colors.black,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _model.textController1,
                                      focusNode: _model.textFieldFocusNode1,
                                      autofocus: false,
                                      autofillHints: [AutofillHints.name],
                                textCapitalization: TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your full name',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                    borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                    borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                    borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                    borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFF0F8FF),
                                      ),
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            lineHeight: 1.0,
                                          ),
                                      minLines: 1,
                                      keyboardType: TextInputType.name,
                                      cursorColor: Color(0xFFFFD700),
                                validator: _model.textController1Validator.asValidator(context),
                                      inputFormatters: [
                                        if (!isAndroid && !isiOS)
                                    TextInputFormatter.withFunction((oldValue, newValue) {
                                            return TextEditingValue(
                                              selection: newValue.selection,
                                        text: newValue.text.toCapitalization(TextCapitalization.words),
                                            );
                                          }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Email Field
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Email Address',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _model.emailTextController,
                                      focusNode: _model.textFieldFocusNode2,
                                      autofocus: false,
                                      autofillHints: [AutofillHints.email],
                                      textInputAction: TextInputAction.next,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email address',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFF0F8FF),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        lineHeight: 1.0,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      cursorColor: Color(0xFFFFD700),
                                      validator: _model.emailTextControllerValidator.asValidator(context),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Phone Number Field
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Phone Number',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _model.phoneNumberController,
                                      focusNode: _model.phoneNumberFocusNode,
                                      autofocus: false,
                                      autofillHints: [AutofillHints.telephoneNumber],
                                      textInputAction: TextInputAction.next,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your phone number',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFF0F8FF),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        lineHeight: 1.0,
                                      ),
                                      keyboardType: TextInputType.phone,
                                      cursorColor: Color(0xFFFFD700),
                                      validator: _model.phoneNumberControllerValidator.asValidator(context),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Role Selection Field
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Account Type',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                      ),
                                    ),
                                    DropdownButtonFormField<String>(
                                      value: _model.roleValue,
                                      hint: Text(
                                        'Select your account type',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context).secondaryText,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                      ),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'user',
                                          child: Text('User'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'agency',
                                          child: Text('Travel Agency'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'admin',
                                          child: Text('Administrator'),
                                        ),
                                      ],
                                      onChanged: (val) => setState(() => _model.roleValue = val),
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFF0F8FF),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please select an account type';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Agency Reference Field (for agency accounts)
                              if (_model.roleValue == 'agency') ...[
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                        child: Text(
                                          'Select Your Agency',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            color: Colors.black,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                        ),
                                      ),
                                      StreamBuilder<List<AgenciesRecord>>(
                                        stream: queryAgenciesRecord(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child: SizedBox(
                                                width: 50.0,
                                                height: 50.0,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    FlutterFlowTheme.of(context).primary,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          List<AgenciesRecord> agencies = snapshot.data!;
                                          
                                          return DropdownButtonFormField<DocumentReference>(
                                            value: _model.agencyReferenceValue,
                                            hint: Text(
                                              'Select the agency you work for',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                            ),
                                            items: agencies.map((agency) {
                                              return DropdownMenuItem(
                                                value: agency.reference,
                                                child: Text(agency.name),
                                              );
                                            }).toList(),
                                            onChanged: (val) => setState(() => _model.agencyReferenceValue = val),
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Color(0x00000000),
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              filled: true,
                                              fillColor: Color(0xFFF0F8FF),
                                            ),
                                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                              ),
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            validator: (val) {
                                              if (_model.roleValue == 'agency' && val == null) {
                                                return 'Please select your agency';
                                              }
                                              return null;
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Admin Key Field (for admin accounts)
                              if (_model.roleValue == 'admin') ...[
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                        child: Text(
                                          'Admin Verification Key',
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                            ),
                                            color: Colors.black,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _model.adminKeyController,
                                        focusNode: _model.adminKeyFocusNode,
                                        autofocus: false,
                                        textInputAction: TextInputAction.next,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: 'Enter admin verification key',
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0x00000000),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor: Color(0xFFF0F8FF),
                                        ),
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          lineHeight: 1.0,
                                        ),
                                        cursorColor: Color(0xFFFFD700),
                                        validator: _model.adminKeyControllerValidator.asValidator(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              
                              // Password Field
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Password',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _model.passwordTextController,
                                      focusNode: _model.textFieldFocusNode3,
                                      autofocus: false,
                                      autofillHints: [AutofillHints.newPassword],
                                      textInputAction: TextInputAction.next,
                                      obscureText: !_model.passwordVisibility1,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your password',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFF0F8FF),
                                        suffixIcon: InkWell(
                                          onTap: () => setState(
                                            () => _model.passwordVisibility1 = !_model.passwordVisibility1,
                                          ),
                                          focusNode: FocusNode(skipTraversal: true),
                                          child: Icon(
                                            _model.passwordVisibility1
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        lineHeight: 1.0,
                                      ),
                                      cursorColor: Color(0xFFFFD700),
                                      validator: _model.passwordTextControllerValidator.asValidator(context),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Confirm Password Field
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
                                      child: Text(
                                        'Confirm Password',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _model.confirmPasswordTextController,
                                      focusNode: _model.textFieldFocusNode4,
                                      autofocus: false,
                                      autofillHints: [AutofillHints.newPassword],
                                      textInputAction: TextInputAction.done,
                                      obscureText: !_model.passwordVisibility2,
                                      decoration: InputDecoration(
                                        hintText: 'Re-enter your password',
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFF0F8FF),
                                        suffixIcon: InkWell(
                                          onTap: () => setState(
                                            () => _model.passwordVisibility2 = !_model.passwordVisibility2,
                                          ),
                                          focusNode: FocusNode(skipTraversal: true),
                                          child: Icon(
                                            _model.passwordVisibility2
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            size: 24.0,
                                          ),
                                        ),
                                      ),
                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        lineHeight: 1.0,
                                      ),
                                      cursorColor: Color(0xFFFFD700),
                                      validator: _model.confirmPasswordTextControllerValidator.asValidator(context),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Sign Up Button
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 16.0),
                                child: FFButtonWidget(
                                  onPressed: () async {
                                    // Validate form
                                    if (!_model.formKey.currentState!.validate()) {
                                      return;
                                    }
                                    
                                    try {
                                      // Create account with email and password
                                      final user = await authManager.createAccountWithEmail(
                                        context,
                                        _model.emailTextController.text,
                                        _model.passwordTextController.text,
                                      );
                                      
                                      if (user == null) {
                                        return;
                                      }
                                      
                                      // Update user profile with additional info
                                      Map<String, dynamic> updateData = {
                                        'display_name': _model.textController1.text,
                                        'name': _model.textController1.text,
                                        'phone_number': _model.phoneNumberController.text,
                                        'role': [_model.roleValue ?? 'user'],
                                        'loyaltyPoints': 0,
                                      };
                                      
                                      // Add agency reference for agency accounts
                                      if (_model.roleValue == 'agency' && _model.agencyReferenceValue != null) {
                                        updateData['agency_reference'] = _model.agencyReferenceValue;
                                      }
                                      
                                      await currentUserDocument?.reference.update(updateData);
                                      
                                      // Navigate to home
                                      context.goNamedAuth('home', context.mounted);
                                      
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Sign up failed: ${e.toString()}'),
                                          backgroundColor: FlutterFlowTheme.of(context).error,
                                        ),
                                      );
                                    }
                                  },
                                  text: 'Create Account',
                                  options: FFButtonOptions(
                                    width: double.infinity,
                                    height: 56.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                    color: Color(0xFFFFD700),
                                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                      ),
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                    ),
                                    elevation: 2.0,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              
                              // Sign In Link
                              Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 24.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: const Color(0xFF4B4B4B),
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                        ),
                                        color: const Color(0xFFFFD700),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                ),
                              ),
                            ],
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
