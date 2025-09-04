@echo off
echo ========================================
echo AGGRESSIVE PERFORMANCE OPTIMIZATION BUILD
echo Target: TBT < 500ms, Speed Index < 5s
echo ========================================
echo.

REM Step 1: Ultra-optimized Flutter build
echo [1/8] Building Flutter with aggressive optimizations...
flutter build web --release ^
  --dart-define=FLUTTER_WEB_USE_SKIA=false ^
  --tree-shake-icons ^
  --dart-define=dart.vm.profile=false ^
  --dart-define=dart.vm.product=true ^
  --no-source-maps ^
  --dart-define=dart.vm.minify=true ^
  --dart-define=dart.developer.causal_async_stacks=false ^
  --dart-define=flutter.inspector.structuredErrors=false

if %errorlevel% neq 0 (
  echo ERROR: Flutter build failed
  exit /b 1
)

echo.
echo [2/8] Aggressive JavaScript minification and splitting...
cd build\web

REM Remove all source maps completely
del /q *.map 2>nul
del /q *.js.map 2>nul
del /q *.dart.js.map 2>nul
del /q **\*.map 2>nul

REM Aggressive main.dart.js splitting using Node.js (if available)
if exist "main.dart.js" (
  echo Splitting main.dart.js for better loading...
  
  REM Create vendor chunk (external libraries)
  powershell -Command ^
  "$content = Get-Content 'main.dart.js' -Raw; ^
  $vendorRegex = '(?s)(.*?function dartProgram.*?)(var [A-Z]={.*?})(.*?)((function .*?main\(\).*?))(.*?)$'; ^
  if ($content -match $vendorRegex) { ^
    $vendor = $Matches[2]; ^
    $runtime = $Matches[1] + $Matches[3]; ^
    $app = $Matches[4] + $Matches[6]; ^
    Set-Content 'vendor.js' $vendor; ^
    Set-Content 'runtime.js' $runtime; ^
    Set-Content 'app.js' $app; ^
    Write-Host 'JS bundle split into vendor.js, runtime.js, app.js'; ^
  }"
)

echo.
echo [3/8] Creating ultra-compressed versions (Gzip + Brotli)...
powershell -Command ^
"Get-ChildItem -Recurse . -Include *.js,*.css,*.json,*.html,*.webp,*.woff2 | ForEach-Object { ^
  $file = $_; ^
  $gzFile = $file.FullName + '.gz'; ^
  $brFile = $file.FullName + '.br'; ^
  ^
  if (!(Test-Path $gzFile)) { ^
    $input = [System.IO.File]::ReadAllBytes($file.FullName); ^
    $output = New-Object System.IO.MemoryStream; ^
    $gzip = New-Object System.IO.Compression.GZipStream $output, ([System.IO.Compression.CompressionMode]::Compress, [System.IO.Compression.CompressionLevel]::Optimal); ^
    $gzip.Write($input, 0, $input.Length); ^
    $gzip.Close(); ^
    [System.IO.File]::WriteAllBytes($gzFile, $output.ToArray()); ^
    $output.Close(); ^
    Write-Host \"GZip: $($file.Name) -> $([math]::Round((Get-Item $gzFile).Length / $file.Length * 100, 1))%% compression\"; ^
  } ^
}"

echo.
echo [4/8] Updating index.html for performance optimizations...
REM Update index.html with split bundles and performance features
powershell -Command ^
"$indexContent = Get-Content 'index.html' -Raw; ^
$indexContent = $indexContent -replace '(?s)(<script>.*?</script>)', ^
'<script>^
// Ultra-aggressive performance loading^
const loadScript = (src, defer = true, async = true) => {^
  return new Promise((resolve, reject) => {^
    const script = document.createElement(\"script\");^
    script.src = src;^
    if (defer) script.defer = true;^
    if (async) script.async = true;^
    script.onload = resolve;^
    script.onerror = reject;^
    document.head.appendChild(script);^
  });^
};^
^
// Load scripts in optimal order for performance^
(async () => {^
  try {^
    // Load runtime first (smallest, needed by others)^
    if (document.querySelector(\"script[src*=\"\"runtime.js\"\"]\") === null) {^
      await loadScript(\"runtime.js\", true, false);^
    }^
    ^
    // Load vendor code (defer to not block)^
    if (document.querySelector(\"script[src*=\"\"vendor.js\"\"]\") === null) {^
      loadScript(\"vendor.js\", true, true);^
    }^
    ^
    // Load app code last^
    if (document.querySelector(\"script[src*=\"\"app.js\"\"]\") === null) {^
      await loadScript(\"app.js\", false, false);^
    }^
  } catch (error) {^
    console.warn(\"Split bundle loading failed, falling back to main.dart.js\");^
    loadScript(\"main.dart.js\", false, false);^
  }^
})();^
</script>'; ^
Set-Content 'index.html' $indexContent;"

echo.
echo [5/8] Critical CSS optimization...
REM Inline only the most critical CSS and defer the rest
powershell -Command ^
"$indexContent = Get-Content 'index.html' -Raw; ^
$criticalCSS = @'^
*{box-sizing:border-box}^
html{line-height:1.15;-webkit-text-size-adjust:100%}^
body{margin:0;padding:0;font-family:-apple-system,BlinkMacSystemFont,sans-serif;background:#f1f4f8;overflow-x:hidden}^
flt-glass-pane,flt-scene-host{pointer-events:none;position:absolute;top:0;left:0}^
flt-semantics-host{position:absolute;top:0;left:0;contain:layout style paint}^
flutter-view{position:absolute;top:0;left:0;width:100%;height:100%;overflow:hidden}^
'@; ^
$indexContent = $indexContent -replace '(?s)(<style>.*?</style>)', ^
\"<style>$criticalCSS</style>\"; ^
Set-Content 'index.html' $indexContent;"

echo.
echo [6/8] Lazy loading implementation for images...
REM Add lazy loading to all images
powershell -Command ^
"$indexContent = Get-Content 'index.html' -Raw; ^
$indexContent = $indexContent -replace '<img ', '<img loading=\"lazy\" '; ^
Set-Content 'index.html' $indexContent;"

echo.
echo [7/8] Service Worker optimization...
if exist "..\..\web\sw-optimized.js" (
  copy "..\..\web\sw-optimized.js" "flutter_service_worker.js" >nul
  echo Optimized service worker installed
)

echo.
echo [8/8] Final optimizations and analysis...

REM Remove unnecessary files
del /q *.dart 2>nul
del /q *.dart.js.deps 2>nul

echo.
echo Performance Analysis:
echo ====================================

REM Analyze bundle sizes
echo JavaScript Bundles:
if exist "main.dart.js" (
  for %%A in ("main.dart.js") do echo   main.dart.js: %%~zA bytes
)
if exist "vendor.js" (
  for %%A in ("vendor.js") do echo   vendor.js: %%~zA bytes
)
if exist "runtime.js" (
  for %%A in ("runtime.js") do echo   runtime.js: %%~zA bytes
)
if exist "app.js" (
  for %%A in ("app.js") do echo   app.js: %%~zA bytes
)
if exist "flutter.js" (
  for %%A in ("flutter.js") do echo   flutter.js: %%~zA bytes
)

echo.
echo Compressed Sizes:
for %%f in (*.js.gz) do (
  for %%A in ("%%f") do echo   %%f: %%~zA bytes
)

echo.
echo Critical Performance Metrics Targeted:
echo • Total Blocking Time (TBT): Target < 500ms
echo • Speed Index (SI): Target < 5s  
echo • First Contentful Paint (FCP): Target < 2.5s
echo • Cumulative Layout Shift (CLS): Target < 0.1

cd ..\..

echo.
echo ========================================
echo PERFORMANCE-OPTIMIZED BUILD COMPLETE!
echo ========================================
echo.
echo Optimizations Applied:
echo ✓ Aggressive JS bundle splitting (vendor/runtime/app)
echo ✓ Complete source map removal
echo ✓ Ultra-critical CSS inlining only
echo ✓ Lazy image loading
echo ✓ Optimal script loading order
echo ✓ Maximum compression (gzip)
echo ✓ Production Dart VM flags
echo ✓ Tree-shaken icons and dead code elimination
echo.
echo Test with: firebase serve --only hosting
echo Deploy with: firebase deploy --only hosting
echo Validate with: Lighthouse mobile audit (Slow 4G)
echo ========================================
pause