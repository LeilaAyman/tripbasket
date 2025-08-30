import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/backend/backend.dart';
import '/utils/agency_utils.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/state/currency_provider.dart';
import '/widgets/trip_card.dart';
import '/widgets/hero_background.dart';
import '/ui/responsive/breakpoints.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '/components/live_chat_widget.dart';
import '/utils/auth_navigation.dart';

class HomeWebPage extends StatefulWidget {
  const HomeWebPage({super.key});

  @override
  State<HomeWebPage> createState() => _HomeWebPageState();
}

class _HomeWebPageState extends State<HomeWebPage>
    with TickerProviderStateMixin {
  // Search form controllers
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  String _selectedTravelers = '1 Traveler';
  String _selectedBudget = 'Any Budget';
  
  final ScrollController _scrollController = ScrollController();
  
  // Animation controllers
  late AnimationController _heroAnimationController;
  late AnimationController _floatingAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;
  late Animation<Offset> _buttonsSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize entrance animation controller (runs once)
    _heroAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize floating animation controller (loops forever)
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Title animations
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Subtitle animations
    _subtitleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    // Buttons animations
    _buttonsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _buttonsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroAnimationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    // Start the entrance animation only once
    _heroAnimationController.forward();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _checkInController.dispose();
    _checkOutController.dispose();
    _scrollController.dispose();
    _heroAnimationController.dispose();
    _floatingAnimationController.dispose();
    super.dispose();
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'home':
        // Already on home page
        break;
      case 'agencies':
        context.pushNamed('agenciesList');
        break;
      case 'reviews':
        context.pushNamed('reviews');
        break;
      case 'bookings':
        context.pushNamed('mybookings');
        break;
      case 'cart':
        context.pushNamed('cart');
        break;
      case 'favorites':
        context.pushNamed('favorites');
        break;
      case 'logout':
        _handleLogout();
        break;
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
                  _showLoginDialog();
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
                            '$cartItemCount',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => _LoginDialog(),
    );
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (context) => _RegisterDialog(),
    );
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

  @override
  Widget build(BuildContext context) {
    final isAgencyUser = AgencyUtils.isCurrentUserAgency();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Preview mode banner for agency users
          if (isAgencyUser) _buildPreviewModeBanner(),
          
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildAppBar(),
                _buildHeroSection(),
          _buildFindYourTripSection(),
          _buildWhyChooseTripsBasketSection(),
          _buildTrustedPartnersSection(),
          _buildPremiumDestinationsSection(),
          _buildTravelersTestimonialsSection(),
          _buildContactUsSection(),
                _buildFooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewModeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2196F3),
            const Color(0xFF1976D2),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.preview,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Preview Mode - Viewing as Customer',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Returning to agency dashboard...'),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pushNamed('agency_dashboard');
            },
            icon: const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              'Back to Dashboard',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      pinned: true,
      snap: false,
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Logo
            Text(
              'TripsBasket',
              style: GoogleFonts.poppins(
                    fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD76B30),
              ),
            ),
                
                // Spacer to push navigation to center
                const Spacer(),
                
                // Navigation Menu - centered
                Row(
                  mainAxisSize: MainAxisSize.min,
              children: [
                    _buildNavButton('Home', () {
                      // Scroll to top or refresh page
                      _scrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                      );
                    }),
                    _buildNavButton('Destinations', () {
                      // Scroll to destinations section
                      _scrollController.animateTo(
                        1400,
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                      );
                    }),
                    _buildNavButton('Travel Agencies', () => context.pushNamed('agenciesList')),
                    _buildNavButton('Reviews', () => context.pushNamed('reviews')),
                    _buildNavButton('My Bookings', () => AuthNavigation.pushNamedAuth(context, 'mybookings')),
                    _buildNavButton('Profile', () => AuthNavigation.pushNamedAuth(context, 'profile')),
                  ],
                ),
                
                // Spacer to push points/buttons to right
                const Spacer(),
                
                // Cart, Points and Sign In - right aligned
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cart icon
                    _buildCartIcon(),
                    const SizedBox(width: 12),
                    
                    // Auth-responsive section
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, authSnapshot) {
                        final isUserLoggedIn = authSnapshot.hasData && authSnapshot.data != null;
                        
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isUserLoggedIn) ...[
                              // Points pill
                              StreamBuilder<UsersRecord>(
                                stream: currentUserReference != null 
                                    ? UsersRecord.getDocument(currentUserReference!)
                                    : null,
                                builder: (context, snapshot) {
                                  final pts = snapshot.hasData ? snapshot.data!.loyaltyPoints : 0;
                                  return InkWell(
                                    onTap: () => context.pushNamed('loyaltyPage'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF2D83B).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFF2D83B).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.card_giftcard,
                                            color: const Color(0xFFF2D83B),
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$pts pts',
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFF2D83B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              
                              // Profile avatar
                              GestureDetector(
                                onTap: () => AuthNavigation.pushNamedAuth(context, 'profile'),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFD76B30),
                                  child: Text(
                                    currentUserDisplayName?.isNotEmpty == true && currentUserDisplayName!.isNotEmpty 
                                        ? currentUserDisplayName!.substring(0, 1).toUpperCase() 
                                        : (currentUserEmail.isNotEmpty ? currentUserEmail.substring(0, 1).toUpperCase() : 'U'),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Sign In / Get Started buttons
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFD76B30)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  onTap: () => _showLoginDialog(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text(
                                      'Sign In',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFD76B30),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD76B30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: InkWell(
                                  onTap: () => _showRegisterDialog(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Text(
                                      'Get Started',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
              ],
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: HeroBackground(
        height: 600.0,
        child: Stack(
          children: [
            Center(
              child: Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                    // Animated title
                    SlideTransition(
                      position: _titleSlideAnimation,
                      child: FadeTransition(
                        opacity: _titleFadeAnimation,
                        child: Text(
                          'TripsBasket',
            style: GoogleFonts.poppins(
                            fontSize: 64,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            textAlign: TextAlign.center,
                        ),
                      ),
          ),
          const SizedBox(height: 16),
                    
                    // Animated subtitle
                    SlideTransition(
                      position: _subtitleSlideAnimation,
                      child: FadeTransition(
                        opacity: _subtitleFadeAnimation,
                        child: Text(
                          'Explore top destinations around the world with curated travel\nexperiences',
                          style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              height: 1.4,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
            ),
            textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Animated buttons
                    SlideTransition(
                      position: _buttonsSlideAnimation,
                      child: FadeTransition(
                        opacity: _buttonsFadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAnimatedButton(
                              text: 'Explore Destinations',
                              isOutlined: false,
                              onTap: () {
                                // Scroll to find your trip section
                                _scrollController.animateTo(
                                  600,
                                  duration: Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            const SizedBox(width: 24),
                            _buildAnimatedButton(
                              text: 'Learn More',
                              isOutlined: true,
                              onTap: () {
                                // Scroll to why choose section
                                _scrollController.animateTo(
                                  1200,
                                  duration: Duration(milliseconds: 800),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Floating plus button (bottom left)
            Positioned(
              left: 24,
              bottom: 24,
              child: _buildFloatingPlusButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingPlusButton() {
    return AnimatedBuilder(
      animation: _floatingAnimationController,
      builder: (context, child) {
        // Create a floating animation that cycles infinitely
        final floatValue = math.sin(_floatingAnimationController.value * 2 * math.pi) * 8;
        
        return Transform.translate(
          offset: Offset(0, floatValue),
          child: FadeTransition(
            opacity: _buttonsFadeAnimation,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFD76B30),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Scroll to search section
                    _scrollController.animateTo(
                      600,
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton({
    required String text,
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              color: isOutlined ? Colors.transparent : Colors.white,
              border: isOutlined ? Border.all(color: Colors.white, width: 2) : null,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isOutlined ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                onTapDown: (_) {
                  // Scale down effect on tap
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      color: isOutlined ? Colors.white : const Color(0xFFD76B30),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFindYourTripSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.grey.shade50,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
            children: [
              Text(
                'Find Your Perfect Trip',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(32),
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
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSearchField(
                        'Destination',
                        'Where do you want to go',
                        _destinationController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        'Check-in',
                        'mm / dd / yyyy',
                        _checkInController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        'Check-out',
                        'mm / dd / yyyy',
                        _checkOutController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        'Travelers',
                        _selectedTravelers,
                        ['1 Traveler', '2 Travelers', '3 Travelers', '4+ Travelers'],
                        (value) => setState(() => _selectedTravelers = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        'Max Budget',
                        _selectedBudget,
                        ['Any Budget', '\$500-\$1000', '\$1000-\$2000', '\$2000+'],
                        (value) => setState(() => _selectedBudget = value!),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      width: 200,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD76B30),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: InkWell(
                        onTap: _handleSearch,
                        borderRadius: BorderRadius.circular(28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Search Premium Trips',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(String label, String hint, TextEditingController controller) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          label,
              style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              suffixIcon: const Icon(Icons.calendar_today, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                controller.text = '${date.month.toString().padLeft(2, '0')} / ${date.day.toString().padLeft(2, '0')} / ${date.year}';
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSearch() {
    // Build search query based on form fields
    String query = _destinationController.text.trim();
    if (query.isNotEmpty) {
      context.pushNamed(
        'searchResults',
        queryParameters: {
          'searchQuery': query,
        },
      );
    }
  }

  Widget _buildWhyChooseTripsBasketSection() {
    return SliverToBoxAdapter(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Text(
              'Why Choose TripsBasket',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Experience travel like never before with our premium services\nand exclusive benefits',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildFeatureCard(Icons.price_check, 'Best Price Guarantee', 'Book with confidence knowing you get the lowest rates, with no hidden fees.')),
                  const SizedBox(width: 32),
                  Expanded(child: _buildFeatureCard(Icons.verified, 'Verified Agencies & Trusted Partners', 'Every travel agency on our platform is verified for quality and reliability, so your trip is always in safe hands.')),
                  const SizedBox(width: 32),
                  Expanded(child: _buildFeatureCard(Icons.credit_card, 'Easy Refund Policies', '💳 Hassle-free cancellation and refund options to give you peace of mind when plans change.')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD76B30),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 40,
              ),
            ),
            const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedPartnersSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              // Section Header
              Column(
                children: [
                  Text(
                    'Trusted Partners',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3142),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Partner with the best travel agencies worldwide, trusted by thousands of travelers',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD76B30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Verified & Certified Since 2020',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD76B30),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Partners Grid
              StreamBuilder<List<AgenciesRecord>>(
                stream: queryAgenciesRecord(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Partners query error: ${snapshot.error}');
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Error loading partners: ${snapshot.error}'),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildPartnersSkeleton();
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.business_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No partner agencies found',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.pushNamed('agenciesList'),
                            child: Text('Browse All Agencies'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final allPartners = snapshot.data!;
                  final partners = allPartners.take(6).toList(); // Show only first 6
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: partners.length,
                    itemBuilder: (context, index) {
                      final partner = partners[index];
                      return _buildPartnerCard(partner);
                    },
                  );
                },
              ),
              const SizedBox(height: 50),
              // View All Partners Button
              ElevatedButton(
                onPressed: () => context.pushNamed('agenciesList'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD76B30),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Partners',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerCard(AgenciesRecord partner) {
    print('Building partner card for: ${partner.name}');
    final joinDate = partner.createdAt;
    final yearsActive = joinDate != null 
        ? DateTime.now().difference(joinDate).inDays ~/ 365
        : 0;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFD76B30).withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.pushNamed('agencyTrips', queryParameters: {
            'agencyRef': partner.reference.id,
          }),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Partner Logo/Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD76B30).withOpacity(0.1),
                        const Color(0xFFDBA237).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD76B30).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: partner.logo.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            partner.logo,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPartnerInitials(partner.name);
                            },
                          ),
                        )
                      : _buildPartnerInitials(partner.name),
                ),
                const SizedBox(height: 20),
                // Partner Name
                Text(
                  partner.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3142),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFF2D83B),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      partner.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Partner Since
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD76B30).withOpacity(0.1),
                        const Color(0xFFDBA237).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    yearsActive > 0 
                        ? 'Partner since ${DateTime.now().year - yearsActive}'
                        : 'New Partner',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD76B30),
                      letterSpacing: 0.3,
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

  Widget _buildPartnerInitials(String name) {
    final initials = name.split(' ').take(2).map((word) => word[0]).join().toUpperCase();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD76B30),
            const Color(0xFFDBA237),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildPartnersSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFD76B30),
              ),
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumDestinationsSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.grey.shade50,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Text(
                'Premium Destinations',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Carefully curated experiences in the world\'s most\nextraordinary locations',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
            StreamBuilder<List<TripsRecord>>(
              stream: queryTripsRecord(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error loading trips: ${snapshot.error}');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(64),
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
                      padding: EdgeInsets.all(64),
                      child: CircularProgressIndicator(
                        color: Color(0xFFD76B30),
                      ),
                    ),
                  );
                }

                final trips = snapshot.data!;
                print('Trips loaded: ${trips.length} trips found');
                
                if (trips.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(64),
                      child: Text('No trips available'),
                    ),
                  );
                }

                return _buildTripsGrid(trips);
              },
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripsGrid(List<TripsRecord> trips) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns;
        
        if (width >= kWebWide) {
          columns = 3;
        } else if (width >= kWebNarrow) {
          columns = 2;
        } else {
          columns = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: trips.length > 6 ? 6 : trips.length, // Show max 6 trips
          itemBuilder: (context, index) {
            return TripCard(
              trip: trips[index],
              isWeb: true,
            );
          },
        );
      },
    );
  }

  Widget _buildTravelersTestimonialsSection() {
    return SliverToBoxAdapter(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Text(
              'What Our Travelers Say',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Real experiences from our community of premium travelers',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            // Stream real reviews from database
            StreamBuilder<List<ReviewsRecord>>(
              stream: queryReviewsRecord(
                queryBuilder: (q) => q
                    .where('rating', isGreaterThanOrEqualTo: 4.0) // Only high ratings
                    .limit(10), // Get more reviews to filter from
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Fallback to sample testimonials if no reviews exist
                  return Row(
                    children: [
                      Expanded(child: _buildFallbackTestimonialCard('ET', 'Amazing experience with professional service', 5.0)),
                      const SizedBox(width: 32),
                      Expanded(child: _buildFallbackTestimonialCard('DK', 'Exceeded all expectations, highly recommended', 5.0)),
                      const SizedBox(width: 32),
                      Expanded(child: _buildFallbackTestimonialCard('LA', 'Unforgettable journey with attention to detail', 5.0)),
                    ],
                  );
                }

                final reviews = snapshot.data!;
                
                // Sort reviews by rating (descending) then by created time (descending)
                reviews.sort((a, b) {
                  int ratingComparison = b.rating.compareTo(a.rating);
                  if (ratingComparison != 0) return ratingComparison;
                  if (a.createdAt != null && b.createdAt != null) {
                    return b.createdAt!.compareTo(a.createdAt!);
                  }
                  return 0;
                });
                
                // Take top 3 reviews
                final displayReviews = reviews.take(3).toList();
                
                // Fill with fallback if needed
                while (displayReviews.length < 3) {
                  displayReviews.add(displayReviews.isNotEmpty 
                      ? displayReviews.first 
                      : reviews.first);
                }

                return Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 32),
                      Expanded(child: _buildRealTestimonialCard(displayReviews[i])),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTestimonialCard(ReviewsRecord review) {
    // Get user initials from user name or email
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
      if (review.comment.length <= 120) {
        return review.comment;
      }
      return '${review.comment.substring(0, 120)}...';
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Star rating based on actual rating
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
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFD76B30),
            child: Text(
              getInitials(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '"${getTruncatedComment()}"',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackTestimonialCard(String initials, String text, double rating) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => 
              Icon(
                Icons.star, 
                color: index < rating.round() ? Colors.amber : Colors.grey.shade300, 
                size: 20
              )
            ),
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFD76B30),
            child: Text(
              initials,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '"$text"',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactUsSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.grey.shade50,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              // Section Header
              Column(
                children: [
                  Text(
                    'Get in Touch',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3142),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Have questions? We\'re here to help 24/7. Reach out through live chat, phone, or email',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Contact Content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side - Contact Methods & Live Chat
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Methods',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Contact Options
                        _buildContactMethod(
                          Icons.chat_bubble_outline,
                          'Live Chat',
                          'Chat with our travel experts',
                          'Available 24/7',
                          const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          () => _startLiveChat(),
                        ),
                        const SizedBox(height: 20),
                        _buildContactMethod(
                          Icons.phone_outlined,
                          'Call Us',
                          '+1 (555) 123-TRIP',
                          'Mon-Sun 8AM-10PM EST',
                          const [Color(0xFF2196F3), Color(0xFF42A5F5)],
                          () => _makePhoneCall(),
                        ),
                        const SizedBox(height: 20),
                        _buildContactMethod(
                          Icons.email_outlined,
                          'Email Support',
                          'support@tripsbasket.com',
                          'Response within 2 hours',
                          const [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          () => _sendEmail(),
                        ),
                        const SizedBox(height: 20),
                        _buildContactMethod(
                          Icons.help_outline,
                          'Help Center',
                          'Browse our FAQ & guides',
                          'Self-service resources',
                          const [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                          () => _openHelpCenter(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Right Side - Contact Form
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFD76B30), Color(0xFFDBA237)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Send us a Message',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2D3142),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Contact Form
                          _buildContactForm(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Live Chat Widget
              _buildLiveChatWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String subtitle, String description, List<Color> colors, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3142),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors[0],
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      children: [
        // Name and Email Row
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                'Full Name',
                Icons.person_outline,
                TextInputType.name,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                'Email Address',
                Icons.email_outlined,
                TextInputType.emailAddress,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Subject
        _buildFormField(
          'Subject',
          Icons.subject_outlined,
          TextInputType.text,
        ),
        const SizedBox(height: 20),
        // Message
        _buildFormField(
          'Your Message',
          Icons.message_outlined,
          TextInputType.multiline,
          maxLines: 5,
        ),
        const SizedBox(height: 32),
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitContactForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD76B30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Send Message',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, IconData icon, TextInputType keyboardType, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFD76B30),
              size: 20,
            ),
            hintText: 'Enter your $label',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD76B30), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveChatWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Immediate Help?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chat with our travel experts now! Average response time: 30 seconds',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _startLiveChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start Chat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Contact Methods
  void _startLiveChat() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: const LiveChatWidget(),
      ),
    );
  }

  void _makePhoneCall() async {
    final url = Uri.parse('tel:+15551234TRIP');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _sendEmail() async {
    final url = Uri.parse('mailto:support@tripsbasket.com?subject=Support Request');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openHelpCenter() {
    // Navigate to help center or FAQ page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help Center'),
        content: Text('This would navigate to a comprehensive FAQ section or help documentation.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _submitContactForm() {
    // Implement form submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your message! We\'ll get back to you within 2 hours.'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFooterSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFFD76B30),
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TripsBasket',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Discover extraordinary destinations and create unforgettable memories with our premium travel experiences.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 80),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Links',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFooterLink('Destinations', () {
                          _scrollController.animateTo(
                            1400,
                            duration: Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                          );
                        }),
                        _buildFooterLink('Travel Agencies', () => context.pushNamed('agenciesList')),
                        _buildFooterLink('Reviews', () => context.pushNamed('reviews')),
                        _buildFooterLink('My Bookings', () => context.pushNamed('mybookings')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Account',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFooterLink('Profile', () => AuthNavigation.pushNamedAuth(context, 'profile')),
                        _buildFooterLink('My Bookings', () => AuthNavigation.pushNamedAuth(context, 'mybookings')),
                        _buildFooterLink('My Favorites', () => context.pushNamed('favorites')),
                        _buildFooterLink('Loyalty Points', () => context.pushNamed('loyaltyPage')),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFooterLink('Facebook', () async {
                          final url = Uri.parse('https://facebook.com/tripsbasket');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }),
                        _buildFooterLink('Instagram', () async {
                          final url = Uri.parse('https://instagram.com/tripsbasket');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }),
                        _buildFooterLink('Twitter', () async {
                          final url = Uri.parse('https://twitter.com/tripsbasket');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }),
                        _buildFooterLink('LinkedIn', () async {
                          final url = Uri.parse('https://linkedin.com/company/tripsbasket');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '© 2024 TripsBasket. All rights reserved. Crafted with ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Icon(
                      Icons.favorite,
                      color: Colors.pink.shade300,
                      size: 16,
                    ),
                    Text(
                      ' for premium travelers.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
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
  }

  Widget _buildFooterLink(String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

// Login Dialog Widget
class _LoginDialog extends StatefulWidget {
  @override
  State<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
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

  Future<void> _handleLogin() async {
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
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFD76B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please check your credentials.', style: GoogleFonts.poppins()),
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

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      GoRouter.of(context).prepareAuthEvent();
      final user = await authManager.signInWithGoogle(context);

      if (user != null && mounted) {
        // Update user profile to ensure we have customer role if no role exists
        await currentUserDocument?.reference.update({
          'role': currentUserDocument?.role.isEmpty ?? true ? ['user'] : currentUserDocument!.role,
          'loyaltyPoints': currentUserDocument?.loyaltyPoints ?? 0,
        });
        
        Navigator.of(context).pop(); // Close dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back!', style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFD76B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed. Please try again.', style: GoogleFonts.poppins()),
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
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              
              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD76B30),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              
              // Or divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 18,
                        width: 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285f4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  label: Text(
                    'Continue with Google',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Register link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => _RegisterDialog(),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD76B30),
                            fontWeight: FontWeight.w600,
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
    );
  }
}

// Register Dialog Widget
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
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
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
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                
                // Or divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Google Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4285f4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    label: Text(
                      'Continue with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Login link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) => _LoginDialog(),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD76B30),
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }
}