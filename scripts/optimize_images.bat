@echo off
echo ========================================
echo    TripBasket Image Optimization
echo ========================================
echo.

cd /d "%~dp0.."

echo Checking current PNG assets...
echo.

echo Badge Design Files:
dir "assets\images\*badgeDesign*.png" 2>nul | findstr /C:".png"

echo.
echo Converting to WebP format...
echo.

:: Check if magick (ImageMagick) is available
magick -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ImageMagick not found. Please install ImageMagick or use the Python script.
    echo Download from: https://imagemagick.org/script/download.php#windows
    echo.
    echo Alternative: Run 'python scripts/optimize_images.py' if you have Python + PIL
    pause
    exit /b 1
)

:: Convert badge designs to WebP
if exist "assets\images\@4xff_badgeDesign_light_small.png" (
    echo Converting light badge design...
    magick "assets\images\@4xff_badgeDesign_light_small.png" -quality 85 "assets\images\@4xff_badgeDesign_light_small.webp"
    if exist "assets\images\@4xff_badgeDesign_light_small.webp" (
        echo ✅ Created: @4xff_badgeDesign_light_small.webp
        call :showSavings "assets\images\@4xff_badgeDesign_light_small.png" "assets\images\@4xff_badgeDesign_light_small.webp"
    )
)

if exist "assets\images\@4xff_badgeDesign_dark_small.png" (
    echo Converting dark badge design...
    magick "assets\images\@4xff_badgeDesign_dark_small.png" -quality 85 "assets\images\@4xff_badgeDesign_dark_small.webp"
    if exist "assets\images\@4xff_badgeDesign_dark_small.webp" (
        echo ✅ Created: @4xff_badgeDesign_dark_small.webp
        call :showSavings "assets\images\@4xff_badgeDesign_dark_small.png" "assets\images\@4xff_badgeDesign_dark_small.webp"
    )
)

echo.
echo ========================================
echo       Manual Steps Required
echo ========================================
echo.
echo 1. Update any code references from .png to .webp
echo 2. Run: flutter clean ^&^& flutter pub get
echo 3. Test that WebP images display correctly
echo 4. Delete original PNG files if everything works
echo.
echo Files converted:
if exist "assets\images\@4xff_badgeDesign_light_small.webp" echo   - @4xff_badgeDesign_light_small.webp
if exist "assets\images\@4xff_badgeDesign_dark_small.webp" echo   - @4xff_badgeDesign_dark_small.webp
echo.
pause
exit /b 0

:showSavings
set "originalFile=%~1"
set "webpFile=%~2"

for %%A in ("%originalFile%") do set "originalSize=%%~zA"
for %%A in ("%webpFile%") do set "webpSize=%%~zA"

set /a "savings=%originalSize% - %webpSize%"
set /a "percent=(%savings% * 100) / %originalSize%"

echo   Original: %originalSize% bytes
echo   WebP:     %webpSize% bytes
echo   Savings:  %savings% bytes (%percent%%% reduction)
echo.
goto :eof