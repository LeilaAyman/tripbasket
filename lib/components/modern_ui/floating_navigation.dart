import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/theme/app_design_system.dart';
import '/components/modern_ui/premium_button.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FloatingNavigation extends StatefulWidget {
  final ScrollController? scrollController;
  final VoidCallback? onCartPressed;
  final int cartItemCount;

  const FloatingNavigation({
    super.key,
    this.scrollController,
    this.onCartPressed,
    this.cartItemCount = 0,
  });

  @override
  State<FloatingNavigation> createState() => _FloatingNavigationState();
}

class _FloatingNavigationState extends State<FloatingNavigation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isVisible = false;
  double _lastScrollPosition = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: AppDesignSystem.animationMedium,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: AppDesignSystem.animationSlow,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Show navigation after initial delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _slideController.forward();
        _fadeController.forward();
      }
    });

    // Listen to scroll changes
    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController == null) return;
    
    final currentPosition = widget.scrollController!.position.pixels;
    const threshold = 100.0;

    if (currentPosition > threshold && !_isVisible) {
      setState(() => _isVisible = true);
      _slideController.forward();
      _fadeController.forward();
    } else if (currentPosition <= threshold && _isVisible) {
      // Keep visible for better UX, or uncomment to hide on scroll up
      // setState(() => _isVisible = false);
      // _slideController.reverse();
      // _fadeController.reverse();
    }

    _lastScrollPosition = currentPosition;
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.pushNamed(
        'searchResults',
        queryParameters: {
          'searchQuery': query.trim(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.all(AppDesignSystem.space16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: AppDesignSystem.glassMorphism.copyWith(
                      boxShadow: [
                        BoxShadow(
                          color: AppDesignSystem.primaryBlue.withOpacity(0.1),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(AppDesignSystem.space16),
                    child: AppDesignSystem.isDesktop(context)
                        ? _buildDesktopNavigation()
                        : _buildMobileNavigation(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopNavigation() {
    return Row(
      children: [
        // Logo
        _buildLogo(),
        
        const SizedBox(width: 32),
        
        // Search Bar
        Expanded(
          child: _buildSearchBar(),
        ),
        
        const SizedBox(width: 32),
        
        // Navigation Links
        _buildNavigationLinks(),
        
        const SizedBox(width: 24),
        
        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildMobileNavigation() {
    return Row(
      children: [
        // Logo
        _buildLogo(),
        
        const Spacer(),
        
        // Search Icon
        _buildIconButton(
          icon: Icons.search_rounded,
          onPressed: () => _showSearchModal(),
        ),
        
        const SizedBox(width: 12),
        
        // Cart Button
        _buildCartButton(),
        
        const SizedBox(width: 12),
        
        // Menu Button
        _buildIconButton(
          icon: Icons.menu_rounded,
          onPressed: () => _showMenuModal(),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return GestureDetector(
      onTap: () => context.pushNamed('home'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'TripsBasket',
          style: AppDesignSystem.heading5.copyWith(
            color: AppDesignSystem.primaryBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Focus(
        onFocusChange: (focused) {
          setState(() => _isSearchFocused = focused);
        },
        child: TextFormField(
          controller: _searchController,
          onFieldSubmitted: _handleSearch,
          style: AppDesignSystem.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search amazing destinations...',
            hintStyle: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.neutralGray500,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppDesignSystem.accentTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppDesignSystem.accentTeal,
                size: 20,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppDesignSystem.neutralGray500,
                      size: 20,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppDesignSystem.neutralWhite.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
              borderSide: BorderSide(
                color: AppDesignSystem.accentTeal,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationLinks() {
    final links = [
      ('Home', 'home'),
      ('Destinations', 'searchResults'),
      ('Reviews', 'reviews'),
      ('Agencies', 'agenciesList'),
    ];

    return Row(
      children: links.map((link) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: PremiumButton(
            text: link.$1,
            type: PremiumButtonType.ghost,
            size: PremiumButtonSize.small,
            onPressed: () {
              if (link.$2 == 'searchResults') {
                // Navigate to search results showing all destinations
                context.pushNamed(link.$2, queryParameters: {
                  'showAll': 'true',
                });
              } else {
                context.pushNamed(link.$2);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildCartButton(),
        const SizedBox(width: 12),
        PremiumButton(
          text: 'Sign In',
          type: PremiumButtonType.primary,
          size: PremiumButtonSize.small,
          onPressed: () => context.pushNamed('home'),
        ),
      ],
    );
  }

  Widget _buildCartButton() {
    return GestureDetector(
      onTap: widget.onCartPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppDesignSystem.accentCoral.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppDesignSystem.accentCoral.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                color: AppDesignSystem.accentCoral,
                size: 20,
              ),
            ),
            if (widget.cartItemCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppDesignSystem.accentCoral,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.cartItemCount.toString(),
                      style: AppDesignSystem.caption.copyWith(
                        color: AppDesignSystem.neutralWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppDesignSystem.neutralWhite.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppDesignSystem.neutralWhite.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppDesignSystem.primaryBlue,
          size: 20,
        ),
      ),
    );
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: AppDesignSystem.glassMorphism,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Search Destinations',
                    style: AppDesignSystem.heading4,
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMenuModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: AppDesignSystem.glassMorphism,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Menu',
              style: AppDesignSystem.heading4,
            ),
            const SizedBox(height: 24),
            // Add menu items here
          ],
        ),
      ),
    );
  }
}