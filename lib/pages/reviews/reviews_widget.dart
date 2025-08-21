import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/components/write_review_dialog.dart';
import '/components/write_agency_review_dialog.dart';
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
          title: Text(
            'Reviews',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.0,
            ),
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
                icon: Icon(Icons.flight_takeoff),
                text: 'Trip Reviews',
              ),
              Tab(
                icon: Icon(Icons.business),
                text: 'Agency Reviews',
              ),
            ],
          ),
          centerTitle: false,
          elevation: 2.0,
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Trip Reviews Tab
            _buildTripReviewsTab(),
            // Agency Reviews Tab
            _buildAgencyReviewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripReviewsTab() {
    return StreamBuilder<List<ReviewsRecord>>(
      stream: queryReviewsRecord(
        queryBuilder: (q) => q.orderBy('created_at', descending: true),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.rate_review,
            title: 'No Trip Reviews Yet',
            subtitle: 'Be the first to review a trip!',
            buttonText: 'Browse Trips',
            onButtonPressed: () => context.pushNamed('home'),
          );
        }

        final reviews = snapshot.data!;
        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildTripReviewCard(review);
          },
        );
      },
    );
  }

  Widget _buildAgencyReviewsTab() {
    return StreamBuilder<List<AgencyReviewsRecord>>(
      stream: queryAgencyReviewsRecord(
        queryBuilder: (q) => q.orderBy('created_at', descending: true),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.business,
            title: 'No Agency Reviews Yet',
            subtitle: 'Be the first to review a travel agency!',
            buttonText: 'Browse Agencies',
            onButtonPressed: () => context.pushNamed('agenciesList'),
          );
        }

        final reviews = snapshot.data!;
        return ListView.separated(
          padding: EdgeInsets.all(16),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildAgencyReviewCard(review);
          },
        );
      },
    );
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
              onPressed: () => context.pushNamed('login'),
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
                          : userSnapshot.data!.email.split('@')[0])
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
                          : userSnapshot.data!.email.split('@')[0])
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
