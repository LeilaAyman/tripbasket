@echo off
echo ========================================
echo    TripBasket Web Optimization Build
echo ========================================
echo.

echo Step 1: Clean previous builds...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    pause
    exit /b 1
)

echo Step 2: Get dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    pause
    exit /b 1
)

echo Step 3: Building optimized web version...
echo - Using HTML renderer (no CanvasKit = -6.7MB)
echo - Deferred imports enabled for code splitting
echo - WebP images for size reduction
flutter build web --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false --release --source-maps
if %errorlevel% neq 0 (
    echo ERROR: Flutter build web failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo       Build Size Analysis
echo ========================================
cd build\web
echo Main bundle size:
powershell "Get-ChildItem -Path '.' -Filter '*.js' | Sort-Object Length -Descending | Select-Object Name, @{Name='Size(MB)';Expression={[math]::round($_.Length/1MB,2)}} | Format-Table -AutoSize"

echo.
echo Image assets:
powershell "Get-ChildItem -Path '.' -Recurse -Include *.png, *.jpg, *.webp | Sort-Object Length -Descending | Select-Object Name, @{Name='Size(KB)';Expression={[math]::round($_.Length/1KB,0)}} | Format-Table -AutoSize"

cd ..\..
echo.
echo ========================================
echo     Optimization Complete!
echo ========================================
echo Expected improvements:
echo - CanvasKit.wasm: REMOVED (-6.7MB)
echo - PNG logo: Compressed to WebP (-1.8MB)
echo - main.dart.js: Reduced via deferred imports (-30-50%%)
echo - Better caching: HTML no-cache, assets immutable
echo.
echo Total expected size reduction: ~8-10MB
echo Target load time: 1-2s (down from 5s)
echo.
pause