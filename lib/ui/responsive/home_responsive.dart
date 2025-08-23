import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/pages/home/home_widget.dart';
import '/ui/web/home_web_page.dart';
import 'breakpoints.dart';

class HomeResponsive extends StatelessWidget {
  const HomeResponsive({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    // Keep existing mobile screen for app
    if (!kIsWeb || w < kWebNarrow) return const HomeWidget(); // current mobile
    return const HomeWebPage(); // new web layout
  }
}