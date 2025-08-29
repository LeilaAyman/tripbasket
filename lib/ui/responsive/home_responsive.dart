import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/pages/home/home_widget.dart';
import '/ui/web/home_web_page.dart';
import '/ui/web/home_web_page_mobile.dart';
import '/ui/web/home_web_page_tablet.dart';
import 'breakpoints.dart';

class HomeResponsive extends StatelessWidget {
  const HomeResponsive({super.key});

  bool _isMobileDevice(BuildContext context) {
    // Check if it's a mobile device based on platform and screen characteristics
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    
    // High device pixel ratio typically indicates mobile device
    if (devicePixelRatio > 2.0) return true;
    
    // Very narrow screens are typically mobile
    if (width < 600) return true;
    
    // Portrait orientation with reasonable width is likely mobile
    if (height > width && width < 900) return true;
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    
    // Keep existing mobile screen for native app
    if (!kIsWeb) return const HomeWidget();
    
    // For web, detect mobile devices and use appropriate layout
    if (_isMobileDevice(context)) {
      return const HomeWebPageMobile();
    }
    
    // Tablet layout for medium screens
    if (w < kWebWide) {
      return const HomeWebPageTablet();
    }
    
    // Desktop layout for large screens
    return const HomeWebPage();
  }
}