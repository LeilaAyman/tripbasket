import 'dart:io';
import 'dart:typed_data';

// This script helps identify large images for optimization
void main() async {
  final assetsDir = Directory('assets/images');
  
  if (await assetsDir.exists()) {
    await for (final entity in assetsDir.list()) {
      if (entity is File && entity.path.endsWith('.png')) {
        final stats = await entity.stat();
        final sizeInMB = stats.size / (1024 * 1024);
        
        print('${entity.path}: ${sizeInMB.toStringAsFixed(2)} MB');
        
        if (sizeInMB > 0.5) {
          print('  → Large image detected! Consider converting to WebP or SVG');
        }
      }
    }
  }
}