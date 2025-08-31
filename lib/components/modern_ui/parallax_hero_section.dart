import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/theme/app_design_system.dart';
import '/components/modern_ui/premium_button.dart';

class ParallaxHeroSection extends StatefulWidget {
  final ScrollController? scrollController;
  final String title;
  final String subtitle;
  final String backgroundImage;
  final List<String> quickSearchTags;
  final VoidCallback? onExplorePressed;

  const ParallaxHeroSection({
    super.key,
    this.scrollController,
    this.title = 'Discover Amazing\nDestinations',
    this.subtitle = 'Explore unique trips and experiences around the world with premium travel experiences that create memories for a lifetime.',
    this.backgroundImage = 'https://img.youm7.com/ArticleImgs/2023/8/1/1192588-%D9%86%D9%88%D9%8A%D8%A8%D8%B9-(2).jpg',
    this.quickSearchTags = const ['Adventure', 'Beach', 'Mountain', 'City', 'Cultural'],
    this.onExplorePressed,
  });

  @override
  State<ParallaxHeroSection> createState() => _ParallaxHeroSectionState();
}

class _ParallaxHeroSectionState extends State<ParallaxHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _floatingController;
  late AnimationController _particleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;
  
  double _scrollOffset = 0;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppDesignSystem.animationXSlow,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppDesignSystem.animationSlow,
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _initializeParticles();
    _startAnimations();
    
    widget.scrollController?.addListener(_onScroll);
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 4 + 2,
          speed: random.nextDouble() * 0.5 + 0.2,
          opacity: random.nextDouble() * 0.6 + 0.2,
        ),
      );
    }
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _floatingController.repeat(reverse: true);
        _particleController.repeat();
      }
    });
  }

  void _onScroll() {
    if (widget.scrollController == null) return;
    setState(() {
      _scrollOffset = widget.scrollController!.offset;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _floatingController.dispose();
    _particleController.dispose();
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = AppDesignSystem.isDesktop(context) 
        ? screenHeight * 0.9 
        : screenHeight * 0.8;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          _buildParallaxBackground(heroHeight),
          _buildParticleEffect(),
          _buildGradientOverlay(),
          _buildContent(),
          _buildFloatingElements(),
        ],
      ),
    );
  }

  Widget _buildParallaxBackground(double heroHeight) {
    final parallaxOffset = _scrollOffset * 0.5;
    
    return Positioned(
      top: -parallaxOffset,
      left: 0,
      right: 0,
      height: heroHeight + parallaxOffset,
      child: Hero(
        tag: 'hero-background',
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.backgroundImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                AppDesignSystem.primaryBlue.withOpacity(0.3),
                BlendMode.overlay,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticleEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              particles: _particles,
              animationValue: _particleController.value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppDesignSystem.primaryBlue.withOpacity(0.2),
              AppDesignSystem.primaryBlue.withOpacity(0.6),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDesignSystem.space24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildMainContent(),
              const Spacer(flex: 1),
              _buildQuickSearchTags(),
              SizedBox(height: AppDesignSystem.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Text(
                widget.title,
                style: AppDesignSystem.heading1.copyWith(
                  color: AppDesignSystem.neutralWhite,
                  fontSize: AppDesignSystem.isDesktop(context) ? 64 : 48,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 4),
                      blurRadius: 20,
                      color: AppDesignSystem.primaryBlue.withOpacity(0.8),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppDesignSystem.space24),
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                widget.subtitle,
                style: AppDesignSystem.bodyLarge.copyWith(
                  color: AppDesignSystem.neutralGray100,
                  fontSize: 20,
                  height: 1.6,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 10,
                      color: AppDesignSystem.primaryBlue.withOpacity(0.6),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppDesignSystem.space40),
            _buildCTAButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return PremiumButton(
      text: 'Explore Destinations',
      type: PremiumButtonType.glow,
      size: PremiumButtonSize.large,
      icon: Icons.explore_rounded,
      onPressed: widget.onExplorePressed ?? _scrollToContent,
    );
  }

  Widget _buildQuickSearchTags() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDesignSystem.space12,
          runSpacing: AppDesignSystem.space12,
          children: widget.quickSearchTags.map((tag) {
            return _buildQuickSearchTag(tag);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickSearchTag(String tag) {
    return GestureDetector(
      onTap: () => _handleQuickSearch(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppDesignSystem.neutralWhite.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppDesignSystem.neutralWhite.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppDesignSystem.primaryBlue.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Text(
            tag,
            style: AppDesignSystem.bodySmall.copyWith(
              color: AppDesignSystem.neutralWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _floatingAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Floating circles
              ...List.generate(5, (index) {
                final offset = math.sin(_floatingAnimation.value * 2 * math.pi + index) * 10;
                return Positioned(
                  top: 100 + (index * 80) + offset,
                  right: 50 + (index * 30),
                  child: Container(
                    width: 20 + (index * 5),
                    height: 20 + (index * 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppDesignSystem.accentTeal.withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          color: AppDesignSystem.accentTeal.withOpacity(0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _handleQuickSearch(String tag) {
    HapticFeedback.lightImpact();
    // Navigate to search results
    // context.pushNamed('searchResults', queryParameters: {'searchQuery': tag});
  }

  void _scrollToContent() {
    if (widget.scrollController != null) {
      widget.scrollController!.animateTo(
        MediaQuery.of(context).size.height * 0.8,
        duration: AppDesignSystem.animationSlow,
        curve: Curves.easeInOut,
      );
    }
  }
}

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Update particle position
      particle.y = (particle.y + particle.speed * 0.01) % 1.0;
      
      final x = particle.x * size.width;
      final y = particle.y * size.height;
      
      paint.color = AppDesignSystem.neutralWhite.withOpacity(
        particle.opacity * (1 - particle.y), // Fade out towards bottom
      );
      
      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}