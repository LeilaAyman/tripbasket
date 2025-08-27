import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/theme/app_design_system.dart';
import '/components/modern_ui/floating_navigation.dart';
import '/components/modern_ui/parallax_hero_section.dart';
import '/components/modern_ui/premium_trip_card.dart';
import '/components/modern_ui/premium_button.dart';
import '/services/favorites_service.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PremiumHomePage extends StatefulWidget {
  const PremiumHomePage({super.key});

  @override
  State<PremiumHomePage> createState() => _PremiumHomePageState();
}

class _PremiumHomePageState extends State<PremiumHomePage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _sectionController;
  late Animation<double> _sectionAnimation;
  
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Adventure', 'Beach', 'Mountain', 'City', 'Cultural'];
  
  @override
  void initState() {
    super.initState();
    
    _scrollController = ScrollController();
    _sectionController = AnimationController(
      duration: AppDesignSystem.animationSlow,
      vsync: this,
    );

    _sectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sectionController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _sectionController.forward();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesignSystem.neutralGray50,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildHeroSection(),
              _buildFeaturesSection(),
              _buildTripsSection(),
              _buildStatsSection(),
              _buildTestimonialsSection(),
              _buildFooterSection(),
            ],
          ),
          // Floating Navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FloatingNavigation(
              scrollController: _scrollController,
              onCartPressed: () => context.pushNamed('cart'),
              cartItemCount: 0, // TODO: Get from provider
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: ParallaxHeroSection(
        scrollController: _scrollController,
        title: 'Discover Amazing\nDestinations',
        subtitle: 'Explore unique trips and experiences around the world with premium travel experiences that create memories for a lifetime.',
        quickSearchTags: const ['Adventure', 'Beach', 'Mountain', 'City', 'Cultural'],
        onExplorePressed: () {
          _scrollController.animateTo(
            MediaQuery.of(context).size.height * 0.8,
            duration: AppDesignSystem.animationSlow,
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _sectionAnimation,
        child: Container(
          padding: EdgeInsets.all(AppDesignSystem.space48),
          child: Column(
            children: [
              Text(
                'Why Choose TripBasket?',
                style: AppDesignSystem.heading2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDesignSystem.space48),
              _buildFeatureCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.verified_user_rounded,
        'title': 'Trusted & Verified',
        'description': 'All our partners are carefully vetted and verified for your safety and peace of mind.',
        'color': AppDesignSystem.accentTeal,
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': '24/7 Support',
        'description': 'Round-the-clock customer support to assist you before, during, and after your trip.',
        'color': AppDesignSystem.accentCoral,
      },
      {
        'icon': Icons.price_check_rounded,
        'title': 'Best Price Guarantee',
        'description': 'We guarantee the best prices. Found cheaper elsewhere? We\'ll match it.',
        'color': AppDesignSystem.primaryGold,
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppDesignSystem.isDesktop(context);
        final cardWidth = isDesktop 
            ? (constraints.maxWidth - 64) / 3 
            : constraints.maxWidth;

        return isDesktop
            ? Row(
                children: features.map((feature) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.space16),
                      child: _buildFeatureCard(feature, cardWidth),
                    ),
                  );
                }).toList(),
              )
            : Column(
                children: features.map((feature) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDesignSystem.space16),
                    child: _buildFeatureCard(feature, cardWidth),
                  );
                }).toList(),
              );
      },
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.all(AppDesignSystem.space32),
      decoration: BoxDecoration(
        color: AppDesignSystem.neutralWhite,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
        boxShadow: AppDesignSystem.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (feature['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              feature['icon'] as IconData,
              size: 40,
              color: feature['color'] as Color,
            ),
          ),
          SizedBox(height: AppDesignSystem.space24),
          Text(
            feature['title'] as String,
            style: AppDesignSystem.heading4,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDesignSystem.space16),
          Text(
            feature['description'] as String,
            style: AppDesignSystem.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripsSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.space48),
        child: Column(
          children: [
            Text(
              'Featured Destinations',
              style: AppDesignSystem.heading2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDesignSystem.space16),
            Text(
              'Handpicked destinations for unforgettable experiences',
              style: AppDesignSystem.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDesignSystem.space40),
            _buildCategoryFilters(),
            SizedBox(height: AppDesignSystem.space32),
            _buildTripsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDesignSystem.space8),
            child: PremiumButton(
              text: category,
              type: isSelected 
                  ? PremiumButtonType.primary 
                  : PremiumButtonType.ghost,
              size: PremiumButtonSize.small,
              onPressed: () {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTripsGrid() {
    return StreamBuilder<List<TripsRecord>>(
      stream: queryTripsRecord(
        queryBuilder: (q) => q.orderBy('created_time', descending: true).limit(6),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildTripsGridSkeleton();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final trips = snapshot.data!;
        final filteredTrips = _selectedCategory == 'All'
            ? trips
            : trips.where((trip) => 
                trip.title.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
                trip.description.toLowerCase().contains(_selectedCategory.toLowerCase())
              ).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = AppDesignSystem.isDesktop(context);
            final crossAxisCount = isDesktop ? 3 : 1;
            final childAspectRatio = isDesktop ? 0.8 : 1.2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: AppDesignSystem.space16,
                mainAxisSpacing: AppDesignSystem.space16,
              ),
              itemCount: filteredTrips.length,
              itemBuilder: (context, index) {
                final trip = filteredTrips[index];
                return PremiumTripCard(
                  trip: trip,
                  isFavorite: false, // TODO: Get from favorites service
                  onFavoritePressed: () => _toggleFavorite(trip),
                  onBookPressed: () => _navigateToBooking(trip),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTripsGridSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AppDesignSystem.isDesktop(context) ? 3 : 1,
        childAspectRatio: AppDesignSystem.isDesktop(context) ? 0.8 : 1.2,
        crossAxisSpacing: AppDesignSystem.space16,
        mainAxisSpacing: AppDesignSystem.space16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppDesignSystem.neutralGray200,
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.space64),
      child: Column(
        children: [
          Icon(
            Icons.explore_off_rounded,
            size: 64,
            color: AppDesignSystem.neutralGray400,
          ),
          SizedBox(height: AppDesignSystem.space24),
          Text(
            'No destinations found',
            style: AppDesignSystem.heading4.copyWith(
              color: AppDesignSystem.neutralGray600,
            ),
          ),
          SizedBox(height: AppDesignSystem.space16),
          Text(
            'Try adjusting your filters or check back later for new destinations.',
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutralGray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.space48),
        decoration: BoxDecoration(
          gradient: AppDesignSystem.primaryGradient,
        ),
        child: Column(
          children: [
            Text(
              'Trusted by Thousands',
              style: AppDesignSystem.heading2.copyWith(
                color: AppDesignSystem.neutralWhite,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDesignSystem.space48),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'number': '10K+', 'label': 'Happy Travelers'},
      {'number': '500+', 'label': 'Destinations'},
      {'number': '50+', 'label': 'Countries'},
      {'number': '4.9', 'label': 'Average Rating'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppDesignSystem.isDesktop(context);
        
        return isDesktop
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: stats.map((stat) => _buildStatItem(stat)).toList(),
              )
            : Column(
                children: stats.map((stat) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDesignSystem.space16),
                    child: _buildStatItem(stat),
                  );
                }).toList(),
              );
      },
    );
  }

  Widget _buildStatItem(Map<String, String> stat) {
    return Column(
      children: [
        Text(
          stat['number']!,
          style: AppDesignSystem.heading1.copyWith(
            color: AppDesignSystem.neutralWhite,
            fontSize: 48,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: AppDesignSystem.space8),
        Text(
          stat['label']!,
          style: AppDesignSystem.bodyLarge.copyWith(
            color: AppDesignSystem.neutralGray200,
          ),
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection() {
    // Placeholder for testimonials
    return SliverToBoxAdapter(
      child: Container(
        height: 200,
        color: AppDesignSystem.neutralGray100,
        child: Center(
          child: Text(
            'Testimonials Section (Coming Soon)',
            style: AppDesignSystem.heading4,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.space48),
        color: AppDesignSystem.neutralGray900,
        child: Column(
          children: [
            Text(
              'TripBasket',
              style: AppDesignSystem.heading3.copyWith(
                color: AppDesignSystem.neutralWhite,
              ),
            ),
            SizedBox(height: AppDesignSystem.space16),
            Text(
              'Your premium travel companion',
              style: AppDesignSystem.bodyLarge.copyWith(
                color: AppDesignSystem.neutralGray300,
              ),
            ),
            SizedBox(height: AppDesignSystem.space32),
            Text(
              '© 2024 TripBasket. All rights reserved.',
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.neutralGray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(TripsRecord trip) {
    // TODO: Implement favorite toggle
  }

  void _navigateToBooking(TripsRecord trip) {
    context.pushNamed(
      'book_trip',
      queryParameters: {
        'tripId': trip.reference.id,
      },
    );
  }
}