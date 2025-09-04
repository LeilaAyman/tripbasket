import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/interactive_trip_rating.dart';
import '/services/favorites_service.dart';
import 'dart:math' as math;
import 'dart:ui';
import '/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'search_results_model.dart';
export 'search_results_model.dart';

class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({
    super.key,
    this.searchQuery,
    this.destination,
    this.month,
    this.travelers,
    this.budget,
    this.showAll,
  });

  final String? searchQuery;
  final String? destination;
  final String? month;
  final String? travelers;
  final String? budget;
  final String? showAll;

  static String routeName = 'searchResults';
  static String routePath = '/searchResults';

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget>
    with TickerProviderStateMixin {
  late SearchResultsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SearchResultsModel());

    _model.searchController ??= TextEditingController(text: widget.searchQuery ?? '');
    _model.searchFocusNode ??= FocusNode();

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

  // Search function that filters trips
  List<TripsRecord> _filterTrips(List<TripsRecord> trips, String query) {
    List<TripsRecord> filteredTrips = trips;
    
    // First, apply text search if query is provided
    if (query.isNotEmpty) {
      final searchTerms = query.toLowerCase().trim().split(RegExp(r'\s+'));
      
      filteredTrips = filteredTrips.where((trip) {
        final title = trip.title.toLowerCase();
        final location = trip.location.toLowerCase();
        final description = trip.description.toLowerCase();
        final specifications = trip.specifications.toLowerCase();
        
        // Check if any search term matches any field
        return searchTerms.any((term) =>
          title.contains(term) ||
          location.contains(term) ||
          description.contains(term) ||
          specifications.contains(term)
        );
      }).toList();
    }
    
    // Apply additional filters
    filteredTrips = _applyFilters(filteredTrips);
    
    return filteredTrips;
  }

  // Apply month, travelers, and budget filters
  List<TripsRecord> _applyFilters(List<TripsRecord> trips) {
    List<TripsRecord> filteredTrips = trips;
    
    // Filter by budget
    if (widget.budget != null && widget.budget!.isNotEmpty && widget.budget != 'Any Budget') {
      filteredTrips = filteredTrips.where((trip) {
        return _matchesBudgetFilter(trip.price, widget.budget!);
      }).toList();
    }
    
    // Filter by travelers (if the trip has capacity constraints)
    if (widget.travelers != null && widget.travelers!.isNotEmpty) {
      final travelerCount = int.tryParse(widget.travelers!) ?? 1;
      filteredTrips = filteredTrips.where((trip) {
        // Assuming trips have a max capacity, you might need to adjust this
        // For now, we'll assume all trips can accommodate any number of travelers
        // You can add capacity checks here if your TripsRecord has a maxCapacity field
        return true;
      }).toList();
    }
    
    // Month filtering would depend on trip dates
    // If your TripsRecord has date fields, you can filter by month here
    if (widget.month != null && widget.month!.isNotEmpty && widget.month != 'Any Month') {
      // This would require trip records to have date information
      // For now, we'll skip month filtering since we need to know the trip date structure
      // You can uncomment and modify this when you have date fields:
      /*
      filteredTrips = filteredTrips.where((trip) {
        return _matchesMonthFilter(trip.startDate, widget.month!);
      }).toList();
      */
    }
    
    return filteredTrips;
  }

  // Helper method to check if price matches budget filter
  bool _matchesBudgetFilter(int price, String budgetFilter) {
    switch (budgetFilter) {
      case 'Under EGP 15,000':
        return price < 15000;
      case 'EGP 15,000 - EGP 30,000':
        return price >= 15000 && price <= 30000;
      case 'EGP 30,000 - EGP 60,000':
        return price >= 30000 && price <= 60000;
      case 'EGP 60,000 - EGP 150,000':
        return price >= 60000 && price <= 150000;
      case 'Over EGP 150,000':
        return price > 150000;
      default:
        return true; // Any Budget or unrecognized filter
    }
  }

  // Check if there are any active filters
  bool _hasActiveFilters() {
    return (widget.month != null && widget.month!.isNotEmpty && widget.month != 'Any Month') ||
           (widget.travelers != null && widget.travelers!.isNotEmpty && widget.travelers != '1') ||
           (widget.budget != null && widget.budget!.isNotEmpty && widget.budget != 'Any Budget');
  }

  // Build filter chips to display active filters
  List<Widget> _buildFilterChips() {
    List<Widget> chips = [];
    
    if (widget.month != null && widget.month!.isNotEmpty && widget.month != 'Any Month') {
      chips.add(_buildFilterChip('Month: ${widget.month}'));
    }
    
    if (widget.travelers != null && widget.travelers!.isNotEmpty && widget.travelers != '1') {
      chips.add(_buildFilterChip('Travelers: ${widget.travelers}'));
    }
    
    if (widget.budget != null && widget.budget!.isNotEmpty && widget.budget != 'Any Budget') {
      chips.add(_buildFilterChip('Budget: ${widget.budget}'));
    }
    
    return chips;
  }

  // Build individual filter chip
  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD76B30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
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
            widget.showAll == 'true' ? 'All Destinations' : 'Search Results',
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
              // Search Bar
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
                  child: TextFormField(
                    controller: _model.searchController,
                    focusNode: _model.searchFocusNode,
                    onChanged: (_) => EasyDebounce.debounce(
                      '_model.searchController',
                      Duration(milliseconds: 500),
                      () => safeSetState(() {}),
                    ),
                    autofocus: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Search destinations...',
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        letterSpacing: 0.0,
                      ),
                      hintText: 'Beach, mountains, cities...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        letterSpacing: 0.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFE0E3E7),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFD76B30),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFFF5963),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFFF5963),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFFD76B30),
                        size: 24.0,
                      ),
                      suffixIcon: _model.searchController!.text.isNotEmpty
                          ? InkWell(
                              onTap: () async {
                                _model.searchController?.clear();
                                safeSetState(() {});
                              },
                              child: Icon(
                                Icons.clear,
                                color: Color(0xFF757575),
                                size: 24.0,
                              ),
                            )
                          : null,
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      letterSpacing: 0.0,
                    ),
                    validator: _model.searchControllerValidator.asValidator(context),
                  ),
                ),
              ),
              
              // Active Filters Display
              if (_hasActiveFilters())
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD76B30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD76B30).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Filters:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD76B30),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _buildFilterChips(),
                      ),
                    ],
                  ),
                ),
              
              // Search Results
              Expanded(
                child: StreamBuilder<List<TripsRecord>>(
                  stream: queryTripsRecord(),
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

                    List<TripsRecord> allTrips = snapshot.data!;
                    List<TripsRecord> filteredTrips = _filterTrips(
                      allTrips, 
                      _model.searchController.text
                    );

                    // No results state
                    if (filteredTrips.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80.0,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              _model.searchController.text.isEmpty
                                  ? 'Start typing to search for trips'
                                  : 'No trips found',
                              style: GoogleFonts.poppins(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                letterSpacing: 0.0,
                              ),
                            ),
                            if (_model.searchController.text.isNotEmpty)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 8.0, 0.0, 0.0),
                                child: Text(
                                  'Try searching for destinations like "London", "Beach", "Adventure", or "Heritage"',
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

                    // Results header
                    return Column(
                      children: [
                        if (_model.searchController.text.isNotEmpty)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 16.0, 16.0, 8.0),
                              child: Text(
                                '${filteredTrips.length} trip${filteredTrips.length == 1 ? '' : 's'} found for "${_model.searchController.text}"',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ),
                        
                        // Trip Results List
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemCount: filteredTrips.length,
                            itemBuilder: (context, index) {
                              final trip = filteredTrips[index];
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
                                          blurRadius: 3.0,
                                          color: Color(0x20000000),
                                          offset: Offset(0.0, 1.0),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 12.0, 12.0, 12.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          // Trip Image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.network(
                                              trip.image.isNotEmpty 
                                                  ? trip.image
                                                  : 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                                              width: 80.0,
                                              height: 80.0,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 80.0,
                                                  height: 80.0,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFFD76B30).withOpacity(0.3),
                                                        Color(0xFFF2D83B).withOpacity(0.3),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius.circular(8.0),
                                                  ),
                                                  child: Icon(
                                                    Icons.image_not_supported_rounded,
                                                    color: Colors.grey[600],
                                                    size: 30,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          
                                          // Trip Details
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(
                                                  12.0, 0.0, 0.0, 0.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    trip.title,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                    child: Text(
                                                      trip.location,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 14.0,
                                                        color: Color(0xFFD76B30),
                                                        letterSpacing: 0.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                    child: Text(
                                                      trip.description.length > 60
                                                          ? '${trip.description.substring(0, math.min(60, trip.description.length))}...'
                                                          : trip.description,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12.0,
                                                        color: FlutterFlowTheme.of(context)
                                                            .secondaryText,
                                                        letterSpacing: 0.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsetsDirectional
                                                        .fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                    child: InteractiveTripRating(
                                                      tripRecord: trip,
                                                      initialRating: trip.rating,
                                                      showReviewsButton: true,
                                                      onRatingChanged: (rating) {
                                                        // Handle rating change if needed
                                                        print('Rating changed to: $rating');
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          // Price
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFD76B30),
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(8.0, 4.0, 8.0, 4.0),
                                                  child: Text(
                                                    '\$${trip.price}',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w600,
                                                      letterSpacing: 0.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0.0, 4.0, 0.0, 0.0),
                                                child: Text(
                                                  'USD',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10.0,
                                                    color: FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animateOnPageLoad(
                                      animationsMap['containerOnPageLoadAnimation']!),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
}
