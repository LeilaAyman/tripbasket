#!/usr/bin/env python3
"""
Generate dynamic sitemap.xml for TripBasket
- Fetches trips from Firebase
- Creates SEO-optimized URLs
- Includes priority and change frequency
"""

import json
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path

def generate_sitemap():
    # Create sitemap root
    urlset = ET.Element('urlset', xmlns="http://www.sitemaps.org/schemas/sitemap/0.9")
    
    base_url = "https://tripbasket-sctkxj.web.app"
    
    # Static pages with priorities
    static_pages = [
        {'path': '/', 'priority': '1.0', 'changefreq': 'daily'},
        {'path': '/home', 'priority': '1.0', 'changefreq': 'daily'},
        {'path': '/search', 'priority': '0.9', 'changefreq': 'weekly'},
        {'path': '/agencies', 'priority': '0.8', 'changefreq': 'weekly'},
        {'path': '/reviews', 'priority': '0.7', 'changefreq': 'weekly'},
        {'path': '/about', 'priority': '0.6', 'changefreq': 'monthly'},
        {'path': '/contact', 'priority': '0.6', 'changefreq': 'monthly'},
        {'path': '/privacy', 'priority': '0.5', 'changefreq': 'yearly'},
        {'path': '/terms', 'priority': '0.5', 'changefreq': 'yearly'},
    ]
    
    # Add static pages
    for page in static_pages:
        url = ET.SubElement(urlset, 'url')
        ET.SubElement(url, 'loc').text = f"{base_url}{page['path']}"
        ET.SubElement(url, 'lastmod').text = datetime.now(timezone.utc).strftime('%Y-%m-%d')
        ET.SubElement(url, 'changefreq').text = page['changefreq']
        ET.SubElement(url, 'priority').text = page['priority']
    
    # Note: In a real implementation, you would fetch trips from Firebase
    # For now, we'll add some example trip URLs
    example_trips = [
        {'id': 'egypt-dahab-adventure', 'title': 'Egypt Dahab Adventure', 'lastmod': '2024-01-15'},
        {'id': 'cairo-cultural-tour', 'title': 'Cairo Cultural Tour', 'lastmod': '2024-01-10'},
        {'id': 'red-sea-diving', 'title': 'Red Sea Diving Experience', 'lastmod': '2024-01-12'},
    ]
    
    # Add trip pages
    for trip in example_trips:
        url = ET.SubElement(urlset, 'url')
        ET.SubElement(url, 'loc').text = f"{base_url}/trips/{trip['id']}"
        ET.SubElement(url, 'lastmod').text = trip['lastmod']
        ET.SubElement(url, 'changefreq').text = 'weekly'
        ET.SubElement(url, 'priority').text = '0.8'
    
    # Add agency pages
    example_agencies = [
        {'id': 'desert-adventures', 'name': 'Desert Adventures', 'lastmod': '2024-01-08'},
        {'id': 'nile-explorers', 'name': 'Nile Explorers', 'lastmod': '2024-01-05'},
    ]
    
    for agency in example_agencies:
        url = ET.SubElement(urlset, 'url')
        ET.SubElement(url, 'loc').text = f"{base_url}/agencies/{agency['id']}"
        ET.SubElement(url, 'lastmod').text = agency['lastmod']
        ET.SubElement(url, 'changefreq').text = 'monthly'
        ET.SubElement(url, 'priority').text = '0.7'
    
    # Pretty print XML
    ET.indent(urlset, space="  ", level=0)
    tree = ET.ElementTree(urlset)
    
    # Save sitemap
    sitemap_path = Path(__file__).parent.parent / 'build' / 'web' / 'sitemap.xml'
    sitemap_path.parent.mkdir(parents=True, exist_ok=True)
    
    tree.write(sitemap_path, encoding='utf-8', xml_declaration=True)
    
    print(f"Sitemap generated: {sitemap_path}")
    print(f"Total URLs: {len(urlset)}")
    
    # Generate sitemap index if needed
    generate_sitemap_index(base_url)

def generate_sitemap_index(base_url):
    """Generate sitemap index for multiple sitemaps"""
    sitemapindex = ET.Element('sitemapindex', xmlns="http://www.sitemaps.org/schemas/sitemap/0.9")
    
    # Main sitemap
    sitemap = ET.SubElement(sitemapindex, 'sitemap')
    ET.SubElement(sitemap, 'loc').text = f"{base_url}/sitemap.xml"
    ET.SubElement(sitemap, 'lastmod').text = datetime.now(timezone.utc).strftime('%Y-%m-%d')
    
    # Save sitemap index
    index_path = Path(__file__).parent.parent / 'build' / 'web' / 'sitemap-index.xml'
    ET.indent(sitemapindex, space="  ", level=0)
    tree = ET.ElementTree(sitemapindex)
    tree.write(index_path, encoding='utf-8', xml_declaration=True)
    
    print(f"Sitemap index generated: {index_path}")

if __name__ == "__main__":
    generate_sitemap()