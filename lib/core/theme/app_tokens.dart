import 'package:flutter/material.dart';

/// Single Source of Truth for all design tokens.
///
/// RULE: NEVER use Color(0xFF...) hex values outside this file.
/// Always reference AppTokens.* or ThemeData color scheme tokens.
///
/// To customize for your product, replace the hex values below.
abstract class AppTokens {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const primary = Color(0xFF6C63FF);        // Main brand color
  static const primaryLight = Color(0xFF9D97FF);   // Lighter variant
  static const primaryDark = Color(0xFF4A42D6);    // Darker variant
  static const accent = Color(0xFFFF6584);         // Accent / CTA color

  // ── Neutral Palette ───────────────────────────────────────────────────────
  static const grey50 = Color(0xFFF9FAFB);
  static const grey100 = Color(0xFFF3F4F6);
  static const grey200 = Color(0xFFE5E7EB);
  static const grey300 = Color(0xFFD1D5DB);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey500 = Color(0xFF6B7280);
  static const grey600 = Color(0xFF4B5563);
  static const grey700 = Color(0xFF374151);
  static const grey800 = Color(0xFF1F2937);
  static const grey900 = Color(0xFF111827);

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF9FAFB);
  static const lightSurfaceVariant = Color(0xFFF3F4F6);
  static const lightOnBackground = Color(0xFF111827);
  static const lightOnSurface = Color(0xFF374151);

  // ── Dark Theme Surfaces ───────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceVariant = Color(0xFF334155);
  static const darkOnBackground = Color(0xFFF8FAFC);
  static const darkOnSurface = Color(0xFFCBD5E1);

  // ── Typography ────────────────────────────────────────────────────────────
  static const fontFamily = 'Inter';

  static const fontSizeXs = 11.0;
  static const fontSizeSm = 12.0;
  static const fontSizeBase = 14.0;
  static const fontSizeMd = 16.0;
  static const fontSizeLg = 18.0;
  static const fontSizeXl = 20.0;
  static const fontSize2xl = 24.0;
  static const fontSize3xl = 30.0;
  static const fontSize4xl = 36.0;

  static const fontWeightRegular = FontWeight.w400;
  static const fontWeightMedium = FontWeight.w500;
  static const fontWeightSemiBold = FontWeight.w600;
  static const fontWeightBold = FontWeight.w700;

  static const lineHeightTight = 1.25;
  static const lineHeightBase = 1.5;
  static const lineHeightRelaxed = 1.625;

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const spacing2 = 2.0;
  static const spacing4 = 4.0;
  static const spacing6 = 6.0;
  static const spacing8 = 8.0;
  static const spacing10 = 10.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing20 = 20.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;
  static const spacing40 = 40.0;
  static const spacing48 = 48.0;
  static const spacing64 = 64.0;
  static const spacing80 = 80.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const radiusXs = 4.0;
  static const radiusS = 6.0;
  static const radiusM = 10.0;
  static const radiusL = 16.0;
  static const radiusXl = 24.0;
  static const radius2xl = 32.0;
  static const radiusFull = 9999.0;

  // ── Elevation / Shadow ────────────────────────────────────────────────────
  static const elevationNone = 0.0;
  static const elevationSm = 1.0;
  static const elevationMd = 4.0;
  static const elevationLg = 8.0;
  static const elevationXl = 16.0;

  // ── Animation Duration ────────────────────────────────────────────────────
  static const durationFast = Duration(milliseconds: 150);
  static const durationBase = Duration(milliseconds: 250);
  static const durationSlow = Duration(milliseconds: 400);
  static const durationVerySlow = Duration(milliseconds: 600);

  // ── Curves ────────────────────────────────────────────────────────────────
  static const curveDefault = Curves.easeInOut;
  static const curveEnter = Curves.easeOut;
  static const curveExit = Curves.easeIn;
  static const curveSpring = Curves.elasticOut;
}
