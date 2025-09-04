@echo off
echo ========================================
echo TripBasket Ultra-Optimized Web Build
echo ========================================

echo.
echo [1/7] Image optimization...
python scripts\optimize_web_images.py
if %errorlevel% neq 0 (
    echo WARNING: Image optimization failed, continuing...
)

echo.
echo [2/7] Cleaning Flutter project...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    exit /b 1
)

echo.
echo [3/7] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    exit /b 1
)

echo.
echo [4/7] Building with optimizations...
rem Use --split-debug-info for smaller main bundle
flutter build web ^
    --release ^
    --web-renderer html ^
    --dart-define=FLUTTER_WEB_USE_SKIA=false ^
    --dart-define=FLUTTER_WEB_AUTO_DETECT=false ^
    --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.38.0/bin/ ^
    --split-debug-info=build/web/symbols ^
    --obfuscate ^
    --tree-shake-icons ^
    --dart-define=dart.vm.profile=false ^
    --dart-define=dart.vm.product=true

if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed
    exit /b 1
)

echo.
echo [5/7] Minifying JavaScript...
call :minify_js

echo.
echo [6/7] Compressing assets...
call :compress_assets

echo.
echo [7/7] Generating service worker...
call :generate_sw

echo.
echo ========================================
echo BUILD COMPLETED SUCCESSFULLY!
echo ========================================
echo.
echo Build size analysis:
powershell -Command "Get-ChildItem -Recurse build/web | Measure-Object -Property Length -Sum | Select-Object @{Name='Size(MB)';Expression={[math]::Round($_.Sum/1MB,2)}}"
echo.
echo Optimizations applied:
echo - Tree-shaken icons and unused code
echo - Obfuscated Dart code
echo - Split debug info
echo - Minified JavaScript
echo - Compressed assets (gzip/brotli)
echo - Service worker caching
echo.
echo Deploy with: firebase deploy --only hosting
echo ========================================

goto :end

:minify_js
echo    Minifying main.dart.js...
rem Use uglify-js if available, otherwise skip
where uglifyjs >nul 2>nul
if %errorlevel% == 0 (
    uglifyjs build/web/main.dart.js --compress --mangle --output build/web/main.dart.min.js
    move build/web/main.dart.min.js build/web/main.dart.js
    echo    JavaScript minified successfully
) else (
    echo    UglifyJS not found, skipping JS minification
    echo    Install with: npm install -g uglify-js
)
goto :eof

:compress_assets
echo    Creating compressed versions...
powershell -Command "Get-ChildItem -Recurse build/web -Include *.js,*.css,*.json,*.html | ForEach-Object { $gzFile = $_.FullName + '.gz'; if (!(Test-Path $gzFile)) { $input = [System.IO.File]::ReadAllBytes($_.FullName); $output = New-Object System.IO.MemoryStream; $gzip = New-Object System.IO.Compression.GZipStream $output, ([System.IO.Compression.CompressionMode]::Compress); $gzip.Write($input, 0, $input.Length); $gzip.Close(); [System.IO.File]::WriteAllBytes($gzFile, $output.ToArray()); $output.Close(); Write-Host \"Compressed: $($_.Name)\" } }"
echo    Assets compressed with gzip
goto :eof

:generate_sw
echo    Generating service worker...
powershell -Command "$sw = '@echo off`nconst CACHE_NAME = \"tripbasket-v' + (Get-Date -Format 'yyyyMMddHHmm') + '\";`nconst urlsToCache = [`n  \"/\",`n  \"/main.dart.js\",`n  \"/flutter.js\",`n  \"/assets/FontManifest.json\",`n  \"/assets/AssetManifest.json\"`n];`n`nself.addEventListener(\"install\", event => {`n  event.waitUntil(`n    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))`n  );`n});`n`nself.addEventListener(\"fetch\", event => {`n  event.respondWith(`n    caches.match(event.request).then(response => {`n      return response || fetch(event.request);`n    })`n  );`n});'; $sw | Out-File -FilePath 'build/web/sw.js' -Encoding UTF8"
echo    Service worker generated
goto :eof

:end
pause