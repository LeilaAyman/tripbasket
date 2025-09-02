import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/theme/app_theme.dart';
import '/utils/formatting.dart';
import '/widgets/sticky_cta_bar.dart';
import '/widgets/price_text.dart';
import '/services/pdf_service.dart';
import '/services/favorites_service.dart';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
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
      child: StreamBuilder<TripsRecord>(
        stream: TripsRecord.getDocument(widget.tripref!),
        builder: (context, tripSnapshot) {
          if (!tripSnapshot.hasData) {
            return Scaffold(
              key: scaffoldKey,
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          
          final trip = tripSnapshot.data!;
          final totalPrice = trip.price * _model.travelers;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
          top: true,
          child: SingleChildScrollView(
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
                    height: 400.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: Image.network(
                            specificImageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) {
                              print('===== DEBUG: Error loading image: $error');
                              // Fall back to default Unsplash image if the specific image fails
                              return Image.network(
                                'https://images.unsplash.com/photo-1519451241324-20b4ea2c4220?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTI3NzMzMTB8&ixlib=rb-4.1.0&q=80&w=1080',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
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
                                        context.safePop();
                                      },
                                    ),
                                    StreamBuilder<bool>(
                                      stream: currentUserReference != null && widget.tripref != null
                                          ? FavoritesService.isFavoriteStream(
                                              currentUserReference!,
                                              widget.tripref!,
                                            )
                                          : Stream.value(false),
                                      builder: (context, favoriteSnapshot) {
                                        final isFavorite = favoriteSnapshot.data ?? false;
                                        
                                        return FlutterFlowIconButton(
                                          borderRadius: 20.0,
                                          buttonSize: 40.0,
                                          fillColor: isFavorite 
                                              ? const Color(0xFFD76B30)  // Solid orange when favorite
                                              : const Color(0x80D76B30), // Orange with opacity when not favorite
                                          icon: Icon(
                                            isFavorite ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.white,
                                            size: 24.0,
                                          ),
                                          onPressed: () async {
                                            if (currentUserReference != null && widget.tripref != null) {
                                              try {
                                                if (isFavorite) {
                                                  await FavoritesService.remove(
                                                    currentUserReference!,
                                                    widget.tripref!,
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Removed from favorites'),
                                                      backgroundColor: Colors.grey.shade600,
                                                    ),
                                                  );
                                                } else {
                                                  await FavoritesService.add(
                                                    currentUserReference!,
                                                    widget.tripref!,
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Added to favorites'),
                                                      backgroundColor: Color(0xFFD76B30),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error updating favorites'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } else {
                                              // User not logged in
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Please sign in to add favorites'),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                            }
                                          },
                                        );
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
                                    StreamBuilder<TripsRecord>(
                                      stream: TripsRecord.getDocument(widget.tripref!),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text(
                                            'Loading...',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          );
                                        }
                                        final trip = snapshot.data!;
                                        
                                        // Calculate days from start and end dates
                                        String daysText = '5 Days • 4 Nights'; // Default fallback
                                        
                                        if (trip.hasStartDate() && trip.hasEndDate() && 
                                            trip.startDate != null && trip.endDate != null) {
                                          final difference = trip.endDate!.difference(trip.startDate!).inDays;
                                          final days = difference + 1; // Include both start and end day
                                          final nights = difference;
                                          daysText = '$days Days • $nights Nights';
                                        }
                                        
                                        return Text(
                                          daysText,
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
                                        );
                                      },
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
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    24.0, 0.0, 24.0, 0.0),
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
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        PriceText(
                                          priceTripsRecord.price,
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
                                        ),
                                      ],
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
                            StreamBuilder<List<ReviewsRecord>>(
                              stream: widget.tripref != null 
                                  ? queryReviewsRecord(
                                      queryBuilder: (q) => q
                                          .where('trip_reference', isEqualTo: widget.tripref),
                                    )
                                  : Stream.value([]),
                              builder: (context, reviewsSnapshot) {
                                final reviews = reviewsSnapshot.data ?? [];
                                final reviewCount = reviews.length;
                                final averageRating = reviewCount > 0 
                                    ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviewCount
                                    : 0.0;
                                
                                return Container(
                                  constraints: BoxConstraints(maxWidth: 150.0),
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).accent1,
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Color(0xFFF2D83B), // Bright Yellow
                                          size: 16.0,
                                        ),
                                        SizedBox(width: 4.0),
                                        Flexible(
                                          child: Text(
                                            reviewCount > 0 
                                                ? '${averageRating.toStringAsFixed(1)} (${reviewCount})'
                                                : 'No reviews',
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
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        // Overview
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                StreamBuilder<List<BookingsRecord>>(
                                  stream: queryBookingsRecord(
                                    queryBuilder: (q) => q
                                        .where('user_reference', isEqualTo: currentUserReference)
                                        .where('trip_reference', isEqualTo: widget.tripref),
                                  ),
                                  builder: (context, bookingSnapshot) {
                                    return StreamBuilder<TripsRecord>(
                                      stream: TripsRecord.getDocument(widget.tripref!),
                                      builder: (context, tripSnapshot) {
                                        if (!tripSnapshot.hasData) {
                                          return const SizedBox.shrink();
                                        }
                                        
                                        final trip = tripSnapshot.data!;
                                        
                                        // Show download button only if PDF exists
                                        if (trip.hasItineraryPdf() && trip.itineraryPdf.isNotEmpty) {
                                          return ElevatedButton.icon(
                                            onPressed: () => _downloadTripPdf(trip.itineraryPdf),
                                            icon: const Icon(Icons.picture_as_pdf),
                                            label: const Text('Download Itinerary'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFD76B30),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                          );
                                        }
                                        
                                        // Fallback: Show generated PDF for existing bookings
                                        if (bookingSnapshot.hasData && bookingSnapshot.data!.isNotEmpty) {
                                          final booking = bookingSnapshot.data!.first;
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              PdfService.downloadItineraryPdf(
                                                trip: trip,
                                                booking: booking,
                                                context: context,
                                              );
                                            },
                                            icon: const Icon(Icons.picture_as_pdf),
                                            label: const Text('Download PDF'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFD76B30),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            ),
                                          );
                                        }
                                        
                                        return const SizedBox.shrink();
                                      },
                                    );
                                  },
                                ),
                              ],
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
                                      final splitParts = hasTitle ? item.split(':') : [];
                                      final title = hasTitle && splitParts.isNotEmpty
                                          ? '${splitParts[0]}:'
                                          : 'Day $dayNumber';
                                      final desc = hasTitle && splitParts.length > 1
                                          ? splitParts
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

                        // Photo Gallery Section
                        StreamBuilder<TripsRecord>(
                          stream: TripsRecord.getDocument(widget.tripref!),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final tripRecord = snapshot.data!;
                            final allImages = <String>[];
                            
                            if (tripRecord.image.isNotEmpty) {
                              allImages.add(tripRecord.image);
                            }
                            if (tripRecord.gallery.isNotEmpty) {
                              allImages.addAll(tripRecord.gallery);
                            }
                            
                            if (allImages.length <= 1) {
                              return const SizedBox.shrink();
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Photos',
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
                                    if (allImages.length > 4)
                                      GestureDetector(
                                        onTap: () => _showAllPhotos(context, allImages),
                                        child: Text(
                                          'View all (${allImages.length})',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                color: const Color(0xFFD76B30),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                decoration: TextDecoration.underline,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: allImages.length > 4 ? 4 : allImages.length,
                                    itemBuilder: (context, index) {
                                      final isLast = index == 3 && allImages.length > 4;
                                      return Padding(
                                        padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
                                        child: GestureDetector(
                                          onTap: () => _showPhotoViewer(context, allImages, index),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  allImages[index],
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: FlutterFlowTheme.of(context).alternate,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: const Icon(
                                                        Icons.image_not_supported,
                                                        color: Colors.grey,
                                                        size: 30,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              if (isLast)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '+${allImages.length - 4}',
                                                        style: GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                
                                // What's Included - Dynamic content
                                if (tripRecord.specifications.isNotEmpty) ...[
                                  const SizedBox(height: 24),
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
                                      const SizedBox(height: 12),
                                      // Parse specifications and create rows
                                      ...tripRecord.specifications
                                          .split('\n')
                                          .where((line) => line.trim().isNotEmpty)
                                          .map((item) => Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: _includedRow(context, item.trim()),
                                          )),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          },
                        ),

                        // What's Included section now moved inside StreamBuilder above
                      ]
                          .divide(const SizedBox(height: 24.0))
                          .addToStart(const SizedBox(height: 24.0)),
                ),
              ),

            ],
            ),
          ),
        ),
        bottomNavigationBar: StickyCtaBar(
          price: totalPrice,
          buttonText: 'Add to Cart',
          currencyCode: 'USD',
          symbol: '',
          icon: Icons.shopping_cart_outlined,
          onPressed: () async {
            // Check if user is signed in
            if (!loggedIn || currentUserReference == null) {
              _showSignInDialog(context);
              return;
            }
            
            // Add to Cart functionality
            try {
              final cartCreateData = {
                'tripReference': widget.tripref,
                'userReference': currentUserReference,
                'tripName': trip.title,
                'tripImage': trip.image,
                'travelers': _model.travelers,
                'totalPrice': totalPrice,
                'requiresAdditionalPaperwork': _model.requiresAdditionalPaperwork,
                'addedAt': DateTime.now(),
              };
              
              await CartRecord.collection.doc().set(cartCreateData);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Trip added to cart!'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Error adding to cart. Please try again.'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      );
        },
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PhotoViewerPage(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showAllPhotos(BuildContext context, List<String> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Photos (${images.length})',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          letterSpacing: 0.0,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showPhotoViewer(context, images, index);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).alternate,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.login,
                color: const Color(0xFFD76B30),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Sign In Required',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You need to sign in to add trips to your cart.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD76B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD76B30).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: const Color(0xFFD76B30),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sign in to save trips and manage your bookings',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFFD76B30),
                          fontWeight: FontWeight.w500,
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
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: FlutterFlowTheme.of(context).secondaryText,
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pushNamed('home'); // Navigate to sign-in page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD76B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadTripPdf(String pdfUrl) async {
    try {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

class _PhotoViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _PhotoViewerPage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.images.length}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[800],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1) ...[
            // Previous button
            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
            // Next button
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
          // Page indicator dots
          if (widget.images.length > 1)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? const Color(0xFFD76B30)
                          : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
