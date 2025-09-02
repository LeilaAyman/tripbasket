import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/widgets/hero_background.dart';
import '/components/live_chat_widget.dart';
import '/utils/auth_navigation.dart';
import 'package:url_launcher/url_launcher.dart';
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

  // Search controllers
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _monthController = TextEditingController(text: 'Any Month');
  final TextEditingController _travelersController = TextEditingController(text: '1 Traveler');
  final TextEditingController _budgetController = TextEditingController(text: 'Any Budget');
  DateTime? _selectedDate;
  int _travelers = 1;
  String _selectedBudget = 'Any Budget';

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
    _destinationController.dispose();
    _monthController.dispose();
    _travelersController.dispose();
    _budgetController.dispose();
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
          _buildMobilePremiumDestinationsSection(),
          _buildMobileTestimonialsSection(),
          _buildMobileContactUsSection(),
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
      automaticallyImplyLeading: false,
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
                              backgroundImage: currentUserPhoto.isNotEmpty 
                                  ? NetworkImage(currentUserPhoto) 
                                  : null,
                              child: currentUserPhoto.isEmpty ? Text(
                                currentUserDisplayName?.isNotEmpty == true && currentUserDisplayName!.isNotEmpty 
                                    ? currentUserDisplayName!.substring(0, 1).toUpperCase() 
                                    : (currentUserEmail.isNotEmpty ? currentUserEmail.substring(0, 1).toUpperCase() : 'U'),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ) : null,
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
                  _buildMobileSearchField(
                    controller: _destinationController,
                    label: 'Destination',
                    icon: Icons.location_on,
                    hintText: 'Where do you want to go?',
                    onTap: null,
                  ),
                  const SizedBox(height: 16),
                  _buildMobileSearchField(
                    controller: _monthController,
                    label: 'Month you wish to travel',
                    icon: Icons.calendar_today,
                    hintText: 'Select month',
                    readOnly: true,
                    onTap: () => _selectMonth(),
                  ),
                  const SizedBox(height: 16),
                  _buildMobileSearchField(
                    controller: _travelersController,
                    label: 'Number of travelers',
                    icon: Icons.people,
                    hintText: 'How many travelers?',
                    readOnly: true,
                    onTap: () => _selectTravelers(),
                  ),
                  const SizedBox(height: 16),
                  _buildMobileSearchField(
                    controller: _budgetController,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSearchField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hintText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
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
              child: TextFormField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
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
              Icons.emoji_events,
              'Best Agencies for Group & Customizable Trips',
              'Travel with confidence — our agencies are known for creating memorable journeys, perfect for solo travelers looking to make new friends and unforgettable experiences.',
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
              'Clear Refund Policies',
              'Transparent and hassle-free cancellation with clear refund options — giving you peace of mind when plans change.',
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

  // Search functionality methods
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
                          color: _monthController.text == months[index] 
                            ? const Color(0xFFD76B30) 
                            : Colors.black87,
                          fontWeight: _monthController.text == months[index] 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _monthController.text = months[index];
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
                          color: _budgetController.text == budgets[index] 
                            ? const Color(0xFFD76B30) 
                            : Colors.black87,
                          fontWeight: _budgetController.text == budgets[index] 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _budgetController.text = budgets[index];
                          _selectedBudget = budgets[index];
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

  Future<void> _selectTravelers() async {
    final int? selected = await showDialog<int>(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Number of Travelers',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _travelers > 1 ? () {
                      setState(() {
                        _travelers--;
                      });
                    } : null,
                    icon: const Icon(Icons.remove),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFD76B30).withOpacity(0.1),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_travelers',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _travelers < 10 ? () {
                      setState(() {
                        _travelers++;
                      });
                    } : null,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFD76B30).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_travelers),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD76B30),
                      ),
                      child: Text(
                        'Done',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _travelers = selected;
        _travelersController.text = '$_travelers traveler${_travelers > 1 ? 's' : ''}';
      });
    }
  }

  void _performSearch() {
    String destination = _destinationController.text.trim();
    String month = _monthController.text.trim();
    String budget = _budgetController.text.trim();
    
    if (destination.isNotEmpty) {
      // Only use destination in the search query, other fields are filters
      context.pushNamed(
        'searchResults',
        queryParameters: {
          'searchQuery': destination, // Only destination goes in search
          'destination': destination,
          'month': month != 'Any Month' ? month : '',
          'travelers': _travelers.toString(),
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


  void _scrollToFeatures() {
    // Navigate to features section - for now we'll scroll down or navigate to search
    context.pushNamed('searchResults');
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
      builder: (context) => _SignInDialog(),
    );
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
        AuthNavigation.pushNamedAuth(context, 'profile');
        break;
      case 'bookings':
        AuthNavigation.pushNamedAuth(context, 'mybookings');
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
      AuthNavigation.goNamedAuth(context, 'landing');
    }
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) => _RegisterDialog(),
    );
  }


  void _scrollToSearch() {
    // Navigate to search results page
    context.pushNamed('searchResults');
  }

  void _scrollToContact() {
    // Open live chat support
    _startLiveChat();
  }

  Widget _buildMobilePremiumDestinationsSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Top Destinations',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Carefully curated experiences in extraordinary locations',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            StreamBuilder<List<TripsRecord>>(
              stream: queryTripsRecord(
                queryBuilder: (q) => q.limit(6),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Mobile: Error loading trips: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.error, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error loading trips: ${snapshot.error}'),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: Color(0xFFD76B30),
                      ),
                    ),
                  );
                }

                final trips = snapshot.data!;
                print('Mobile: Trips loaded: ${trips.length} trips found');
                
                if (trips.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Amazing trips coming soon!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: math.min(3, trips.length),
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return _buildMobileDestinationCard(trip);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => context.pushNamed('searchResults'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD76B30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'View All Destinations',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDestinationCard(TripsRecord trip) {
    return GestureDetector(
      onTap: () {
        // Navigate to trip booking page
        print('Mobile: Tapping destination card for trip: ${trip.title}');
        print('Mobile: Trip reference ID: ${trip.reference.id}');
        
        context.pushNamed(
          'bookings',
          queryParameters: {
            'tripref': trip.reference.id,
          },
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
            // Background Image
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: trip.image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(trip.image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: trip.image.isEmpty
                  ? Icon(
                      Icons.image,
                      size: 64,
                      color: Colors.grey.shade400,
                    )
                  : null,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.location,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD76B30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'From EGP ${trip.price.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (trip.rating > 0) ...[
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildMobileContactUsSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Get in Touch',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Have questions? We\'re here to help 24/7',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                _buildMobileContactMethod(
                  Icons.chat_bubble_outline,
                  'Live Chat',
                  'Chat with our travel experts',
                  () => _startLiveChat(),
                ),
                const SizedBox(height: 16),
                _buildMobileContactMethod(
                  Icons.phone_outlined,
                  'Call Us',
                  '+1 (555) 123-TRIP',
                  () => _makePhoneCall(),
                ),
                const SizedBox(height: 16),
                _buildMobileContactMethod(
                  Icons.email_outlined,
                  'Email Support',
                  'info@tripsbasket.com',
                  () => _sendEmail(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContactMethod(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFD76B30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFFD76B30),
        ),
      ),
    );
  }

  void _startLiveChat() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.center,
        child: const LiveChatWidget(),
      ),
    );
  }

  void _makePhoneCall() async {
    final url = Uri.parse('tel:+15551234TRIP');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make phone call'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendEmail() async {
    final url = Uri.parse('mailto:info@tripsbasket.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open email app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Sign In Dialog for Mobile
class _SignInDialog extends StatefulWidget {
  @override
  State<_SignInDialog> createState() => _SignInDialogState();
}

class _SignInDialogState extends State<_SignInDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      GoRouter.of(context).prepareAuthEvent();
      final user = await authManager.signInWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text,
      );

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD76B30),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back! Please sign in to your account.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD76B30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Google Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: const Icon(Icons.login, color: Color(0xFFD76B30)),
                    label: Text(
                      'Sign in with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD76B30),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD76B30)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sign up link
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Show register dialog instead
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => _RegisterDialog(),
                        );
                      }
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFD76B30),
                            fontWeight: FontWeight.w600,
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
}

// Register Dialog for Mobile
class _RegisterDialog extends StatefulWidget {
  @override
  State<_RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<_RegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'user';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await authManager.createAccountWithEmail(
        context,
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        // Update user profile with additional info
        await currentUserDocument?.reference.update({
          'display_name': _nameController.text.trim(),
          'name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'role': [_selectedRole],
          'loyaltyPoints': 0,
        });

        Navigator.of(context).pop(); // Close dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Welcome to TripsBasket!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFD76B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed. Please try again.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);

    try {
      GoRouter.of(context).prepareAuthEvent();
      final user = await authManager.signInWithGoogle(context);

      if (user != null && mounted) {
        // Update user profile for new Google users (default to user role)
        await currentUserDocument?.reference.update({
          'role': currentUserDocument?.role.isEmpty ?? true ? ['user'] : currentUserDocument!.role,
          'loyaltyPoints': currentUserDocument?.loyaltyPoints ?? 0,
          'display_name': currentUserDocument?.displayName.isEmpty ?? true 
              ? user.displayName ?? '' 
              : currentUserDocument!.displayName,
          'name': currentUserDocument?.name.isEmpty ?? true 
              ? user.displayName ?? '' 
              : currentUserDocument!.name,
        });
        
        Navigator.of(context).pop(); // Close dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Welcome to TripsBasket!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFD76B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-up failed. Please try again.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 650),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD76B30),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Join us today and start planning your dream travels!',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Phone field
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Account type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Account Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.account_circle_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('Traveler')),
                    DropdownMenuItem(value: 'agency', child: Text('Travel Agency')),
                  ],
                  onChanged: (value) => setState(() => _selectedRole = value ?? 'user'),
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Register button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD76B30),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Google Register button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleRegister,
                    icon: const Icon(Icons.account_circle, color: Color(0xFFD76B30)),
                    label: Text(
                      'Sign up with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD76B30),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD76B30)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sign in link
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Show sign in dialog instead
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => _SignInDialog(),
                        );
                      }
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFD76B30),
                            fontWeight: FontWeight.w600,
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
}
