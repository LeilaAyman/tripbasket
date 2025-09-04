@echo off
echo ========================================
echo TripBasket Build with Image Optimization
echo ========================================

echo.
echo [1/5] Running image optimization...
python scripts\auto_optimize_images.py
if %errorlevel% neq 0 (
    echo ERROR: Image optimization failed
    exit /b 1
)

echo.
echo [2/5] Cleaning Flutter project...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    exit /b 1
)

echo.
echo [3/5] Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    exit /b 1
)

echo.
echo [4/5] Analyzing code...
flutter analyze
if %errorlevel% neq 0 (
    echo WARNING: Flutter analyze found issues (continuing build)
)

echo.
echo [5/5] Building for web with HTML renderer...
flutter build web --target lib/main.dart --release --dart-define=FLUTTER_WEB_USE_SKIA=false
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed
    exit /b 1
)

echo.
echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo Built files are in: build\web\
echo.
echo Next steps:
echo 1. Deploy functions: firebase deploy --only functions
echo 2. Deploy web app: firebase deploy --only hosting
echo ========================================

pause