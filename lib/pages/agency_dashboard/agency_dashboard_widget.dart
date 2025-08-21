import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/agency_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgencyDashboardModel());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  /// Check if current user is an admin
  bool _isCurrentUserAdmin() {
    final userDoc = currentUserDocument;
    print('DEBUG AgencyDashboard: Checking admin status');
    print('DEBUG AgencyDashboard: userDoc: $userDoc');
    print('DEBUG AgencyDashboard: userDoc?.role: ${userDoc?.role}');
    
    if (userDoc == null) {
      print('DEBUG AgencyDashboard: userDoc is null, returning false');
      return false;
    }
    
    // TEMPORARY FIX: Allow adv@gmail.com access
    if (userDoc.email == 'adv@gmail.com') {
      print('DEBUG AgencyDashboard: Allowing access for adv@gmail.com');
      return true;
    }
    
    bool isAdmin = userDoc.role.contains('admin');
    print('DEBUG AgencyDashboard: isAdmin result: $isAdmin');
    return isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    // Check if user has agency OR admin access
    bool isAgency = AgencyUtils.isCurrentUserAgency();
    bool isAdmin = _isCurrentUserAdmin();
    bool hasAccess = isAgency || isAdmin;
    
    print('DEBUG AgencyDashboard: Access check results:');
    print('DEBUG AgencyDashboard: isAgency: $isAgency');
    print('DEBUG AgencyDashboard: isAdmin: $isAdmin');
    print('DEBUG AgencyDashboard: hasAccess: $hasAccess');
    
    if (!hasAccess) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Access Denied'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Agency Access Required',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'You need agency privileges to access this dashboard.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text('Go Back'),
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
    return AppBar(
      backgroundColor: Color(0xFFD76B30),
          automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
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
        margin: EdgeInsets.only(left: 16),
        child: FlutterFlowIconButton(
          borderColor: Colors.white.withOpacity(0.2),
          borderRadius: 12,
          borderWidth: 1,
          buttonSize: 48,
            icon: Icon(
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
            _isCurrentUserAdmin() ? 'Agency Dashboard (Admin)' : 'Agency Dashboard',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                    color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            _isCurrentUserAdmin() ? 'Manage all agency trips and performance' : 'Manage your trips and performance',
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
          margin: EdgeInsets.only(right: 16),
              child: FlutterFlowIconButton(
            borderColor: Colors.white.withOpacity(0.2),
            borderRadius: 12,
            borderWidth: 1,
            buttonSize: 48,
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
              size: 24,
                ),
                onPressed: () async {
                  context.pushNamed('create_trip');
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
      child: SingleChildScrollView(
          child: Column(
            children: [
            _buildSearchAndFilter(),
            _buildDashboardStats(),
            _buildQuickActions(),
            _buildTripsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (_searchQuery != value) {
                  setState(() {
                    _searchQuery = value;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Search trips...',
                hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', Icons.all_inclusive),
                SizedBox(width: 12),
                _buildFilterChip('Active', 'active', Icons.check_circle),
                SizedBox(width: 12),
                _buildFilterChip('Inactive', 'inactive', Icons.cancel),
                SizedBox(width: 12),
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFFD76B30)
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? Color(0xFFD76B30)
                : FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFD76B30).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
                        children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : FlutterFlowTheme.of(context).secondaryText,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: FlutterFlowTheme.of(context).labelMedium.override(
                color: isSelected
                    ? Colors.white
                    : FlutterFlowTheme.of(context).secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStats() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    // If no agency reference and not admin, show zero stats
    if (!isAdmin && agencyRef == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 140,
        child: Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                            'Total Trips',
                '0',
                            Icons.flight_takeoff,
                [Color(0xFFD76B30), Color(0xFFDBA237)],
                'trips',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatCard(
                            'Active',
                '0',
                            Icons.check_circle,
                [Color(0xFFD76B30), Color(0xFFE8A657)],
                'trips',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatCard(
                'Revenue',
                '\$0',
                Icons.attach_money,
                [Color(0xFFDBA237), Color(0xFFD76B30)],
                'total',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedStatCard(
                'Rating',
                '0.0',
                Icons.star,
                [Color(0xFFE8A657), Color(0xFFDBA237)],
                'avg',
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
                  child: StreamBuilder<List<TripsRecord>>(
                    stream: _isCurrentUserAdmin() 
                      ? queryTripsRecord() // Admin sees all trips
                      : queryTripsRecord(
                      queryBuilder: (tripsRecord) => tripsRecord.where(
                        'agency_reference',
                            isEqualTo: agencyRef,
                          ),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
            return _buildStatsLoading();
          }
          
          List<TripsRecord> trips = snapshot.data!;
          final activeTrips = AgencyUtils.getActiveTripsCount(trips);
          final totalRevenue = AgencyUtils.calculateTotalRevenue(trips);
          final avgRating = AgencyUtils.calculateAverageRating(trips);
          
          return Container(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Total Trips',
                    trips.length.toString(),
                    Icons.flight_takeoff,
                    [Color(0xFFD76B30), Color(0xFFDBA237)],
                    'trips',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Active',
                    activeTrips.toString(),
                    Icons.check_circle,
                    [Color(0xFFD76B30), Color(0xFFE8A657)],
                    'trips',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Revenue',
                    '\$${totalRevenue.toStringAsFixed(0)}',
                    Icons.attach_money,
                    [Color(0xFFDBA237), Color(0xFFD76B30)],
                    'total',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Rating',
                    avgRating.toStringAsFixed(1),
                    Icons.star,
                    [Color(0xFFE8A657), Color(0xFFDBA237)],
                    'avg',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      height: 140,
      child: Row(
        children: List.generate(4, (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (type == 'trips' || type == 'total')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type == 'trips' ? 'trips' : 'total',
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  title,
                  style: FlutterFlowTheme.of(context).labelSmall.override(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Quick Actions',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
          ),
                     Row(
             children: [
               Expanded(
                 child: _buildQuickActionCard(
                   'Create Trip',
                   Icons.add_location,
                   [Color(0xFFD76B30), Color(0xFFDBA237)],
                   () => context.pushNamed('create_trip'),
                 ),
               ),
               SizedBox(width: 12),
               Expanded(
                 child: _buildQuickActionCard(
                   'CSV Upload',
                   Icons.upload_file,
                   [Color(0xFFDBA237), Color(0xFFE8A657)],
                   () => context.pushNamed('agencyCsvUpload'),
                 ),
               ),
               SizedBox(width: 12),
               Expanded(
                 child: _buildQuickActionCard(
                   'View Bookings',
                   Icons.book_online,
                   [Color(0xFFE8A657), Color(0xFFD76B30)],
                   () => context.pushNamed('bookings'),
                 ),
               ),
             ],
           ),
         ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, List<Color> colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
        child: Padding(
              padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(height: 8),
                                     Center(
                     child: Text(
                       title,
                       style: FlutterFlowTheme.of(context).labelMedium.override(
                         color: Colors.white,
                         fontSize: 12,
                         fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildTripsSection() {
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = isAdmin ? null : AgencyUtils.getCurrentAgencyRef();
    
    // If no agency reference and not admin, show setup message instead of empty results
    if (!isAdmin && agencyRef == null) {
      return _buildNoAgencyReferenceState();
    }
    
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Trips',
                style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              StreamBuilder<List<TripsRecord>>(
                stream: _isCurrentUserAdmin() 
                  ? queryTripsRecord() // Admin sees all trips
                  : queryTripsRecord(
                      queryBuilder: (tripsRecord) => tripsRecord.where(
                        'agency_reference',
                        isEqualTo: agencyRef,
                      ),
                    ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Text('0 trips');
                  
                  List<TripsRecord> trips = snapshot.data!;
                  List<TripsRecord> filteredTrips = AgencyUtils.filterTrips(
                    trips,
                    _searchQuery,
                    _filterStatus,
                  );
                  
                  return Text(
                    '${filteredTrips.length} trips',
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontSize: 14,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          StreamBuilder<List<TripsRecord>>(
            stream: _isCurrentUserAdmin() 
              ? queryTripsRecord(
                  queryBuilder: (tripsRecord) => tripsRecord.orderBy('created_at', descending: true),
                ) // Admin sees all trips
              : queryTripsRecord(
                  queryBuilder: (tripsRecord) => tripsRecord.where(
                    'agency_reference',
                    isEqualTo: agencyRef,
                  ).orderBy('created_at', descending: true),
                ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildTripsLoading();
              }
              
              List<TripsRecord> trips = snapshot.data!;
              List<TripsRecord> filteredTrips = AgencyUtils.filterTrips(
                trips,
                _searchQuery,
                _filterStatus,
              );
              
              if (filteredTrips.isEmpty) {
                return _buildEnhancedEmptyState(context);
              }
              
              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: filteredTrips.length,
                itemBuilder: (context, index) {
                  final trip = filteredTrips[index];
                  return _buildEnhancedTripCard(context, trip);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripsLoading() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
        child: Center(
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

  Widget _buildEnhancedTripCard(BuildContext context, TripsRecord trip) {
    return GestureDetector(
      onTap: () => _showTripDetails(context, trip),
      child: Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Trip Image with Status Badge
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
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
                                  child: Center(
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
                              child: Icon(
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
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: trip.availableSeats > 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: Offset(0, 2),
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
                            SizedBox(width: 4),
                            Text(
                        trip.availableSeats > 0 ? 'Active' : 'Inactive',
                              style: FlutterFlowTheme.of(context).labelSmall.override(
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
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${trip.price}',
                          style: FlutterFlowTheme.of(context).labelMedium.override(
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
                  padding: EdgeInsets.all(16),
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
                      SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: FlutterFlowTheme.of(context).secondaryText,
                            size: 16,
                        ),
                          SizedBox(width: 6),
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
                      SizedBox(height: 8),
                    Row(
                      children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                        Text(
                          trip.rating != null ? trip.rating.toStringAsFixed(1) : '0.0',
                            style: FlutterFlowTheme.of(context).labelMedium.override(
                            color: Colors.orange,
                              fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFFD76B30).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${trip.availableSeats} seats',
                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                color: Color(0xFFD76B30),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                            child: _buildActionButton(
                              'Edit',
                              Icons.edit,
                              Color(0xFFD76B30),
                              () => context.pushNamed(
                                'edit_trip',
                                queryParameters: {'tripRef': trip.reference.id}.withoutNulls,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              'Delete',
                              Icons.delete,
                              FlutterFlowTheme.of(context).error,
                              () => _showDeleteConfirmation(context, trip),
                            ),
                          ),
                        ],
                      ),
                      // Action Buttons end
                    ],
                  ),
                ),
              ),
            ],
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
          textStyle: FlutterFlowTheme.of(context).labelMedium.override(
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
      margin: EdgeInsets.all(16),
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
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 60,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Agency Setup Required',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Your account needs to be linked to an agency to view and manage trips.',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontSize: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please contact your administrator or support team to complete the setup.',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FFButtonWidget(
                  onPressed: () => context.pop(),
                  text: 'Go Back',
                  options: FFButtonOptions(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 24),
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
                SizedBox(width: 16),
                FFButtonWidget(
                  onPressed: () {
                    // Refresh the page to check again
                    setState(() {});
                  },
                  text: 'Refresh',
                  icon: Icon(Icons.refresh),
                  options: FFButtonOptions(
                    height: 48,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    color: Color(0xFFD76B30),
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
                  Color(0xFFD76B30).withOpacity(0.1),
                  Color(0xFFD76B30).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
            Icons.flight_takeoff,
              color: Color(0xFFD76B30),
              size: 60,
          ),
          ),
          SizedBox(height: 24),
          Text(
            'No trips found',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
              fontSize: 24,
                    fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
          SizedBox(height: 12),
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
          SizedBox(height: 32),
          FFButtonWidget(
            onPressed: () async {
              context.pushNamed('create_trip');
            },
            text: 'Create Your First Trip',
             icon: Icon(Icons.add),
            options: FFButtonOptions(
               height: 56,
               padding: EdgeInsets.symmetric(horizontal: 32),
               color: Color(0xFFD76B30),
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
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
    return Container(
      margin: EdgeInsets.only(bottom: 16, right: 16),
      child: FloatingActionButton.extended(
        onPressed: () async {
          context.pushNamed('create_trip');
        },
        backgroundColor: Color(0xFFD76B30),
        elevation: 8,
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'New Trip',
          style: FlutterFlowTheme.of(context).titleSmall.override(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
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
                    SizedBox(height: 16),
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

  void _showAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Analytics feature coming soon!'),
        backgroundColor: FlutterFlowTheme.of(context).info,
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
                padding: EdgeInsets.all(8),
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
              SizedBox(width: 12),
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
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
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
                    SizedBox(width: 8),
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
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trip deleted successfully'),
                      backgroundColor: FlutterFlowTheme.of(context).success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                    ),
                  );
                } catch (e) {
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
              },
              ),
            ),
          ],
        );
      },
    );
  }


}
