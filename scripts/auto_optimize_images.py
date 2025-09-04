#!/usr/bin/env python3
"""
TripBasket Automatic Image Optimization System
- Converts JPG/PNG → WebP at 70-80% quality
- Resizes images larger than 1920px width to max 1920px
- Keeps small icons (favicons) untouched
- Saves optimized versions in /assets/images/optimized/
- Updates references in pubspec.yaml and code
"""

import os
import sys
import shutil
import re
from pathlib import Path
from PIL import Image, ImageOps
import json

class TripBasketImageOptimizer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.assets_path = self.project_root / 'assets' / 'images'
        self.optimized_path = self.assets_path / 'optimized'
        self.pubspec_path = self.project_root / 'pubspec.yaml'
        
        # Optimization settings
        self.webp_quality = 75  # 70-80% quality for regular images
        self.hero_webp_quality = 50  # 50-60% quality for hero/banner images
        self.max_width = 1920
        self.max_height = 1080
        
        # Files to skip optimization
        self.skip_patterns = [
            'favicon',
            'icon-',
            'launcher',
            'logo_small',
            'badge_small',
        ]
        
        # Keep these as original format
        self.keep_original_patterns = [
            'android/',
            'ios/',
            'web/icons/',
            'web/favicon',
        ]
        
        self.optimization_log = []

    def should_optimize(self, file_path):
        """Determine if an image should be optimized"""
        path_str = str(file_path).lower()
        name = file_path.name.lower()
        
        # Skip platform-specific icons
        for pattern in self.keep_original_patterns:
            if pattern in path_str:
                return False
        
        # Skip small icons and favicons
        for pattern in self.skip_patterns:
            if pattern in name:
                return False
        
        # Only optimize images in assets/images (not subdirectories like optimized/)
        if 'optimized' in path_str:
            return False
            
        # Check file size - skip very small files (likely icons)
        try:
            size_kb = file_path.stat().st_size / 1024
            if size_kb < 10:  # Skip files smaller than 10KB
                return False
        except:
            return False
        
        return True

    def optimize_image(self, input_path, output_path, target_format='webp'):
        """Optimize a single image"""
        try:
            with Image.open(input_path) as img:
                # Convert RGBA to RGB for WebP if needed
                if img.mode in ('RGBA', 'LA') and target_format.lower() == 'webp':
                    # Create white background for transparency
                    background = Image.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'RGBA':
                        background.paste(img, mask=img.split()[-1])
                    else:
                        background.paste(img, mask=img.split()[-1])
                    img = background
                elif img.mode == 'P':
                    img = img.convert('RGB')
                
                # Get original dimensions
                original_width, original_height = img.size
                
                # Resize if larger than max dimensions
                if original_width > self.max_width or original_height > self.max_height:
                    # Calculate new dimensions maintaining aspect ratio
                    ratio = min(self.max_width / original_width, self.max_height / original_height)
                    new_width = int(original_width * ratio)
                    new_height = int(original_height * ratio)
                    
                    img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
                    print(f"   Resized: {original_width}x{original_height} → {new_width}x{new_height}")
                
                # Save optimized image
                save_kwargs = {'optimize': True}
                if target_format.lower() == 'webp':
                    save_kwargs['quality'] = self.webp_quality
                    save_kwargs['method'] = 6  # Best compression
                elif target_format.lower() in ['jpg', 'jpeg']:
                    save_kwargs['quality'] = self.webp_quality
                    save_kwargs['progressive'] = True
                
                img.save(output_path, target_format.upper(), **save_kwargs)
                
                # Calculate savings
                original_size = input_path.stat().st_size
                optimized_size = output_path.stat().st_size
                savings = original_size - optimized_size
                savings_percent = (savings / original_size) * 100 if original_size > 0 else 0
                
                return {
                    'success': True,
                    'original_size': original_size,
                    'optimized_size': optimized_size,
                    'savings': savings,
                    'savings_percent': savings_percent,
                    'resized': img.size != (original_width, original_height)
                }
                
        except Exception as e:
            return {'success': False, 'error': str(e)}

    def create_optimized_directory(self):
        """Create optimized directory structure"""
        self.optimized_path.mkdir(parents=True, exist_ok=True)
        print(f"Created optimized directory: {self.optimized_path}")

    def optimize_all_images(self):
        """Optimize all eligible images in the assets directory"""
        print("TripBasket Automatic Image Optimization")
        print("=" * 60)
        
        # Create optimized directory
        self.create_optimized_directory()
        
        # Find all image files
        image_extensions = ['.jpg', '.jpeg', '.png']
        image_files = []
        
        for ext in image_extensions:
            image_files.extend(self.assets_path.rglob(f"*{ext}"))
            image_files.extend(self.assets_path.rglob(f"*{ext.upper()}"))
        
        # Filter files that should be optimized
        optimizable_files = [f for f in image_files if self.should_optimize(f)]
        
        print(f"Found {len(image_files)} image files")
        print(f"Optimizing {len(optimizable_files)} files")
        print(f"Preserving {len(image_files) - len(optimizable_files)} icons/platform assets")
        print("-" * 60)
        
        total_original = 0
        total_optimized = 0
        successful_optimizations = 0
        
        for image_file in optimizable_files:
            # Create relative path for organized structure
            rel_path = image_file.relative_to(self.assets_path)
            
            # Determine output format and filename
            if rel_path.suffix.lower() in ['.jpg', '.jpeg', '.png']:
                output_name = rel_path.stem + '.webp'
            else:
                output_name = rel_path.name
            
            output_path = self.optimized_path / output_name
            
            print(f"Processing: {rel_path.name}")
            
            # Optimize the image
            result = self.optimize_image(image_file, output_path, 'webp')
            
            if result['success']:
                total_original += result['original_size']
                total_optimized += result['optimized_size']
                successful_optimizations += 1
                
                # Log the optimization
                log_entry = {
                    'original_path': str(rel_path),
                    'optimized_path': f"optimized/{output_name}",
                    'original_size': result['original_size'],
                    'optimized_size': result['optimized_size'],
                    'savings_percent': result['savings_percent'],
                    'resized': result.get('resized', False)
                }
                self.optimization_log.append(log_entry)
                
                print(f"   Original: {result['original_size']:,} bytes")
                print(f"   Optimized: {result['optimized_size']:,} bytes")
                print(f"   Savings: {result['savings']:,} bytes ({result['savings_percent']:.1f}%)")
                if result.get('resized'):
                    print(f"   Image resized to fit max dimensions")
                print()
                
            else:
                print(f"   Failed: {result['error']}")
                print()
        
        # Print summary
        total_savings = total_original - total_optimized
        savings_percent = (total_savings / total_original * 100) if total_original > 0 else 0
        
        print("=" * 60)
        print("OPTIMIZATION SUMMARY")
        print("=" * 60)
        print(f"Successfully optimized: {successful_optimizations} files")
        print(f"Original total size:   {total_original:,} bytes ({total_original/1024/1024:.2f} MB)")
        print(f"Optimized total size:  {total_optimized:,} bytes ({total_optimized/1024/1024:.2f} MB)")
        print(f"Total savings:        {total_savings:,} bytes ({total_savings/1024/1024:.2f} MB)")
        print(f"Size reduction:       {savings_percent:.1f}%")
        
        return self.optimization_log

    def update_pubspec_yaml(self, optimization_log):
        """Update pubspec.yaml to include optimized images"""
        if not self.pubspec_path.exists():
            print("Warning: pubspec.yaml not found")
            return
        
        print("\nUpdating pubspec.yaml...")
        
        with open(self.pubspec_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Add optimized folder to assets if not already present
        if 'assets/images/optimized/' not in content:
            # Find the assets section and add optimized folder
            assets_pattern = r'(\s+assets:\s*\n(?:\s+-\s+[^\n]+\n)*)'
            
            def add_optimized_folder(match):
                assets_section = match.group(1)
                if 'assets/images/optimized/' not in assets_section:
                    assets_section += '    - assets/images/optimized/\n'
                return assets_section
            
            content = re.sub(assets_pattern, add_optimized_folder, content)
        
        # Write updated pubspec.yaml
        with open(self.pubspec_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print("Added optimized folder to pubspec.yaml")

    def generate_optimization_report(self, optimization_log):
        """Generate a JSON report of optimizations"""
        report_path = self.project_root / 'image_optimization_report.json'
        
        report = {
            'timestamp': str(Path().resolve()),
            'total_files_optimized': len(optimization_log),
            'total_savings_bytes': sum(log['original_size'] - log['optimized_size'] for log in optimization_log),
            'average_savings_percent': sum(log['savings_percent'] for log in optimization_log) / len(optimization_log) if optimization_log else 0,
            'optimizations': optimization_log
        }
        
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"Optimization report saved: {report_path}")

def main():
    """Main optimization process"""
    
    # Check dependencies
    try:
        from PIL import Image
    except ImportError:
        print("ERROR: PIL (Pillow) not found. Install with: pip install Pillow")
        sys.exit(1)
    
    # Get project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    print(f"Project root: {project_root}")
    
    # Initialize optimizer
    optimizer = TripBasketImageOptimizer(project_root)
    
    # Run optimization
    optimization_log = optimizer.optimize_all_images()
    
    # Update pubspec.yaml
    if optimization_log:
        optimizer.update_pubspec_yaml(optimization_log)
        optimizer.generate_optimization_report(optimization_log)
    
    print("\nAutomatic image optimization completed!")
    print("Next steps:")
    print("   1. Run 'flutter clean && flutter pub get'")
    print("   2. Update your code to use optimized images")
    print("   3. Test that optimized images display correctly")
    print("   4. Run automated build with './build_with_optimization.bat'")

if __name__ == "__main__":
    main()