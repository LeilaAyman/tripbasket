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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.pushNamed(
                    'searchResults',
                    queryParameters: {
                      'searchQuery': serializeParam(
                        value,
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                }
              },
              decoration: InputDecoration(
                hintText: 'Where do you want to go?',
                hintStyle: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 18,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF6B7280),
                  size: 24,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD76B30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        context.pushNamed(
                          'searchResults',
                          queryParameters: {
                            'searchQuery': serializeParam(
                              _searchController.text,
                              ParamType.String,
                            ),
                          }.withoutNulls,
                        );
                      }
                    },
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}