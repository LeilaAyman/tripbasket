import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/widgets/hero_background.dart';
import '/utils/agency_utils.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/add_sample_agencies.dart';
import '/components/interactive_trip_rating.dart';
import '/services/favorites_service.dart';
import '/widgets/price_text.dart';
import 'dart:math';
import 'dart:ui';
import '/index.dart';
import '/components/floating_chat_button.dart';
import '/utils/auth_navigation.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with TickerProviderStateMixin {
  late HomeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    
    _model.destinationController ??= TextEditingController();
    _model.destinationFocusNode ??= FocusNode();
    _model.monthController ??= TextEditingController(text: 'Any Month');
    _model.monthFocusNode ??= FocusNode();
    _model.travelersController ??= TextEditingController(text: '1 Traveler');
    _model.travelersFocusNode ??= FocusNode();
    _model.budgetController ??= TextEditingController(text: 'Any Budget');
    _model.budgetFocusNode ??= FocusNode();


    animationsMap.addAll({
      'textOnPageLoadAnimation1': AnimationInfo(
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
            begin: Offset(0.0, 60.0),
            end: Offset(0.0, 0.0),
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: Offset(0.95, 1.0),
            end: Offset(1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
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
            begin: Offset(30.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation3': AnimationInfo(
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
            begin: Offset(40.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation1': AnimationInfo(
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
            begin: Offset(60.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
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
            begin: Offset(60.0, 0.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation4': AnimationInfo(
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
      'textOnPageLoadAnimation5': AnimationInfo(
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
            begin: Offset(0.0, 60.0),
            end: Offset(0.0, 0.0),
          ),
        ],
      ),
      'listViewOnPageLoadAnimation': AnimationInfo(
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
            begin: Offset(0.0, 80.0),
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

  Widget _favoriteButton(TripsRecord trip) {
    final userRef = currentUserReference;
    if (userRef == null) return const SizedBox(); // not signed in
    
    return StreamBuilder<bool>(
      stream: FavoritesService.isFavoriteStream(userRef, trip.reference),
      builder: (context, snap) {
        final isFav = snap.data ?? false;
        return GestureDetector(
          onTap: () async {
            try {
              if (isFav) {
                await FavoritesService.remove(userRef, trip.reference);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed from favorites'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                await FavoritesService.add(userRef, trip.reference);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added to favorites'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Favorite error: $e'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.grey[600],
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required String hintText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(icon, color: const Color(0xFFD76B30), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _selectMonth() {
    List<String> months = [
      'Any Month',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            children: [
              Text(
                'Select Month',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        months[index],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _model.monthController!.text == months[index] 
                            ? const Color(0xFFD76B30) 
                            : Colors.black87,
                          fontWeight: _model.monthController!.text == months[index] 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _model.monthController!.text = months[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _selectTravelers() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        int tempTravelers = _model.travelers;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 200,
              child: Column(
                children: [
                  Text(
                    'Number of Travelers',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: tempTravelers > 1 
                          ? () {
                              setModalState(() {
                                tempTravelers--;
                              });
                            }
                          : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tempTravelers.toString(),
                          style: GoogleFonts.poppins(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: tempTravelers < 20 
                          ? () {
                              setModalState(() {
                                tempTravelers++;
                              });
                            }
                          : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _model.travelers = tempTravelers;
                        _model.travelersController!.text = 
                          '$tempTravelers ${tempTravelers == 1 ? 'Traveler' : 'Travelers'}';
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD76B30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _selectBudget() {
    List<String> budgets = [
      'Any Budget',
      'Under EGP 15,000',
      'EGP 15,000 - EGP 30,000',
      'EGP 30,000 - EGP 60,000',
      'EGP 60,000 - EGP 150,000',
      'Over EGP 150,000'
    ];
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            children: [
              Text(
                'Select Budget',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        budgets[index],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: _model.budgetController!.text == budgets[index] 
                            ? const Color(0xFFD76B30) 
                            : Colors.black87,
                          fontWeight: _model.budgetController!.text == budgets[index] 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _model.budgetController!.text = budgets[index];
                          _model.selectedBudget = budgets[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _performSearch() {
    String destination = _model.destinationController!.text.trim();
    String month = _model.monthController!.text.trim();
    String budget = _model.budgetController!.text.trim();
    
    if (destination.isNotEmpty) {
      // Only use destination in the search query, other fields are filters
      context.pushNamed(
        'searchResults',
        queryParameters: {
          'searchQuery': destination, // Only destination goes in search
          'destination': destination,
          'month': month != 'Any Month' ? month : '',
          'travelers': _model.travelers.toString(),
          'budget': budget != 'Any Budget' ? budget : '',
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a destination to search'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildTripsList(List<TripsRecord> listViewTripsRecordList) {
    return Column(
      children: [
        ListView.builder(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: listViewTripsRecordList.length,
          itemBuilder: (context, listViewIndex) {
            final listViewTripsRecord = listViewTripsRecordList[listViewIndex];
            return Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
              child: InkWell(
                onTap: () {
                  context.pushNamed(
                    'bookings',
                    queryParameters: {
                      'tripref': listViewTripsRecord.reference.id,
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: 270.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8.0,
                        color: Color(0x230F1113),
                        offset: Offset(0.0, 4.0),
                      )
                    ],
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Hero(
                        tag: 'tripImage_${listViewTripsRecord.reference.id}',
                        transitionOnUserGestures: true,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                listViewTripsRecord.image.isNotEmpty 
                                    ? listViewTripsRecord.image
                                    : 'https://images.unsplash.com/photo-1528114039593-4366cc08227d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8aXRhbHl8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                width: double.infinity,
                                height: 200.0,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200.0,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFD76B30).withOpacity(0.3),
                                          Color(0xFFF2D83B).withOpacity(0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      color: Colors.grey[600],
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                              if (loggedIn && currentUserReference != null)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: _favoriteButton(listViewTripsRecord),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listViewTripsRecord.title,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                    child: InteractiveTripRating(
                                      tripRecord: listViewTripsRecord,
                                      initialRating: listViewTripsRecord.rating,
                                      showReviewsButton: true,
                                      onRatingChanged: (rating) {
                                        print('Rating changed to: $rating');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.0),
                            Container(
                              constraints: BoxConstraints(maxWidth: 150),
                              height: 32.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFD76B30),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: PriceText(
                                  listViewTripsRecord.price,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
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
            );
          },
        ),
        // Add "View All Destinations" button
        if (listViewTripsRecordList.length >= 6)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  context.pushNamed('searchResults', queryParameters: {
                    'showAll': 'true',
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFFD76B30), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore, color: Color(0xFFD76B30)),
                    SizedBox(width: 8),
                    Text(
                      'View All Destinations',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD76B30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewModeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Preview Mode - Viewing as Customer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/agency_dashboard');
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 16,
            ),
            label: Text(
              'Back to Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
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
      child: Stack(
        children: [
          Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: Color(0xFFD76B30),
          automaticallyImplyLeading: false,
          title: Text(
            'Tripsbasket',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
          ),
          actions: [
            // Loyalty Points Badge
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                onTap: () => context.pushNamed('loyaltyPage'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_giftcard, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      StreamBuilder<UsersRecord>(
                        stream: UsersRecord.getDocument(currentUserReference!),
                        builder: (context, snap) {
                          final pts = snap.hasData ? snap.data!.loyaltyPoints : 0;
                          return Text(
                            "$pts pts",
                            style: FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        drawer: Drawer(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD76B30), // Primary Orange
                      Color(0xFFDBA237), // Golden Yellow
                    ],
                    stops: [0.0, 1.0],
                    begin: AlignmentDirectional(-1.0, -1.0),
                    end: AlignmentDirectional(1.0, 1.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tripsbasket',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.0,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Your travel companion',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.home,
                  color: Color(0xFFD76B30),
                ),
                title: Text(
                  'Home',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.business,
                  color: Color(0xFFD76B30),
                ),
                title: Text(
                  'Travel Agencies',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed('agenciesList');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.rate_review,
                  color: Color(0xFFD76B30),
                ),
                title: Text(
                  'Reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed('reviews');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Color(0xFFD76B30),
                ),
                title: Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AuthNavigation.pushNamedAuth(context, 'profile');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.book_online,
                  color: Color(0xFFD76B30),
                ),
                title: Text(
                  'My Bookings',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AuthNavigation.pushNamedAuth(context, 'mybookings');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.shopping_cart,
                  color: Color(0xFFD76B30),
                ),
                title: Text(
                  'Shopping Cart',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed('cart');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.favorite,
                  color: Color(0xFFD76B30),
                ),
                title: Text(
                  'My Favorites',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    color: Color(0xFF333333),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed('favorites');
                },
              ),
              Divider(
                color: Color(0xFFDBA237).withOpacity(0.3),
                thickness: 1.0,
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.red[600],
                ),
                title: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 16.0,
                    color: Colors.red[600],
                    letterSpacing: 0.0,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  GoRouter.of(context).prepareAuthEvent();
                  await authManager.signOut();
                  GoRouter.of(context).clearRedirectLocation();
                  AuthNavigation.goNamedAuth(context, 'landing');
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Preview mode banner for agency users
            if (AgencyUtils.isCurrentUserAgency())
              _buildPreviewModeBanner(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    HeroBackground(
                height: 420.0,
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 44.0),
                          child: Text(
                            'Explore top destinations around the world.',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation1']!),
                        ),
                        
                        // Search Bar Section
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildSearchField(
                                  controller: _model.destinationController!,
                                  focusNode: _model.destinationFocusNode!,
                                  label: 'Destination',
                                  icon: Icons.location_on,
                                  hintText: 'Where do you want to go?',
                                ),
                                const SizedBox(height: 16),
                                _buildSearchField(
                                  controller: _model.monthController!,
                                  focusNode: _model.monthFocusNode!,
                                  label: 'Month you wish to travel',
                                  icon: Icons.calendar_today,
                                  hintText: 'Select month',
                                  readOnly: true,
                                  onTap: () => _selectMonth(),
                                ),
                                const SizedBox(height: 16),
                                _buildSearchField(
                                  controller: _model.travelersController!,
                                  focusNode: _model.travelersFocusNode!,
                                  label: 'Number of travelers',
                                  icon: Icons.people,
                                  hintText: 'How many travelers?',
                                  readOnly: true,
                                  onTap: () => _selectTravelers(),
                                ),
                                const SizedBox(height: 16),
                                _buildSearchField(
                                  controller: _model.budgetController!,
                                  focusNode: _model.budgetFocusNode!,
                                  label: 'Budget',
                                  icon: Icons.account_balance_wallet,
                                  hintText: 'Select your budget',
                                  readOnly: true,
                                  onTap: () => _selectBudget(),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _performSearch,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFD76B30),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.search, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Search Trips',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Top Destinations Section - Moved here after search bar
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                          child: Text(
                            'Top Destinations',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation4']!),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 0.0),
                          child: Text(
                            'Our most popular featured destinations',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              letterSpacing: 0.0,
                            ),
                          ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation5']!),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 24.0),
                          child: StreamBuilder<List<TripsRecord>>(
                            stream: queryTripsRecord(
                              queryBuilder: (tripsRecord) => tripsRecord
                                  .where('is_featured', isEqualTo: true)
                                  .orderBy('priority', descending: true)
                                  .limit(6),
                            ),
                            builder: (context, snapshot) {
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
                              
                              List<TripsRecord> listViewTripsRecordList = snapshot.data!;
                              
                              // If no featured trips found, fallback to first 6 trips
                              if (listViewTripsRecordList.isEmpty) {
                                return StreamBuilder<List<TripsRecord>>(
                                  stream: queryTripsRecord(
                                    queryBuilder: (tripsRecord) => tripsRecord.limit(6),
                                  ),
                                  builder: (context, fallbackSnapshot) {
                                    if (!fallbackSnapshot.hasData) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    listViewTripsRecordList = fallbackSnapshot.data!;
                                    return _buildTripsList(listViewTripsRecordList);
                                  },
                                );
                              }

                              return _buildTripsList(listViewTripsRecordList);
                            },
                          ),
                        ),
                        
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 763.7,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).primaryBackground,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(0.0),
                                bottomRight: Radius.circular(0.0),
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 24.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      height: 8.0,
                                      thickness: 4.0,
                                      indent: 140.0,
                                      endIndent: 140.0,
                                      color: FlutterFlowTheme.of(context).alternate,
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                      child: Text(
                                        'Hey TripBasket',
                                        style: GoogleFonts.poppins(
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                      ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation2']!),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 0.0),
                                      child: Text(
                                        '30 locations world wide',
                                        style: GoogleFonts.poppins(
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          letterSpacing: 0.0,
                                        ),
                                      ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation3']!),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                      child: Container(
                                        width: double.infinity,
                                        height: 210.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                        ),
                                        child: ListView(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 0.0, 12.0),
                                              child: InkWell(
                                                onTap: () {
                                                  context.pushNamed(
                                                    'searchResults',
                                                    queryParameters: {
                                                      'searchQuery': 'Cinque Terre Italy',
                                                      'destination': 'Cinque Terre Italy',
                                                    },
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(12.0),
                                                child: Container(
                                                width: 270.0,
                                                height: 100.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 8.0,
                                                      color: Color(0x230F1113),
                                                      offset: Offset(0.0, 4.0),
                                                    )
                                                  ],
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(0.0),
                                                        bottomRight: Radius.circular(0.0),
                                                        topLeft: Radius.circular(12.0),
                                                        topRight: Radius.circular(12.0),
                                                      ),
                                                      child: Image.network(
                                                        'https://images.unsplash.com/photo-1534445867742-43195f401b6c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8aXRhbHl8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                                        width: double.infinity,
                                                        height: 110.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Cinque Terre',
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 16.0,
                                                                  fontWeight: FontWeight.w600,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    RatingBarIndicator(
                                                                      itemBuilder: (context, index) => Icon(
                                                                        Icons.star,
                                                                        color: Color(0xFFF2D83B),
                                                                      ),
                                                                      direction: Axis.horizontal,
                                                                      rating: 4.0,
                                                                      unratedColor: FlutterFlowTheme.of(context).secondaryText,
                                                                      itemCount: 5,
                                                                      itemSize: 16.0,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                      child: Text(
                                                                        '4.7',
                                                                        style: GoogleFonts.poppins(
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            height: 32.0,
                                                            decoration: BoxDecoration(
                                                              color: Color(0xFFD76B30),
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                            child: Padding(
                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                                              child: PriceText(
                                                                220,
                                                                style: GoogleFonts.poppins(
                                                                  color: Colors.white,
                                                                  letterSpacing: 0.0,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ),
                                              ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!),
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 12.0),
                                              child: InkWell(
                                                onTap: () {
                                                  context.pushNamed(
                                                    'searchResults',
                                                    queryParameters: {
                                                      'searchQuery': 'Bellagio Italy',
                                                      'destination': 'Bellagio Italy',
                                                    },
                                                  );
                                                },
                                                borderRadius: BorderRadius.circular(12.0),
                                                child: Container(
                                                width: 270.0,
                                                height: 100.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      blurRadius: 8.0,
                                                      color: Color(0x230F1113),
                                                      offset: Offset(0.0, 4.0),
                                                    )
                                                  ],
                                                  borderRadius: BorderRadius.circular(12.0),
                                                  border: Border.all(
                                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(0.0),
                                                        bottomRight: Radius.circular(0.0),
                                                        topLeft: Radius.circular(12.0),
                                                        topRight: Radius.circular(12.0),
                                                      ),
                                                      child: Image.network(
                                                        'https://images.unsplash.com/photo-1515859005217-8a1f08870f59?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8aXRhbHl8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                                        width: double.infinity,
                                                        height: 110.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            mainAxisSize: MainAxisSize.max,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Bellagio Italy',
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 16.0,
                                                                  fontWeight: FontWeight.w600,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    RatingBarIndicator(
                                                                      itemBuilder: (context, index) => Icon(
                                                                        Icons.star,
                                                                        color: Color(0xFFF2D83B),
                                                                      ),
                                                                      direction: Axis.horizontal,
                                                                      rating: 4.0,
                                                                      unratedColor: FlutterFlowTheme.of(context).secondaryText,
                                                                      itemCount: 5,
                                                                      itemSize: 16.0,
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                                                                      child: Text(
                                                                        '4.7',
                                                                        style: GoogleFonts.poppins(
                                                                          letterSpacing: 0.0,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            height: 32.0,
                                                            decoration: BoxDecoration(
                                                              color: Color(0xFFD76B30),
                                                              borderRadius: BorderRadius.circular(12.0),
                                                            ),
                                                            alignment: AlignmentDirectional(0.0, 0.0),
                                                            child: Padding(
                                                              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                                              child: PriceText(
                                                                220,
                                                                style: GoogleFonts.poppins(
                                                                  color: Colors.white,
                                                                  letterSpacing: 0.0,
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ),
                                              ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation2']!),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Reviews section with trip names
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                                      child: Text(
                                        'Customer Reviews',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 16.0),
                                      child: Text(
                                        'What our customers say about their trips',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
                                      child: StreamBuilder<List<ReviewsRecord>>(
                                        stream: queryReviewsRecord(
                                          queryBuilder: (reviewsRecord) => reviewsRecord
                                              .orderBy('created_at', descending: true)
                                              .limit(5),
                                        ),
                                        builder: (context, snapshot) {
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
                                          
                                          List<ReviewsRecord> reviewsList = snapshot.data!;
                                          
                                          if (reviewsList.isEmpty) {
                                            return Center(
                                              child: Text(
                                                'No reviews yet',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            );
                                          }

                                          return Column(
                                            children: reviewsList.map((review) {
                                              return Padding(
                                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(12.0),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Trip name for this review
                                                      StreamBuilder<TripsRecord?>(
                                                        stream: review.tripReference != null ? TripsRecord.getDocument(review.tripReference!) : null,
                                                        builder: (context, tripSnapshot) {
                                                          String tripName = 'Unknown Trip';
                                                          if (tripSnapshot.hasData && tripSnapshot.data != null) {
                                                            tripName = tripSnapshot.data!.title;
                                                          }
                                                          // Use tripTitle if available as fallback
                                                          if (tripName == 'Unknown Trip' && review.tripTitle.isNotEmpty) {
                                                            tripName = review.tripTitle;
                                                          }
                                                          return Text(
                                                            'Review for: $tripName',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14.0,
                                                              fontWeight: FontWeight.w600,
                                                              color: Color(0xFFD76B30),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      SizedBox(height: 8.0),
                                                      // Rating
                                                      Row(
                                                        children: [
                                                          RatingBarIndicator(
                                                            itemBuilder: (context, index) => Icon(
                                                              Icons.star,
                                                              color: Color(0xFFF2D83B),
                                                            ),
                                                            direction: Axis.horizontal,
                                                            rating: review.rating,
                                                            unratedColor: Colors.grey[300],
                                                            itemCount: 5,
                                                            itemSize: 16.0,
                                                          ),
                                                          SizedBox(width: 8.0),
                                                          Text(
                                                            review.rating.toString(),
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14.0,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 8.0),
                                                      // Review text
                                                      Text(
                                                        review.comment,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14.0,
                                                          color: Colors.black87,
                                                          letterSpacing: 0.0,
                                                        ),
                                                        maxLines: 3,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      SizedBox(height: 8.0),
                                                      // Reviewer name and date
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            review.userName.isNotEmpty ? review.userName : 'Anonymous',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.w500,
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                          Text(
                                                            dateTimeFormat('relative', review.createdAt),
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12.0,
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
          ],
        ),
        ),
        const FloatingChatButton(),
        ],
      ),
    );
  }
}
