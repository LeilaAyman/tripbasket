import 'dart:developer' as developer;

/// Helper class for managing optimized image paths in TripBasket
/// Automatically maps original image paths to their optimized WebP versions
class ImageOptimizationHelper {
  static const String _optimizedFolder = 'assets/images/optimized/';
  static const String _originalFolder = 'assets/images/';
  
  /// Maps of known original images to their optimized versions
  static const Map<String, String> _optimizedMappings = {
    // Hero background images - manually placed
    'assets/images/200611101955-01-egypt-dahab.jpg': 'assets/images/optimized/200611101955-01-egypt-dahab.webp',
    'assets/images/200611101955-01-egypt-dahab.webp': 'assets/images/optimized/200611101955-01-egypt-dahab.webp',
    
    // Other trip images (add as you manually place them)
    'assets/images/Farsha_Cafe4.webp': 'assets/images/optimized/Farsha_Cafe4.webp',
    'assets/images/salte.jpg': 'assets/images/optimized/salte.webp',
    
    // Add more mappings as you manually place optimized images
  };
  
  /// Get the optimized version of an image path
  /// Falls back to original if optimized version doesn't exist
  static String getOptimizedPath(String originalPath) {
    // Check if we have a direct mapping
    if (_optimizedMappings.containsKey(originalPath)) {
      return _optimizedMappings[originalPath]!;
    }
    
    // Try to auto-generate optimized path
    if (originalPath.startsWith(_originalFolder)) {
      // Remove the original folder prefix
      String relativePath = originalPath.substring(_originalFolder.length);
      
      // Skip if already optimized
      if (relativePath.startsWith('optimized/')) {
        return originalPath;
      }
      
      // Skip favicons and small icons
      if (relativePath.toLowerCase().contains('favicon') ||
          relativePath.toLowerCase().contains('icon-') ||
          relativePath.toLowerCase().contains('launcher')) {
        return originalPath;
      }
      
      // Generate WebP version path
      String webpName = _changeExtensionToWebP(relativePath);
      String optimizedPath = _optimizedFolder + webpName;
      
      developer.log('Auto-mapped: $originalPath → $optimizedPath');
      return optimizedPath;
    }
    
    // Return original if no optimization available
    return originalPath;
  }
  
  /// Check if an optimized version exists for the given path
  static bool hasOptimizedVersion(String originalPath) {
    String optimizedPath = getOptimizedPath(originalPath);
    return optimizedPath != originalPath;
  }
  
  /// Get multiple optimized paths at once
  static List<String> getOptimizedPaths(List<String> originalPaths) {
    return originalPaths.map((path) => getOptimizedPath(path)).toList();
  }
  
  /// Helper to change file extension to .webp
  static String _changeExtensionToWebP(String filename) {
    String nameWithoutExtension = filename.split('.').first;
    return '$nameWithoutExtension.webp';
  }
  
  /// Get the original path from an optimized path (reverse mapping)
  static String getOriginalPath(String optimizedPath) {
    // Check reverse mappings
    for (var entry in _optimizedMappings.entries) {
      if (entry.value == optimizedPath) {
        return entry.key;
      }
    }
    
    // Try to reverse-engineer original path
    if (optimizedPath.startsWith(_optimizedFolder)) {
      String filename = optimizedPath.substring(_optimizedFolder.length);
      return _originalFolder + filename;
    }
    
    return optimizedPath;
  }
  
  /// Register a new mapping (useful for dynamic content)
  static void registerMapping(String originalPath, String optimizedPath) {
    // Note: This would need to be implemented with a mutable map
    // For now, this is a placeholder for the concept
    developer.log('Registered mapping: $originalPath → $optimizedPath');
  }
  
  /// Get all optimized image paths (for preloading)
  static List<String> getAllOptimizedPaths() {
    return _optimizedMappings.values.toList();
  }
  
  /// Debug helper to print all mappings
  static void debugPrintMappings() {
    developer.log('=== Image Optimization Mappings ===');
    for (var entry in _optimizedMappings.entries) {
      developer.log('${entry.key} → ${entry.value}');
    }
    developer.log('====================================');
  }
}

/// Extension on String to make image optimization easier
extension ImageOptimization on String {
  /// Get the optimized version of this image path
  String get optimized => ImageOptimizationHelper.getOptimizedPath(this);
  
  /// Check if this image has an optimized version
  bool get hasOptimized => ImageOptimizationHelper.hasOptimizedVersion(this);
}

/// Widget mixin for easy optimized image usage
mixin OptimizedImageMixin {
  /// Helper method to get optimized image path in widgets
  String optimizedImage(String originalPath) {
    return ImageOptimizationHelper.getOptimizedPath(originalPath);
  }
  
  /// Helper method to get multiple optimized image paths
  List<String> optimizedImages(List<String> originalPaths) {
    return ImageOptimizationHelper.getOptimizedPaths(originalPaths);
  }
}