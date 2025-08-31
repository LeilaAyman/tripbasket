import 'dart:async';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/agency_utils.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminDashboardModel());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
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
    return Container(
      child: Text('Agencies tab - TODO: Implement agencies list'),
    );
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
    return Container(
      child: Text('Messages tab - TODO: Implement messages list'),
    );
  }
}