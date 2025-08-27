import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/hero_background.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WebHero extends StatefulWidget {
  const WebHero({super.key});

  @override
  State<WebHero> createState() => _WebHeroState();
}

class _WebHeroState extends State<WebHero> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeroBackground(
      height: 360,
      child: Center(
        child: _buildHeroContent(),
      ),
    );
  }

  Widget _buildHeroContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Discover Amazing Destinations',
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.8),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Explore unique trips and experiences around the world',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              height: 1.4,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}