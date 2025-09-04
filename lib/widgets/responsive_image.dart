import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/utils/image_optimization_helper.dart';

class ResponsiveImage extends StatelessWidget {
  final String basePath;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool isLCP;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const ResponsiveImage({
    super.key,
    required this.basePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.isLCP = false,
    this.errorBuilder,
  });

  String _getResponsiveImagePath(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final effectiveWidth = screenWidth * devicePixelRatio;
    
    // Choose the appropriate size variant based on screen dimensions
    String sizeVariant;
    if (effectiveWidth <= 480) {
      sizeVariant = '_sm'; // 300x200
    } else if (effectiveWidth <= 768) {
      sizeVariant = '_md'; // 600x400  
    } else {
      sizeVariant = '_lg'; // 1200x800
    }
    
    // For LCP element on large screens, always use large variant
    if (isLCP && effectiveWidth > 768) {
      sizeVariant = '_lg';
    }
    
    // Get base path without extension
    final pathWithoutExt = basePath.split('.').first;
    final extension = basePath.split('.').last;
    
    return '${pathWithoutExt}${sizeVariant}.${extension}';
  }

  @override
  Widget build(BuildContext context) {
    final responsivePath = _getResponsiveImagePath(context);
    final optimizedPath = ImageOptimizationHelper.getOptimizedPath(responsivePath);
    
    if (kDebugMode) {
      print('ResponsiveImage: ${basePath} -> ${responsivePath} -> ${optimizedPath}');
      print('Screen width: ${MediaQuery.of(context).size.width}, DPR: ${MediaQuery.of(context).devicePixelRatio}');
    }
    
    return Image.asset(
      optimizedPath,
      fit: fit,
      width: width,
      height: height,
      // Enable lazy loading for non-LCP images
      frameBuilder: !isLCP ? _lazyFrameBuilder : null,
      errorBuilder: errorBuilder ?? (context, error, stackTrace) {
        if (kDebugMode) {
          print('Error loading responsive image: $optimizedPath');
          print('Falling back to base path: $basePath');
        }
        // Fallback to original image if responsive version fails
        return Image.asset(
          basePath,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }

  Widget _lazyFrameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded || frame != null) {
      return AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: child,
      );
    }
    
    // Aggressive lazy loading - minimal placeholder
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F5F5), // Neutral background
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCCCCCC)),
          ),
        ),
      ),
    );
  }
}