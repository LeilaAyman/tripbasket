#!/usr/bin/env python3
"""
Advanced Web Image Optimization for TripBasket
- Creates multiple sizes for responsive loading
- Aggressive WebP compression
- Generates .webp.gz for even smaller sizes
- Creates image manifests for optimal loading
"""

import os
import sys
import gzip
import json
from pathlib import Path
from PIL import Image
import shutil

class WebImageOptimizer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.assets_path = self.project_root / 'assets' / 'images'
        self.optimized_path = self.assets_path / 'optimized'
        self.manifest_path = self.optimized_path / 'image_manifest.json'
        
        # Create optimized directory
        self.optimized_path.mkdir(exist_ok=True, parents=True)
        
        # Size configurations for different use cases
        self.size_configs = {
            'hero': {
                'sizes': [(480, 320), (768, 512), (1200, 800), (1920, 1280)],
                'quality': 35,  # Lower quality for backgrounds
                'suffix': ['_sm', '_md', '_lg', '_xl']
            },
            'card': {
                'sizes': [(150, 100), (300, 200), (600, 400)],
                'quality': 55,  # Medium quality for cards
                'suffix': ['_sm', '_md', '_lg']
            },
            'gallery': {
                'sizes': [(300, 200), (600, 400), (1200, 800)],
                'quality': 65,  # Higher quality for gallery
                'suffix': ['_sm', '_md', '_lg']
            }
        }
        
        self.manifest = {}

    def detect_image_type(self, filename):
        """Detect image type based on filename patterns"""
        filename_lower = filename.lower()
        
        if any(word in filename_lower for word in ['hero', 'banner', 'background']):
            return 'hero'
        elif any(word in filename_lower for word in ['card', 'thumb', 'preview']):
            return 'card'
        else:
            return 'gallery'

    def optimize_image_sizes(self, input_path, output_base, config_type):
        """Create multiple optimized sizes of an image"""
        try:
            with Image.open(input_path) as img:
                # Convert RGBA to RGB if needed
                if img.mode in ('RGBA', 'LA'):
                    background = Image.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'RGBA':
                        background.paste(img, mask=img.split()[-1])
                    else:
                        background.paste(img, mask=img.split()[-1])
                    img = background
                elif img.mode == 'P':
                    img = img.convert('RGB')
                
                config = self.size_configs[config_type]
                original_size = os.path.getsize(input_path)
                results = []
                
                for i, (width, height) in enumerate(config['sizes']):
                    # Skip if image is smaller than target size
                    if img.width <= width and img.height <= height:
                        continue
                    
                    # Resize maintaining aspect ratio
                    img_resized = img.copy()
                    img_resized.thumbnail((width, height), Image.Resampling.LANCZOS)
                    
                    # Generate filename with size suffix
                    suffix = config['suffix'][i]
                    output_path = Path(str(output_base) + suffix + '.webp')
                    
                    # Save WebP
                    img_resized.save(
                        output_path,
                        'WEBP',
                        quality=config['quality'],
                        method=6,  # Maximum compression
                        optimize=True
                    )
                    
                    # Create gzipped version for ultra-small files
                    self.create_gzipped_version(output_path)
                    
                    # Record results
                    optimized_size = output_path.stat().st_size
                    results.append({
                        'size': f"{width}x{height}",
                        'path': str(output_path.relative_to(self.assets_path)),
                        'file_size': optimized_size,
                        'compression_ratio': round((1 - optimized_size/original_size) * 100, 1)
                    })
                
                return results
                
        except Exception as e:
            print(f"Error optimizing {input_path}: {e}")
            return []

    def create_gzipped_version(self, webp_path):
        """Create gzipped version of WebP for ultra compression"""
        try:
            gz_path = webp_path.with_suffix('.webp.gz')
            with open(webp_path, 'rb') as f_in:
                with gzip.open(gz_path, 'wb', compresslevel=9) as f_out:
                    shutil.copyfileobj(f_in, f_out)
        except Exception as e:
            print(f"Error creating gzipped version: {e}")

    def process_all_images(self):
        """Process all images in the assets directory"""
        image_extensions = ['.jpg', '.jpeg', '.png', '.webp']
        processed_count = 0
        total_original_size = 0
        total_optimized_size = 0
        
        print("Advanced Web Image Optimization Starting...")
        print("=" * 60)
        
        for image_file in self.assets_path.glob('*'):
            if image_file.suffix.lower() not in image_extensions:
                continue
            if image_file.parent == self.optimized_path:
                continue
            if any(skip in image_file.name.lower() for skip in ['favicon', 'icon-', 'logo']):
                continue
            
            print(f"\nProcessing: {image_file.name}")
            
            # Detect image type and get config
            image_type = self.detect_image_type(image_file.name)
            print(f"   Type: {image_type}")
            
            # Create output base name
            output_base = self.optimized_path / image_file.stem
            
            # Get original size
            original_size = image_file.stat().st_size
            total_original_size += original_size
            print(f"   Original: {original_size:,} bytes")
            
            # Optimize to multiple sizes
            results = self.optimize_image_sizes(image_file, output_base, image_type)
            
            if results:
                # Add to manifest
                self.manifest[str(image_file.relative_to(self.assets_path))] = {
                    'type': image_type,
                    'original_size': original_size,
                    'variants': results
                }
                
                # Calculate total optimized size
                variant_sizes = sum(r['file_size'] for r in results)
                total_optimized_size += variant_sizes
                
                print(f"   Created {len(results)} variants:")
                for result in results:
                    print(f"     {result['size']}: {result['file_size']:,} bytes ({result['compression_ratio']}% smaller)")
                
                processed_count += 1
        
        # Save manifest
        with open(self.manifest_path, 'w') as f:
            json.dump(self.manifest, f, indent=2)
        
        # Print summary
        print("\n" + "=" * 60)
        print("OPTIMIZATION COMPLETE")
        print("=" * 60)
        print(f"Images processed: {processed_count}")
        print(f"Original total: {total_original_size:,} bytes ({total_original_size/1024/1024:.2f} MB)")
        print(f"Optimized total: {total_optimized_size:,} bytes ({total_optimized_size/1024/1024:.2f} MB)")
        if total_original_size > 0:
            savings = total_original_size - total_optimized_size
            savings_percent = (savings / total_original_size) * 100
            print(f"Total savings: {savings:,} bytes ({savings_percent:.1f}%)")
        print(f"Manifest saved: {self.manifest_path}")

def main():
    try:
        from PIL import Image
    except ImportError:
        print("ERROR: PIL (Pillow) not found. Install with: pip install Pillow")
        return
    
    project_root = Path(__file__).parent.parent
    optimizer = WebImageOptimizer(project_root)
    optimizer.process_all_images()
    
    print("\nNext steps:")
    print("1. Update your Flutter code to use OptimizedImage component")
    print("2. Test responsive image loading")
    print("3. Run build: flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=false")

if __name__ == "__main__":
    main()