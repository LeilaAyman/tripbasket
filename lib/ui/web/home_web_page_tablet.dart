import 'package:flutter/material.dart';
import '/ui/web/home_web_page.dart';
import '/ui/responsive/breakpoints.dart';

class HomeWebPageTablet extends StatelessWidget {
  const HomeWebPageTablet({super.key});

  @override
  Widget build(BuildContext context) {
    // For tablets, use the desktop version but with smaller constraints
    return const HomeWebPage();
  }
}
