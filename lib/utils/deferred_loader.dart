import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Deferred loading utility to reduce initial bundle size
class DeferredLoader {
  static final Map<String, Completer<dynamic>> _loadingCache = {};
  static final Map<String, dynamic> _loadedModules = {};

  /// Load a module with deferred loading
  static Future<T> loadModule<T>(
    String moduleKey,
    Future<T> Function() loader, {
    Duration? timeout,
  }) async {
    // Return cached module if already loaded
    if (_loadedModules.containsKey(moduleKey)) {
      return _loadedModules[moduleKey] as T;
    }

    // Return existing loading future if already in progress
    if (_loadingCache.containsKey(moduleKey)) {
      return _loadingCache[moduleKey]!.future as T;
    }

    // Start loading
    final completer = Completer<T>();
    _loadingCache[moduleKey] = completer;

    try {
      final result = timeout != null
          ? await loader().timeout(timeout)
          : await loader();
      
      _loadedModules[moduleKey] = result;
      completer.complete(result);
      return result;
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _loadingCache.remove(moduleKey);
    }
  }

  /// Preload modules in the background
  static void preloadModules(Map<String, Future<dynamic> Function()> modules) {
    if (kIsWeb) {
      // Preload after initial paint
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          for (final entry in modules.entries) {
            loadModule(entry.key, entry.value).catchError((e) {
              debugPrint('Preload failed for ${entry.key}: $e');
            });
          }
        });
      });
    }
  }

  /// Check if module is loaded
  static bool isLoaded(String moduleKey) {
    return _loadedModules.containsKey(moduleKey);
  }

  /// Clear cache (useful for testing)
  static void clearCache() {
    _loadingCache.clear();
    _loadedModules.clear();
  }
}

/// Widget that loads content lazily when it becomes visible
class LazyLoadWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget placeholder;
  final String? moduleKey;
  final Future<dynamic> Function()? preloader;

  const LazyLoadWidget({
    Key? key,
    required this.builder,
    required this.placeholder,
    this.moduleKey,
    this.preloader,
  }) : super(key: key);

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isVisible = false;
  bool _isLoaded = false;
  Widget? _content;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted) return;

    final renderObject = context.findRenderObject() as RenderBox?;
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) {
      _loadContent();
      return;
    }

    final offset = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    final viewportHeight = MediaQuery.of(context).size.height;

    final isVisible = offset.dy + size.height >= -200 &&
                     offset.dy <= viewportHeight + 200;

    if (isVisible && !_isVisible) {
      setState(() => _isVisible = true);
      _loadContent();
    }
  }

  void _loadContent() async {
    if (_isLoaded) return;

    try {
      // Load module if specified
      if (widget.moduleKey != null && widget.preloader != null) {
        await DeferredLoader.loadModule(
          widget.moduleKey!,
          widget.preloader!,
          timeout: const Duration(seconds: 10),
        );
      }

      // Build content
      final content = widget.builder();
      
      if (mounted) {
        setState(() {
          _content = content;
          _isLoaded = true;
        });
      }
    } catch (error) {
      debugPrint('LazyLoadWidget error: $error');
      if (mounted) {
        setState(() => _isLoaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _content != null) {
      return _content!;
    }
    
    return widget.placeholder;
  }
}

/// Shimmer placeholder for loading states
class ShimmerPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerPlaceholder({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}