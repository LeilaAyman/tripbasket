@echo off
echo ========================================
echo    TripBasket Asset Cleanup
echo ========================================
echo.

cd /d "%~dp0.."

echo Analyzing large PNG assets...
echo.

:: Check for badge design files
if exist "assets\images\@4xff_badgeDesign_light_small.png" (
    echo Found: @4xff_badgeDesign_light_small.png
    for %%A in ("assets\images\@4xff_badgeDesign_light_small.png") do echo   Size: %%~zA bytes (%%~zA / 1024 KB^)
    
    :: Check if referenced in code
    findstr /r /c:"badgeDesign" "lib\*.dart" "lib\**\*.dart" >nul 2>&1
    if %errorlevel% neq 0 (
        echo   ⚠️  Not found in Dart code - potentially unused
    ) else (
        echo   ✅ Referenced in code - keeping
    )
)

if exist "assets\images\@4xff_badgeDesign_dark_small.png" (
    echo Found: @4xff_badgeDesign_dark_small.png
    for %%A in ("assets\images\@4xff_badgeDesign_dark_small.png") do echo   Size: %%~zA bytes (%%~zA / 1024 KB^)
    
    :: Check if referenced in code
    findstr /r /c:"badgeDesign" "lib\*.dart" "lib\**\*.dart" >nul 2>&1
    if %errorlevel% neq 0 (
        echo   ⚠️  Not found in Dart code - potentially unused
    ) else (
        echo   ✅ Referenced in code - keeping
    )
)

echo.
echo ========================================
echo      Asset Cleanup Options
echo ========================================
echo.
echo 1. Keep all assets (no changes)
echo 2. Move unused assets to backup folder
echo 3. Delete unused assets (saves ~1.6MB)
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto :keep_all
if "%choice%"=="2" goto :backup_assets
if "%choice%"=="3" goto :delete_assets

echo Invalid choice. Exiting...
goto :end

:keep_all
echo No changes made. Assets preserved.
goto :end

:backup_assets
echo Creating backup folder...
if not exist "assets\images\backup" mkdir "assets\images\backup"

if exist "assets\images\@4xff_badgeDesign_light_small.png" (
    echo Moving badge design files to backup...
    move "assets\images\@4xff_badgeDesign_light_small.png" "assets\images\backup\"
    echo   Moved: @4xff_badgeDesign_light_small.png
)

if exist "assets\images\@4xff_badgeDesign_dark_small.png" (
    move "assets\images\@4xff_badgeDesign_dark_small.png" "assets\images\backup\"
    echo   Moved: @4xff_badgeDesign_dark_small.png
)

echo ✅ Unused assets moved to assets\images\backup\
goto :end

:delete_assets
echo.
echo ⚠️  WARNING: This will permanently delete unused assets!
echo.
set /p confirm="Are you sure? Type 'DELETE' to confirm: "

if not "%confirm%"=="DELETE" (
    echo Deletion cancelled.
    goto :end
)

set "deleted_size=0"

if exist "assets\images\@4xff_badgeDesign_light_small.png" (
    for %%A in ("assets\images\@4xff_badgeDesign_light_small.png") do set /a "deleted_size+=%%~zA"
    del "assets\images\@4xff_badgeDesign_light_small.png"
    echo   Deleted: @4xff_badgeDesign_light_small.png
)

if exist "assets\images\@4xff_badgeDesign_dark_small.png" (
    for %%A in ("assets\images\@4xff_badgeDesign_dark_small.png") do set /a "deleted_size+=%%~zA"
    del "assets\images\@4xff_badgeDesign_dark_small.png"
    echo   Deleted: @4xff_badgeDesign_dark_small.png
)

set /a "deleted_mb=%deleted_size% / 1024 / 1024"
echo.
echo ✅ Deleted %deleted_size% bytes (~%deleted_mb% MB) of unused assets
goto :end

:end
echo.
echo Asset cleanup completed!
echo.
echo Recommendations:
echo - Run 'flutter clean' after asset changes
echo - Test your app to ensure no missing images
echo - Use 'build_optimized.bat' for optimized builds
echo.
pause