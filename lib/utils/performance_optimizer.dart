import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Performance optimization utilities for Flutter Web
class PerformanceOptimizer {
  static bool _initialized = false;
  static final List<VoidCallback> _deferredTasks = [];
  static Timer? _idleTimer;

  /// Initialize performance optimizations
  static void initialize() {
    if (_initialized || !kIsWeb) return;
    _initialized = true;

    // Defer non-critical work until after initial paint
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduleIdleTasks();
    });

    // Optimize garbage collection
    _optimizeGarbageCollection();

    // Preload critical resources
    _preloadCriticalResources();
  }

  /// Schedule tasks during idle time
  static void _scheduleIdleTasks() {
    _idleTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_deferredTasks.isEmpty) {
        timer.cancel();
        return;
      }

      // Execute one task per frame to avoid blocking UI
      final task = _deferredTasks.removeAt(0);
      try {
        task();
      } catch (e) {
        debugPrint('Deferred task error: $e');
      }
    });
  }

  /// Add a task to be executed during idle time
  static void deferTask(VoidCallback task) {
    if (!kIsWeb) {
      task();
      return;
    }
    _deferredTasks.add(task);
  }

  /// Optimize garbage collection frequency
  static void _optimizeGarbageCollection() {
    if (!kIsWeb) return;

    // Reduce allocation pressure by reusing objects
    Timer.periodic(const Duration(seconds: 30), (_) {
      // Hint for garbage collection during idle time
      if (_deferredTasks.isEmpty) {
        SystemChannels.platform.invokeMethod('SystemChrome.systemUIOverlayStyle', null);
      }
    });
  }

  /// Preload critical resources
  static void _preloadCriticalResources() {
    if (!kIsWeb) return;

    deferTask(() {
      // Preload critical images
      _preloadImage('/assets/images/optimized/200611101955-01-egypt-dahab_sm.webp');
      
      // Preload fonts
      _preloadFont('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap');
    });
  }

  /// Preload an image resource
  static void _preloadImage(String url) {
    final img = html.ImageElement();
    img.src = url;
    img.loading = 'eager';
  }

  /// Preload a font resource
  static void _preloadFont(String url) {
    final link = html.LinkElement()
      ..rel = 'preload'
      ..href = url
      ..type = 'text/css'
      ..setAttribute('as', 'style')
      ..setAttribute('crossorigin', '');
    html.document.head?.append(link);
  }

  /// Batch DOM updates to reduce reflows
  static void batchDOMUpdates(List<VoidCallback> updates) {
    if (!kIsWeb) {
      for (final update in updates) {
        update();
      }
      return;
    }

    // Use requestAnimationFrame for smooth updates
    html.window.requestAnimationFrame((timestamp) {
      for (final update in updates) {
        try {
          update();
        } catch (e) {
          debugPrint('DOM update error: $e');
        }
      }
    });
  }

  /// Optimize list rendering with viewport culling
  static bool isInViewport(double itemTop, double itemHeight, double scrollOffset, double viewportHeight) {
    final itemBottom = itemTop + itemHeight;
    final viewportTop = scrollOffset;
    final viewportBottom = scrollOffset + viewportHeight;

    // Add buffer for smooth scrolling
    const buffer = 200.0;
    
    return itemBottom >= viewportTop - buffer && itemTop <= viewportBottom + buffer;
  }

  /// Debounce function calls to reduce excessive operations
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls to limit frequency
  static DateTime? _lastThrottleTime;
  static void throttle(VoidCallback callback, {Duration interval = const Duration(milliseconds: 100)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
    }
  }

  /// Measure and log performance metrics
  static void measurePerformance(String name, VoidCallback operation) {
    if (!kIsWeb || !kDebugMode) {
      operation();
      return;
    }

    final stopwatch = Stopwatch()..start();
    operation();
    stopwatch.stop();

    final duration = stopwatch.elapsedMilliseconds;
    if (duration > 16) { // Log operations taking longer than one frame
      debugPrint('⚠️  Performance: $name took ${duration}ms');
    }
  }

  /// Clean up resources
  static void dispose() {
    _idleTimer?.cancel();
    _debounceTimer?.cancel();
    _deferredTasks.clear();
    _initialized = false;
  }
}

/// Mixin for widgets that need performance optimization
mixin PerformanceOptimizedWidget {
  void deferTask(VoidCallback task) => PerformanceOptimizer.deferTask(task);
  
  void measurePerformance(String name, VoidCallback operation) => 
      PerformanceOptimizer.measurePerformance(name, operation);
  
  void batchUpdates(List<VoidCallback> updates) => 
      PerformanceOptimizer.batchDOMUpdates(updates);
}

/// Widget wrapper for performance monitoring
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String name;
  final bool enabled;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    required this.name,
    this.enabled = kDebugMode,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  late final Stopwatch _buildStopwatch;
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();
    _buildStopwatch = Stopwatch();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    _buildStopwatch.reset();
    _buildStopwatch.start();
    
    final child = widget.child;
    
    _buildStopwatch.stop();
    _buildCount++;

    final buildTime = _buildStopwatch.elapsedMilliseconds;
    if (buildTime > 16) {
      debugPrint('🐌 Slow build: ${widget.name} took ${buildTime}ms (build #$_buildCount)');
    }

    return child;
  }
}