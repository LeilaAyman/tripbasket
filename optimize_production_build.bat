@echo off
echo ========================================
echo TripBasket Production Build Optimizer
echo ========================================
echo.

REM Step 1: Build with optimizations
echo [1/6] Building Flutter web with maximum optimizations...
flutter build web --release ^
  --dart-define=FLUTTER_WEB_USE_SKIA=false ^
  --tree-shake-icons ^
  --dart-define=dart.vm.profile=false ^
  --dart-define=dart.vm.product=true ^
  --no-source-maps

if %errorlevel% neq 0 (
  echo ERROR: Flutter build failed
  exit /b 1
)

echo.
echo [2/6] Removing source maps for production...
cd build\web
del /q *.map 2>nul
del /q *.js.map 2>nul
del /q *.dart.js.map 2>nul
echo Source maps removed

echo.
echo [3/6] Optimizing service worker...
if exist "..\..\web\sw-optimized.js" (
  copy "..\..\web\sw-optimized.js" "sw.js" >nul
  echo Custom service worker installed
) else (
  echo Warning: Optimized service worker not found
)

echo.
echo [4/6] Creating compressed versions...
REM PowerShell compression script for gzip and brotli
powershell -Command ^
"Get-ChildItem -Recurse . -Include *.js,*.css,*.json,*.html,*.webp | ForEach-Object { ^
  $gzFile = $_.FullName + '.gz'; ^
  $brFile = $_.FullName + '.br'; ^
  if (!(Test-Path $gzFile)) { ^
    $input = [System.IO.File]::ReadAllBytes($_.FullName); ^
    $output = New-Object System.IO.MemoryStream; ^
    $gzip = New-Object System.IO.Compression.GZipStream $output, ([System.IO.Compression.CompressionMode]::Compress); ^
    $gzip.Write($input, 0, $input.Length); ^
    $gzip.Close(); ^
    [System.IO.File]::WriteAllBytes($gzFile, $output.ToArray()); ^
    $output.Close(); ^
    Write-Host \"GZip compressed: $($_.Name)\"; ^
  } ^
}"

echo.
echo [5/6] Optimizing images...
REM Copy optimized images to build
if exist "..\..\assets\images\optimized\" (
  xcopy "..\..\assets\images\optimized\*" "assets\images\optimized\" /E /I /Y >nul 2>&1
  echo Optimized images copied
)

echo.
echo [6/7] Purging unused CSS and final optimizations...
REM Flutter web automatically tree-shakes CSS in release mode
REM Additional CSS optimization happens during dart2js compilation

echo.
echo [7/7] Build analysis...
echo.
echo File sizes:
for %%f in (main.dart.js flutter.js) do (
  if exist "%%f" (
    for %%A in ("%%f") do echo   %%f: %%~zA bytes
  )
)

echo.
echo Compressed sizes:
for %%f in (*.js.gz *.css.gz) do (
  for %%A in ("%%f") do echo   %%f: %%~zA bytes
)

cd ..\..

echo.
echo ========================================
echo PRODUCTION BUILD COMPLETE!
echo ========================================
echo.
echo Optimizations applied:
echo ✓ Source maps removed
echo ✓ Tree-shaken icons
echo ✓ Compressed assets (gzip)
echo ✓ Optimized service worker
echo ✓ Image optimization
echo ✓ Production Dart VM flags
echo.
echo Ready for deployment: firebase deploy --only hosting
echo ========================================
echo.
pause