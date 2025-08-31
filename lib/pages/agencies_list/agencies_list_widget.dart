import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/write_agency_review_dialog.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'dart:math' as math;
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'agencies_list_model.dart';
export 'agencies_list_model.dart';

class AgenciesListWidget extends StatefulWidget {
  const AgenciesListWidget({super.key});

  static String routeName = 'agenciesList';
  static String routePath = '/agenciesList';

  @override
  State<AgenciesListWidget> createState() => _AgenciesListWidgetState();
}

class _AgenciesListWidgetState extends State<AgenciesListWidget>
    with TickerProviderStateMixin {
  late AgenciesListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgenciesListModel());

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
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
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
            'Travel Agencies',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3.0,
                      color: Color(0x33000000),
                      offset: Offset(0.0, 1.0),
                    )
                  ],
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                  child: Text(
                    'Discover our trusted travel partners',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              
              // Agencies List
              Expanded(
                child: StreamBuilder<List<AgenciesRecord>>(
                  stream: queryAgenciesRecord(),
                  builder: (context, snapshot) {
                    // Loading state
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFD76B30),
                            ),
                          ),
                        ),
                      );
                    }

                    List<AgenciesRecord> agencies = snapshot.data!;

                    // No agencies state
                    if (agencies.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business,
                              size: 80.0,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'No agencies found',
                              style: GoogleFonts.poppins(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                letterSpacing: 0.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 8.0, 0.0, 0.0),
                              child: Text(
                                'Check back later for new agencies',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.0,
                                  color: Colors.grey[500],
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Agencies List
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      itemCount: agencies.length,
                      itemBuilder: (context, index) {
                        final agency = agencies[index];
                        return Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 8.0, 16.0, 8.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(
                                'agencyTrips',
                                queryParameters: {
                                  'agencyRef': serializeParam(
                                    agency.reference,
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
                                    blurRadius: 3.0,
                                    color: Color(0x20000000),
                                    offset: Offset(0.0, 1.0),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 16.0, 16.0, 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header row with logo and basic info
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        // Agency Logo
                                        Container(
                                          width: 60.0,
                                          height: 60.0,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFD76B30).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: Color(0xFFD76B30).withOpacity(0.3),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: agency.logo.isNotEmpty
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  child: Image.network(
                                                    agency.logo,
                                                    width: 60.0,
                                                    height: 60.0,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Icon(
                                                        Icons.business,
                                                        color: Color(0xFFD76B30),
                                                        size: 30.0,
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.business,
                                                  color: Color(0xFFD76B30),
                                                  size: 30.0,
                                                ),
                                        ),
                                        
                                        // Agency name and location
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsetsDirectional.fromSTEB(
                                                16.0, 0.0, 8.0, 0.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  agency.name,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (agency.location.isNotEmpty)
                                                  Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.location_on,
                                                          color: Color(0xFFD76B30),
                                                          size: 16.0,
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding: EdgeInsetsDirectional
                                                                .fromSTEB(4.0, 0.0, 0.0, 0.0),
                                                            child: Text(
                                                              agency.location,
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14.0,
                                                                color: Colors.grey[600],
                                                                letterSpacing: 0.0,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        // Trip count badge
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFD76B30).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsetsDirectional
                                                .fromSTEB(12.0, 6.0, 12.0, 6.0),
                                            child: Text(
                                              '${agency.totalTrips}\ntrips',
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.0,
                                                color: Color(0xFFD76B30),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.0,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Description
                                    if (agency.description.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsetsDirectional
                                            .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Text(
                                          agency.description.length > 100
                                              ? '${agency.description.substring(0, math.min(100, agency.description.length))}...'
                                              : agency.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.0,
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    
                                    // Rating and action
                                    Padding(
                                      padding: EdgeInsetsDirectional
                                          .fromSTEB(0.0, 12.0, 0.0, 0.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          // Rating
                                          RatingBarIndicator(
                                            itemBuilder: (context, index) =>
                                                Icon(
                                              Icons.star,
                                              color: Color(0xFFF2D83B),
                                            ),
                                            direction: Axis.horizontal,
                                            rating: agency.rating,
                                            unratedColor:
                                                FlutterFlowTheme.of(context)
                                                    .secondaryText,
                                            itemCount: 5,
                                            itemSize: 16.0,
                                          ),
                                          Padding(
                                            padding: EdgeInsetsDirectional
                                                .fromSTEB(8.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              agency.rating.toStringAsFixed(1),
                                              style: GoogleFonts.poppins(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ),
                                          Spacer(),
                                          // Chat button
                                          InkWell(
                                            onTap: () => _showChatDialog(agency),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 6.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: Colors.blue,
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.chat,
                                                    color: Colors.blue,
                                                    size: 16.0,
                                                  ),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    'Chat',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12.0,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          // Review button
                                          InkWell(
                                            onTap: () => _showReviewDialog(agency),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 6.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFD76B30).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: Color(0xFFD76B30),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.rate_review,
                                                    color: Color(0xFFD76B30),
                                                    size: 16.0,
                                                  ),
                                                  SizedBox(width: 4.0),
                                                  Text(
                                                    'Review',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12.0,
                                                      color: Color(0xFFD76B30),
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.0),
                                          // View trips arrow
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Color(0xFFD76B30),
                                            size: 16.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animateOnPageLoad(
                                animationsMap['containerOnPageLoadAnimation']!),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewDialog(AgenciesRecord agency) async {
    if (!loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in to write a review'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return WriteAgencyReviewDialog(
          agencyRecord: agency,
        );
      },
    );

    if (result == true) {
      // Reviews will auto-refresh due to StreamBuilder
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showChatDialog(AgenciesRecord agency) {
    print('Chat button clicked for agency: ${agency.name}'); // Debug log
    
    if (!loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to chat with agencies'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final TextEditingController messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.chat, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Text('Chat with ${agency.name}'),
          ],
        ),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type your message to the agency...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your message will be sent directly to the agency. They\'ll see your contact information to respond.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FFButtonWidget(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a message'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              try {
                // Create message in MessagesRecord collection
                await MessagesRecord.collection.add({
                  'from': currentUserReference,
                  'to': null, // Agency will see this in their dashboard
                  'trip_reference': null, // General inquiry, not trip-specific
                  'content': messageController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                  'message_type': 'customer_to_agency',
                  'read_status': false,
                  'agency_reference': agency.reference,
                });
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message sent successfully! The agency will respond soon.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error sending message: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            text: 'Send Message',
            options: FFButtonOptions(
              color: Colors.blue,
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
