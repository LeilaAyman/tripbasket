import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class InteractiveTripRating extends StatefulWidget {
  const InteractiveTripRating({
    super.key,
    required this.tripRecord,
    this.initialRating,
    this.showReviewsButton = true,
    this.onRatingChanged,
    this.onViewReviews,
  });

  final TripsRecord tripRecord;
  final double? initialRating;
  final bool showReviewsButton;
  final Function(double)? onRatingChanged;
  final VoidCallback? onViewReviews;

  @override
  State<InteractiveTripRating> createState() => _InteractiveTripRatingState();
}

class _InteractiveTripRatingState extends State<InteractiveTripRating>
    with SingleTickerProviderStateMixin {
  double _currentRating = 0.0;
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _hasUserRated = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentRating = 0.0; // Start with no rating, will be set from review data
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadReviewData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadReviewData() async {
    try {
      // Get all reviews for this trip (simplified query)
      final reviews = await queryReviewsRecordOnce(
        queryBuilder: (q) => q.where('trip_reference', isEqualTo: widget.tripRecord.reference),
      );

      // Check if current user has already rated this trip
      bool userHasRated = false;
      double userRating = 0.0;
      if (loggedIn) {
        final userReviews = reviews.where((review) => 
          review.userReference == currentUserReference).toList();
        userHasRated = userReviews.isNotEmpty;
        if (userHasRated && userReviews.first.hasRating()) {
          userRating = userReviews.first.rating;
        }
      }

      // Calculate average rating
      double avgRating = 0.0;
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
        avgRating = totalRating / reviews.length;
      }

      if (mounted) {
        setState(() {
          _averageRating = avgRating;
          _reviewCount = reviews.length;
          _hasUserRated = userHasRated;
          _currentRating = userRating;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading review data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 20,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating and info row
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: Stars and rating info
            Row(
              children: [
                // Display-only rating stars
                RatingBarIndicator(
                  rating: _reviewCount > 0 ? _averageRating : 0.0,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Color(0xFFF2D83B), // Bright yellow stars
                  ),
                  unratedColor: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                  itemSize: 18.0,
                ),
                
                
                SizedBox(width: 8),
                
                // Rating display and count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_averageRating > 0) ...[
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.0,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        if (_reviewCount > 0)
                          Text(
                            '($_reviewCount ${_reviewCount == 1 ? 'review' : 'reviews'})',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              letterSpacing: 0.0,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            // Second row: View Reviews button only
            if (widget.showReviewsButton && _reviewCount > 0) ...[
              SizedBox(height: 6),
              Row(
                children: [
                  // View Reviews button - navigates to dedicated Reviews page
                  InkWell(
                    onTap: widget.onViewReviews ?? () => _showReviewsDialog(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rate_review,
                            size: 12,
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'View Reviews',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.0,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        
      ],
    );
  }

  void _showReviewsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TripReviewsDialog(tripRecord: widget.tripRecord);
      },
    );
  }

}

class TripReviewsDialog extends StatelessWidget {
  const TripReviewsDialog({
    super.key,
    required this.tripRecord,
  });

  final TripsRecord tripRecord;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reviews for ${tripRecord.title}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            
            Divider(height: 24),
            
            // Reviews list
            Expanded(
              child: StreamBuilder<List<ReviewsRecord>>(
                stream: queryReviewsRecord(
                  queryBuilder: (q) => q
                      .where('trip_reference', isEqualTo: tripRecord.reference)
                      .orderBy('created_at', descending: true),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink(); // Hide the no reviews text
                  }
                  
                  final reviews = snapshot.data!;
                  return ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => Divider(height: 16),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ReviewCard(review: review);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
  });

  final ReviewsRecord review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 16,
                backgroundImage: review.userPhoto.isNotEmpty
                    ? NetworkImage(review.userPhoto)
                    : null,
                child: review.userPhoto.isEmpty
                    ? Icon(Icons.person, size: 16)
                    : null,
              ),
              
              SizedBox(width: 8),
              
              // User name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName.isNotEmpty ? review.userName : 'Anonymous',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: review.rating,
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: Color(0xFFF2D83B),
                          ),
                          itemCount: 5,
                          itemSize: 12.0,
                          unratedColor: FlutterFlowTheme.of(context).secondaryText,
                        ),
                        SizedBox(width: 4),
                        Text(
                          review.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            letterSpacing: 0.0,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Date
              if (review.hasCreatedAt())
                Text(
                  _formatDate(review.createdAt!),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    letterSpacing: 0.0,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
            ],
          ),
          
          // Comment
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              review.comment,
              style: GoogleFonts.poppins(
                fontSize: 12,
                letterSpacing: 0.0,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
          ],
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
