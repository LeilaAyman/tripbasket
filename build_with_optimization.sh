#!/bin/bash

echo "========================================"
echo "TripBasket Build with Image Optimization"
echo "========================================"

echo ""
echo "[1/5] Running image optimization..."
python3 scripts/auto_optimize_images.py
if [ $? -ne 0 ]; then
    echo "ERROR: Image optimization failed"
    exit 1
fi

echo ""
echo "[2/5] Cleaning Flutter project..."
flutter clean
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter clean failed"
    exit 1
fi

echo ""
echo "[3/5] Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter pub get failed"
    exit 1
fi

echo ""
echo "[4/5] Analyzing code..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "WARNING: Flutter analyze found issues (continuing build)"
fi

echo ""
echo "[5/5] Building for web with HTML renderer..."
flutter build web --target lib/main.dart --release --dart-define=FLUTTER_WEB_USE_SKIA=false
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter build failed"
    exit 1
fi

echo ""
echo "========================================"
echo "Build completed successfully!"
echo "========================================"
echo ""
echo "Built files are in: build/web/"
echo ""
echo "Next steps:"
echo "1. Deploy functions: firebase deploy --only functions"
echo "2. Deploy web app: firebase deploy --only hosting"
echo "========================================"