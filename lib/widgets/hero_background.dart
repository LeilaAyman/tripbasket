import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:math' as math;

const List<String> kHeroAssets = [
  'assets/images/200611101955-01-egypt-dahab.jpg',
];

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Use Timer for image switching every 3 seconds
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % kHeroAssets.length;
          print('Switching to image ${_currentImageIndex}: ${kHeroAssets[_currentImageIndex]}');
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
              child: Image.asset(
                kHeroAssets[_currentImageIndex],
                key: ValueKey(_currentImageIndex),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: ${kHeroAssets[_currentImageIndex]}');
                  print('Error details: $error');
                  return _fallback();
                },
              ),
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