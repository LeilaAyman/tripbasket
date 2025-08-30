import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/widgets/hero_background.dart';
import 'dart:math' as math;

class HomeWebPageMobile extends StatefulWidget {
  const HomeWebPageMobile({super.key});

  @override
  State<HomeWebPageMobile> createState() => _HomeWebPageMobileState();
}

class _HomeWebPageMobileState extends State<HomeWebPageMobile> 
    with TickerProviderStateMixin {
  
  late AnimationController _heroController;
  late AnimationController _fadeController;
  
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Check if user was redirected from a protected page and show sign-in dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAuthRedirect();
    });
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _buttonsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildMobileAppBar(),
          _buildMobileHeroSection(),
          _buildMobileNavigationSection(),
          _buildMobileSearchSection(),
          _buildMobileFeaturesSection(),
          _buildMobileStatsSection(),
          _buildMobileTestimonialsSection(),
          _buildMobileFooter(),
        ],
      ),
    );
  }

  Widget _buildMobileAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      snap: true,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Logo
                Text(
                  'TripsBasket',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD76B30),
                  ),
                ),
                const Spacer(),
                
                // Authentication State dependent widgets
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (loggedIn) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Cart icon with badge
                          _buildCartIcon(),
                          const SizedBox(width: 8),
                          
                          // Profile menu
                          PopupMenuButton<String>(
                            onSelected: _handleMenuSelection,
                            icon: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFD76B30),
                              child: Text(
                                currentUserDisplayName?.isNotEmpty == true && currentUserDisplayName!.isNotEmpty 
                                    ? currentUserDisplayName!.substring(0, 1).toUpperCase() 
                                    : (currentUserEmail.isNotEmpty ? currentUserEmail.substring(0, 1).toUpperCase() : 'U'),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: [
                                    Icon(Icons.person, color: Color(0xFFD76B30), size: 16),
                                    SizedBox(width: 8),
                                    Text('Profile', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'bookings',
                                child: Row(
                                  children: [
                                    Icon(Icons.book, color: Color(0xFFD76B30), size: 16),
                                    SizedBox(width: 8),
                                    Text('My Bookings', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'favorites',
                                child: Row(
                                  children: [
                                    Icon(Icons.favorite, color: Color(0xFFD76B30), size: 16),
                                    SizedBox(width: 8),
                                    Text('Favorites', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.red.shade600, size: 16),
                                    SizedBox(width: 8),
                                    Text('Logout', style: TextStyle(fontSize: 14, color: Colors.red.shade600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Sign In / Get Started buttons for mobile
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sign In button (compact for mobile)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD76B30), width: 1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => _showSignInDialog(),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFD76B30),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Get Started button (compact for mobile)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFD76B30),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => _showRegisterDialog(),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Text(
                                  'Get Started',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeroSection() {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final heroHeight = math.min(screenHeight * 0.6, 400.0); // Cap maximum height
    final horizontalPadding = math.min(screenWidth * 0.05, 20.0); // Responsive padding
    
    return SliverToBoxAdapter(
      child: Container(
        height: heroHeight,
        child: HeroBackground(
          height: heroHeight,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _heroFadeAnimation,
                  child: SlideTransition(
                    position: _heroSlideAnimation,
                    child: Column(
                      children: [
                        Text(
                          'Discover Your Next\nAdventure',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: math.min(screenWidth * 0.07, 28).clamp(20, 28).toDouble(),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Curated premium travel experiences\nfrom trusted local agencies',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: math.min(screenWidth * 0.04, 16).clamp(12, 16).toDouble(),
                            color: Colors.white,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                offset: const Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        FadeTransition(
                          opacity: _buttonsFadeAnimation,
                          child: Column(
                            children: [
                              _buildMobileButton(
                                text: 'Explore Trips',
                                onPressed: () => context.pushNamed('searchResults'),
                              ),
                              const SizedBox(height: 12),
                              _buildMobileButton(
                                text: 'Learn More',
                                isOutlined: true,
                                onPressed: () => _scrollToFeatures(),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildMobileButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : Colors.white,
          foregroundColor: isOutlined ? Colors.white : const Color(0xFFD76B30),
          side: isOutlined ? const BorderSide(color: Colors.white, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: isOutlined ? 0 : 8,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavigationSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavigationItem(
              icon: Icons.business,
              label: 'Agencies',
              onTap: () => context.pushNamed('agenciesList'),
            ),
            _buildNavigationItem(
              icon: Icons.rate_review,
              label: 'Reviews',
              onTap: () => context.pushNamed('reviews'),
            ),
            if (loggedIn) ...[
              _buildNavigationItem(
                icon: Icons.favorite,
                label: 'Favorites',
                onTap: () => context.pushNamed('favorites'),
              ),
            ] else ...[
              _buildNavigationItem(
                icon: Icons.search,
                label: 'Search',
                onTap: () => _scrollToSearch(),
              ),
            ],
            _buildNavigationItem(
              icon: Icons.help_outline,
              label: 'Support',
              onTap: () => _scrollToContact(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD76B30).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFD76B30),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSearchSection() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsivePadding = math.min(screenWidth * 0.05, 20.0);
    
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(responsivePadding),
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your Perfect Trip',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Container(
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
                  _buildMobileSearchField('Destination', Icons.location_on),
                  const SizedBox(height: 16),
                  _buildMobileSearchField('Check-in', Icons.calendar_today),
                  const SizedBox(height: 16),
                  _buildMobileSearchField('Travelers', Icons.people),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed('searchResults'),
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
                            'Search Premium Trips',
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
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSearchField(String label, IconData icon) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFD76B30).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD76B30),
              size: 20,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFeaturesSection() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsivePadding = math.min(screenWidth * 0.05, 20.0);
    
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(responsivePadding),
        child: Column(
          children: [
            Text(
              'Why Choose TripsBasket?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            _buildMobileFeatureCard(
              Icons.price_check,
              'Best Price Guarantee',
              'Book with confidence knowing you get the lowest rates, with no hidden fees.',
            ),
            const SizedBox(height: 20),
            _buildMobileFeatureCard(
              Icons.verified,
              'Verified Agencies & Trusted Partners',
              'Every travel agency on our platform is verified for quality and reliability, so your trip is always in safe hands.',
            ),
            const SizedBox(height: 20),
            _buildMobileFeatureCard(
              Icons.credit_card,
              'Easy Refund Policies',
              '💳 Hassle-free cancellation and refund options to give you peace of mind when plans change.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD76B30),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatsSection() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsivePadding = math.min(screenWidth * 0.05, 20.0);
    
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(responsivePadding),
        color: const Color(0xFFD76B30),
        child: Column(
          children: [
            Text(
              'Trusted by Travelers Worldwide',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildMobileStatCard('10K+', 'Happy Travelers')),
                const SizedBox(width: 16),
                Expanded(child: _buildMobileStatCard('500+', 'Premium Trips')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMobileStatCard('50+', 'Trusted Agencies')),
                const SizedBox(width: 16),
                Expanded(child: _buildMobileStatCard('4.9★', 'Average Rating')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTestimonialsSection() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsivePadding = math.min(screenWidth * 0.05, 20.0);
    
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(responsivePadding),
        child: Column(
          children: [
            Text(
              'What Our Travelers Say',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            StreamBuilder<List<ReviewsRecord>>(
              stream: queryReviewsRecord(
                queryBuilder: (q) => q
                    .where('rating', isGreaterThanOrEqualTo: 4.0)
                    .limit(3),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      _buildMobileTestimonialCard('ET', 'Amazing experience with professional service', 5.0),
                      const SizedBox(height: 16),
                      _buildMobileTestimonialCard('DK', 'Exceeded all expectations, highly recommended', 5.0),
                      const SizedBox(height: 16),
                      _buildMobileTestimonialCard('LA', 'Unforgettable journey with attention to detail', 5.0),
                    ],
                  );
                }

                final reviews = snapshot.data!;
                reviews.sort((a, b) {
                  int ratingComparison = b.rating.compareTo(a.rating);
                  if (ratingComparison != 0) return ratingComparison;
                  if (a.createdAt != null && b.createdAt != null) {
                    return b.createdAt!.compareTo(a.createdAt!);
                  }
                  return 0;
                });

                final displayReviews = reviews.take(3).toList();

                return Column(
                  children: displayReviews.asMap().entries.map((entry) {
                    int index = entry.key;
                    ReviewsRecord review = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const SizedBox(height: 16),
                        _buildMobileTestimonialCard(
                          _generateInitials(review.userName),
                          review.comment.length > 80 
                              ? '${review.comment.substring(0, math.min(80, review.comment.length))}...'
                              : review.comment,
                          review.rating,
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTestimonialCard(String initials, String comment, double rating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD76B30),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating.floor() ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF2D83B),
                      size: 20,
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            comment,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFooter() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsivePadding = math.min(screenWidth * 0.05, 20.0);
    
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(responsivePadding),
        color: Colors.grey.shade900,
        child: Column(
          children: [
            Text(
              'TripsBasket',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your gateway to premium travel experiences',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMobileFooterLink('About'),
                _buildMobileFooterLink('Contact'),
                _buildMobileFooterLink('Terms'),
                _buildMobileFooterLink('Privacy'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '© 2024 TripsBasket. All rights reserved.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFooterLink(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }


  void _scrollToFeatures() {
    // Scroll to features section
    // This would need a ScrollController to work properly
  }

  void _checkForAuthRedirect() {
    // Check if user is not logged in and there's a redirect location
    if (!loggedIn) {
      final appStateNotifier = GoRouter.of(context).appState;
      if (appStateNotifier.hasRedirect()) {
        // User was redirected from a protected page, show sign-in dialog
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showSignInDialog();
          }
        });
      }
    }
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD76B30),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _signInWithGoogle(),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: Text(
                    'Sign in with Google',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD76B30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      GoRouter.of(context).prepareAuthEvent();
      final user = await authManager.signInWithGoogle(context);
      
      if (user != null && mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully signed in!'),
            backgroundColor: Color(0xFFD76B30),
          ),
        );
        
        // Check if there's a redirect location and navigate there
        final appStateNotifier = GoRouter.of(context).appState;
        if (appStateNotifier.hasRedirect()) {
          final redirectLocation = appStateNotifier.getRedirectLocation();
          appStateNotifier.clearRedirectLocation();
          if (redirectLocation != null) {
            context.go(redirectLocation);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCartIcon() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        final isUserLoggedIn = authSnapshot.hasData && authSnapshot.data != null;
        
        return StreamBuilder<List<CartRecord>>(
          stream: isUserLoggedIn 
              ? queryCartRecord(
                  queryBuilder: (cart) => cart.where('userReference', isEqualTo: currentUserReference),
                )
              : Stream.value([]),
          builder: (context, snapshot) {
            final cartItemCount = snapshot.hasData ? snapshot.data!.length : 0;
            
            return InkWell(
              onTap: () {
                if (isUserLoggedIn) {
                  context.pushNamed('cart');
                } else {
                  _showSignInDialog();
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: const Color(0xFFD76B30),
                      size: 20,
                    ),
                    if (cartItemCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            cartItemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        context.pushNamed('profile');
        break;
      case 'bookings':
        context.pushNamed('mybookings');
        break;
      case 'favorites':
        context.pushNamed('favorites');
        break;
      case 'logout':
        _handleLogout();
        break;
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
            ),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true) {
      GoRouter.of(context).prepareAuthEvent();
      await authManager.signOut();
      GoRouter.of(context).clearRedirectLocation();
      context.goNamedAuth('landing', context.mounted);
    }
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Started',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD76B30),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create your account to start booking amazing trips!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _registerWithGoogle(),
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  label: Text(
                    'Sign up with Google',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD76B30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerWithGoogle() async {
    try {
      GoRouter.of(context).prepareAuthEvent();
      final user = await authManager.signInWithGoogle(context);
      
      if (user != null && mounted) {
        Navigator.of(context).pop(); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome to TripsBasket!'),
            backgroundColor: Color(0xFFD76B30),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToSearch() {
    // For now, just show a snackbar since we'd need a scroll controller to implement this
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scroll down to see search options'),
        backgroundColor: Color(0xFFD76B30),
      ),
    );
  }

  void _scrollToContact() {
    // For now, just show a snackbar since we'd need a scroll controller to implement this
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scroll down to see contact information'),
        backgroundColor: Color(0xFFD76B30),
      ),
    );
  }
}
