import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <- for currency formatting
import 'mybookings_model.dart';
export 'mybookings_model.dart';

class MybookingsWidget extends StatefulWidget {
  const MybookingsWidget({super.key});

  static String routeName = 'mybookings';
  static String routePath = '/mybookings';

  @override
  State<MybookingsWidget> createState() => _MybookingsWidgetState();
}

class _MybookingsWidgetState extends State<MybookingsWidget> {
  late MybookingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MybookingsModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (currentUserReference == null) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            'My Bookings',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.poppins(
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 28.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 48, color: Color(0xFFD76B30)),
              SizedBox(height: 16),
              Text(
                'Please sign in to view your bookings',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pushNamed('SignInSignUp'),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD76B30)),
                child: Text('Sign In', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 46.0,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFD76B30), // Orange theme color
            size: 25.0,
          ),
          onPressed: () async {
            context.safePop();
          },
        ),
        actions: const [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Align(
        alignment: const AlignmentDirectional(0.0, -1.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Description
                Text(
                  'My Bookings',
                  style: GoogleFonts.poppins(
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 28.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track your confirmed trips and booking history',
                  style: GoogleFonts.poppins(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                  ),
                ),
                SizedBox(height: 24),
                
                // Bookings Stream
                StreamBuilder<List<BookingsRecord>>(
                  stream: BookingsRecord.collection
                      .where('user_reference', isEqualTo: currentUserReference)
                      .snapshots()
                      .map((snapshot) => snapshot.docs
                          .map((doc) => BookingsRecord.fromSnapshot(doc))
                          .toList()),
                  builder: (context, snapshot) {
                    print('Mybookings snapshot state: ${snapshot.connectionState}');
                    print('Mybookings has data: ${snapshot.hasData}');
                    print('Mybookings data length: ${snapshot.data?.length ?? 0}');
                    
                    // Show loading spinner while waiting
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                        ),
                      );
                    }

                    // Show error state if there's an error
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'Error loading bookings',
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please check your connection and try again',
                              style: GoogleFonts.poppins(color: FlutterFlowTheme.of(context).secondaryText),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Handle no data
                    if (!snapshot.hasData) {
                      return _buildEmptyBookings(context);
                    }

                    final bookings = snapshot.data!;

                    // Show empty state if no items
                    if (bookings.isEmpty) {
                      return _buildEmptyBookings(context);
                    }

                    // Otherwise show bookings
                    return _buildBookingsList(context, bookings);
                  },
                ),
                
                SizedBox(height: 24),
                
                // Quick Actions
                _buildQuickActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildEmptyBookings(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              color: const Color(0xFFD76B30).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: Color(0xFFD76B30),
              size: 60.0,
            ),
          ),
          const SizedBox(height: 24.0),
          Text(
            'No Bookings Yet',
            style: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'You haven\'t booked any trips yet. Start exploring and book your next adventure!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FFButtonWidget(
                onPressed: () => context.pushNamed('home'),
                text: 'Browse Trips',
                icon: const Icon(Icons.explore_outlined, size: 20.0),
                options: FFButtonOptions(
                  height: 48.0,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  color: const Color(0xFFD76B30),
                  textStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, List<BookingsRecord> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${bookings.length} Booking${bookings.length != 1 ? 's' : ''}',
          style: GoogleFonts.poppins(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildBookingCard(context, booking);
          },
        ),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingsRecord booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: booking.tripReference != null
          ? StreamBuilder<TripsRecord>(
              stream: TripsRecord.getDocument(booking.tripReference!),
              builder: (context, tripSnapshot) {
                if (!tripSnapshot.hasData) {
                  return _buildLoadingBookingCard();
                }
                
                final trip = tripSnapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            trip.image.isNotEmpty ? trip.image : 'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.tripTitle.isNotEmpty ? booking.tripTitle : trip.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: FlutterFlowTheme.of(context).primaryText,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                trip.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Color(0xFFD76B30),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Booked: ${DateFormat('MMM dd, yyyy').format(booking.bookingDate ?? DateTime.now())}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildBookingStatus(booking.paymentStatus, booking.bookingStatus),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(color: FlutterFlowTheme.of(context).alternate),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                            ),
                            Text(
                              'EGP ${booking.totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD76B30),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (booking.paymentStatus == 'completed')
                              FFButtonWidget(
                                onPressed: () {
                                  // Navigate to trip details or booking details
                                  context.pushNamed('TripDetails', queryParameters: {
                                    'tripRef': trip.reference.id,
                                  });
                                },
                                text: 'View Details',
                                options: FFButtonOptions(
                                  height: 36,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  textStyle: GoogleFonts.poppins(
                                    color: Color(0xFFD76B30),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  borderSide: BorderSide(color: Color(0xFFD76B30), width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            if (booking.paymentStatus != 'completed') ...[
                              SizedBox(width: 8),
                              FFButtonWidget(
                                onPressed: () {
                                  // Retry payment
                                  context.pushNamed('payment', queryParameters: {
                                    'tripRecord': trip.reference.id,
                                    'totalAmount': booking.totalAmount.toString(),
                                  });
                                },
                                text: 'Pay Now',
                                options: FFButtonOptions(
                                  height: 36,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  color: Color(0xFFD76B30),
                                  textStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            )
          : _buildInvalidBookingCard(booking),
    );
  }

  Widget _buildBookingStatus(String paymentStatus, String? bookingStatus) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Check booking status first (new workflow)
    if (bookingStatus != null && bookingStatus.isNotEmpty) {
      switch (bookingStatus.toLowerCase()) {
        case 'pending_agency_approval':
          statusColor = Colors.orange;
          statusText = 'Pending Agency Approval';
          statusIcon = Icons.hourglass_empty;
          break;
        case 'confirmed':
          statusColor = Colors.green;
          statusText = 'Confirmed';
          statusIcon = Icons.check_circle;
          break;
        case 'denied':
          statusColor = Colors.red;
          statusText = 'Denied by Agency';
          statusIcon = Icons.cancel;
          break;
        case 'cancelled':
          statusColor = Colors.grey;
          statusText = 'Cancelled';
          statusIcon = Icons.cancel_outlined;
          break;
        default:
          // Fall back to payment status for unknown booking statuses
          statusColor = Colors.grey;
          statusText = bookingStatus;
          statusIcon = Icons.help;
          break;
      }
    } else {
      // Fall back to legacy payment status logic
      switch (paymentStatus.toLowerCase()) {
        case 'completed':
          statusColor = Colors.green;
          statusText = 'Confirmed';
          statusIcon = Icons.check_circle;
          break;
        case 'pending':
          statusColor = Colors.orange;
          statusText = 'Pending Payment';
          statusIcon = Icons.pending;
          break;
        case 'failed':
          statusColor = Colors.red;
          statusText = 'Payment Failed';
          statusIcon = Icons.error;
          break;
        default:
          statusColor = Colors.grey;
          statusText = 'Unknown';
          statusIcon = Icons.help;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          SizedBox(width: 4),
          Text(
            statusText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBookingCard() {
    return Container(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
        ),
      ),
    );
  }

  Widget _buildInvalidBookingCard(BookingsRecord booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.error_outline, color: Colors.red, size: 40),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.tripTitle.isNotEmpty ? booking.tripTitle : 'Invalid Booking',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: FlutterFlowTheme.of(context).primaryText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Trip reference missing',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'EGP ${booking.totalAmount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFD76B30),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFD76B30).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD76B30).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FFButtonWidget(
                  onPressed: () => context.pushNamed('home'),
                  text: 'Browse More Trips',
                  icon: Icon(Icons.explore, size: 20),
                  options: FFButtonOptions(
                    height: 44,
                    color: Color(0xFFD76B30),
                    textStyle: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
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
}
