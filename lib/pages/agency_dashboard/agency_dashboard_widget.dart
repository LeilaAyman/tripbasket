import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgencyDashboardModel());
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Trip Management',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: Colors.transparent,
                borderRadius: 30.0,
                borderWidth: 1.0,
                buttonSize: 60.0,
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30.0,
                ),
                onPressed: () async {
                  context.pushNamed('create_trip');
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Dashboard Stats
              Container(
                width: double.infinity,
                height: 120.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3.0,
                      color: Color(0x33000000),
                      offset: Offset(
                        0.0,
                        1.0,
                      ),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                  child: StreamBuilder<List<TripsRecord>>(
                    stream: queryTripsRecord(
                      queryBuilder: (tripsRecord) => tripsRecord.where(
                        'agency_reference',
                        isEqualTo: _getCurrentAgencyRef(),
                      ),
                    ),
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
                      List<TripsRecord> trips = snapshot.data!;
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            context,
                            'Total Trips',
                            trips.length.toString(),
                            Icons.flight_takeoff,
                            FlutterFlowTheme.of(context).primary,
                          ),
                          _buildStatCard(
                            context,
                            'Active',
                            trips.where((trip) => trip.availableSeats > 0).length.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStatCard(
                            context,
                            'Avg Rating',
                            trips.isNotEmpty 
                                ? (trips.map((t) => t.rating).reduce((a, b) => a + b) / trips.length).toStringAsFixed(1)
                                : '0.0',
                            Icons.star,
                            Colors.orange,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              
              // Trips Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                  child: StreamBuilder<List<TripsRecord>>(
                    stream: queryTripsRecord(
                      queryBuilder: (tripsRecord) => tripsRecord.where(
                        'agency_reference',
                        isEqualTo: _getCurrentAgencyRef(),
                      ).orderBy('created_at', descending: true),
                    ),
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
                      
                      List<TripsRecord> trips = snapshot.data!;
                      
                      if (trips.isEmpty) {
                        return _buildEmptyState(context);
                      }
                      
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: trips.length,
                        itemBuilder: (context, index) {
                          final trip = trips[index];
                          return _buildTripCard(context, trip);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            context.pushNamed('create_trip');
          },
          backgroundColor: FlutterFlowTheme.of(context).primary,
          elevation: 8.0,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24.0,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 100.0,
        margin: EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.18), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 32.0,
              ),
              SizedBox(height: 8.0),
              Text(
                value,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.poppins(
                        color: color,
                        fontSize: 24.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
              SizedBox(height: 2.0),
              Text(
                title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripsRecord trip) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
              ),
              child: Stack(
                children: [
                  Image.network(
                    trip.image.isNotEmpty
                        ? trip.image
                        : 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=300&fit=crop',
                    width: double.infinity,
                    height: 120.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 120.0,
                        color: FlutterFlowTheme.of(context).alternate,
                        child: Icon(
                          Icons.image_not_supported,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 40.0,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trip.availableSeats > 0 ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        trip.availableSeats > 0 ? 'Active' : 'Inactive',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
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
                padding: EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.poppins(
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                            ),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 14.0,
                        ),
                        SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            trip.location,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '\u000024${trip.price}',
                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                            font: GoogleFonts.poppins(
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 2),
                        Text(
                          trip.rating != null ? trip.rating.toStringAsFixed(1) : '0.0',
                          style: GoogleFonts.poppins(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed(
                                'edit_trip',
                                queryParameters: {'tripRef': trip.reference.id}.withoutNulls,
                              );
                            },
                            text: 'Edit',
                            options: FFButtonOptions(
                              height: 32.0,
                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              await _showDeleteConfirmation(context, trip);
                            },
                            text: 'Delete',
                            options: FFButtonOptions(
                              height: 32.0,
                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).error,
                              textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              elevation: 2.0,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 80.0,
          ),
          SizedBox(height: 16.0),
          Text(
            'No trips yet',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.poppins(
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Create your first trip to get started',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  font: GoogleFonts.inter(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
          ),
          SizedBox(height: 24.0),
          FFButtonWidget(
            onPressed: () async {
              context.pushNamed('create_trip');
            },
            text: 'Create Your First Trip',
            options: FFButtonOptions(
              height: 48.0,
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    font: GoogleFonts.poppins(
                      color: Colors.white,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              elevation: 3.0,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, TripsRecord trip) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Trip',
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  font: GoogleFonts.poppins(
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete "${trip.title}"?',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.inter(
                          letterSpacing: 0.0,
                        ),
                      ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'This action cannot be undone.',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          color: FlutterFlowTheme.of(context).error,
                          letterSpacing: 0.0,
                        ),
                      ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.inter(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.inter(
                        color: FlutterFlowTheme.of(context).error,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
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
                    ),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting trip: $e'),
                      backgroundColor: FlutterFlowTheme.of(context).error,
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

  // Helper method to get current agency reference
  // This should be replaced with actual logic to get the current agency
  DocumentReference? _getCurrentAgencyRef() {
    // For now, return null - this should be implemented based on your authentication logic
    // You might want to store agency reference in user profile or have a separate lookup
    return null;
  }
}
