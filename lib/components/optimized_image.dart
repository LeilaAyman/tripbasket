import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/utils/image_optimization_helper.dart';

/// High-performance image component with lazy loading and WebP optimization
class OptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableLazyLoading;
  final double lazyLoadThreshold;
  final String? heroTag;

  const OptimizedImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.enableLazyLoading = true,
    this.lazyLoadThreshold = 200.0,
    this.heroTag,
  }) : super(key: key);

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  bool _shouldLoad = false;
  late ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    if (!widget.enableLazyLoading) {
      _shouldLoad = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.enableLazyLoading && !_shouldLoad) {
      _findScrollController();
    }
  }

  void _findScrollController() {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _scrollController = scrollable.widget.controller;
      _scrollController?.addListener(_checkVisibility);
      _checkVisibility();
    } else {
      // If no scroll controller found, load immediately
      _shouldLoad = true;
    }
  }

  void _checkVisibility() {
    if (!mounted || _shouldLoad) return;

    final renderObject = context.findRenderObject() as RenderBox?;
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final offset = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;

    final viewportHeight = MediaQuery.of(context).size.height;
    final isVisible = offset.dy + size.height + widget.lazyLoadThreshold >= 0 &&
                     offset.dy - widget.lazyLoadThreshold <= viewportHeight;

    if (isVisible && mounted) {
      setState(() => _shouldLoad = true);
      _scrollController?.removeListener(_checkVisibility);
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_checkVisibility);
    super.dispose();
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: widget.borderRadius,
          ),
          child: Center(
            child: Icon(
              Icons.image,
              color: Colors.grey[400],
              size: 32,
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: widget.borderRadius,
          ),
          child: Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.grey[400],
              size: 32,
            ),
          ),
        );
  }

  Widget _buildImage() {
    final optimizedUrl = ImageOptimizationHelper.getOptimizedPath(widget.imageUrl);
    
    final imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: widget.width?.toInt(),
      memCacheHeight: widget.height?.toInt(),
      maxWidthDiskCache: (widget.width ?? 800) * 2, // 2x for high DPI
      maxHeightDiskCache: (widget.height ?? 600) * 2,
    );

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLoad) {
      return _buildPlaceholder();
    }

    return _buildImage();
  }
}

/// Specialized component for trip card images with optimal sizing
class TripCardImage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const TripCardImage({
    Key? key,
    required this.imageUrl,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: 300,
      height: 200,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(12),
      heroTag: heroTag,
      enableLazyLoading: true,
      lazyLoadThreshold: 300.0,
    );
  }
}

/// Specialized component for hero background images
class HeroImage extends StatelessWidget {
  final String imageUrl;

  const HeroImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final constrainedWidth = screenWidth > 1920 ? 1920 : screenWidth;
    
    return OptimizedImage(
      imageUrl: imageUrl,
      width: constrainedWidth.toDouble(),
      height: 420,
      fit: BoxFit.cover,
      enableLazyLoading: false, // Load immediately for hero (LCP)
      placeholder: Container(
        width: constrainedWidth.toDouble(),
        height: 420,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD76B30).withOpacity(0.8),
              Color(0xFFD76B30),
            ],
          ),
        ),
      ),
    );
  }
}