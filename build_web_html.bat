@echo off
echo Building Flutter Web with HTML renderer (no CanvasKit)...
flutter build web --web-renderer html --dart-define=FLUTTER_WEB_USE_SKIA=false --release
echo Build complete! CanvasKit.wasm avoided.
pause