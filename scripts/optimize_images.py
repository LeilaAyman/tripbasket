#!/usr/bin/env python3
"""
TripBasket Image Optimization Script
Converts PNG assets to WebP format for better web performance
Preserves platform-specific icons (Android/iOS) as PNG
"""

import os
import sys
import subprocess
from pathlib import Path
from PIL import Image
import shutil

def should_convert_to_webp(file_path):
    """
    Determine if a PNG file should be converted to WebP
    Keep platform icons as PNG for compatibility
    """
    path_str = str(file_path).lower()
    
    # Keep platform-specific icons as PNG
    skip_patterns = [
        'android/app/',      # Android app icons
        'ios/runner/',       # iOS app icons  
        'web/icons/',        # Web app icons
        'web/favicon.png',   # Web favicon
        'mipmap-',          # Android mipmaps
        'appiconset',       # iOS app icon sets
        'launchimage',      # iOS launch images
    ]
    
    for pattern in skip_patterns:
        if pattern in path_str:
            return False
    
    # Convert badge designs and other assets
    convert_patterns = [
        'badgedesign',
        'assets/images/',   # General assets (but not favicons)
    ]
    
    # Skip favicon files specifically
    if 'favicon.png' in path_str:
        return False
        
    for pattern in convert_patterns:
        if pattern in path_str:
            return True
    
    return False

def convert_png_to_webp(png_path, quality=85):
    """
    Convert PNG to WebP with specified quality
    Returns the WebP file path if successful, None otherwise
    """
    try:
        webp_path = png_path.with_suffix('.webp')
        
        # Open and convert
        with Image.open(png_path) as img:
            # Convert RGBA to RGB if necessary for better WebP compression
            if img.mode in ('RGBA', 'LA'):
                # Create white background
                background = Image.new('RGB', img.size, (255, 255, 255))
                # Paste image on white background using alpha channel as mask
                if img.mode == 'RGBA':
                    background.paste(img, mask=img.split()[-1])
                else:  # LA mode
                    background.paste(img, mask=img.split()[-1])
                img = background
            
            # Save as WebP
            img.save(webp_path, 'WebP', quality=quality, optimize=True)
            
        # Get file sizes
        original_size = png_path.stat().st_size
        webp_size = webp_path.stat().st_size
        savings = original_size - webp_size
        savings_percent = (savings / original_size) * 100
        
        print(f"✅ Converted: {png_path.name}")
        print(f"   Original: {original_size:,} bytes")
        print(f"   WebP:     {webp_size:,} bytes") 
        print(f"   Savings:  {savings:,} bytes ({savings_percent:.1f}%)")
        
        return webp_path
        
    except Exception as e:
        print(f"❌ Error converting {png_path}: {e}")
        return None

def optimize_images(project_root):
    """
    Find and optimize PNG images in the project
    """
    project_path = Path(project_root)
    
    print("🖼️  TripBasket Image Optimization")
    print("=" * 50)
    
    # Find all PNG files
    png_files = list(project_path.rglob("*.png"))
    
    # Filter files that should be converted
    convertible_files = [f for f in png_files if should_convert_to_webp(f)]
    
    print(f"📊 Found {len(png_files)} PNG files")
    print(f"🔄 Converting {len(convertible_files)} files to WebP")
    print(f"🔒 Preserving {len(png_files) - len(convertible_files)} platform icons as PNG")
    print("-" * 50)
    
    total_original = 0
    total_webp = 0
    successful_conversions = []
    
    for png_file in convertible_files:
        original_size = png_file.stat().st_size
        total_original += original_size
        
        webp_file = convert_png_to_webp(png_file)
        if webp_file:
            webp_size = webp_file.stat().st_size
            total_webp += webp_size
            successful_conversions.append((png_file, webp_file))
        print()
    
    # Summary
    total_savings = total_original - total_webp
    savings_percent = (total_savings / total_original * 100) if total_original > 0 else 0
    
    print("=" * 50)
    print("📈 OPTIMIZATION SUMMARY")
    print("=" * 50)
    print(f"✅ Successfully converted: {len(successful_conversions)} files")
    print(f"📦 Original total size:   {total_original:,} bytes ({total_original/1024/1024:.2f} MB)")
    print(f"🚀 Optimized total size:  {total_webp:,} bytes ({total_webp/1024/1024:.2f} MB)")
    print(f"💾 Total savings:        {total_savings:,} bytes ({total_savings/1024/1024:.2f} MB)")
    print(f"📊 Size reduction:       {savings_percent:.1f}%")
    
    return successful_conversions

def update_pubspec_references(project_root, converted_files):
    """
    Update pubspec.yaml to reference WebP files instead of PNG
    """
    pubspec_path = Path(project_root) / 'pubspec.yaml'
    
    if not pubspec_path.exists():
        print("⚠️  pubspec.yaml not found")
        return
    
    print("\n🔧 Updating pubspec.yaml references...")
    
    # Read current pubspec.yaml
    with open(pubspec_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Track changes
    changes_made = 0
    original_content = content
    
    # Update references to converted files
    for png_file, webp_file in converted_files:
        # Get relative paths from project root
        png_rel = png_file.relative_to(project_root)
        webp_rel = webp_file.relative_to(project_root)
        
        # Replace in pubspec.yaml
        png_ref = str(png_rel).replace('\\', '/')
        webp_ref = str(webp_rel).replace('\\', '/')
        
        if png_ref in content:
            content = content.replace(png_ref, webp_ref)
            changes_made += 1
            print(f"   📝 Updated: {png_ref} → {webp_ref}")
    
    # Write updated pubspec.yaml
    if changes_made > 0:
        with open(pubspec_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✅ Updated {changes_made} references in pubspec.yaml")
    else:
        print("ℹ️  No references found in pubspec.yaml to update")

def main():
    """Main optimization process"""
    
    # Check if PIL is available
    try:
        from PIL import Image
    except ImportError:
        print("❌ PIL (Pillow) not found. Install with: pip install Pillow")
        sys.exit(1)
    
    # Get project root (script location parent directory)
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    print(f"📁 Project root: {project_root}")
    
    # Optimize images
    converted_files = optimize_images(project_root)
    
    # Update pubspec.yaml references
    if converted_files:
        update_pubspec_references(project_root, converted_files)
    
    print("\n🎉 Image optimization completed!")
    print(f"💡 Next steps:")
    print(f"   1. Run 'flutter clean && flutter pub get'")
    print(f"   2. Test your app to ensure WebP images load correctly")
    print(f"   3. Run './build_optimized.bat' for optimized build")

if __name__ == "__main__":
    main()