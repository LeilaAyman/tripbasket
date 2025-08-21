import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'agency_trips_model.dart';
export 'agency_trips_model.dart';

class AgencyTripsWidget extends StatefulWidget {
  const AgencyTripsWidget({
    super.key,
    this.agencyRef,
  });

  final DocumentReference? agencyRef;

  static String routeName = 'agencyTrips';
  static String routePath = '/agencyTrips';

  @override
  State<AgencyTripsWidget> createState() => _AgencyTripsWidgetState();
}

class _AgencyTripsWidgetState extends State<AgencyTripsWidget>
    with TickerProviderStateMixin {
  late AgencyTripsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgencyTripsModel());

    animationsMap.addAll({
      'containerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.0, 40.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFFD76B30),
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
            'Agency Trips',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Inter Tight',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<AgenciesRecord>(
            stream: AgenciesRecord.getDocument(widget.agencyRef!),
            builder: (context, snapshot) {
              // Loading state
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFD76B30),
                    ),
                  ),
                );
              }
              
              final agency = snapshot.data!;
              
              return CustomScrollView(
                slivers: [
                  // Agency Header
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFD76B30), Color(0xFFE88B4F)],
                          stops: [0.0, 1.0],
                          begin: AlignmentDirectional(0.0, -1.0),
                          end: AlignmentDirectional(0, 1.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agency.name,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.0,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              agency.description,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                RatingBarIndicator(
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                  ),
                                  direction: Axis.horizontal,
                                  rating: agency.rating,
                                  unratedColor: Color(0x33FFFFFF),
                                  itemCount: 5,
                                  itemSize: 16.0,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                  child: Text(
                                    agency.rating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${agency.totalTrips} trips available',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Trips List
                  SliverToBoxAdapter(
                    child: StreamBuilder<List<TripsRecord>>(
                      stream: queryTripsRecord(
                        queryBuilder: (tripsRecord) => tripsRecord.where(
                          'agency_reference',
                          isEqualTo: widget.agencyRef,
                        ),
                      ),
                      builder: (context, snapshot) {
                        // Loading state
                        if (!snapshot.hasData) {
                          return Container(
                            height: 200.0,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD76B30),
                                ),
                              ),
                            ),
                          );
                        }

                        List<TripsRecord> trips = snapshot.data!;

                        // No trips state
                        if (trips.isEmpty) {
                          return Container(
                            height: 400.0,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.card_travel,
                                    size: 80.0,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16.0),
                                  Text(
                                    'No trips available',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'This agency hasn\'t added any trips yet.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.0,
                                      color: Colors.grey[500],
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Trips list
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 16.0, 16.0),
                              child: Text(
                                'Available Trips (${trips.length})',
                                style: GoogleFonts.poppins(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: trips.length,
                              itemBuilder: (context, index) {
                                final trip = trips[index];
                                return Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 16.0),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.pushNamed(
                                        'bookings',
                                        queryParameters: {
                                          'tripref': serializeParam(
                                            trip.reference,
                                            ParamType.DocumentReference,
                                          ),
                                        }.withoutNulls,
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 12.0,
                                            color: Color(0x1A000000),
                                            offset: Offset(0.0, 6.0),
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          // Trip Image (Left side)
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(16.0),
                                              topLeft: Radius.circular(16.0),
                                            ),
                                            child: Image.network(
                                              trip.image,
                                              width: 120.0,
                                              height: 140.0,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 120.0,
                                                height: 140.0,
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[600],
                                                  size: 40.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          
                                          // Trip Details (Right side)
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 16.0, 16.0, 16.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          trip.title,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 18.0,
                                                            fontWeight: FontWeight.w600,
                                                            letterSpacing: 0.0,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12.0),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFFD76B30),
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                              12.0, 6.0, 12.0, 6.0),
                                                          child: Text(
                                                            '\$${trip.price}',
                                                            style: GoogleFonts.poppins(
                                                              color: Colors.white,
                                                              fontSize: 16.0,
                                                              fontWeight: FontWeight.w600,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        color: Colors.grey[600],
                                                        size: 16.0,
                                                      ),
                                                      SizedBox(width: 4.0),
                                                      Expanded(
                                                        child: Text(
                                                          trip.location,
                                                          style: GoogleFonts.poppins(
                                                            color: Colors.grey[600],
                                                            fontSize: 14.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8.0),
                                                  Text(
                                                    trip.description,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey[700],
                                                      fontSize: 13.0,
                                                      letterSpacing: 0.0,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 12.0),
                                                  Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            color: Colors.amber,
                                                            size: 16.0,
                                                          ),
                                                          SizedBox(width: 4.0),
                                                          Text(
                                                            '4.5',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14.0,
                                                              fontWeight: FontWeight.w500,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.green[50],
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsetsDirectional.fromSTEB(
                                                              6.0, 2.0, 6.0, 2.0),
                                                          child: Text(
                                                            '${trip.availableSeats} seats left',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 10.0,
                                                              color: Colors.green[700],
                                                              fontWeight: FontWeight.w500,
                                                              letterSpacing: 0.0,
                                                            ),
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
                                    ).animateOnPageLoad(
                                        animationsMap['containerOnPageLoadAnimation']!),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
