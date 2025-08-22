import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/index.dart';
import '/pages/agency_dashboard/agency_dashboard_widget.dart';
import '/components/currency_selector.dart';
import '/components/language_selector.dart';
import '/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String selectedCurrency = 'USD';
  String selectedCurrencyDisplay = 'US Dollar (\$)';
  String selectedLanguage = 'en';
  String selectedLanguageDisplay = 'English';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCurrency = prefs.getString('currency') ?? 'USD';
      selectedCurrencyDisplay = prefs.getString('currency_display') ?? 'US Dollar (\$)';
      selectedLanguage = prefs.getString('language') ?? 'en';
      selectedLanguageDisplay = prefs.getString('language_display') ?? 'English';
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', selectedCurrency);
    await prefs.setString('currency_display', selectedCurrencyDisplay);
    await prefs.setString('language', selectedLanguage);
    await prefs.setString('language_display', selectedLanguageDisplay);
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

  bool get isAgency {
    print('DEBUG: Checking agency status');
    print('DEBUG: currentUserDocument: ${currentUserDocument}');
    print('DEBUG: currentUserDocument?.role: ${currentUserDocument?.role}');
    print('DEBUG: currentUserDocument?.agencyReference: ${currentUserDocument?.agencyReference}');
    
    if (currentUserDocument == null) {
      print('DEBUG: currentUserDocument is null');
      return false;
    }
    
    bool agencyStatus = currentUserDocument!.role.contains('agency') || 
                       currentUserDocument!.agencyReference != null;
    print('DEBUG: isAgency result: $agencyStatus');
    return agencyStatus;
  }

  Future<void> _showPhotoUploadMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo upload feature coming soon! For now, you can update your photo through your account settings.'),
        duration: Duration(seconds: 3),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _showCurrencySelector() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: EdgeInsets.only(top: 50),
        child: CurrencySelector(
          currentCurrency: selectedCurrency,
          onCurrencyChanged: (code, display) {
            setState(() {
              selectedCurrency = code;
              selectedCurrencyDisplay = display;
            });
            _savePreferences();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Currency updated to $display'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showLanguageSelector() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: EdgeInsets.only(top: 50),
        child: LanguageSelector(
          currentLanguage: selectedLanguage,
          onLanguageChanged: (code, display) {
            setState(() {
              selectedLanguage = code;
              selectedLanguageDisplay = display;
            });
            _savePreferences();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Language updated to $display'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPhoneNumberDialog() async {
    final TextEditingController phoneController = TextEditingController(
      text: currentPhoneNumber,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Update Phone Number',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text('Save'),
              onPressed: () async {
                try {
                  if (currentUserDocument != null) {
                    await currentUserDocument!.reference.update({
                      'phone_number': phoneController.text,
                    });
                  }

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Phone number updated successfully!'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  setState(() {});
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update phone number.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
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
    Widget? trailing,
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
                        ? AppTheme.seed
                        : Theme.of(context).colorScheme.onSurfaceVariant,
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
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onBackground,
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
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.0,
                    ),
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
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 28.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.0,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        currentUserEmail,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0,
                        ),
                      ),
                      SizedBox(height: 12.0),
                      Row(
                        children: [
                          if (isAdmin)
                            Container(
                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    size: 16.0,
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    'ADMIN',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isAdmin && isAgency) SizedBox(width: 8.0),
                          if (isAgency)
                            Container(
                              padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.business,
                                    color: Theme.of(context).colorScheme.onSecondary,
                                    size: 16.0,
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    'AGENCY',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context).colorScheme.onSecondary,
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
                    ],
                  ),
                ),
              ),

              // Main content area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                                  _showPhoneNumberDialog();
                                },
                                showArrow: true,
                              ),
                              
                              // Language
                              _buildSettingsRow(
                                context,
                                Icons.language_outlined,
                                'Language',
                                selectedLanguageDisplay,
                                false,
                                () {
                                  _showLanguageSelector();
                                },
                                showArrow: true,
                              ),
                              
                              // Currency
                              _buildSettingsRow(
                                context,
                                Icons.attach_money_outlined,
                                'Currency',
                                selectedCurrencyDisplay,
                                false,
                                () {
                                  _showCurrencySelector();
                                },
                                showArrow: true,
                              ),
                              
                              // Profile Settings
                              _buildSettingsRow(
                                context,
                                Icons.edit_outlined,
                                'Profile Settings',
                                'Edit Profile',
                                false,
                                () {
                                  context.pushNamed('edit_profile');
                                },
                                showArrow: true,
                              ),
                              
                              // Notification Settings
                              _buildSettingsRow(
                                context,
                                Icons.notifications_outlined,
                                'Notification Settings',
                                'Manage Notifications',
                                false,
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Notification settings coming soon!'),
                                      backgroundColor: Color(0xFF6B73FF),
                                    ),
                                  );
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

                              // Agency Dashboard Section (if agency or admin)
                              if (isAgency || isAdmin)
                                _buildSettingsRow(
                                  context,
                                  Icons.dashboard_outlined,
                                  'Agency Dashboard',
                                  isAdmin ? 'Admin Access' : 'Manage Trips',
                                  false,
                                  () {
                                    context.pushNamed(AgencyDashboardWidget.routeName);
                                  },
                                  showArrow: true,
                                ),

                              // Agency CSV Upload Section (if agency)
                              if (isAgency)
                                _buildSettingsRow(
                                  context,
                                  Icons.upload_file_outlined,
                                  'Upload Trips (CSV)',
                                  'Agency Access',
                                  false,
                                  () {
                                    context.pushNamed('agencyCsvUpload');
                                  },
                                  showArrow: true,
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
