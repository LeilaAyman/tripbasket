#!/usr/bin/env python3
"""
Convert Egypt Dahab image to WebP format
"""

from PIL import Image
import os

def convert_dahab_image():
    input_path = "assets/images/200611101955-01-egypt-dahab.jpg"
    output_path = "assets/images/200611101955-01-egypt-dahab.webp"
    
    if not os.path.exists(input_path):
        print(f"❌ Input file not found: {input_path}")
        return
    
    try:
        # Open and convert
        with Image.open(input_path) as img:
            # Save as WebP with high quality for hero images
            img.save(output_path, 'WebP', quality=90, optimize=True)
        
        # Get file sizes
        original_size = os.path.getsize(input_path)
        webp_size = os.path.getsize(output_path)
        savings = original_size - webp_size
        savings_percent = (savings / original_size) * 100
        
        print("🖼️  Egypt Dahab Image Conversion")
        print("=" * 40)
        print(f"✅ Converted: 200611101955-01-egypt-dahab.jpg → .webp")
        print(f"📊 Original: {original_size:,} bytes ({original_size/1024:.1f} KB)")
        print(f"🚀 WebP:     {webp_size:,} bytes ({webp_size/1024:.1f} KB)") 
        print(f"💾 Savings:  {savings:,} bytes ({savings_percent:.1f}% reduction)")
        print()
        print("🔧 Next steps:")
        print("1. Update hero_background.dart to use .webp file")
        print("2. Test the image displays correctly")
        print("3. Remove original .jpg file if everything works")
        
    except Exception as e:
        print(f"❌ Error converting image: {e}")

if __name__ == "__main__":
    convert_dahab_image()