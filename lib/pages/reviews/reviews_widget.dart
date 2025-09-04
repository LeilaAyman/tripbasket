import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/index.dart';
import 'reviews_model.dart';
export 'reviews_model.dart';

class ReviewsWidget extends StatefulWidget {
  const ReviewsWidget({super.key});

  static String routeName = 'reviews';
  static String routePath = '/reviews';

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget>
    with SingleTickerProviderStateMixin {
  late ReviewsModel _model;
  late TabController _tabController;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Filter and sort states
  double? _selectedRatingFilter; // null for 'All', or 1.0-5.0 for specific ratings
  String _sortBy = 'newest'; // 'newest', 'oldest', 'highest_rated'
  
  String? get tripId => GoRouterState.of(context).uri.queryParameters['tripId'];
  String? get agencyId => GoRouterState.of(context).uri.queryParameters['agencyId'];
  String? get fromTripId => GoRouterState.of(context).uri.queryParameters['fromTrip'];
  
  DocumentReference? get tripReference => tripId != null 
    ? FirebaseFirestore.instance.collection('trips').doc(tripId!) 
    : null;
    
  DocumentReference? get agencyReference => agencyId != null 
    ? FirebaseFirestore.instance.collection('agencies').doc(agencyId!) 
    : null;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReviewsModel());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _model.dispose();
    _tabController.dispose();
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
          title: StreamBuilder<AgenciesRecord?>(
            stream: agencyReference != null ? AgenciesRecord.getDocument(agencyReference!) : null,
            builder: (context, snapshot) {
              String title = 'Reviews';
              if (snapshot.hasData && snapshot.data != null) {
                title = '${snapshot.data!.name} Reviews';
              } else if (fromTripId != null) {
                title = 'Agency Reviews';
              }
              
              return Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              );
            },
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.business),
                text: 'Agency Reviews',
              ),
              Tab(
                icon: Icon(Icons.flight_takeoff),
                text: 'Trip Reviews',
              ),
            ],
          ),
          centerTitle: false,
          elevation: 2.0,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Agency Reviews Tab (now first)
            _buildAgencyReviewsTab(),
            // Trip Reviews Tab (now second)
            _buildTripReviewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripReviewsTab() {
    return Column(
      children: [
        // Filter and Sort Controls
        _buildFilterSortControls(),
        
        // Reviews List
        Expanded(
          child: StreamBuilder<List<ReviewsRecord>>(
            stream: _buildFilteredReviewsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildEmptyState(
                  icon: Icons.error_outline,
                  title: 'Error Loading Reviews',
                  subtitle: 'Unable to load reviews. Please try again.',
                  buttonText: 'Refresh',
                  onButtonPressed: () => setState(() {}),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                String title = tripReference != null ? 'No Reviews for This Trip Yet' : 'No Trip Reviews Yet';
                String subtitle = tripReference != null ? 'No reviews available for this trip.' : 'No trip reviews available.';
                
                // Check if filters are applied
                if (_selectedRatingFilter != null) {
                  title = 'No Reviews Match Your Filter';
                  subtitle = 'Try adjusting your rating filter or clear all filters.';
                }
                
                return _buildEmptyState(
                  icon: Icons.rate_review,
                  title: title,
                  subtitle: 'Trip reviews are only available after booking completion.\n\nFor now, check out agency reviews in the other tab.',
                  buttonText: _selectedRatingFilter != null ? 'Clear Filters' : 'Browse Trips',
                  onButtonPressed: _selectedRatingFilter != null 
                    ? () => setState(() { 
                        _selectedRatingFilter = null; 
                        _sortBy = 'newest';
                      })
                    : () => context.pushNamed('home'),
                );
              }

              final reviews = _applySorting(snapshot.data!);
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return _buildModernTripReviewCard(review);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSortControls() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Rating Filter
          Row(
            children: [
              Text(
                'Filter by Rating:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRatingFilterChip('All', null),
                      SizedBox(width: 8),
                      _buildRatingFilterChip('5★', 5.0),
                      SizedBox(width: 8),
                      _buildRatingFilterChip('4★', 4.0),
                      SizedBox(width: 8),
                      _buildRatingFilterChip('3★', 3.0),
                      SizedBox(width: 8),
                      _buildRatingFilterChip('2★', 2.0),
                      SizedBox(width: 8),
                      _buildRatingFilterChip('1★', 1.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Sort Options
          Row(
            children: [
              Text(
                'Sort by:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('Newest', 'newest'),
                      SizedBox(width: 8),
                      _buildSortChip('Oldest', 'oldest'),
                      SizedBox(width: 8),
                      _buildSortChip('Highest Rated', 'highest_rated'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilterChip(String label, double? rating) {
    final isSelected = _selectedRatingFilter == rating;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRatingFilter = rating;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFD76B30) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFFD76B30) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String sortKey) {
    final isSelected = _sortBy == sortKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = sortKey;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFD76B30) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFFD76B30) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Stream<List<ReviewsRecord>> _buildFilteredReviewsStream() {
    return queryReviewsRecord(
      queryBuilder: (q) {
        var query = q;
        
        // Apply trip filter if specified
        if (tripReference != null) {
          query = query.where('trip_reference', isEqualTo: tripReference);
        }
        
        // Apply rating filter - simplified to avoid index conflicts
        if (_selectedRatingFilter != null) {
          double minRating = _selectedRatingFilter!;
          double maxRating = _selectedRatingFilter! + 0.99;
          query = query
              .where('rating', isGreaterThanOrEqualTo: minRating)
              .where('rating', isLessThanOrEqualTo: maxRating);
        }
        
        // Single orderBy to avoid index conflicts
        return query.orderBy('created_at', descending: true);
      },
    );
  }

  List<ReviewsRecord> _applySorting(List<ReviewsRecord> reviews) {
    final sortedReviews = List<ReviewsRecord>.from(reviews);
    
    switch (_sortBy) {
      case 'newest':
        sortedReviews.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case 'oldest':
        sortedReviews.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        break;
      case 'highest_rated':
        sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    
    return sortedReviews;
  }

  Widget _buildAgencyReviewsTab() {
    // If we have an agency reference (directly or from trip), show agency reviews
    if (agencyReference != null || fromTripId != null) {
      return _buildSpecificAgencyReviews();
    } else {
      // Show all agency reviews
      return Column(
        children: [
          // Filter and Sort Controls
          _buildFilterSortControls(),
          
          // Reviews List
          Expanded(
            child: StreamBuilder<List<AgencyReviewsRecord>>(
              stream: _buildFilteredAgencyReviewsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildEmptyState(
                    icon: Icons.error_outline,
                    title: 'Error Loading Reviews',
                    subtitle: 'Unable to load agency reviews. Please try again.',
                    buttonText: 'Refresh',
                    onButtonPressed: () => setState(() {}),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  String title = 'No Agency Reviews Yet';
                  String subtitle = 'No agency reviews available.';
                  
                  // Check if filters are applied
                  if (_selectedRatingFilter != null) {
                    title = 'No Reviews Match Your Filter';
                    subtitle = 'Try adjusting your rating filter or clear all filters.';
                  }
                  
                  return _buildEmptyState(
                    icon: Icons.business,
                    title: title,
                    subtitle: subtitle,
                    buttonText: _selectedRatingFilter != null ? 'Clear Filters' : 'Browse Agencies',
                    onButtonPressed: _selectedRatingFilter != null 
                      ? () => setState(() { 
                          _selectedRatingFilter = null; 
                          _sortBy = 'newest';
                        })
                      : () => context.pushNamed('agenciesList'),
                  );
                }

                final reviews = _applyAgencySorting(snapshot.data!);
                return ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _buildModernAgencyReviewCard(review);
                  },
                );
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildSpecificAgencyReviews() {
    // Get agency reference - either direct or from trip
    if (agencyReference != null) {
      return _buildAgencyReviewsForReference(agencyReference!);
    } else if (fromTripId != null) {
      // Trip is selected, get the trip to find its agency
      final tripRef = FirebaseFirestore.instance.collection('trips').doc(fromTripId!);
      return StreamBuilder<TripsRecord>(
        stream: TripsRecord.getDocument(tripRef),
        builder: (context, tripSnapshot) {
          if (tripSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
              ),
            );
          }

          if (!tripSnapshot.hasData || !tripSnapshot.data!.hasAgencyReference()) {
            return _buildEmptyState(
              icon: Icons.business,
              title: 'No Agency Linked',
              subtitle: 'This trip is not linked to any agency.',
              buttonText: 'Browse Agencies',
              onButtonPressed: () => context.pushNamed('agenciesList'),
            );
          }

          final trip = tripSnapshot.data!;
          return _buildAgencyReviewsForReference(trip.agencyReference!);
        },
      );
    }
    
    return _buildEmptyState(
      icon: Icons.error,
      title: 'No Agency Found',
      subtitle: 'Unable to determine which agency to show reviews for.',
      buttonText: 'Go Back',
      onButtonPressed: () => context.pop(),
    );
  }

  Widget _buildAgencyReviewsForReference(DocumentReference agencyRef) {
    return Column(
      children: [
        // Filter and Sort Controls
        _buildFilterSortControls(),
        
        // Reviews List
        Expanded(
          child: StreamBuilder<List<AgencyReviewsRecord>>(
            stream: queryAgencyReviewsRecord(
              queryBuilder: (q) {
                var query = q.where('agency_reference', isEqualTo: agencyRef);
                
                // Apply rating filter - simplified to avoid index conflicts
                if (_selectedRatingFilter != null) {
                  double minRating = _selectedRatingFilter!;
                  double maxRating = _selectedRatingFilter! + 0.99;
                  query = query
                      .where('rating', isGreaterThanOrEqualTo: minRating)
                      .where('rating', isLessThanOrEqualTo: maxRating);
                }
                
                // Single orderBy to avoid index conflicts
                return query.orderBy('created_at', descending: true);
              },
            ),
            builder: (context, reviewSnapshot) {
              if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                  ),
                );
              }

              if (reviewSnapshot.hasError) {
                return _buildEmptyState(
                  icon: Icons.error_outline,
                  title: 'Error Loading Reviews',
                  subtitle: 'Unable to load agency reviews. Please try again.',
                  buttonText: 'Refresh',
                  onButtonPressed: () => setState(() {}),
                );
              }

              if (!reviewSnapshot.hasData || reviewSnapshot.data!.isEmpty) {
                String title = 'No Reviews for This Agency';
                String subtitle = 'No reviews available for this agency.';
                
                // Check if filters are applied
                if (_selectedRatingFilter != null) {
                  title = 'No Reviews Match Your Filter';
                  subtitle = 'Try adjusting your rating filter or clear all filters.';
                }
                
                return _buildEmptyState(
                  icon: Icons.business,
                  title: title,
                  subtitle: subtitle,
                  buttonText: _selectedRatingFilter != null ? 'Clear Filters' : 'Browse Agencies',
                  onButtonPressed: _selectedRatingFilter != null 
                    ? () => setState(() { 
                        _selectedRatingFilter = null; 
                        _sortBy = 'newest';
                      })
                    : () => context.pushNamed('agenciesList'),
                );
              }

              final reviews = _applyAgencySorting(reviewSnapshot.data!);
              return ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return _buildModernAgencyReviewCard(review);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<List<AgencyReviewsRecord>> _buildFilteredAgencyReviewsStream() {
    return queryAgencyReviewsRecord(
      queryBuilder: (q) {
        var query = q;
        
        // Apply rating filter - simplified to avoid index conflicts
        if (_selectedRatingFilter != null) {
          double minRating = _selectedRatingFilter!;
          double maxRating = _selectedRatingFilter! + 0.99;
          query = query
              .where('rating', isGreaterThanOrEqualTo: minRating)
              .where('rating', isLessThanOrEqualTo: maxRating);
        }
        
        // Single orderBy to avoid index conflicts
        return query.orderBy('created_at', descending: true);
      },
    );
  }

  List<AgencyReviewsRecord> _applyAgencySorting(List<AgencyReviewsRecord> reviews) {
    final sortedReviews = List<AgencyReviewsRecord>.from(reviews);
    
    switch (_sortBy) {
      case 'newest':
        sortedReviews.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case 'oldest':
        sortedReviews.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        break;
      case 'highest_rated':
        sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    
    return sortedReviews;
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 80,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            SizedBox(height: 24),
            Text(
              'Sign In Required',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Please sign in to view and manage your reviews',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            SizedBox(height: 32),
            FFButtonWidget(
              onPressed: () => context.pushNamed('home'),
              text: 'Sign In',
              options: FFButtonOptions(
                height: 50,
                padding: EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                color: Color(0xFFD76B30),
                textStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 2,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            SizedBox(height: 16),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            SizedBox(height: 32),
            FFButtonWidget(
              onPressed: onButtonPressed,
              text: buttonText,
              options: FFButtonOptions(
                height: 50,
                padding: EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                color: Color(0xFFD76B30),
                textStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 2,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTripReviewCard(ReviewsRecord review) {
    // Get user initials from user name
    String getInitials() {
      if (review.userName.isNotEmpty) {
        final parts = review.userName.split(' ');
        if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else if (review.userName.isNotEmpty) {
          return review.userName.substring(0, math.min(2, review.userName.length)).toUpperCase();
        } else {
          return 'U';
        }
      }
      return 'U';
    }

    // Truncate comment to ~120 characters
    String getTruncatedComment() {
      if (review.comment.isEmpty) return 'No comment provided';
      if (review.comment.length <= 120) {
        return review.comment;
      }
      return '${review.comment.substring(0, 120)}...';
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Trip title at top
          if (review.tripTitle.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flight_takeoff,
                  color: Color(0xFFD76B30),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.tripTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD76B30),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
          
          // Star rating at top
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => 
              Icon(
                Icons.star, 
                color: index < review.rating.round() ? Colors.amber : Colors.grey.shade300, 
                size: 20
              )
            ),
          ),
          SizedBox(height: 20),
          
          // Circular avatar with profile picture or initials
          StreamBuilder<UsersRecord?>(
            stream: review.userReference != null ? UsersRecord.getDocument(review.userReference!) : null,
            builder: (context, userSnapshot) {
              final user = userSnapshot.data;
              final hasProfilePicture = user?.hasPhotoUrl() == true && user!.photoUrl.isNotEmpty;
              
              return CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFD76B30),
                backgroundImage: hasProfilePicture ? NetworkImage(user!.photoUrl) : null,
                child: hasProfilePicture ? null : Text(
                  getInitials(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          
          // User name
          Text(
            review.userName.isNotEmpty ? review.userName : 'Anonymous',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          
          // Review text in italic gray
          Text(
            '"${getTruncatedComment()}"',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Date at bottom
          if (review.hasCreatedAt()) ...[
            SizedBox(height: 12),
            Text(
              _formatDate(review.createdAt!),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripReviewCard(ReviewsRecord review) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flight_takeoff,
                color: Color(0xFFD76B30),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.tripTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // User info and rating
          Row(
            children: [
              StreamBuilder<UsersRecord?>(
                stream: UsersRecord.getDocument(review.userReference!),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.hasData && userSnapshot.data != null 
                      ? (userSnapshot.data!.displayName.isNotEmpty 
                          ? userSnapshot.data!.displayName 
                          : (userSnapshot.data!.email.split('@').isNotEmpty ? userSnapshot.data!.email.split('@')[0] : 'User'))
                      : 'Anonymous';
                  
                  return Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(width: 16),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Color(0xFFF2D83B),
                ),
                itemCount: 5,
                itemSize: 16.0,
                unratedColor: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
              ),
              SizedBox(width: 8),
              Text(
                review.rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              Spacer(),
              if (review.hasCreatedAt())
                Text(
                  _formatDate(review.createdAt!),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              review.comment,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).primaryText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernAgencyReviewCard(AgencyReviewsRecord review) {
    // Get user initials from user name
    String getInitials() {
      if (review.userName.isNotEmpty) {
        final parts = review.userName.split(' ');
        if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else if (review.userName.isNotEmpty) {
          return review.userName.substring(0, math.min(2, review.userName.length)).toUpperCase();
        } else {
          return 'U';
        }
      }
      return 'U';
    }

    // Truncate comment to ~120 characters
    String getTruncatedComment() {
      if (review.comment.isEmpty) return 'No comment provided';
      if (review.comment.length <= 120) {
        return review.comment;
      }
      return '${review.comment.substring(0, 120)}...';
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Agency name at top
          if (review.agencyName.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business,
                  color: Color(0xFFD76B30),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    review.agencyName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD76B30),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
          
          // Star rating at top
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => 
              Icon(
                Icons.star, 
                color: index < review.rating.round() ? Colors.amber : Colors.grey.shade300, 
                size: 20
              )
            ),
          ),
          SizedBox(height: 20),
          
          // Circular avatar with profile picture or initials
          StreamBuilder<UsersRecord?>(
            stream: review.userReference != null ? UsersRecord.getDocument(review.userReference!) : null,
            builder: (context, userSnapshot) {
              final user = userSnapshot.data;
              final hasProfilePicture = user?.hasPhotoUrl() == true && user!.photoUrl.isNotEmpty;
              
              return CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFD76B30),
                backgroundImage: hasProfilePicture ? NetworkImage(user!.photoUrl) : null,
                child: hasProfilePicture ? null : Text(
                  getInitials(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          
          // User name
          Text(
            review.userName.isNotEmpty ? review.userName : 'Anonymous',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          
          // Review text in italic gray
          Text(
            '"${getTruncatedComment()}"',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          
          // Detailed ratings if available
          if (review.hasServiceQuality() || review.hasCommunication() || review.hasValueForMoney()) ...[
            SizedBox(height: 16),
            _buildCompactDetailedRatings(review),
          ],
          
          // Date at bottom
          if (review.hasCreatedAt()) ...[
            SizedBox(height: 12),
            Text(
              _formatDate(review.createdAt!),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactDetailedRatings(AgencyReviewsRecord review) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Detailed Ratings',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          if (review.hasServiceQuality())
            _buildCompactRatingRow('Service', review.serviceQuality),
          if (review.hasCommunication())
            _buildCompactRatingRow('Communication', review.communication),
          if (review.hasValueForMoney())
            _buildCompactRatingRow('Value', review.valueForMoney),
        ],
      ),
    );
  }

  Widget _buildCompactRatingRow(String label, double rating) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          Row(
            children: [
              ...List.generate(5, (index) => 
                Icon(
                  Icons.star,
                  color: index < rating.round() ? Colors.amber : Colors.grey.shade300,
                  size: 10,
                )
              ),
              SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyReviewCard(AgencyReviewsRecord review) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.business,
                color: Color(0xFFD76B30),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.agencyName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // User info and rating
          Row(
            children: [
              StreamBuilder<UsersRecord?>(
                stream: UsersRecord.getDocument(review.userReference!),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.hasData && userSnapshot.data != null 
                      ? (userSnapshot.data!.displayName.isNotEmpty 
                          ? userSnapshot.data!.displayName 
                          : (userSnapshot.data!.email.split('@').isNotEmpty ? userSnapshot.data!.email.split('@')[0] : 'User'))
                      : 'Anonymous';
                  
                  return Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        userName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(width: 16),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Color(0xFFF2D83B),
                ),
                itemCount: 5,
                itemSize: 16.0,
                unratedColor: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
              ),
              SizedBox(width: 8),
              Text(
                review.rating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              Spacer(),
              if (review.hasCreatedAt())
                Text(
                  _formatDate(review.createdAt!),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
            ],
          ),
          // Detailed ratings for agencies
          if (review.hasServiceQuality() || review.hasCommunication() || review.hasValueForMoney()) ...[
            SizedBox(height: 12),
            _buildDetailedRatings(review),
          ],
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              review.comment,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).primaryText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedRatings(AgencyReviewsRecord review) {
    return Column(
      children: [
        if (review.hasServiceQuality())
          _buildRatingRow('Service Quality', review.serviceQuality),
        if (review.hasCommunication())
          _buildRatingRow('Communication', review.communication),
        if (review.hasValueForMoney())
          _buildRatingRow('Value for Money', review.valueForMoney),
      ],
    );
  }

  Widget _buildRatingRow(String label, double rating) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Color(0xFFF2D83B),
            ),
            itemCount: 5,
            itemSize: 12.0,
            unratedColor: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
          ),
          SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
