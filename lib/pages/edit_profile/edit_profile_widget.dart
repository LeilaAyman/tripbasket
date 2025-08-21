import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_model.dart';
export 'edit_profile_model.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'edit_profile';
  static String routePath = '/edit_profile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  late EditProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditProfileModel());

    _model.displayNameTextController ??= TextEditingController(
      text: currentUserDisplayName
    );
    _model.displayNameFocusNode ??= FocusNode();

    _model.emailTextController ??= TextEditingController(
      text: currentUserEmail
    );
    _model.emailFocusNode ??= FocusNode();

    _model.phoneTextController ??= TextEditingController(
      text: currentPhoneNumber
    );
    _model.phoneFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_model.displayNameTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Display name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Update Firebase Auth user profile
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_model.displayNameTextController.text);
      }

      // Update Firestore document
      if (currentUserDocument != null) {
        await currentUserDocument!.reference.update({
          'display_name': _model.displayNameTextController.text,
          'phone_number': _model.phoneTextController.text,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF6B73FF),
        ),
      );

      context.pop();
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.black,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
              child: FFButtonWidget(
                onPressed: _saveProfile,
                text: 'Save',
                options: FFButtonOptions(
                  width: 80.0,
                  height: 36.0,
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Color(0xFF6B73FF),
                  textStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                  elevation: 0.0,
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Profile Photo Section
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Photo upload feature coming soon!'),
                              backgroundColor: Color(0xFF6B73FF),
                            ),
                          );
                        },
                        child: Container(
                          width: 120.0,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF6B73FF),
                              width: 3.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8.0,
                                color: Color(0x1A000000),
                                offset: Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60.0),
                                  child: currentUserPhoto.isNotEmpty
                                      ? Image.network(
                                          currentUserPhoto,
                                          width: 114.0,
                                          height: 114.0,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 114.0,
                                              height: 114.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF5F5F5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: 60.0,
                                                color: Color(0xFF9E9E9E),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          width: 114.0,
                                          height: 114.0,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF5F5F5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: 60.0,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6B73FF),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3.0,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Tap to change profile photo',
                        style: GoogleFonts.poppins(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Fields
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                  child: Column(
                    children: [
                      // Display Name Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display Name',
                            style: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            controller: _model.displayNameTextController,
                            focusNode: _model.displayNameFocusNode,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Enter your display name',
                              hintStyle: GoogleFonts.poppins(
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 14.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF6B73FF),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 14.0,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Display name is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 24.0),

                      // Email Field (Read-only)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            controller: _model.emailTextController,
                            focusNode: _model.emailFocusNode,
                            readOnly: true,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Email cannot be changed',
                              hintStyle: GoogleFonts.poppins(
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 14.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF0F0F0),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF0F0F0),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Color(0xFFF8F8F8),
                              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).secondaryText,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.0),

                      // Phone Number Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number',
                            style: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          TextFormField(
                            controller: _model.phoneTextController,
                            focusNode: _model.phoneFocusNode,
                            obscureText: false,
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              hintStyle: GoogleFonts.poppins(
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 14.0,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF6B73FF),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: FlutterFlowTheme.of(context).secondaryText,
                                size: 20.0,
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontSize: 14.0,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),

                      SizedBox(height: 32.0),

                      // Save Button (Full Width)
                      FFButtonWidget(
                        onPressed: _saveProfile,
                        text: 'Save Changes',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 54.0,
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: Color(0xFF6B73FF),
                          textStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 3.0,
                          borderRadius: BorderRadius.circular(12.0),
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
    );
  }
}