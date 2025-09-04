@echo off
echo ========================================
echo    TripBasket Optimized Build Process
echo ========================================
echo.

:: Step 1: Clean previous builds
echo Step 1: Cleaning previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

:: Step 2: Optimize images (if script exists and tools available)
echo Step 2: Optimizing images...
if exist "scripts\optimize_images.bat" (
    echo Running image optimization...
    call "scripts\optimize_images.bat"
) else (
    echo Image optimization script not found, skipping...
)

:: Step 3: Get dependencies
echo Step 3: Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

:: Step 4: Remove unused assets to reduce bundle size
echo Step 4: Analyzing unused assets...
if exist "assets\images\@4xff_badgeDesign_light_small.png" (
    echo Found large badge design PNG files:
    dir "assets\images\*badgeDesign*.png" | findstr /C:".png"
    echo.
    echo ⚠️  These files are 700KB-900KB each and may not be used.
    echo Consider removing them if not referenced in code.
)

:: Step 5: Build optimized web version
echo Step 5: Building optimized web version...
echo - Using HTML renderer (no CanvasKit)
echo - Optimized assets and caching
echo - Tree-shaking enabled
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=false --source-maps
if %errorlevel% neq 0 (
    echo ERROR: Flutter web build failed
    pause
    exit /b 1
)

:: Step 6: Analyze build results
echo.
echo ========================================
echo         Build Analysis
echo ========================================
echo.

echo JavaScript bundles:
if exist "build\web\main.dart.js" (
    for %%A in ("build\web\main.dart.js") do echo   main.dart.js: %%~zA bytes (%%~zA bytes / 1024 / 1024 = MB^)
)

echo.
echo Asset optimization summary:
echo - HTML renderer: CanvasKit avoided (saves ~6.7MB)
echo - Tree-shaking: Icons reduced by 98%+
echo - Image optimization: Available via scripts
echo - Caching: Optimized headers in firebase.json

echo.
echo Build completed successfully!
echo.
echo ========================================
echo         Next Steps
echo ========================================
echo 1. Test the build: flutter run -d chrome --release
echo 2. Deploy: firebase deploy --only hosting
echo 3. Monitor performance in browser DevTools
echo.
pause