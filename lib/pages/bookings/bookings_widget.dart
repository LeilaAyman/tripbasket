import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'bookings_model.dart';
export 'bookings_model.dart';

class BookingsWidget extends StatefulWidget {
  const BookingsWidget({
    super.key,
    this.tripref,
  });

  final DocumentReference? tripref;

  static String routeName = 'bookings';
  static String routePath = '/bookings';

  @override
  State<BookingsWidget> createState() => _BookingsWidgetState();
}

class _BookingsWidgetState extends State<BookingsWidget> {
  late BookingsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BookingsModel());
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
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // HEADER IMAGE
              StreamBuilder<TripsRecord>(
                stream: TripsRecord.getDocument(widget.tripref!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      width: double.infinity,
                      height: 300.0,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFD76B30), // Orange
                          ),
                        ),
                      ),
                    );
                  }

                  final headerTripsRecord = snapshot.data!;
                  
                  // Always prioritize image from database if available
                  String specificImageUrl;
                  final tripName = (headerTripsRecord.title ?? '').toLowerCase();
                  
                  // Check if database has an image first
                  if ((headerTripsRecord.image ?? '').isNotEmpty) {
                    // Use image from database
                    specificImageUrl = headerTripsRecord.image!;
                  } else {
                    // Use fallbacks based on trip name if no image in database
                    if (tripName.contains('paris')) {
                      specificImageUrl = 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/La_Tour_Eiffel_vue_de_la_Tour_Saint-Jacques%2C_Paris_ao%C3%BBt_2014_%282%29.jpg/1280px-La_Tour_Eiffel_vue_de_la_Tour_Saint-Jacques%2C_Paris_ao%C3%BBt_2014_%282%29.jpg';
                    } else if (tripName.contains('japan') || tripName.contains('tokyo')) {
                      specificImageUrl = 'https://images.unsplash.com/photo-1528164344705-47542687000d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1492&q=80';
                    } else if (tripName.contains('italy') || tripName.contains('rome')) {
                      specificImageUrl = 'https://images.unsplash.com/photo-1529260830199-42c24126f198?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1476&q=80';
                    } else if (tripName.contains('dahab')) {
                      specificImageUrl = 'https://images.unsplash.com/photo-1635068742130-8c9c5b3fe28c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1480&q=80';
                    } else {
                      // Default fallback for any other destination
                      specificImageUrl = 'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTI3NzMzMTB8&ixlib=rb-4.1.0&q=80&w=1080';
                    }
                  }
                  
                  // Debug print to verify the image URL being used
                  print('===== DEBUG: Trip title: ${headerTripsRecord.title}');
                  print('===== DEBUG: Original image URL from DB: ${headerTripsRecord.image}');
                  print('===== DEBUG: Selected image URL: $specificImageUrl');

                  return Container(
                    width: double.infinity,
                    height: 300.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                    ),
                    child: Stack(
                      children: [
                        Image.network(
                          specificImageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            print('===== DEBUG: Error loading image: $error');
                            // Fall back to default Unsplash image if the specific image fails
                            return Image.network(
                              'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTI3NzMzMTB8&ixlib=rb-4.1.0&q=80&w=1080',
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.transparent, // Remove gradient overlay
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FlutterFlowIconButton(
                                      borderRadius: 20.0,
                                      buttonSize: 40.0,
                                      fillColor: const Color(0x80D76B30), // Orange with opacity
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                      onPressed: () async {
                                        context.pushNamed(HomeWidget.routeName);
                                      },
                                    ),
                                    FlutterFlowIconButton(
                                      borderRadius: 20.0,
                                      buttonSize: 40.0,
                                      fillColor: const Color(0x80D76B30), // Orange with opacity
                                      icon: const Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                      onPressed: () {
                                        // TODO: handle favorite
                                      },
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StreamBuilder<TripsRecord>(
                                      stream: TripsRecord.getDocument(
                                          widget.tripref!),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child:
                                                  CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        final textTripsRecord =
                                            snapshot.data!;
                                        return Text(
                                          valueOrDefault<String>(
                                            textTripsRecord.title,
                                            'Trip Name',
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .headlineMedium
                                              .override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                color: Colors.white,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        );
                                      },
                                    ),
                                    Text(
                                      '5 Days • 4 Nights',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
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
                  );
                },
              ),

              // CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      24.0, 0.0, 24.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price + rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<TripsRecord>(
                                  stream: TripsRecord.getDocument(
                                      widget.tripref!),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Text(
                                        'Loading...',
                                        style: FlutterFlowTheme.of(context)
                                            .headlineSmall
                                            .override(
                                              color: const Color(0xFFD76B30), // Orange
                                              letterSpacing: 0.0,
                                            ),
                                      );
                                    }
                                    final priceTripsRecord = snapshot.data!;
                                    return Text(
                                      'From \$${priceTripsRecord.price}',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            font: GoogleFonts.interTight(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .headlineSmall
                                                      .fontStyle,
                                            ),
                                            color: const Color(0xFFD76B30), // Orange
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .headlineSmall
                                                    .fontStyle,
                                          ),
                                    );
                                  },
                                ),
                                Text(
                                  'per person',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                      ),
                                ),
                              ],
                            ),
                            Container(
                              width: 120.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).accent1,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Color(0xFFF2D83B), // Bright Yellow
                                      size: 16.0,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              4.0, 0.0, 4.0, 0.0),
                                      child: Text(
                                        '4.8 (124)',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Overview
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Itinerary Overview',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                            ),
                            StreamBuilder<TripsRecord>(
                              stream:
                                  TripsRecord.getDocument(widget.tripref!),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFFD76B30),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final textTripsRecord = snapshot.data!;
                                return Text(
                                  valueOrDefault<String>(
                                    textTripsRecord.description,
                                    'Alooo',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.inter(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                        lineHeight: 1.5,
                                      ),
                                );
                              },
                            ),

                            // Dynamic itinerary
                            StreamBuilder<TripsRecord>(
                              stream:
                                  TripsRecord.getDocument(widget.tripref!),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: SizedBox(
                                      width: 50.0,
                                      height: 50.0,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFFD76B30),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final columnTripsRecord = snapshot.data!;

                                // Build itinerary items
                                List<String> itineraryItems = [];

                                // Prefer list field if available
                                final listField =
                                    (columnTripsRecord.itenarary ?? []);
                                if (listField.isNotEmpty) {
                                  itineraryItems = List<String>.from(listField);
                                } else {
                                  // Fallback: parse description or title
                                  String itinerarySource = '';
                                  if ((columnTripsRecord.description ?? '')
                                      .isNotEmpty) {
                                    itinerarySource =
                                        columnTripsRecord.description ?? '';
                                  } else if ((columnTripsRecord.title ?? '')
                                      .isNotEmpty) {
                                    itinerarySource =
                                        columnTripsRecord.title ?? '';
                                  }

                                  if (itinerarySource.isNotEmpty) {
                                    itineraryItems = itinerarySource
                                        .split(RegExp(r'\n|•|\*|\d+\.'))
                                        .where(
                                            (item) => item.trim().isNotEmpty)
                                        .map((item) => item.trim())
                                        .toList();
                                  }
                                }

                                if (itineraryItems.isEmpty) {
                                  final tripName =
                                      (columnTripsRecord.title ?? '')
                                          .toLowerCase();
                                  if (tripName.contains('dahab')) {
                                    itineraryItems = [
                                      'Day 1: Arrival in Dahab - Check into accommodation and welcome dinner',
                                      'Day 2: Blue Hole diving experience - World famous diving spot',
                                      'Day 3: Camel trek in the desert - Sunset adventure with Bedouin camp',
                                      'Day 4: Snorkeling at Three Pools - Crystal clear waters and coral reefs',
                                      'Day 5: Free time and departure - Last minute shopping and relaxation',
                                    ];
                                  } else if (tripName.contains('paris')) {
                                    itineraryItems = [
                                      'Day 1: Arrival in Paris - Eiffel Tower visit and Seine river cruise',
                                      'Day 2: Louvre Museum and Champs-Élysées shopping',
                                      'Day 3: Versailles Palace day trip',
                                      'Day 4: Montmartre and Sacré-Cœur exploration',
                                      'Day 5: Free time and departure',
                                    ];
                                  } else {
                                    itineraryItems = [
                                      'Day 1: Arrival and check-in',
                                      'Day 2: City exploration and local attractions',
                                      'Day 3: Adventure activities and cultural experiences',
                                      'Day 4: Free time and optional excursions',
                                      'Day 5: Departure',
                                    ];
                                  }
                                }

                                return Column(
                                  children: List.generate(
                                    itineraryItems.length,
                                    (index) {
                                      final item = itineraryItems[index];
                                      final dayNumber = (index + 1).toString();
                                      final hasTitle = item.contains(':');
                                      final title = hasTitle
                                          ? '${item.split(':')[0]}:'
                                          : 'Day $dayNumber';
                                      final desc = hasTitle
                                          ? item
                                              .split(':')
                                              .skip(1)
                                              .join(':')
                                              .trim()
                                          : item;

                                      return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFFD76B30), // Orange theme color
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      dayNumber,
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        title,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleMedium
                                                                .override(
                                                                  font: GoogleFonts
                                                                      .interTight(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle:
                                                                        FlutterFlowTheme.of(context)
                                                                            .titleMedium
                                                                            .fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleMedium
                                                                          .fontStyle,
                                                                ),
                                                      ),
                                                      Text(
                                                        desc,
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontWeight,
                                                                    fontStyle:
                                                                        FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondaryText,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontWeight,
                                                                  fontStyle:
                                                                      FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                  lineHeight: 1.4,
                                                                ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ].divide(const SizedBox(height: 16.0)),
                        ),

                        // What's Included
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What's Included",
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                            ),
                            _includedRow(
                                context, 'Professional mountain guide'),
                            _includedRow(context, '4 nights accommodation'),
                            _includedRow(context, 'All meals and snacks'),
                            _includedRow(context, 'Safety equipment provided'),
                            _includedRow(
                                context, 'Transportation to/from base'),
                          ].divide(const SizedBox(height: 12.0)),
                        ),
                      ]
                          .divide(const SizedBox(height: 24.0))
                          .addToStart(const SizedBox(height: 24.0)),
                    ),
                  ),
                ),
              ),

              // Bottom bar
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$1,299',
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    font: GoogleFonts.interTight(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .fontStyle,
                                    ),
                                    color: const Color(0xFFD76B30), // Orange theme color
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                            ),
                            Text(
                              'per person',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight:
                                          FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: () async {
                              // Add to Cart functionality
                              try {
                                // Get trip details
                                final tripSnapshot = await widget.tripref!.get();
                                final tripData = tripSnapshot.data() as Map<String, dynamic>;
                                
                                final cartCreateData = {
                                  'tripReference': widget.tripref,
                                  'userReference': currentUserReference,
                                  'tripName': tripData['name'],
                                  'tripImage': tripData['image'],
                                  'travelers': _model.travelers,
                                  'totalPrice': (tripData['price'] as num).toDouble() * _model.travelers,
                                  'requiresAdditionalPaperwork': _model.requiresAdditionalPaperwork,
                                  'addedAt': DateTime.now(),
                                };
                                
                                await CartRecord.collection.doc().set(cartCreateData);
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Trip added to cart!'),
                                    backgroundColor: FlutterFlowTheme.of(context).primary,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding to cart. Please try again.'),
                                    backgroundColor: FlutterFlowTheme.of(context).error,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            text: 'Add to Cart',
                            options: FFButtonOptions(
                              height: 50.0,
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      32.0, 0.0, 32.0, 0.0),
                              iconPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                              color: const Color(0xFFD76B30), // Orange
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                              elevation: 0.0,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
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

  Widget _includedRow(BuildContext context, String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: FlutterFlowTheme.of(context).success,
          size: 20.0,
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            text,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FlutterFlowTheme.of(context)
                        .bodyMedium
                        .fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .fontWeight,
                  fontStyle: FlutterFlowTheme.of(context)
                      .bodyMedium
                      .fontStyle,
                ),
          ),
        ),
      ],
    );
  }
}
