import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/national_id_upload/national_id_upload_page.dart';
import '/pages/admin_upload/admin_upload_widget.dart';
import '/pages/agency_dashboard/agency_dashboard_widget.dart';
import '/pages/agency_csv_upload/agency_csv_upload_widget.dart';
import '/state/currency_provider.dart';
import '/utils/kyc_utils.dart';
import '/utils/money.dart';
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
    if (currentUserDocument == null) return false;
    return currentUserDocument!.role.isNotEmpty && currentUserDocument!.role.contains('admin');
  }

  bool get isAgency {
    if (currentUserDocument == null) return false;
    return currentUserDocument!.role.isNotEmpty && currentUserDocument!.role.contains('agency');
  }

  String _getInitials(String? displayName, String? email) {
    if (displayName != null && displayName.isNotEmpty) {
      final parts = displayName.split(' ');
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    }
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return 'U';
  }

  Widget _buildHeaderCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: currentUserPhoto.isNotEmpty 
                ? NetworkImage(currentUserPhoto) 
                : null,
              child: currentUserPhoto.isEmpty 
                ? Text(
                    _getInitials(currentUserDisplayName, currentUserEmail),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentUserDisplayName.isNotEmpty 
                      ? currentUserDisplayName 
                      : (currentUserEmail.split('@').isNotEmpty ? currentUserEmail.split('@').first : 'User'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUserEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ADMIN',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, child) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.attach_money_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Currency'),
                  subtitle: Text(currencyProvider.selected.name),
                  trailing: DropdownButton<AppCurrency>(
                    value: currencyProvider.selected,
                    underline: const SizedBox.shrink(),
                    items: AppCurrency.values.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency.name),
                      );
                    }).toList(),
                    onChanged: (AppCurrency? newCurrency) async {
                      if (newCurrency != null) {
                        await currencyProvider.setCurrency(newCurrency);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Currency saved'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // National ID Verification
            StreamBuilder<UsersRecord>(
              stream: UsersRecord.getDocument(currentUserReference!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                
                final userDoc = snapshot.data!;
                final idStatus = userDoc.nationalIdStatus;
                final hasId = userDoc.hasNationalIdUrl() && userDoc.nationalIdUrl.isNotEmpty;
                
                IconData statusIcon;
                Color statusColor;
                String statusText = KycUtils.getNationalIdStatusDisplay(idStatus);
                
                switch (idStatus) {
                  case 'verified':
                    statusIcon = Icons.verified_rounded;
                    statusColor = Colors.green;
                    break;
                  case 'uploaded':
                    statusIcon = Icons.pending_rounded;
                    statusColor = Colors.orange;
                    break;
                  case 'rejected':
                    statusIcon = Icons.error_rounded;
                    statusColor = Colors.red;
                    break;
                  default:
                    statusIcon = Icons.upload_rounded;
                    statusColor = Colors.grey;
                }
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(statusIcon, color: statusColor),
                  title: const Text('National ID'),
                  subtitle: Text(statusText),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NationalIdUploadPage(),
                      ),
                    );
                    if (result == true && mounted) {
                      setState(() {});
                    }
                  },
                );
              },
            ),
            
            const Divider(height: 24),
            
            // Change Password
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.lock_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password change feature coming soon!'),
                  ),
                );
              },
            ),
            
            const Divider(height: 24),
            
            // Sign Out
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );
                
                if (shouldLogout == true) {
                  GoRouter.of(context).prepareAuthEvent();
                  await authManager.signOut();
                  GoRouter.of(context).clearRedirectLocation();
                  context.goNamedAuth('landing', context.mounted);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.upload_file_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Upload Trips (CSV)'),
              subtitle: const Text('Bulk upload trips from CSV file'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminUploadWidget(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgencySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Agency Dashboard',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.dashboard_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Agency Dashboard'),
              subtitle: const Text('View and manage your agency trips'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AgencyDashboardWidget(),
                  ),
                );
              },
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.upload_file_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Upload Trips (CSV)'),
              subtitle: const Text('Bulk upload trips from CSV file'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AgencyCsvUploadWidget(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) => Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30,
            borderWidth: 1,
            buttonSize: 60,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildPreferencesSection(),
              if (isAdmin) ...[
                const SizedBox(height: 16),
                _buildAdminSection(),
              ],
              if (isAgency) ...[
                const SizedBox(height: 16),
                _buildAgencySection(),
              ],
              const SizedBox(height: 16),
              _buildAccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}