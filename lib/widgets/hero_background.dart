import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

const kHeroAsset = 'assets/images/Cairo Egypt_GettyImages-1370918272.webp';
const kHeroUrl =
    'https://media.cntraveler.com/photos/655cdf1d2d09a7e0b27741b5/16:9/w_1920,c_limit/Cairo%20Egypt_GettyImages-1370918272.jpg';

class HeroBackground extends StatelessWidget {
  final double height;
  final Widget child;
  final String assetPath;
  final String? networkUrl; // optional
  
  const HeroBackground({
    super.key,
    required this.height,
    required this.child,
    this.assetPath = kHeroAsset,
    this.networkUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Prefer asset on web to avoid CORS; allow network on mobile.
          if (kIsWeb || networkUrl == null)
            Image.asset(assetPath, fit: BoxFit.cover)
          else
            CachedNetworkImage(
              imageUrl: networkUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => _fallback(),
              errorWidget: (_, __, ___) => Image.asset(assetPath, fit: BoxFit.cover),
            ),

          // Readability overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xAA000000), Color(0x33000000), Color(0xAA000000)],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Content
          child,
        ],
      ),
    );
  }

  Widget _fallback() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF7F3EE), Color(0xFFEDE7DE)],
      ),
    ),
  );
}