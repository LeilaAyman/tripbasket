import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/utils/image_optimization_helper.dart';
import 'dart:async';
import 'dart:math' as math;

const List<String> _kHeroAssetsOriginal = [
  'assets/images/200611101955-01-egypt-dahab.jpg',
];

// Get optimized versions of hero assets
List<String> get kHeroAssets => ImageOptimizationHelper.getOptimizedPaths(_kHeroAssetsOriginal);

class HeroBackground extends StatefulWidget {
  final double height;
  final Widget child;
  
  const HeroBackground({
    super.key,
    required this.height,
    required this.child,
  });

  @override
  State<HeroBackground> createState() => _HeroBackgroundState();
}

class _HeroBackgroundState extends State<HeroBackground> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _imageTimer;
  late List<FloatingDot> _dots;
  int _currentImageIndex = 0;
  bool _imagesPreloaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Preload all hero images for better performance
    _preloadHeroImages();

    // Use Timer for image switching every 3 seconds
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _imagesPreloaded) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % kHeroAssets.length;
          if (kDebugMode) {
            print('Switching to image ${_currentImageIndex}: ${kHeroAssets[_currentImageIndex]}');
          }
        });
      }
    });

    // Generate random floating dots
    _dots = List.generate(15, (index) => FloatingDot(
      dx: math.Random().nextDouble(),
      dy: math.Random().nextDouble(),
      size: math.Random().nextDouble() * 8 + 4,
      speed: math.Random().nextDouble() * 0.5 + 0.2,
      opacity: math.Random().nextDouble() * 0.6 + 0.2,
    ));
  }

  Future<void> _preloadHeroImages() async {
    try {
      // Preload the first image immediately for LCP
      if (kHeroAssets.isNotEmpty) {
        await precacheImage(AssetImage(kHeroAssets[0]), context);
        if (mounted) setState(() => _imagesPreloaded = true);
      }
      
      // Preload remaining images in the background
      for (int i = 1; i < kHeroAssets.length; i++) {
        if (mounted) {
          Future.microtask(() => precacheImage(AssetImage(kHeroAssets[i]), context));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error preloading hero images: $e');
      }
      if (mounted) setState(() => _imagesPreloaded = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _imageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: _imagesPreloaded && kHeroAssets.isNotEmpty
                  ? Image.asset(
                      kHeroAssets[_currentImageIndex],
                      key: ValueKey(_currentImageIndex),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        if (kDebugMode) {
                          print('Error loading image: ${kHeroAssets[_currentImageIndex]}');
                          print('Error details: $error');
                        }
                        return _fallback();
                      },
                    )
                  : _fallback(), // Show fallback while preloading
            ),
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000), 
                  Color(0x33000000), 
                  Color(0x66000000)
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Animated floating dots
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: FloatingDotsPainter(_dots, _controller.value),
                size: Size.infinite,
              );
            },
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }

  Widget _fallback() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF7F3EE), Color(0xFFEDE7DE)],
      ),
    ),
  );
}

class FloatingDot {
  final double dx;
  final double dy;
  final double size;
  final double speed;
  final double opacity;

  FloatingDot({
    required this.dx,
    required this.dy,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class FloatingDotsPainter extends CustomPainter {
  final List<FloatingDot> dots;
  final double animationValue;

  FloatingDotsPainter(this.dots, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var dot in dots) {
      // Calculate animated position
      final x = (dot.dx + (animationValue * dot.speed)) % 1.0 * size.width;
      final y = (dot.dy + (animationValue * dot.speed * 0.3)) % 1.0 * size.height;
      
      // Create animated opacity
      final opacity = (dot.opacity * (0.8 + 0.2 * math.sin(animationValue * 2 * math.pi + dot.dx * 10))).clamp(0.0, 1.0);
      paint.color = Colors.white.withOpacity(opacity);
      
      // Draw the dot
      canvas.drawCircle(
        Offset(x, y),
        dot.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}