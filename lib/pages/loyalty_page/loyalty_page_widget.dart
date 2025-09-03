import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/loyalty_utils.dart';
import '/utils/manual_points_award.dart';
// import '/utils/debug_points.dart'; // Removed for performance
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'loyalty_page_model.dart';
export 'loyalty_page_model.dart';

class LoyaltyPageWidget extends StatefulWidget {
  const LoyaltyPageWidget({super.key});

  static String routeName = 'loyaltyPage';
  static String routePath = '/loyalty';

  @override
  State<LoyaltyPageWidget> createState() => _LoyaltyPageWidgetState();
}

class _LoyaltyPageWidgetState extends State<LoyaltyPageWidget> {
  late LoyaltyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoyaltyPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Color _getTierColor(int points) {
    if (points >= 1000) return const Color(0xFFFFD700); // Gold
    if (points >= 800) return const Color(0xFFC0C0C0); // Silver
    if (points >= 400) return const Color(0xFFCD7F32); // Bronze
    return const Color(0xFF9E9E9E); // Standard
  }

  IconData _getTierIcon(int points) {
    if (points >= 1000) return Icons.workspace_premium;
    if (points >= 800) return Icons.military_tech;
    if (points >= 400) return Icons.star;
    return Icons.card_membership;
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
          backgroundColor: const Color(0xFFD76B30),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Loyalty Points',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 22.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: StreamBuilder<UsersRecord>(
            stream: UsersRecord.getDocument(currentUserReference!),
            builder: (context, snapshot) {
              // Debug logging
              if (snapshot.hasData) {
                print('🔍 Loyalty page - Current user points: ${snapshot.data!.loyaltyPoints}');
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
                  ),
                );
              }

              final user = snapshot.data!;
              final points = user.loyaltyPoints;
              final discount = Loyalty.discountFor(points);
              final tier = Loyalty.tierLabel(points);
              final tierName = Loyalty.tierName(points);
              final next = Loyalty.nextMilestone(points);
              final toGo = Loyalty.pointsToNextTier(points);
              final progress = Loyalty.progressToNextTier(points);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Points Balance Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD76B30),
                              const Color(0xFFDBA237),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD76B30).withOpacity(0.3),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Your Balance',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.card_giftcard,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 24.0,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '$points pts',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 36.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTierColor(points).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: _getTierColor(points),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getTierIcon(points),
                                      color: _getTierColor(points),
                                      size: 16.0,
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      tierName,
                                      style: GoogleFonts.poppins(
                                        color: _getTierColor(points),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Current Benefits
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_offer,
                                    color: const Color(0xFFD76B30),
                                    size: 24.0,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Text(
                                    'Current Benefits',
                                    style: GoogleFonts.poppins(
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              if (discount > 0) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD76B30).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: const Color(0xFFD76B30).withOpacity(0.3),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.discount,
                                        color: const Color(0xFFD76B30),
                                        size: 20.0,
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Text(
                                          'You get ${Loyalty.formatDiscount(discount)} off at checkout!',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFD76B30),
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        size: 20.0,
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: Text(
                                          'Earn 100 points per purchase to unlock discounts!',
                                          style: GoogleFonts.poppins(
                                            color: FlutterFlowTheme.of(context).secondaryText,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // Progress to Next Tier
                      if (points < 1000) ...[
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      color: const Color(0xFFD76B30),
                                      size: 24.0,
                                    ),
                                    const SizedBox(width: 12.0),
                                    Text(
                                      'Progress to Next Tier',
                                      style: GoogleFonts.poppins(
                                        color: FlutterFlowTheme.of(context).primaryText,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16.0),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: FlutterFlowTheme.of(context).alternate,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFD76B30),
                                  ),
                                  minHeight: 8.0,
                                ),
                                const SizedBox(height: 12.0),
                                Text(
                                  '$toGo points to reach $next and unlock ${Loyalty.tierName(next)}',
                                  style: GoogleFonts.poppins(
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA000),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.white,
                                  size: 28.0,
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Text(
                                    'Congratulations! You\'ve reached the highest tier!',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24.0),

                      // All Tiers Info
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Loyalty Tiers',
                                style: GoogleFonts.poppins(
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              _buildTierRow(context, Icons.star, 'Bronze', '400+ points', '10% off', points >= 400),
                              const SizedBox(height: 12.0),
                              _buildTierRow(context, Icons.military_tech, 'Silver', '800+ points', '15% off', points >= 800),
                              const SizedBox(height: 12.0),
                              _buildTierRow(context, Icons.workspace_premium, 'Gold', '1000+ points', '20% off', points >= 1000),
                            ],
                          ),
                        ),
                      ),
                      
                      // Manual Points Button (Temporary)
                      const SizedBox(height: 24.0),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.build,
                                    color: Colors.orange,
                                    size: 24.0,
                                  ),
                                  const SizedBox(width: 12.0),
                                  Text(
                                    'Temporary Points Fix',
                                    style: GoogleFonts.poppins(
                                      color: FlutterFlowTheme.of(context).primaryText,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              Text(
                                'If you completed a booking but didn\'t receive points, click the button below to manually award points for your completed bookings.',
                                style: GoogleFonts.poppins(
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 14.0,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              FFButtonWidget(
                                onPressed: () async {
                                  final result = await awardPointsForCompletedBookings();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result),
                                      backgroundColor: result.contains('Successfully') 
                                          ? Colors.green 
                                          : Colors.red,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                },
                                text: 'Award Missing Points',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 48,
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  color: Colors.orange,
                                  textStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(height: 12.0),
                              FFButtonWidget(
                                onPressed: () async {
                                  final result = 'Debug function removed for performance';
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Debug Report'),
                                      content: SingleChildScrollView(
                                        child: Text(result, style: TextStyle(fontFamily: 'monospace', fontSize: 12)),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                text: 'Debug Points & Bookings',
                                options: FFButtonOptions(
                                  width: double.infinity,
                                  height: 48,
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  color: Colors.blue,
                                  textStyle: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildTierRow(BuildContext context, IconData icon, String tier, String requirement, String benefit, bool achieved) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: achieved 
          ? const Color(0xFFD76B30).withOpacity(0.1)
          : FlutterFlowTheme.of(context).alternate.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: achieved 
            ? const Color(0xFFD76B30)
            : FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: achieved 
              ? const Color(0xFFD76B30)
              : FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier,
                  style: GoogleFonts.poppins(
                    color: achieved 
                      ? const Color(0xFFD76B30)
                      : FlutterFlowTheme.of(context).primaryText,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  requirement,
                  style: GoogleFonts.poppins(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            benefit,
            style: GoogleFonts.poppins(
              color: achieved 
                ? const Color(0xFFD76B30)
                : FlutterFlowTheme.of(context).secondaryText,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (achieved) ...[
            const SizedBox(width: 8.0),
            const Icon(
              Icons.check_circle,
              color: Color(0xFFD76B30),
              size: 20.0,
            ),
          ],
        ],
      ),
    );
  }
}