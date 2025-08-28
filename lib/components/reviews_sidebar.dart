import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/components/write_review_dialog.dart';
import '/components/write_agency_review_dialog.dart';

class ReviewsSidebar extends StatefulWidget {
  const ReviewsSidebar({
    super.key,
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  State<ReviewsSidebar> createState() => _ReviewsSidebarState();
}

class _ReviewsSidebarState extends State<ReviewsSidebar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ReviewsRecord> _tripReviews = [];
  List<AgencyReviewsRecord> _agencyReviews = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    if (!loggedIn) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Load user's trip reviews
      final tripReviews = await queryReviewsRecordOnce(
        queryBuilder: (q) => q
            .where('user_reference', isEqualTo: currentUserReference)
            .orderBy('created_at', descending: true),
      );

      // Load user's agency reviews
      final agencyReviews = await queryAgencyReviewsRecordOnce(
        queryBuilder: (q) => q
            .where('user_reference', isEqualTo: currentUserReference)
            .orderBy('created_at', descending: true),
      );

      if (mounted) {
        setState(() {
          _tripReviews = tripReviews;
          _agencyReviews = agencyReviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reviews: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Color(0x1A000000),
            offset: Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.rate_review,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'My Reviews',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Auth check
          if (!loggedIn) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 64,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Sign in to view your reviews',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: FlutterFlowTheme.of(context).secondaryText,
                        letterSpacing: 0.0,
                      ),
                    ),
                    SizedBox(height: 16),
                    FFButtonWidget(
                      onPressed: () {
                        context.pushNamed('home');
                      },
                      text: 'Sign In',
                      options: FFButtonOptions(
                        height: 40,
                        padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                        ),
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Tab bar
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).alternate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.0,
                ),
                indicator: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flight, size: 16),
                        SizedBox(width: 8),
                        Text('Trips'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business, size: 16),
                        SizedBox(width: 8),
                        Text('Agencies'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Trip Reviews Tab
                        _buildTripReviewsTab(),
                        // Agency Reviews Tab
                        _buildAgencyReviewsTab(),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripReviewsTab() {
    return Column(
      children: [
        // Header with count
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Trip Reviews (${_tripReviews.length})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
              Spacer(),
              if (_tripReviews.isNotEmpty)
                Text(
                  'Avg: ${_calculateTripAverage().toStringAsFixed(1)}⭐',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
                ),
            ],
          ),
        ),

        Divider(height: 1),

        // Reviews list
        Expanded(
          child: _tripReviews.isEmpty
              ? _buildEmptyState(
                  icon: Icons.rate_review,
                  title: 'No trip reviews yet',
                  subtitle: 'Start reviewing trips you\'ve experienced!',
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: _tripReviews.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = _tripReviews[index];
                    return _buildTripReviewCard(review);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAgencyReviewsTab() {
    return Column(
      children: [
        // Header with count
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Agency Reviews (${_agencyReviews.length})',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
              Spacer(),
              if (_agencyReviews.isNotEmpty)
                Text(
                  'Avg: ${_calculateAgencyAverage().toStringAsFixed(1)}⭐',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.0,
                  ),
                ),
            ],
          ),
        ),

        Divider(height: 1),

        // Reviews list
        Expanded(
          child: _agencyReviews.isEmpty
              ? _buildEmptyState(
                  icon: Icons.business,
                  title: 'No agency reviews yet',
                  subtitle: 'Rate agencies you\'ve worked with!',
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: _agencyReviews.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = _agencyReviews[index];
                    return _buildAgencyReviewCard(review);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripReviewCard(ReviewsRecord review) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip name and rating
          Row(
            children: [
              Expanded(
                child: Text(
                  review.tripTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Color(0xFFF2D83B),
                    ),
                    SizedBox(width: 2),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              review.comment,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          SizedBox(height: 8),

          // Date and actions
          Row(
            children: [
              Text(
                _formatDate(review.createdAt!),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () => _editTripReview(review),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 12,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                        ),
                      ),
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

  Widget _buildAgencyReviewCard(AgencyReviewsRecord review) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agency name and overall rating
          Row(
            children: [
              Expanded(
                child: Text(
                  review.agencyName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Color(0xFFF2D83B),
                    ),
                    SizedBox(width: 2),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          // Detailed ratings
          Row(
            children: [
              Expanded(
                child: _buildRatingItem('Service', review.serviceQuality),
              ),
              Expanded(
                child: _buildRatingItem('Communication', review.communication),
              ),
              Expanded(
                child: _buildRatingItem('Value', review.valueForMoney),
              ),
            ],
          ),

          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              review.comment,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          SizedBox(height: 8),

          // Date and actions
          Row(
            children: [
              Text(
                _formatDate(review.createdAt!),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: () => _editAgencyReview(review),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 12,
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: FlutterFlowTheme.of(context).primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                        ),
                      ),
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

  Widget _buildRatingItem(String label, double rating) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: FlutterFlowTheme.of(context).secondaryText,
            letterSpacing: 0.0,
          ),
        ),
        SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 10,
              color: rating > 0 ? Color(0xFFF2D83B) : FlutterFlowTheme.of(context).secondaryText,
            ),
            SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateTripAverage() {
    if (_tripReviews.isEmpty) return 0.0;
    final total = _tripReviews.fold<double>(0.0, (sum, review) => sum + review.rating);
    return total / _tripReviews.length;
  }

  double _calculateAgencyAverage() {
    if (_agencyReviews.isEmpty) return 0.0;
    final total = _agencyReviews.fold<double>(0.0, (sum, review) => sum + review.rating);
    return total / _agencyReviews.length;
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

  void _editTripReview(ReviewsRecord review) async {
    // Get the trip record
    try {
      final tripRecord = await TripsRecord.getDocumentOnce(review.tripReference!);
      
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return WriteReviewDialog(
            tripRecord: tripRecord,
            existingReview: review,
          );
        },
      );

      if (result == true) {
        _loadReviews(); // Reload reviews
      }
    } catch (e) {
      print('Error loading trip for edit: $e');
    }
  }

  void _editAgencyReview(AgencyReviewsRecord review) async {
    // Get the agency record
    try {
      final agencyRecord = await AgenciesRecord.getDocumentOnce(review.agencyReference!);
      
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return WriteAgencyReviewDialog(
            agencyRecord: agencyRecord,
            existingReview: review,
          );
        },
      );

      if (result == true) {
        _loadReviews(); // Reload reviews
      }
    } catch (e) {
      print('Error loading agency for edit: $e');
    }
  }
}
