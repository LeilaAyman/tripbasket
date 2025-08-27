import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/state/currency_provider.dart';
import '/widgets/trip_card.dart';
import '/widgets/hero_background.dart';
import '/ui/responsive/breakpoints.dart';
import 'package:go_router/go_router.dart';

class HomeWebPage extends StatefulWidget {
  const HomeWebPage({super.key});

  @override
  State<HomeWebPage> createState() => _HomeWebPageState();
}

class _HomeWebPageState extends State<HomeWebPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          _buildStickyTopBar(),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                _buildHeroSection(),
                _buildTripsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyTopBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Logo
            Text(
              'TripBasket',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD76B30),
              ),
            ),
            const SizedBox(width: 48),
            
            // Search bar (center)
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      context.pushNamed(
                        'searchResults',
                        queryParameters: {
                          'searchQuery': value.trim(),
                        },
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: 16,
                    ),
                    prefixIcon: InkWell(
                      onTap: () {
                        final query = _searchController.text.trim();
                        if (query.isNotEmpty) {
                          context.pushNamed(
                            'searchResults',
                            queryParameters: {
                              'searchQuery': query,
                            },
                          );
                        }
                      },
                      child: Icon(
                        Icons.search,
                        color: const Color(0xFFD76B30),
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 48),
            
            // Navigation + Points + Profile
            Row(
              children: [
                // Navigation Menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onSelected: (value) => _handleMenuSelection(value),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'home',
                      child: ListTile(
                        leading: Icon(Icons.home, color: Color(0xFFD76B30)),
                        title: Text('Home'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'agencies',
                      child: ListTile(
                        leading: Icon(Icons.business, color: Color(0xFFD76B30)),
                        title: Text('Travel Agencies'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'reviews',
                      child: ListTile(
                        leading: Icon(Icons.rate_review, color: Color(0xFFD76B30)),
                        title: Text('Reviews'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'bookings',
                      child: ListTile(
                        leading: Icon(Icons.book_online, color: Color(0xFFD76B30)),
                        title: Text('My Bookings'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'cart',
                      child: ListTile(
                        leading: Icon(Icons.shopping_cart, color: Color(0xFFD76B30)),
                        title: Text('Shopping Cart'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'favorites',
                      child: ListTile(
                        leading: Icon(Icons.favorite, color: Color(0xFFD76B30)),
                        title: Text('My Favorites'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout, color: Colors.red[600]),
                        title: Text('Logout', style: TextStyle(color: Colors.red[600])),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2D83B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
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
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$pts pts',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFF2D83B),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Profile
                GestureDetector(
                  onTap: () => context.pushNamed('profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      currentUserDisplayName?.substring(0, 1).toUpperCase() ?? 
                      currentUserEmail.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onPrimary,
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
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: HeroBackground(
        height: 360.0, // web hero height
        // In the future we can pass networkUrl: kHeroUrl; on web the asset will still be used.
        child: Center(
          child: _buildHeroContent(),
        ),
      ),
    );
  }

  Widget _buildHeroContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Discover Amazing Destinations',
            style: GoogleFonts.poppins(
              fontSize: 48,
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
          const SizedBox(height: 16),
          Text(
            'Explore unique trips and experiences around the world',
            style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildTripsSection() {
    return SliverToBoxAdapter(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              'Popular Destinations',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<TripsRecord>>(
              stream: queryTripsRecord(),
              builder: (context, snapshot) {
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
            const SizedBox(height: 64),
          ],
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
            childAspectRatio: 0.75, // Adjust based on card content
          ),
          itemCount: trips.length,
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
}