import 'dart:async';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/agency_utils.dart';
import '/utils/migration_helper.dart';
import '/components/review_import_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'agency_dashboard_model.dart';
export 'agency_dashboard_model.dart';

class AgencyDashboardWidget extends StatefulWidget {
  const AgencyDashboardWidget({super.key});

  static String routeName = 'agency_dashboard';
  static String routePath = '/agency-dashboard';

  @override
  State<AgencyDashboardWidget> createState() => _AgencyDashboardWidgetState();
}

class _AgencyDashboardWidgetState extends State<AgencyDashboardWidget> {
  late AgencyDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all';
  Timer? _debounce;
  // bool _isPreviewMode = false; // Temporarily commented out

  // Currency formatter
  static final _currency = NumberFormat.currency(symbol: '\$');

  // Consistent status colors
  static const Color _activeColor = Color(0xFF4CAF50);
  static const Color _inactiveColor = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgencyDashboardModel());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _model.dispose();
    super.dispose();
  }

  /// Check if current user is an admin (case-insensitive, no hardcoded override)
  bool _isCurrentUserAdmin() {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    
    final role = AgencyUtils.lc(userDoc.role.join(' '));
    return role.contains('admin');
  }

  /// Debounced search handler (300ms)
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

  /// Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  /// Validate trip access before navigation with proper error handling
  Future<bool> _validateTripAccess(TripsRecord trip) async {
    final isAdmin = _isCurrentUserAdmin();
    final owns = trip.agencyReference == AgencyUtils.getCurrentAgencyRef();
    
    if (!isAdmin && !owns) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied: You can only access trips from your agency'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Check if user has agency OR admin access
    bool isAgency = AgencyUtils.isCurrentUserAgency();
    bool isAdmin = _isCurrentUserAdmin();
    bool hasAccess = isAgency || isAdmin;
    
    if (!hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Agency Access Required',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'You need agency privileges to access this dashboard.',
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
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isAdmin = _isCurrentUserAdmin();
    
    return AppBar(
      backgroundColor: const Color(0xFFD76B30),
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD76B30), // Primary Orange
              Color(0xFFDBA237), // Golden Yellow
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
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = MediaQuery.of(context).size.width < 768;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin ? (isMobile ? 'Dashboard (Admin)' : 'Agency Dashboard (Admin)') 
                       : (isMobile ? 'Dashboard' : 'Agency Dashboard'),
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  color: Colors.white,
                  fontSize: isMobile ? 18 : 24,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!isMobile)
                Text(
                  isAdmin ? 'Manage all agency trips and performance' : 'Manage your trips and performance',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width < 768;
            final buttonSize = isMobile ? 40.0 : 48.0;
            final iconSize = isMobile ? 20.0 : 24.0;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(right: isMobile ? 4 : 8),
                  child: FlutterFlowIconButton(
                    borderColor: Colors.white.withOpacity(0.2),
                    borderRadius: isMobile ? 8 : 12,
                    borderWidth: 1,
                    buttonSize: buttonSize,
                    icon: Icon(
                      Icons.sync,
                      color: Colors.white,
                      size: iconSize,
                    ),
                    onPressed: () async {
                      // Temporary migration button
                      try {
                        await MigrationHelper.checkMigrationStatus();
                        await MigrationHelper.migrateBookingAgencyReferences();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Migration completed! Check console for details.')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Migration failed: $e')),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: isMobile ? 8 : 8),
                  child: FlutterFlowIconButton(
                    borderColor: Colors.white.withOpacity(0.2),
                    borderRadius: isMobile ? 8 : 12,
                    borderWidth: 1,
                    buttonSize: buttonSize,
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: iconSize,
                    ),
                    onPressed: () async {
                      context.pushNamed('create_trip');
                    },
                  ),
                ),
              ],
            );
          },
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
          
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : (isTablet ? 24 : 12),
                vertical: isMobile ? 8 : 0,
              ),
              child: Column(
                children: [
                  _buildSearchAndFilter(constraints),
                  _buildDashboardStats(constraints),
                  _buildQuickActions(constraints),
                  _buildBookingsSection(),
                  _buildMessagingInbox(),
                  _buildAnalyticsSection(),
                  _buildReviewsSection(),
                  _buildTripsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 768;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 8, 
        vertical: isMobile ? 12 : 16
      ),
      child: Column(
        children: [
          // Enhanced Search Bar with better styling
          Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFFD76B30).withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: isMobile ? '🔍 Search trips...' : '🔍 Search trips by name, location, or category...',
                hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                  color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.7),
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD76B30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFFD76B30),
                    size: 20,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 16,
                            ),
                          ),
                          onPressed: _clearSearch,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 24,
                  vertical: isMobile ? 16 : 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: const Color(0xFFD76B30).withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', Icons.all_inclusive),
                const SizedBox(width: 12),
                _buildFilterChip('Active', 'active', Icons.check_circle),
                const SizedBox(width: 12),
                _buildFilterChip('Inactive', 'inactive', Icons.cancel),
                const SizedBox(width: 12),
                _buildFilterChip('Featured', 'featured', Icons.star),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        if (_filterStatus != value) {
          setState(() {
            _filterStatus = value;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFD76B30), Color(0xFFDBA237)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD76B30).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFFDBA237).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFD76B30).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFFD76B30),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                color: isSelected
                    ? Colors.white
                    : FlutterFlowTheme.of(context).primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats(BoxConstraints constraints) {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    // If no agency reference and not admin, show zero stats
    if (!isAdmin && agencyRef == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildAgencyInfoCard(),
            const SizedBox(height: 16),
            _buildResponsiveStatsGrid(constraints, [
              {'title': 'Total Trips', 'value': '0', 'icon': Icons.flight_takeoff, 'colors': [Color(0xFFD76B30), Color(0xFFDBA237)], 'subtitle': 'trips'},
              {'title': 'Active', 'value': '0', 'icon': Icons.check_circle, 'colors': [Color(0xFFD76B30), Color(0xFFE8A657)], 'subtitle': 'trips'},
              {'title': 'Revenue', 'value': _currency.format(0), 'icon': Icons.attach_money, 'colors': [Color(0xFFDBA237), Color(0xFFD76B30)], 'subtitle': 'total'},
              {'title': 'Rating', 'value': '4.8', 'icon': Icons.star, 'colors': [Color(0xFFE8A657), Color(0xFFD76B30)], 'subtitle': 'rating'},
            ])
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<List<TripsRecord>>(
        // NOTE: A composite index may be required for this query combining
        // .where('agency_reference', ...) + .orderBy('created_at', ...)
        stream: isAdmin 
          ? queryTripsRecord() // Admin sees all trips
          : queryTripsRecord(
            queryBuilder: (r) => r
              .where('agency_reference', isEqualTo: agencyRef),
          ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              children: [
                _buildAgencyInfoCard(),
                const SizedBox(height: 16),
                _buildStatsLoading(),
              ],
            );
          }
          
          List<TripsRecord> trips = snapshot.data!;
          final activeTrips = AgencyUtils.getActiveTripsCount(trips);
          final avgRating = AgencyUtils.calculateAverageRating(trips);
          
          return Column(
            children: [
              _buildAgencyInfoCard(),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 768;
                  
                  if (isMobile) {
                    // Mobile: 2x2 Grid Layout
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildEnhancedStatCard(
                                'Total Trips',
                                trips.length.toString(),
                                Icons.flight_takeoff,
                                const [Color(0xFFD76B30), Color(0xFFDBA237)],
                                'trips',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildEnhancedStatCard(
                                'Active',
                                activeTrips.toString(),
                                Icons.check_circle,
                                const [Color(0xFFD76B30), Color(0xFFE8A657)],
                                'trips',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FutureBuilder<double>(
                                future: AgencyUtils.calculateRealTotalRevenue(
                                  _isCurrentUserAdmin() ? null : AgencyUtils.getCurrentAgencyRef(), 
                                  _isCurrentUserAdmin()
                                ),
                                builder: (context, revenueSnapshot) {
                                  final totalRevenue = revenueSnapshot.data ?? 0.0;
                                  return _buildEnhancedStatCard(
                                    'Revenue',
                                    _currency.format(totalRevenue.toInt()),
                                    Icons.attach_money,
                                    const [Color(0xFFDBA237), Color(0xFFD76B30)],
                                    'total',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildEnhancedStatCard(
                                'Rating',
                                avgRating.toStringAsFixed(1),
                                Icons.star,
                                const [Color(0xFFE8A657), Color(0xFFDBA237)],
                                'avg',
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Desktop/Tablet: Single Row Layout
                    return Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildEnhancedStatCard(
                              'Total Trips',
                              trips.length.toString(),
                              Icons.flight_takeoff,
                              const [Color(0xFFD76B30), Color(0xFFDBA237)],
                              'trips',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEnhancedStatCard(
                              'Active',
                              activeTrips.toString(),
                              Icons.check_circle,
                              const [Color(0xFFD76B30), Color(0xFFE8A657)],
                              'trips',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<double>(
                              future: AgencyUtils.calculateRealTotalRevenue(
                                _isCurrentUserAdmin() ? null : AgencyUtils.getCurrentAgencyRef(), 
                                _isCurrentUserAdmin()
                              ),
                              builder: (context, revenueSnapshot) {
                                final totalRevenue = revenueSnapshot.data ?? 0.0;
                                return _buildEnhancedStatCard(
                                  'Revenue',
                                  _currency.format(totalRevenue.toInt()),
                                  Icons.attach_money,
                                  const [Color(0xFFDBA237), Color(0xFFD76B30)],
                                  'total',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEnhancedStatCard(
                              'Rating',
                              avgRating.toStringAsFixed(1),
                              Icons.star,
                              const [Color(0xFFE8A657), Color(0xFFDBA237)],
                              'avg',
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      height: 160,
      child: Row(
        children: List.generate(4, (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FlutterFlowTheme.of(context).secondaryBackground,
                  FlutterFlowTheme.of(context).secondaryBackground.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFD76B30),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
      
  Widget _buildEnhancedStatCard(String title, String value, IconData icon, List<Color> colors, String type) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: colors[1].withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            // Add haptic feedback
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // Add subtle inner glow
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (type == 'trips' || type == 'total')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          type == 'trips' ? 'TRIPS' : 'TOTAL',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 0.9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BoxConstraints constraints) {
    final isMobile = constraints.maxWidth < 768;
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 0 : 16, 
        vertical: 8
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD76B30), Color(0xFFDBA237)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Quick Actions',
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isMobile || constraints.maxWidth > 400) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD76B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '5 ACTIONS',
                      style: TextStyle(
                        color: const Color(0xFFD76B30),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildResponsiveActionGrid(constraints, [
            {'title': 'Create Trip', 'icon': Icons.add_location, 'colors': [Color(0xFFD76B30), Color(0xFFDBA237)], 'onTap': () => context.pushNamed('create_trip')},
            {'title': 'CSV Upload', 'icon': Icons.upload_file, 'colors': [Color(0xFFDBA237), Color(0xFFE8A657)], 'onTap': () => context.pushNamed('agencyCsvUpload')},
            {'title': 'View Bookings', 'icon': Icons.book_online, 'colors': [Color(0xFFE8A657), Color(0xFFD76B30)], 'onTap': () => _showAllBookingsDialog()},
            {'title': 'Import Reviews', 'icon': Icons.rate_review, 'colors': [Color(0xFF4CAF50), Color(0xFF66BB6A)], 'onTap': () => _showReviewImportDialog()},
            // {'title': 'Preview Mode', 'icon': Icons.preview, 'colors': [Color(0xFF2196F3), Color(0xFF42A5F5)], 'onTap': () => _togglePreviewMode()},
          ]),
        ],
      ),
    );
  }

  void _showReviewImportDialog() {
    showDialog(
      context: context,
      builder: (context) => const ReviewImportDialog(),
    );
  }

  // Temporarily commented out preview mode functionality
  // void _togglePreviewMode() {
  //   if (_isPreviewMode) {
  //     // Exit preview mode - stay on dashboard
  //     setState(() {
  //       _isPreviewMode = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Exited customer preview mode'),
  //         backgroundColor: Colors.grey.shade600,
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   } else {
  //     // Enter preview mode - go to customer view
  //     setState(() {
  //       _isPreviewMode = true;
  //     });
  //     
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Viewing as customer - tap "Exit Preview" to return'),
  //         backgroundColor: const Color(0xFF2196F3),
  //         behavior: SnackBarBehavior.floating,
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //     
  //     // Navigate to home page to see customer view
  //     context.pushNamed('home');
  //   }
  // }

  Widget _buildQuickActionCard(String title, IconData icon, List<Color> colors, VoidCallback onTap) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: colors[1].withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsSection() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    print('Agency Dashboard - isAdmin: $isAdmin, agencyRef: $agencyRef');
    print('Current User: ${currentUser?.uid}');
    print('Current User Email: ${currentUser?.email}');
    print('User Document: ${currentUserDocument?.reference.path}');
    
    // Test basic Firestore connectivity and auth status
    _testFirestoreConnection();
    _debugAuthStatus();
    
    // If no agency reference and not admin, show setup message
    if (!isAdmin && agencyRef == null) {
      return _buildNoAgencyReferenceState();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bookings header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.book_online,
                  color: const Color(0xFFD76B30),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Bookings',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllBookingsDialog(),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: const Color(0xFFD76B30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bookings stream
          StreamBuilder<List<BookingsRecord>>(
            stream: isAdmin 
              ? queryBookingsRecord(
                  queryBuilder: (q) => q.orderBy('created_at', descending: true).limit(5),
                )
              : agencyRef != null
                ? queryBookingsRecord(
                    queryBuilder: (q) {
                      print('DEBUG: Querying bookings for agency: ${agencyRef!.path}');
                      // TEMPORARY: Query all bookings and filter in memory
                      // TODO: Restore agency_reference filter after migration
                      // ULTRA SIMPLE TEST - just get any bookings
                      print('DEBUG: Making ultra simple bookings query...');
                      return q.limit(5);
                    },
                  )
                : Stream.value(<BookingsRecord>[]),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Main booking query error: ${snapshot.error}');
                final errorString = snapshot.error.toString();
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading bookings',
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorString.contains('permission-denied') 
                          ? 'Permission denied. Please ensure:\n• Firestore rules are deployed\n• Existing bookings have agency_reference field'
                          : 'Please check your permissions or try refreshing',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Show debugging info dialog
                          _showDebuggingInfo();
                        },
                        child: Text('Debug Info'),
                      ),
                    ],
                  ),
                );
              }
              
              if (!snapshot.hasData) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  height: 200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                    ),
                  ),
                );
              }
              
              if (snapshot.data!.isEmpty) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.book_online_outlined,
                        size: 48,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bookings for your trips will appear here',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              // TEMPORARY: Filter bookings client-side until migration is complete
              final allBookings = snapshot.data!;
              print('DEBUG: Got ${allBookings.length} bookings from query');
              for (var booking in allBookings) {
                print('DEBUG: Booking ${booking.reference.id} - agency_ref: ${booking.agencyReference?.path} - has_ref: ${booking.hasAgencyReference()}');
              }
              print('DEBUG: Looking for agency path: ${agencyRef?.path}');
              
              final relevantBookings = isAdmin ? allBookings : allBookings.where((booking) {
                // If booking has agency_reference, check if it matches
                if (booking.hasAgencyReference()) {
                  final matches = booking.agencyReference?.path == agencyRef?.path;
                  print('DEBUG: Booking ${booking.reference.id} matches agency: $matches');
                  return matches;
                }
                // If no agency_reference, skip for now (will be migrated)
                print('DEBUG: Booking ${booking.reference.id} has no agency_reference');
                return false;
              }).toList();
              
              print('DEBUG: Found ${relevantBookings.length} relevant bookings after filtering');
              
              if (relevantBookings.isEmpty) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.book_online_outlined,
                        size: 48,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bookings yet',
                        style: FlutterFlowTheme.of(context).headlineSmall.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAdmin 
                          ? 'No bookings in the system yet'
                          : 'No bookings for your agency yet.\nExisting bookings may need migration.',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: const Color(0x1A000000),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: relevantBookings.take(5).map((booking) {
                    return _buildBookingCard(booking);
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingsRecord booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with trip title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.tripTitle,
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              _buildBookingStatusChip(booking.bookingStatus),
            ],
          ),
          const SizedBox(height: 16),
          
          // Customer Information Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 18,
                      color: Color(0xFFD76B30),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Customer Information',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD76B30),
                      ),
                    ),
                    const Spacer(),
                    FutureBuilder<UsersRecord?>(
                      future: booking.hasUserReference() 
                          ? UsersRecord.getDocumentOnce(booking.userReference!)
                          : null,
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data;
                        final verificationStatus = booking.customerVerificationStatus.isNotEmpty 
                            ? booking.customerVerificationStatus
                            : (userData?.nationalIdStatus ?? 'unverified');
                        
                        return _buildVerificationBadge(verificationStatus);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Customer profile row with avatar
                Row(
                  children: [
                    // Customer avatar
                    FutureBuilder<UsersRecord?>(
                      future: booking.hasUserReference() 
                          ? UsersRecord.getDocumentOnce(booking.userReference!)
                          : null,
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data;
                        final profilePhoto = booking.customerProfilePhoto.isNotEmpty 
                            ? booking.customerProfilePhoto
                            : (userData?.profilePhotoUrl?.isNotEmpty == true 
                                ? userData!.profilePhotoUrl
                                : (userData?.photoUrl?.isNotEmpty == true 
                                    ? userData!.photoUrl 
                                    : ''));
                        
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: FlutterFlowTheme.of(context).alternate,
                            image: profilePhoto.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(profilePhoto),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profilePhoto.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 30,
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    
                    // Customer details
                    Expanded(
                      child: FutureBuilder<UsersRecord?>(
                        future: booking.hasUserReference() 
                            ? UsersRecord.getDocumentOnce(booking.userReference!)
                            : null,
                        builder: (context, userSnapshot) {
                          final userData = userSnapshot.data;
                          
                          // Use customer info from booking if available, otherwise fallback to user document
                          final displayName = booking.customerName.isNotEmpty 
                              ? booking.customerName 
                              : (userData?.displayName?.isNotEmpty == true 
                                  ? userData!.displayName 
                                  : (userData?.name?.isNotEmpty == true 
                                      ? userData!.name 
                                      : (booking.customerEmail.isNotEmpty 
                                          ? booking.customerEmail.split('@').first 
                                          : (userData?.email?.isNotEmpty == true
                                              ? userData!.email.split('@').first 
                                              : 'Unknown Customer'))));
                          
                          final email = booking.customerEmail.isNotEmpty 
                              ? booking.customerEmail
                              : (userData?.email ?? 'Email not available');
                          
                          final phone = booking.customerPhone.isNotEmpty 
                              ? booking.customerPhone
                              : (userData?.phoneNumber ?? 'Phone not available');
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: FlutterFlowTheme.of(context).bodyLarge.override(
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email,
                                    size: 14,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: FlutterFlowTheme.of(context).bodySmall.override(
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    phone,
                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    // Loyalty points
                    FutureBuilder<UsersRecord?>(
                      future: booking.hasUserReference() 
                          ? UsersRecord.getDocumentOnce(booking.userReference!)
                          : null,
                      builder: (context, userSnapshot) {
                        final userData = userSnapshot.data;
                        final loyaltyPoints = booking.customerLoyaltyPoints > 0 
                            ? booking.customerLoyaltyPoints
                            : (userData?.loyaltyPoints ?? 0);
                        
                        if (loyaltyPoints <= 0) return const SizedBox.shrink();
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$loyaltyPoints',
                                style: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Booking details
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                '${booking.travelerCount} traveler${booking.travelerCount > 1 ? 's' : ''}',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.attach_money,
                size: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                _currency.format(booking.totalAmount),
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(booking.createdAt ?? DateTime.now()),
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
          
          // Special requests if any
          if (booking.specialRequests.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Special Requests:',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.specialRequests,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Action buttons
          if (booking.bookingStatus == 'pending_agency_approval') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveBooking(booking),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _denyBooking(booking),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    
    switch (status) {
      case 'pending_agency_approval':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        displayText = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        displayText = 'Confirmed';
        break;
      case 'denied':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        displayText = 'Denied';
        break;
      case 'cancelled':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        displayText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(String verificationStatus) {
    Color backgroundColor;
    Color iconColor;
    IconData iconData;
    String tooltip;
    
    switch (verificationStatus) {
      case 'verified':
        backgroundColor = Colors.green.shade100;
        iconColor = Colors.green.shade700;
        iconData = Icons.verified_user;
        tooltip = 'ID Verified Customer';
        break;
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        iconColor = Colors.orange.shade700;
        iconData = Icons.pending;
        tooltip = 'ID Verification Pending';
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade100;
        iconColor = Colors.red.shade700;
        iconData = Icons.cancel;
        tooltip = 'ID Verification Rejected';
        break;
      default: // unverified
        backgroundColor = Colors.grey.shade100;
        iconColor = Colors.grey.shade600;
        iconData = Icons.shield;
        tooltip = 'ID Not Verified';
    }
    
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          size: 16,
          color: iconColor,
        ),
      ),
    );
  }

  Future<void> _approveBooking(BookingsRecord booking) async {
    try {
      await booking.reference.update({
        'booking_status': 'confirmed',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking approved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _denyBooking(BookingsRecord booking) async {
    try {
      await booking.reference.update({
        'booking_status': 'denied',
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking denied.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error denying booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAllBookingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'All Bookings',
                style: TextStyle(color: const Color(0xFFD76B30)),
              ),
              backgroundColor: Colors.white,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.close, color: const Color(0xFFD76B30)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: _buildAllBookingsContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildAllBookingsContent() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    return StreamBuilder<List<BookingsRecord>>(
      stream: isAdmin 
        ? queryBookingsRecord(
            queryBuilder: (q) => q.orderBy('created_at', descending: true),
          )
        : agencyRef != null
          ? queryBookingsRecord(
              queryBuilder: (q) {
                print('DEBUG: Querying ALL bookings for agency: ${agencyRef!.path}');
                // TEMPORARY: Query all bookings and filter client-side
                return q.orderBy('created_at', descending: true);
              },
            )
          : Stream.value(<BookingsRecord>[]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Booking query error: ${snapshot.error}');
          return Container(
            margin: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bookings',
                    style: FlutterFlowTheme.of(context).headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your permissions',
                    style: FlutterFlowTheme.of(context).bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
            ),
          );
        }
        
        // TEMPORARY: Filter bookings client-side BEFORE checking if empty
        final allBookings = snapshot.data!;
        print('DEBUG [View All]: Got ${allBookings.length} bookings from query');
        for (var booking in allBookings) {
          print('DEBUG [View All]: Booking ${booking.reference.id} - agency_ref: ${booking.agencyReference?.path} - has_ref: ${booking.hasAgencyReference()}');
        }
        print('DEBUG [View All]: Looking for agency path: ${agencyRef?.path}');
        
        final relevantBookings = isAdmin ? allBookings : allBookings.where((booking) {
          if (booking.hasAgencyReference()) {
            final matches = booking.agencyReference?.path == agencyRef?.path;
            print('DEBUG [View All]: Booking ${booking.reference.id} matches agency: $matches');
            return matches;
          }
          print('DEBUG [View All]: Booking ${booking.reference.id} has no agency_reference');
          return false;
        }).toList();
        
        print('DEBUG [View All]: Found ${relevantBookings.length} relevant bookings after filtering');
        
        if (relevantBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_online_outlined,
                  size: 64,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                const SizedBox(height: 16),
                Text(
                  'No bookings found',
                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAdmin 
                    ? 'No bookings in the system yet'
                    : 'No bookings for your agency yet.\nBookings may need migration.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: relevantBookings.length,
          itemBuilder: (context, index) {
            final booking = relevantBookings[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: const Color(0x1A000000),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildBookingCard(booking),
            );
          },
        );
      },
    );
  }

  void _showDebuggingInfo() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = AgencyUtils.getCurrentAgencyRef();
    final userDoc = currentUserDocument;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debug Information',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                  color: const Color(0xFFD76B30),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text('User ID: ${currentUser?.uid ?? 'None'}'),
              Text('Is Admin: $isAdmin'),
              Text('Agency Reference: ${agencyRef?.path ?? 'None'}'),
              Text('User Roles: ${userDoc?.role ?? []}'),
              const SizedBox(height: 16),
              Text(
                'Next Steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('1. Deploy Firestore rules: firebase deploy --only firestore:rules'),
              Text('2. Check if bookings have agency_reference field'),
              Text('3. Run migration script if needed'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testFirestoreConnection() async {
    try {
      print('🧪 Testing Firestore connection...');
      
      // Test 1: Can we access users collection (should work for auth user)
      final userTest = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      print('✅ Users collection access: ${userTest.exists}');
      
      // Test 2: Can we read trips collection (should be public)
      final tripsTest = await FirebaseFirestore.instance
          .collection('trips')
          .limit(1)
          .get();
      print('✅ Trips collection access: ${tripsTest.docs.length} trips');
      
      // Test 3: Can we read bookings collection (should work with new rules)
      final bookingsTest = await FirebaseFirestore.instance
          .collection('bookings')
          .limit(1)
          .get();
      print('✅ Bookings collection access: ${bookingsTest.docs.length} bookings');
      
    } catch (e) {
      print('❌ Firestore connection test failed: $e');
    }
  }

  Widget _buildTripsSection() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    // If no agency reference and not admin, show setup message
    if (!isAdmin && agencyRef == null) {
      return _buildNoAgencyReferenceState();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Single StreamBuilder to avoid duplicate queries
          StreamBuilder<List<TripsRecord>>(
            // NOTE: A composite index may be required for this query combining
            // .where('agency_reference', ...) + .orderBy('created_at', ...)
            stream: isAdmin 
              ? queryTripsRecord() // Admin sees all trips
              : queryTripsRecord(
                  queryBuilder: (r) => r
                    .where('agency_reference', isEqualTo: agencyRef),
                ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    _buildTripsHeader('Loading...'),
                    const SizedBox(height: 16),
                    _buildTripsLoading(),
                  ],
                );
              }
              
              List<TripsRecord> trips = snapshot.data!;
              List<TripsRecord> filteredTrips = AgencyUtils.filterTrips(
                trips,
                _searchQuery,
                _filterStatus,
              );
              
              return Column(
                children: [
                  _buildTripsHeader('${filteredTrips.length} trips'),
                  const SizedBox(height: 16),
                  // Trips grid
                  if (filteredTrips.isEmpty)
                    _buildEnhancedEmptyState(context)
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Fixed order grid breakpoints
                        int crossAxisCount;
                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 800) {
                          crossAxisCount = 3;
                        } else {
                          crossAxisCount = 2;
                        }
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = filteredTrips[index];
                            return _buildEnhancedTripCard(context, trip, index);
                          },
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripsHeader(String countText) {
    final isAdmin = _isCurrentUserAdmin();
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFD76B30),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            isAdmin ? 'All Agency Trips' : 'Your Trips',
            style: FlutterFlowTheme.of(context).titleLarge.override(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          countText,
          style: FlutterFlowTheme.of(context).labelMedium.override(
            fontSize: 14,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildTripsLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFD76B30),
              ),
              strokeWidth: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyInfoCard() {
    final userDoc = currentUserDocument;
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = AgencyUtils.getCurrentAgencyRef();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD76B30).withOpacity(0.1),
            const Color(0xFFDBA237).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD76B30).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD76B30), Color(0xFFDBA237)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.business,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdmin ? 'Admin Dashboard' : 'Agency Dashboard',
                  style: FlutterFlowTheme.of(context).titleMedium.override(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin 
                    ? 'Manage all agencies and trips system-wide'
                    : agencyRef != null 
                      ? 'Manage your agency trips and bookings'
                      : 'Agency setup required',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontSize: 14,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                if (userDoc?.email != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      userDoc!.email,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        fontSize: 12,
                        color: const Color(0xFFD76B30),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD76B30).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAdmin ? 'ADMIN' : 'AGENCY',
              style: FlutterFlowTheme.of(context).labelSmall.override(
                color: const Color(0xFFD76B30),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTripCard(BuildContext context, TripsRecord trip, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      child: GestureDetector(
        onTap: () async {
          if (await _validateTripAccess(trip)) {
            _showTripDetails(context, trip);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD76B30).withOpacity(0.1),
              width: 1,
            ),
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
              // Trip Image with Status Badge
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 140,
                      child: trip.image.isNotEmpty
                          ? Image.network(
                              trip.image,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: double.infinity,
                                  height: 140,
                                  color: FlutterFlowTheme.of(context).alternate,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFFD76B30),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 140,
                                  color: FlutterFlowTheme.of(context).alternate,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: double.infinity,
                              height: 140,
                              color: FlutterFlowTheme.of(context).alternate,
                              child: const Icon(
                                Icons.flight_takeoff,
                                color: Color(0xFFD76B30),
                                size: 40,
                              ),
                            ),
                    ),
                    // Status Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: trip.availableSeats > 0 ? _activeColor : _inactiveColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trip.availableSeats > 0 ? Icons.check_circle : Icons.cancel,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.availableSeats > 0 ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Price Tag
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currency.format(trip.price),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Trip Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.title,
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              trip.location,
                              style: FlutterFlowTheme.of(context).labelMedium.override(
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trip.rating != null ? trip.rating!.toStringAsFixed(1) : '0.0',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD76B30).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${trip.availableSeats} seats',
                              style: const TextStyle(
                                color: Color(0xFFD76B30),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Edit',
                              Icons.edit,
                              const Color(0xFFD76B30),
                              () async {
                                if (await _validateTripAccess(trip)) {
                                  context.pushNamed(
                                    'edit_trip',
                                    queryParameters: {
                                      'tripRef': serializeParam(trip.reference, ParamType.DocumentReference),
                                    }.withoutNulls,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              'Delete',
                              Icons.delete,
                              FlutterFlowTheme.of(context).error,
                              () async {
                                if (await _validateTripAccess(trip)) {
                                  _showDeleteConfirmation(context, trip);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 36,
      child: FFButtonWidget(
        onPressed: onPressed,
        text: text,
        icon: Icon(icon),
        options: FFButtonOptions(
          height: 36,
          padding: EdgeInsets.zero,
          iconPadding: EdgeInsets.zero,
          color: color,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildNoAgencyReferenceState() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.orange.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Agency Setup Required',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your account needs to be linked to an agency to view and manage trips.',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontSize: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact your administrator or support team to complete the setup.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FFButtonWidget(
                  onPressed: () => context.pop(),
                  text: 'Go Back',
                  options: FFButtonOptions(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 2,
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FFButtonWidget(
                  onPressed: () {
                    setState(() {});
                  },
                  text: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  options: FFButtonOptions(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: const Color(0xFFD76B30),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD76B30).withOpacity(0.1),
                  const Color(0xFFD76B30).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flight_takeoff,
              color: Color(0xFFD76B30),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No trips found',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != 'all'
                ? 'Try adjusting your search or filters'
                : 'Create your first trip to get started',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontSize: 16,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FFButtonWidget(
            onPressed: () async {
              context.pushNamed('create_trip');
            },
            text: 'Create Your First Trip',
            icon: const Icon(Icons.add),
            options: FFButtonOptions(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              color: const Color(0xFFD76B30),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 768;
        
        return Container(
          margin: EdgeInsets.only(
            bottom: isMobile ? 16 : 8, 
            right: isMobile ? 16 : 8
          ),
          child: isMobile
              ? FloatingActionButton(
                  onPressed: () async {
                    context.pushNamed('create_trip');
                  },
                  backgroundColor: const Color(0xFFD76B30),
                  elevation: 6,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                )
              : FloatingActionButton.extended(
                  onPressed: () async {
                    context.pushNamed('create_trip');
                  },
                  backgroundColor: const Color(0xFFD76B30),
                  elevation: 8,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text(
                    'New Trip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showTripDetails(BuildContext context, TripsRecord trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add more trip details here
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, TripsRecord trip) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_forever,
                  color: FlutterFlowTheme.of(context).error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Trip',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${trip.title}"?',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontSize: 16,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: FlutterFlowTheme.of(context).error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone and will remove all associated data.',
                        style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontSize: 14,
                          color: FlutterFlowTheme.of(context).error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                child: Text(
                  'Delete',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  try {
                    await trip.reference.delete();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Trip deleted successfully'),
                          backgroundColor: FlutterFlowTheme.of(context).success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting trip: $e'),
                          backgroundColor: FlutterFlowTheme.of(context).error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsSection() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    // If no agency reference and not admin, show empty analytics
    if (!isAdmin && agencyRef == null) {
      return Container();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD76B30),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Analytics & Insights',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<TripsRecord>>(
            stream: isAdmin 
              ? queryTripsRecord() 
              : queryTripsRecord(
                  queryBuilder: (r) => r
                    .where('agency_reference', isEqualTo: agencyRef),
                ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildAnalyticsLoading();
              }
              
              final trips = snapshot.data!;
              final monthlyRevenue = AgencyUtils.getMonthlyRevenue(trips);
              final topDestinations = AgencyUtils.getTopDestinations(trips, limit: 3);
              
              // Get real booking statistics, booking rate, and performance trends
              return FutureBuilder<Map<String, dynamic>>(
                future: Future.wait([
                  AgencyUtils.getCustomerActivityStatsFromBookings(agencyRef, isAdmin),
                  AgencyUtils.calculateRealBookingRate(trips, agencyRef, isAdmin),
                  AgencyUtils.getRealPerformanceTrends(agencyRef, isAdmin),
                ]).then((results) => {
                  'customerStats': results[0],
                  'bookingRate': results[1],
                  'trends': results[2],
                }),
                builder: (context, futureSnapshot) {
                  if (!futureSnapshot.hasData) {
                    return _buildAnalyticsLoading();
                  }
                  
                  final data = futureSnapshot.data;
                  final customerStats = data?['customerStats'] ?? {
                    'totalCustomers': 0,
                    'totalBookings': 0,
                    'averageBookingsPerCustomer': 0.0,
                    'averageRevenuePerCustomer': 0.0,
                    'customerRetentionRate': 0.0,
                  };
                  final bookingRate = data?['bookingRate'] ?? 0.0;
                  final trends = data?['trends'] ?? {
                    'revenueGrowth': 0.0,
                    'bookingGrowth': 0.0,
                    'currentMonthRevenue': 0,
                    'previousMonthRevenue': 0,
                    'currentMonthBookings': 0,
                    'previousMonthBookings': 0,
                  };
              
              return Column(
                children: [
                  // Performance Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Booking Rate',
                          '${bookingRate.toStringAsFixed(1)}%',
                          Icons.trending_up,
                          trends['bookingGrowth'] >= 0 ? Colors.green : Colors.red,
                          trends['bookingGrowth'] >= 0 ? '+${trends['bookingGrowth'].toStringAsFixed(1)}%' : '${trends['bookingGrowth'].toStringAsFixed(1)}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Revenue Growth',
                          '${trends['revenueGrowth'] >= 0 ? '+' : ''}${trends['revenueGrowth'].toStringAsFixed(1)}%',
                          Icons.attach_money,
                          trends['revenueGrowth'] >= 0 ? Colors.green : Colors.red,
                          'This Month',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Customer Activity Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                            Icon(
                              Icons.people,
                              color: const Color(0xFFD76B30),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Customer Activity',
                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomerStatItem(
                                'Total Bookings',
                                customerStats['totalBookings'].toString(),
                                Icons.book_online,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              child: _buildCustomerStatItem(
                                'Avg per Customer',
                                _currency.format(customerStats['averageRevenuePerCustomer']?.toInt() ?? 0),
                                Icons.person,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Top Destinations Card
                  if (topDestinations.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                              Icon(
                                Icons.location_on,
                                color: const Color(0xFFD76B30),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Top Performing Destinations',
                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...topDestinations.asMap().entries.map((entry) {
                            final index = entry.key;
                            final destination = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(bottom: index < topDestinations.length - 1 ? 12 : 0),
                              child: _buildDestinationItem(
                                destination['location'],
                                destination['revenue'],
                                destination['bookings'],
                                index + 1,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                ],
              );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsLoading() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFD76B30),
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading analytics...',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleLarge.override(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          Text(
            title,
            style: FlutterFlowTheme.of(context).labelMedium.override(
              fontSize: 12,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerStatItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFD76B30),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: FlutterFlowTheme.of(context).titleMedium.override(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          Text(
            title,
            style: FlutterFlowTheme.of(context).labelSmall.override(
              fontSize: 11,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationItem(String location, int revenue, int bookings, int rank) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFD76B30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: FlutterFlowTheme.of(context).titleSmall.override(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              Text(
                '$bookings bookings',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                  fontSize: 11,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
        ),
        Text(
          _currency.format(revenue),
          style: FlutterFlowTheme.of(context).titleSmall.override(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD76B30),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    // If no agency reference and not admin, show empty reviews
    if (!isAdmin && agencyRef == null) {
      return Container();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD76B30),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Customer Reviews',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showAllReviews(),
                  child: Text(
                    'View All',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      color: const Color(0xFFD76B30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<List<TripsRecord>>(
            stream: isAdmin 
              ? queryTripsRecord() 
              : queryTripsRecord(
                  queryBuilder: (r) => r
                    .where('agency_reference', isEqualTo: agencyRef),
                ),
            builder: (context, tripsSnapshot) {
              if (!tripsSnapshot.hasData) {
                return _buildReviewsLoading();
              }
              
              final trips = tripsSnapshot.data!;
              final tripRefs = trips.map((trip) => trip.reference).toList();
              
              if (tripRefs.isEmpty) {
                return _buildNoReviewsState();
              }
              
              return StreamBuilder<List<ReviewsRecord>>(
                stream: queryReviewsRecord(
                  queryBuilder: (r) => r
                    .limit(10), // Show recent reviews
                ),
                builder: (context, reviewsSnapshot) {
                  if (!reviewsSnapshot.hasData) {
                    return _buildReviewsLoading();
                  }
                  
                  final reviews = reviewsSnapshot.data!;
                  
                  if (reviews.isEmpty) {
                    return _buildNoReviewsState();
                  }
                  
                  return Column(
                    children: [
                      // Reviews summary
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD76B30).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Color(0xFFD76B30),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${reviews.length} Recent Reviews',
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: FlutterFlowTheme.of(context).primaryText,
                                    ),
                                  ),
                                  Text(
                                    'Average: ${_calculateAverageRating(reviews).toStringAsFixed(1)}★',
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildRatingDistribution(reviews),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Recent reviews list
                      ...reviews.take(3).map((review) => _buildReviewCard(review)).toList(),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsLoading() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFFD76B30),
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading reviews...',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoReviewsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: FlutterFlowTheme.of(context).titleMedium.override(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer reviews will appear here once your trips receive feedback',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewsRecord review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User avatar or initials
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFD76B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _getUserInitials(review.userName),
                    style: const TextStyle(
                      color: Color(0xFFD76B30),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : 'Anonymous',
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      review.tripTitle.isNotEmpty ? review.tripTitle : 'Trip Review',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) => 
                  Icon(
                    Icons.star,
                    color: index < review.rating.round() ? Colors.amber : Colors.grey.shade300,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: FlutterFlowTheme.of(context).bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (review.createdAt != null) ...[
            const SizedBox(height: 8),
            Text(
              _formatReviewDate(review.createdAt!),
              style: FlutterFlowTheme.of(context).bodySmall.override(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(List<ReviewsRecord> reviews) {
    final ratingCounts = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingCounts[i] = reviews.where((r) => r.rating.round() == i).length;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int rating = 5; rating >= 1; rating--)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$rating',
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: reviews.isEmpty ? 0.0 : (ratingCounts[rating] ?? 0) / reviews.length,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD76B30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  double _calculateAverageRating(List<ReviewsRecord> reviews) {
    if (reviews.isEmpty) return 0.0;
    return reviews.fold<double>(0.0, (sum, review) => sum + review.rating) / reviews.length;
  }

  String _getUserInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showAllReviews() {
    // Navigate to a dedicated reviews page or show in a dialog
    context.pushNamed('reviews');
  }

  void _debugAuthStatus() {
    print('=== AUTH DEBUG INFO ===');
    print('Current user: ${currentUser?.uid}');
    print('Current user email: ${currentUser?.email}');
    print('Is authenticated: ${currentUser != null}');
    print('User is logged in: ${loggedIn}');
    print('========================');
  }

  // Responsive helper methods
  Widget _buildResponsiveStatsGrid(BoxConstraints constraints, List<Map<String, dynamic>> stats) {
    final isMobile = constraints.maxWidth < 768;
    final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
    
    final crossAxisCount = isMobile ? 2 : (isTablet ? 4 : 4);
    final childAspectRatio = isMobile ? 1.3 : 1.5;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 8 : 12,
        mainAxisSpacing: isMobile ? 8 : 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildEnhancedStatCard(
          stat['title'],
          stat['value'],
          stat['icon'],
          stat['colors'],
          stat['subtitle'],
        );
      },
    );
  }

  Widget _buildResponsiveActionGrid(BoxConstraints constraints, List<Map<String, dynamic>> actions) {
    final isMobile = constraints.maxWidth < 768;
    final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
    
    final crossAxisCount = isMobile ? 1 : (isTablet ? 3 : 5);
    final childAspectRatio = isMobile ? 2.5 : 1.8;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 8 : 12,
        mainAxisSpacing: isMobile ? 8 : 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildQuickActionCard(
          action['title'],
          action['icon'],
          action['colors'],
          action['onTap'],
        );
      },
    );
  }

  Widget _buildMessagingInbox() {
    final currentAgencyRef = AgencyUtils.getCurrentAgencyRef();
    final isAdmin = _isCurrentUserAdmin();
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
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
              Text(
                'Customer Messages',
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD76B30),
                ),
              ),
              Icon(
                Icons.message,
                color: const Color(0xFFD76B30),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<MessagesRecord>>(
            stream: isAdmin
                ? MessagesRecord.collection
                    .where('message_type', whereIn: ['customer_to_admin', 'customer_to_agency'])
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => MessagesRecord.fromSnapshot(doc))
                        .toList())
                : MessagesRecord.collection
                    .where('agency_reference', isEqualTo: currentAgencyRef)
                    .where('message_type', isEqualTo: 'customer_to_agency')
                    .orderBy('timestamp', descending: true)
                    .limit(5)
                    .snapshots()
                    .map((snapshot) => snapshot.docs
                        .map((doc) => MessagesRecord.fromSnapshot(doc))
                        .toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD76B30),
                  ),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customer messages will appear here',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              final messages = snapshot.data!;
              return Column(
                children: [
                  ...messages.map((message) => _buildMessageCard(message)).toList(),
                  const SizedBox(height: 16),
                  FFButtonWidget(
                    onPressed: () {
                      // TODO: Navigate to full messaging interface
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Full messaging interface coming soon!'),
                        ),
                      );
                    },
                    text: 'View All Messages',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 44,
                      color: const Color(0xFFD76B30),
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(MessagesRecord message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: message.readStatus 
            ? FlutterFlowTheme.of(context).primaryBackground
            : const Color(0xFFD76B30).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: message.readStatus 
              ? FlutterFlowTheme.of(context).alternate
              : const Color(0xFFD76B30).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!message.readStatus)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD76B30),
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                ),
              StreamBuilder<UsersRecord>(
                stream: message.from != null
                    ? UsersRecord.getDocument(message.from!)
                    : null,
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Text(
                      'Customer',
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }
                  final user = userSnapshot.data!;
                  return Expanded(
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName : user.email,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
              Text(
                message.timestamp != null
                    ? DateFormat('MMM dd, HH:mm').format(message.timestamp!)
                    : '',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: FlutterFlowTheme.of(context).bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (message.tripReference != null) ...[
            const SizedBox(height: 8),
            StreamBuilder<TripsRecord>(
              stream: TripsRecord.getDocument(message.tripReference!),
              builder: (context, tripSnapshot) {
                if (!tripSnapshot.hasData) return const SizedBox();
                final trip = tripSnapshot.data!;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).alternate,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Re: ${trip.title}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FFButtonWidget(
                onPressed: () {
                  _showReplyDialog(message);
                },
                text: 'Reply',
                options: FFButtonOptions(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: const Color(0xFFD76B30),
                  textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(MessagesRecord originalMessage) {
    final TextEditingController replyController = TextEditingController();
    final currentAgencyRef = AgencyUtils.getCurrentAgencyRef();
    final isAdmin = _isCurrentUserAdmin();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Customer'),
        content: SizedBox(
          width: 300,
          child: TextField(
            controller: replyController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Type your reply...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FFButtonWidget(
            onPressed: () async {
              if (replyController.text.trim().isEmpty) return;
              
              try {
                // Create reply message
                await MessagesRecord.collection.add({
                  'from': currentUserReference,
                  'to': originalMessage.from,
                  'trip_reference': originalMessage.tripReference,
                  'content': replyController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                  'message_type': isAdmin ? 'admin_to_customer' : 'agency_to_customer',
                  'read_status': false,
                  'agency_reference': isAdmin ? originalMessage.agencyReference : currentAgencyRef,
                });
                
                // Mark original message as read
                await originalMessage.reference.update({'read_status': true});
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply sent successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending reply: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            text: 'Send Reply',
            options: FFButtonOptions(
              color: const Color(0xFFD76B30),
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}