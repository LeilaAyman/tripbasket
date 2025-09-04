#!/usr/bin/env python3
"""
Compress hero/banner images for optimal web performance
- Target: ≤150KB per image
- Quality: 50-60% for backgrounds
- Format: WebP with maximum compression
"""

import os
import sys
from pathlib import Path
from PIL import Image
import shutil

def compress_hero_image(input_path, output_path, max_size_kb=150, quality=55):
    """Compress image to target file size with WebP"""
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
            
            # Start with target quality
            current_quality = quality
            
            # Try different qualities until we hit target size
            for attempt_quality in range(quality, 30, -5):  # Try 55, 50, 45, 40, 35
                # Save to temporary buffer to check size
                temp_path = output_path.with_suffix('.temp.webp')
                
                img.save(temp_path, 'WEBP', 
                        quality=attempt_quality, 
                        method=6,  # Maximum compression
                        optimize=True)
                
                file_size_kb = temp_path.stat().st_size / 1024
                
                print(f"   Quality {attempt_quality}%: {file_size_kb:.1f} KB")
                
                if file_size_kb <= max_size_kb:
                    # Found acceptable size, use this version
                    shutil.move(str(temp_path), str(output_path))
                    return {
                        'success': True,
                        'final_size_kb': file_size_kb,
                        'final_quality': attempt_quality,
                        'achieved_target': True
                    }
                else:
                    # Too big, clean up and try lower quality
                    temp_path.unlink()
            
            # If we couldn't reach target, use the lowest quality we tried
            final_quality = 35
            img.save(output_path, 'WEBP', 
                    quality=final_quality, 
                    method=6,
                    optimize=True)
            
            final_size_kb = output_path.stat().st_size / 1024
            
            return {
                'success': True,
                'final_size_kb': final_size_kb,
                'final_quality': final_quality,
                'achieved_target': final_size_kb <= max_size_kb
            }
            
    except Exception as e:
        return {'success': False, 'error': str(e)}

def main():
    print("Hero Image Compression for Web Performance")
    print("Target: <=150KB per image with WebP")
    print("=" * 50)
    
    project_root = Path(__file__).parent.parent
    assets_path = project_root / 'assets' / 'images'
    optimized_path = assets_path / 'optimized'
    
    # Hero images to compress
    hero_images = [
        '200611101955-01-egypt-dahab.webp'
    ]
    
    for image_name in hero_images:
        input_path = optimized_path / image_name
        
        if not input_path.exists():
            print(f"❌ {image_name} not found, checking main assets folder...")
            input_path = assets_path / image_name
            
            if not input_path.exists():
                print(f"❌ {image_name} not found in assets")
                continue
        
        # Get original size
        original_size_kb = input_path.stat().st_size / 1024
        print(f"\nCompressing {image_name}")
        print(f"   Original: {original_size_kb:.1f} KB")
        
        if original_size_kb <= 150:
            print(f"   Already under 150KB, skipping")
            continue
        
        # Compress the image
        output_path = optimized_path / image_name
        result = compress_hero_image(input_path, output_path, max_size_kb=150)
        
        if result['success']:
            print(f"   Compressed to {result['final_size_kb']:.1f} KB at {result['final_quality']}% quality")
            if result['achieved_target']:
                print(f"   Target achieved!")
            else:
                print(f"   Close to target (couldn't get under 150KB)")
            
            savings = original_size_kb - result['final_size_kb']
            savings_percent = (savings / original_size_kb) * 100
            print(f"   Savings: {savings:.1f} KB ({savings_percent:.1f}%)")
        else:
            print(f"   Failed: {result['error']}")
    
    print("\n" + "=" * 50)
    print("Hero image compression completed!")
    print("Run 'flutter clean && flutter pub get' to refresh assets")

if __name__ == "__main__":
    main()