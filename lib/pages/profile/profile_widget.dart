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
    
    bool adminStatus = currentUserDocument!.role.contains('admin');
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

  Widget _buildSettingsRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    bool isAddValue,
    VoidCallback onTap, {
    bool showArrow = false,
    bool isAdmin = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout 
                    ? Colors.red 
                    : isAdmin 
                        ? Color(0xFFD76B30)
                        : FlutterFlowTheme.of(context).secondaryText,
                size: 24.0,
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isLogout 
                        ? Colors.red 
                        : FlutterFlowTheme.of(context).primaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.chevron_right_rounded,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 20.0,
                )
              else if (value.isNotEmpty)
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: isAddValue 
                        ? Color(0xFFD76B30) 
                        : isLogout 
                            ? Colors.red
                            : isAdmin
                                ? Color(0xFFD76B30)
                                : Color(0xFF6B73FF),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.0,
                  ),
                ),
            ],
          ),
        ),
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
              // Header with User Info in Light Space
              Container(
                width: double.infinity,
                height: 160.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1A1F24),
                      Color(0xFF131A1F),
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
                        currentUserDisplayName.isNotEmpty 
                            ? currentUserDisplayName 
                            : (currentUserEmail.isNotEmpty 
                                ? currentUserEmail.split('@')[0] 
                                : 'User'),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        currentUserEmail,
                        style: GoogleFonts.poppins(
                          color: Color(0xFFE0E0E0),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0,
                        ),
                      ),
                      SizedBox(height: 12.0),
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
                        // Profile Photo Section - Centered
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                await _showPhotoUploadMessage();
                              },
                              child: Container(
                                width: 100.0,
                                height: 100.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color(0xFFE0E0E0),
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x1A000000),
                                      offset: Offset(0.0, 2.0),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: currentUserPhoto.isNotEmpty
                                        ? Image.network(
                                            currentUserPhoto,
                                            width: 96.0,
                                            height: 96.0,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 96.0,
                                                height: 96.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF5F5F5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 48.0,
                                                  color: Color(0xFF9E9E9E),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 96.0,
                                            height: 96.0,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF5F5F5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt_outlined,
                                              size: 32.0,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
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
                              SizedBox(height: 20.0),
                              
                              // Phone Number
                              _buildSettingsRow(
                                context,
                                Icons.phone_outlined,
                                'Phone Number',
                                currentPhoneNumber.isNotEmpty ? currentPhoneNumber : 'Add Number',
                                currentPhoneNumber.isEmpty,
                                () {
                                  // TODO: Navigate to phone number edit
                                },
                              ),
                              
                              // Language
                              _buildSettingsRow(
                                context,
                                Icons.language_outlined,
                                'Language',
                                'English (eng)',
                                false,
                                () {
                                  // TODO: Navigate to language settings
                                },
                              ),
                              
                              // Currency
                              _buildSettingsRow(
                                context,
                                Icons.attach_money_outlined,
                                'Currency',
                                'US Dollar (\$)',
                                false,
                                () {
                                  // TODO: Navigate to currency settings
                                },
                              ),
                              
                              // Profile Settings
                              _buildSettingsRow(
                                context,
                                Icons.edit_outlined,
                                'Profile Settings',
                                'Edit Profile',
                                false,
                                () {
                                  // TODO: Navigate to profile edit
                                },
                              ),
                              
                              // Notification Settings
                              _buildSettingsRow(
                                context,
                                Icons.notifications_outlined,
                                'Notification Settings',
                                '',
                                false,
                                () {
                                  // TODO: Navigate to notification settings
                                },
                                showArrow: true,
                              ),
                              
                              // Admin Upload Section (if admin)
                              if (isAdmin)
                                _buildSettingsRow(
                                  context,
                                  Icons.cloud_upload_outlined,
                                  'Upload Trips (CSV)',
                                  'Admin Only',
                                  false,
                                  () {
                                    context.pushNamed(AdminUploadWidget.routeName);
                                  },
                                  isAdmin: true,
                                ),

                              SizedBox(height: 20.0),
                              
                              // Logout Button
                              _buildSettingsRow(
                                context,
                                Icons.logout_outlined,
                                'Log out of account',
                                'Log Out?',
                                false,
                                () async {
                                  Function() navigate = () {};
                                  navigate = () => context.goNamedAuth(
                                        'onboarding',
                                        context.mounted,
                                      );
                                  await authManager.signOut();
                                  navigate();
                                },
                                isLogout: true,
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
