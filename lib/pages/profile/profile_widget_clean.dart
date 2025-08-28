import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_model.dart';
export 'profile_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  static String routeName = 'profile';
  static String routePath = '/profile';

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool get isAdmin {
    print('DEBUG: Checking admin status');
    print('DEBUG: currentUserDocument: ${currentUserDocument}');
    print('DEBUG: currentUserDocument?.role: ${currentUserDocument?.role}');
    
    if (currentUserDocument == null) {
      print('DEBUG: currentUserDocument is null');
      return false;
    }
    
    bool adminStatus = (currentUserDocument!.role.isNotEmpty && currentUserDocument!.role.contains('admin'));
    print('DEBUG: isAdmin result: $adminStatus');
    return adminStatus;
  }

  Future<void> _showPhotoUploadMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo upload feature coming soon! For now, you can update your photo through your account settings.'),
        duration: Duration(seconds: 3),
        backgroundColor: FlutterFlowTheme.of(context).primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondaryText,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).secondaryText,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: FlutterFlowTheme.of(context).info,
                size: 30.0,
              ),
              onPressed: () async {
                context.pop();
              },
            ),
            actions: [],
            centerTitle: false,
            elevation: 0.0,
          ),
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header with User Info in Black Space
              Container(
                width: double.infinity,
                height: 200.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2D2D2D),
                      Color(0xFF1A1A1A),
                    ],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(0.0, -1.0),
                    end: AlignmentDirectional(0, 1.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24.0, 20.0, 24.0, 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        currentUserDisplayName.isNotEmpty 
                            ? currentUserDisplayName 
                            : (currentUserEmail.isNotEmpty 
                                ? (currentUserEmail.split('@').isNotEmpty ? currentUserEmail.split('@')[0] : 'User') 
                                : 'User'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Color(0xFFD76B30),
                            size: 16.0,
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              currentUserEmail,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (currentPhoneNumber.isNotEmpty) ...[
                        SizedBox(height: 4.0),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: Color(0xFFDBA237),
                              size: 16.0,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              currentPhoneNumber,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 8.0),
                      if (isAdmin)
                        Container(
                          padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFD76B30),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 16.0,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                'ADMIN',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Main content area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Photo Section
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 16.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await _showPhotoUploadMessage();
                                },
                                child: Container(
                                  width: 120.0,
                                  height: 120.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFD76B30),
                                      width: 4.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 8.0,
                                        color: Color(0x1F000000),
                                        offset: Offset(0.0, 4.0),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(60.0),
                                      child: currentUserPhoto.isNotEmpty
                                          ? Image.network(
                                              currentUserPhoto,
                                              width: 112.0,
                                              height: 112.0,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 112.0,
                                                  height: 112.0,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFD76B30).withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 60.0,
                                                    color: Color(0xFFD76B30),
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 112.0,
                                              height: 112.0,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFD76B30).withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add_a_photo,
                                                size: 40.0,
                                                color: Color(0xFFD76B30),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                currentUserDisplayName.isNotEmpty 
                                    ? currentUserDisplayName 
                                    : (currentUserEmail.isNotEmpty 
                                        ? (currentUserEmail.split('@').isNotEmpty ? currentUserEmail.split('@')[0] : 'User') 
                                        : 'User'),
                                style: GoogleFonts.poppins(
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                currentUserEmail,
                                style: GoogleFonts.poppins(
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Settings Content
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Settings',
                                style: GoogleFonts.poppins(
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              
                              // Admin Upload Section (if admin)
                              if (isAdmin)
                                Container(
                                  margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                  child: InkWell(
                                    onTap: () {
                                      context.pushNamed(AdminUploadWidget.routeName);
                                    },
                                    child: Container(
                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFD76B30).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border.all(
                                          color: Color(0xFFD76B30).withOpacity(0.3),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 48.0,
                                            height: 48.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFD76B30),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Icon(
                                              Icons.cloud_upload,
                                              color: Colors.white,
                                              size: 24.0,
                                            ),
                                          ),
                                          SizedBox(width: 16.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Upload Trips (CSV)',
                                                  style: GoogleFonts.poppins(
                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                Text(
                                                  'Bulk upload trip data from CSV files',
                                                  style: GoogleFonts.poppins(
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w400,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFFD76B30),
                                            size: 24.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // Help Center
                              Container(
                                margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                child: Container(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48.0,
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFDBA237).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Icon(
                                          Icons.help_outline,
                                          color: Color(0xFFDBA237),
                                          size: 24.0,
                                        ),
                                      ),
                                      SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Help Center',
                                              style: GoogleFonts.poppins(
                                                color: FlutterFlowTheme.of(context).primaryText,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                            Text(
                                              'Get support and find answers',
                                              style: GoogleFonts.poppins(
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 24.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Debug Info
                              Container(
                                margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                                child: Container(
                                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DEBUG INFO',
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        'Role Array: ${currentUserDocument?.role?.toString() ?? "No role array"}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      Text(
                                        'isAdmin Result: ${isAdmin}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      Text(
                                        'UID: ${currentUserUid}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.blue,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Logout Button
                              Container(
                                width: double.infinity,
                                margin: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Function() navigate = () {};
                                    navigate = () => context.goNamedAuth(
                                          'onboarding',
                                          context.mounted,
                                        );
                                    await authManager.signOut();
                                    navigate();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.withOpacity(0.1),
                                    foregroundColor: Colors.red,
                                    elevation: 0,
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      side: BorderSide(
                                        color: Colors.red.withOpacity(0.3),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 20.0,
                                      ),
                                      SizedBox(width: 8.0),
                                      Text(
                                        'Sign Out',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ],
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
            ],
          ),
        ),
      ),
    );
  }
}
