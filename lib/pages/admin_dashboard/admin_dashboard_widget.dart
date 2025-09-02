import 'dart:async';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/agency_utils.dart';
import '/utils/chat_cleanup_utils.dart';
import '/services/user_management_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'admin_dashboard_model.dart';
export 'admin_dashboard_model.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  static String routeName = 'admin_dashboard';
  static String routePath = '/admin-dashboard';

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> {
  late AdminDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'overview'; // overview, agencies, trips, bookings, messages
  Timer? _debounce;
  Timer? _cleanupTimer;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDashboardModel());
    _startCleanupTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _cleanupTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  /// Check if current user is an admin
  bool _isCurrentUserAdmin() {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    
    final role = AgencyUtils.lc(userDoc.role.join(' '));
    return role.contains('admin');
  }

  /// Debounced search handler
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value;
        });
      }
    });
  }

  /// Start automatic cleanup timer (checks every hour)
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      final now = DateTime.now();
      
      // Run cleanup at midnight (00:00)
      if (now.hour == 0 && now.minute < 5) {
        try {
          print('Running automatic end-of-day chat cleanup...');
          await ChatCleanupUtils.deleteAllChatsAtEndOfDay();
          print('Automatic chat cleanup completed successfully');
        } catch (e) {
          print('Error in automatic chat cleanup: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if user has admin access
    if (!_isCurrentUserAdmin()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings_outlined, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Admin Access Required',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'You need admin privileges to access this dashboard.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A237E), // Deep blue for admin
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E), // Deep blue
              Color(0xFF283593), // Lighter blue
            ],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.only(left: 16),
        child: FlutterFlowIconButton(
          borderColor: Colors.white.withOpacity(0.2),
          borderRadius: 12,
          borderWidth: 1,
          buttonSize: 48,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Dashboard',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'System-wide management and monitoring',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: FlutterFlowIconButton(
            borderColor: Colors.white.withOpacity(0.2),
            borderRadius: 12,
            borderWidth: 1,
            buttonSize: 48,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () async {
              setState(() {});
            },
          ),
        ),
      ],
      centerTitle: false,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      top: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1200;
          final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
          final isMobile = constraints.maxWidth < 768;
          
          return Row(
            children: [
              // Sidebar Navigation (only on desktop/tablet)
              if (!isMobile) _buildSidebar(isDesktop),
              
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        if (isMobile) _buildMobileTabBar(),
                        _buildSearchBar(constraints),
                        _buildMainContent(constraints),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(bool isDesktop) {
    return Container(
      width: isDesktop ? 280 : 240,
      color: FlutterFlowTheme.of(context).secondaryBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: const Color(0xFF1A237E),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                    color: const Color(0xFF1A237E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem('overview', Icons.dashboard, 'Overview'),
                _buildSidebarItem('users', Icons.people, 'Users'),
                _buildSidebarItem('agencies', Icons.business, 'Agencies'),
                _buildSidebarItem('trips', Icons.travel_explore, 'All Trips'),
                _buildSidebarItem('bookings', Icons.book_online, 'All Bookings'),
                _buildSidebarItem('messages', Icons.message, 'All Messages'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(String tabId, IconData icon, String title) {
    final isSelected = _selectedTab == tabId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF1A237E) : FlutterFlowTheme.of(context).secondaryText,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1A237E) : FlutterFlowTheme.of(context).primaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: const Color(0xFF1A237E).withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          setState(() {
            _selectedTab = tabId;
          });
        },
      ),
    );
  }

  Widget _buildMobileTabBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMobileTab('overview', 'Overview'),
            _buildMobileTab('users', 'Users'),
            _buildMobileTab('agencies', 'Agencies'),
            _buildMobileTab('trips', 'Trips'),
            _buildMobileTab('bookings', 'Bookings'),
            _buildMobileTab('messages', 'Messages'),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTab(String tabId, String title) {
    final isSelected = _selectedTab == tabId;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FFButtonWidget(
        onPressed: () {
          setState(() {
            _selectedTab = tabId;
          });
        },
        text: title,
        options: FFButtonOptions(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: isSelected ? const Color(0xFF1A237E) : FlutterFlowTheme.of(context).secondaryBackground,
          textStyle: TextStyle(
            color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isSelected ? const Color(0xFF1A237E) : FlutterFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 768;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: FlutterFlowTheme.of(context).bodyLarge,
        decoration: InputDecoration(
          hintText: '🔍 Search ${_getSearchHint()}...',
          hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.7),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.search,
              color: Color(0xFF1A237E),
              size: 20,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  String _getSearchHint() {
    switch (_selectedTab) {
      case 'users':
        return 'users by name or email';
      case 'agencies':
        return 'agencies by name or email';
      case 'trips':
        return 'trips by title or location';
      case 'bookings':
        return 'bookings by customer or trip';
      case 'messages':
        return 'messages by content or customer';
      default:
        return 'anything';
    }
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    switch (_selectedTab) {
      case 'overview':
        return _buildOverviewTab();
      case 'users':
        return _buildUsersTab();
      case 'agencies':
        return _buildAgenciesTab();
      case 'trips':
        return _buildTripsTab();
      case 'bookings':
        return _buildBookingsTab();
      case 'messages':
        return _buildMessagesTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        
        // Stats Cards
        _buildStatsGrid(),
        
        const SizedBox(height: 32),
        
        // Recent Activity
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Agencies', Icons.business, _getAgenciesCount()),
        _buildStatCard('Total Trips', Icons.travel_explore, _getTripsCount()),
        _buildStatCard('Total Bookings', Icons.book_online, _getBookingsCount()),
        _buildStatCard('Unread Messages', Icons.message, _getUnreadMessagesCount()),
      ],
    );
  }

  Widget _buildStatCard(String title, IconData icon, Widget countWidget) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: const Color(0xFF1A237E), size: 24),
              countWidget,
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAgenciesCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: AgenciesRecord.collection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Text(
          '${snapshot.data!.docs.length}',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }

  Widget _getTripsCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: TripsRecord.collection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Text(
          '${snapshot.data!.docs.length}',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }

  Widget _getBookingsCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: BookingsRecord.collection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Text(
          '${snapshot.data!.docs.length}',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }

  Widget _getUnreadMessagesCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: MessagesRecord.collection
          .where('read_status', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return Text(
          '${snapshot.data!.docs.length}',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
            color: const Color(0xFF1A237E),
            fontWeight: FontWeight.w700,
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: FlutterFlowTheme.of(context).titleLarge.override(
              color: const Color(0xFF1A237E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<BookingsRecord>>(
            stream: BookingsRecord.collection
                .orderBy('created_at', descending: true)
                .limit(5)
                .snapshots()
                .map((snapshot) => snapshot.docs
                    .map((doc) => BookingsRecord.fromSnapshot(doc))
                    .toList()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.data!.isEmpty) {
                return const Text('No recent activity');
              }
              
              return Column(
                children: snapshot.data!
                    .map((booking) => _buildActivityItem(
                          'New booking for ${booking.tripTitle}',
                          DateFormat('MMM dd, HH:mm').format(booking.createdAt ?? DateTime.now()),
                          Icons.book_online,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1A237E), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: FlutterFlowTheme.of(context).bodyMedium),
          ),
          Text(
            time,
            style: FlutterFlowTheme.of(context).bodySmall.override(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgenciesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pending Approvals Section
        _buildPendingAgencyApprovalsSection(),
        const SizedBox(height: 32),
        
        // Approved Agencies Section
        _buildApprovedAgenciesSection(),
      ],
    );
  }

  Widget _buildPendingAgencyApprovalsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pending_actions,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Agency Approvals',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and approve new agency applications',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          StreamBuilder<List<AgenciesRecord>>(
            stream: queryAgenciesRecord(
              queryBuilder: (q) => q.where('status', isEqualTo: 'pending'),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading pending agencies: ${snapshot.error}'),
                );
              }
              
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final pendingAgencies = snapshot.data!;
              
              if (pendingAgencies.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No pending agency applications',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingAgencies.length,
                itemBuilder: (context, index) {
                  final agency = pendingAgencies[index];
                  return _buildPendingAgencyCard(agency);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAgencyCard(AgenciesRecord agency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Agency Logo or Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  image: agency.logo.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(agency.logo),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: agency.logo.isEmpty
                    ? Icon(
                        Icons.business,
                        color: Colors.orange.shade700,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Agency Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agency.name,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (agency.description.isNotEmpty) ...[
                      Text(
                        agency.description,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        if (agency.contactEmail.isNotEmpty) ...[
                          Icon(
                            Icons.email,
                            size: 16,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            agency.contactEmail,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                        if (agency.contactEmail.isNotEmpty && agency.location.isNotEmpty) 
                          const Text(' • ', style: TextStyle(color: Colors.grey)),
                        if (agency.location.isNotEmpty) ...[
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            agency.location,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (agency.website.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            size: 16,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            agency.website,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: () => _approveAgency(agency),
                  text: 'Approve',
                  icon: const Icon(Icons.check, size: 18),
                  options: FFButtonOptions(
                    height: 40,
                    color: Colors.green,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FFButtonWidget(
                  onPressed: () => _rejectAgency(agency),
                  text: 'Reject',
                  icon: const Icon(Icons.close, size: 18),
                  options: FFButtonOptions(
                    height: 40,
                    color: Colors.red,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedAgenciesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approved Agencies',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All verified and active agencies',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          StreamBuilder<List<AgenciesRecord>>(
            stream: queryAgenciesRecord(
              queryBuilder: (q) => q.where('status', isEqualTo: 'approved'),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error loading approved agencies: ${snapshot.error}'),
                );
              }
              
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              final approvedAgencies = snapshot.data!;
              
              if (approvedAgencies.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No approved agencies yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: approvedAgencies.length,
                itemBuilder: (context, index) {
                  final agency = approvedAgencies[index];
                  return _buildApprovedAgencyCard(agency);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedAgencyCard(AgenciesRecord agency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Agency Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
              image: agency.logo.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(agency.logo),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: agency.logo.isEmpty
                ? Icon(
                    Icons.business,
                    color: Colors.green.shade700,
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          
          // Agency Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agency.name,
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (agency.contactEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    agency.contactEmail,
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Agency Approval Methods
  Future<void> _approveAgency(AgenciesRecord agency) async {
    try {
      // Update agency status to approved
      await agency.reference.update({
        'status': 'approved',
      });
      
      // Find users who applied as this agency and give them agency reference
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('pending_agency_application', isEqualTo: agency.reference.id)
          .get();
      
      for (final userDoc in userQuery.docs) {
        await userDoc.reference.update({
          'agency_reference': agency.reference,
          'role': FieldValue.arrayUnion(['agency']),
          'pending_agency_application': FieldValue.delete(),
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Agency "${agency.name}" has been approved successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error approving agency: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error approving agency: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _rejectAgency(AgenciesRecord agency) async {
    try {
      // Update agency status to rejected
      await agency.reference.update({
        'status': 'rejected',
      });
      
      // Clean up any pending applications
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('pending_agency_application', isEqualTo: agency.reference.id)
          .get();
      
      for (final userDoc in userQuery.docs) {
        await userDoc.reference.update({
          'pending_agency_application': FieldValue.delete(),
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Agency "${agency.name}" application has been rejected.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error rejecting agency: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error rejecting agency: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildTripsTab() {
    return Container(
      child: Text('Trips tab - TODO: Implement trips list'),
    );
  }

  Widget _buildBookingsTab() {
    return Container(
      child: Text('Bookings tab - TODO: Implement bookings list'),
    );
  }

  Widget _buildMessagesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatRooms = snapshot.data?.docs ?? [];
        
        if (chatRooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active chats', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return Row(
          children: [
            // Chat List
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(right: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat, color: Color(0xFFD76B30)),
                          const SizedBox(width: 8),
                          Text(
                            'Live Chats (${chatRooms.length})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'cleanup_old':
                                  _showCleanupDialog();
                                  break;
                                case 'cleanup_all':
                                  _showCleanupAllDialog();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'cleanup_old',
                                child: Row(
                                  children: [
                                    Icon(Icons.cleaning_services, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Cleanup Old Chats'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'cleanup_all',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_sweep, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete All Chats'),
                                  ],
                                ),
                              ),
                            ],
                            child: const Icon(Icons.more_vert, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
                          final chatRoomId = chatRooms[index].id;
                          
                          return _buildChatListItem(chatRoom, chatRoomId);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Chat Messages
            Expanded(
              flex: 2,
              child: _selectedChatRoomId != null 
                ? _buildChatMessages(_selectedChatRoomId!)
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Select a chat to view messages', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  ),
            ),
          ],
        );
      },
    );
  }

  String? _selectedChatRoomId;
  final TextEditingController _adminMessageController = TextEditingController();

  Widget _buildChatListItem(Map<String, dynamic> chatRoom, String chatRoomId) {
    final lastMessage = chatRoom['lastMessage'] ?? '';
    final userEmail = chatRoom['userEmail'] ?? 'Unknown';
    final lastMessageTime = chatRoom['lastMessageTime'] as Timestamp?;
    final isSelected = _selectedChatRoomId == chatRoomId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD76B30).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD76B30),
          child: Text(
            userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          userEmail,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lastMessage.isNotEmpty ? lastMessage : 'No messages yet',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: lastMessageTime != null 
          ? Text(
              _formatTime(lastMessageTime.toDate()),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            )
          : null,
        onTap: () {
          setState(() {
            _selectedChatRoomId = chatRoomId;
          });
        },
      ),
    );
  }

  Widget _buildChatMessages(String chatRoomId) {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Color(0xFFD76B30)),
              const SizedBox(width: 8),
              const Text(
                'Customer Support Chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showDeleteChatDialog(chatRoomId),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete Chat',
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chat_rooms')
                .doc(chatRoomId)
                .collection('messages')
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data?.docs ?? [];
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index].data() as Map<String, dynamic>;
                  final isAdmin = message['isAdmin'] ?? false;
                  
                  return _buildAdminMessageBubble(
                    message['message'] ?? '',
                    isAdmin,
                    message['senderName'] ?? '',
                    message['timestamp'] as Timestamp?,
                  );
                },
              );
            },
          ),
        ),
        // Message Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _adminMessageController,
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) => _sendAdminMessage(chatRoomId, value),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: () => _sendAdminMessage(chatRoomId, _adminMessageController.text),
                backgroundColor: const Color(0xFFD76B30),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminMessageBubble(String message, bool isAdmin, String senderName, Timestamp? timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.grey, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAdmin ? const Color(0xFFD76B30) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: isAdmin ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(timestamp.toDate()),
                      style: TextStyle(
                        color: isAdmin ? Colors.white70 : Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFD76B30),
              child: const Icon(Icons.support_agent, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sendAdminMessage(String chatRoomId, String message) async {
    if (message.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'message': message,
      'senderId': 'admin',
      'senderName': 'Support Team',
      'isAdmin': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message in chat room
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    _adminMessageController.clear();
  }

  void _showDeleteChatDialog(String chatRoomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteChatRoom(chatRoomId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteChatRoom(String chatRoomId) async {
    // Delete all messages first
    final messagesQuery = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .get();
    
    for (final doc in messagesQuery.docs) {
      await doc.reference.delete();
    }
    
    // Delete chat room
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .delete();
    
    if (_selectedChatRoomId == chatRoomId) {
      setState(() {
        _selectedChatRoomId = null;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services, color: Colors.orange),
            SizedBox(width: 8),
            Text('Cleanup Old Chats'),
          ],
        ),
        content: const Text(
          'This will delete all chat conversations that are older than 1 day. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performCleanup();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Cleanup'),
          ),
        ],
      ),
    );
  }

  void _showCleanupAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete All Chats'),
          ],
        ),
        content: const Text(
          'This will delete ALL chat conversations immediately. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performCleanupAll();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCleanup() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cleaning up old chats...'),
            ],
          ),
        ),
      );

      await ChatCleanupUtils.manualCleanupOldChats(daysOld: 1);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Reset selected chat room if it was deleted
        setState(() {
          _selectedChatRoomId = null;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Old chats cleaned up successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cleaning up chats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performCleanupAll() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Deleting all chats...'),
            ],
          ),
        ),
      );

      // Get all chat rooms and delete them
      final allChats = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .get();
      
      for (final chatDoc in allChats.docs) {
        await ChatCleanupUtils.deleteChatRoomWithMessages(chatDoc.id);
      }
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Reset selected chat room
        setState(() {
          _selectedChatRoomId = null;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All ${allChats.docs.length} chats deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting chats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUsersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'User Management',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                color: const Color(0xFF1A237E),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Admin Only',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('created_time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data?.docs ?? [];
              final filteredUsers = users.where((doc) {
                if (_searchQuery.isEmpty) return true;
                final userData = doc.data() as Map<String, dynamic>;
                final email = userData['email']?.toString().toLowerCase() ?? '';
                final displayName = userData['display_name']?.toString().toLowerCase() ?? '';
                final name = userData['name']?.toString().toLowerCase() ?? '';
                return email.contains(_searchQuery.toLowerCase()) ||
                       displayName.contains(_searchQuery.toLowerCase()) ||
                       name.contains(_searchQuery.toLowerCase());
              }).toList();

              return Column(
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Users',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${users.length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtered Results',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${filteredUsers.length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Users List
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? const Center(
                            child: Text('No users found'),
                          )
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final userDoc = filteredUsers[index];
                              final userData = userDoc.data() as Map<String, dynamic>;
                              return _buildUserCard(userDoc.id, userData);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(String uid, Map<String, dynamic> userData) {
    final email = userData['email'] ?? 'No email';
    final displayName = userData['display_name'] ?? '';
    final name = userData['name'] ?? '';
    final phoneNumber = userData['phone_number'] ?? '';
    final roles = List<String>.from(userData['role'] ?? []);
    final createdTime = userData['created_time'] as Timestamp?;
    final loyaltyPoints = userData['loyaltyPoints'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isNotEmpty ? displayName : name.isNotEmpty ? name : email.split('@').first,
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Roles
                if (roles.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 4,
                    children: roles.map((role) {
                      final isAdmin = role.toLowerCase() == 'admin';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAdmin ? Colors.red.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isAdmin ? Colors.red[700] : Colors.blue[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                // Delete Button
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    UserManagementService.showDeleteUserDialog(
                      context,
                      email: email,
                      uid: uid,
                      onDeleted: () {
                        // Refresh will happen automatically due to StreamBuilder
                        setState(() {});
                      },
                    );
                  },
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 20,
                  ),
                  tooltip: 'Delete User Completely',
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Details Row
            Row(
              children: [
                if (phoneNumber.isNotEmpty) ...[
                  Icon(Icons.phone, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                  const SizedBox(width: 4),
                  Text(
                    phoneNumber,
                    style: FlutterFlowTheme.of(context).bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.stars, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '$loyaltyPoints pts',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 14, color: FlutterFlowTheme.of(context).secondaryText),
                const SizedBox(width: 4),
                Text(
                  createdTime != null 
                    ? DateFormat('MMM dd, yyyy').format(createdTime.toDate())
                    : 'Unknown',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}