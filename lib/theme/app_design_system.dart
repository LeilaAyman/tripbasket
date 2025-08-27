import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDesignSystem {
  // Modern Color Palette - Premium travel theme
  static const Color primaryBlue = Color(0xFF0A2E5C);      // Deep ocean blue
  static const Color primaryGold = Color(0xFFD4AF37);      // Luxury gold
  static const Color accentTeal = Color(0xFF1ABFAE);       // Modern teal
  static const Color accentCoral = Color(0xFFFF6B6B);      // Vibrant coral
  
  // Neutral palette
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray50 = Color(0xFFFAFBFC);
  static const Color neutralGray100 = Color(0xFFF4F6F8);
  static const Color neutralGray200 = Color(0xFFE7EAEF);
  static const Color neutralGray300 = Color(0xFFD1D8E0);
  static const Color neutralGray400 = Color(0xFFA6B4C8);
  static const Color neutralGray500 = Color(0xFF758CA3);
  static const Color neutralGray600 = Color(0xFF5E728A);
  static const Color neutralGray700 = Color(0xFF4A5568);
  static const Color neutralGray800 = Color(0xFF2D3748);
  static const Color neutralGray900 = Color(0xFF1A202C);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, accentTeal],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD700), primaryGold],
  );
  
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x66000000),
      Color(0xCC000000),
    ],
  );

  // Glass Morphism
  static BoxDecoration get glassMorphism => BoxDecoration(
    color: neutralWhite.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: neutralWhite.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Card Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryBlue.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primaryBlue.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedCardShadow => [
    BoxShadow(
      color: primaryBlue.withOpacity(0.15),
      blurRadius: 40,
      offset: const Offset(0, 16),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: primaryBlue.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // Typography System
  static TextStyle get heading1 => GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02,
    color: neutralGray900,
  );

  static TextStyle get heading2 => GoogleFonts.playfairDisplay(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.01,
    color: neutralGray900,
  );

  static TextStyle get heading3 => GoogleFonts.playfairDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: neutralGray900,
  );

  static TextStyle get heading4 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: neutralGray900,
  );

  static TextStyle get heading5 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: neutralGray900,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: neutralGray700,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: neutralGray700,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: neutralGray600,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.4,
    color: neutralGray500,
  );

  // Button Styles
  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // Spacing System
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;
  static const double space128 = 128.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationXSlow = Duration(milliseconds: 800);

  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  static const double wideBreakpoint = 1440;

  // Helper methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
}

// Animation Extensions
extension AnimatedBoxDecoration on BoxDecoration {
  BoxDecoration get withHoverElevation => BoxDecoration(
    color: color,
    borderRadius: borderRadius,
    border: border,
    gradient: gradient,
    boxShadow: AppDesignSystem.elevatedCardShadow,
  );
}

// Color Extensions
extension ColorExtensions on Color {
  Color get withLightOpacity => withOpacity(0.1);
  Color get withMediumOpacity => withOpacity(0.3);
  Color get withHighOpacity => withOpacity(0.7);
}