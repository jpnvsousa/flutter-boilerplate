import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_tokens.dart';

/// ThemeData factory using AppTokens as Single Source of Truth.
/// Never define colors directly here — always use AppTokens.
abstract class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppTokens.primary,
      onPrimary: Colors.white,
      primaryContainer: AppTokens.primaryLight,
      onPrimaryContainer: AppTokens.primaryDark,
      secondary: AppTokens.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppTokens.accent.withOpacity(0.15),
      onSecondaryContainer: AppTokens.accent,
      surface: AppTokens.lightSurface,
      onSurface: AppTokens.lightOnSurface,
      surfaceContainerHighest: AppTokens.lightSurfaceVariant,
      error: AppTokens.error,
      onError: Colors.white,
      errorContainer: AppTokens.errorLight,
      onErrorContainer: AppTokens.error,
      outline: AppTokens.grey300,
      outlineVariant: AppTokens.grey200,
      shadow: AppTokens.grey900,
      scrim: AppTokens.grey900,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTokens.fontFamily,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.lightBackground,
        foregroundColor: AppTokens.lightOnBackground,
        elevation: AppTokens.elevationNone,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: AppTokens.fontFamily,
          fontSize: AppTokens.fontSizeMd,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: AppTokens.lightOnBackground,
        ),
      ),

      // ── Scaffold ─────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppTokens.lightBackground,

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: AppTokens.lightSurface,
        elevation: AppTokens.elevationSm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusL),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacing16,
          vertical: AppTokens.spacing8,
        ),
      ),

      // ── Elevated Button ──────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.primary,
          foregroundColor: Colors.white,
          elevation: AppTokens.elevationNone,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing24,
            vertical: AppTokens.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusM),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTokens.fontFamily,
            fontSize: AppTokens.fontSizeBase,
            fontWeight: AppTokens.fontWeightSemiBold,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.primary,
          side: const BorderSide(color: AppTokens.primary),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spacing24,
            vertical: AppTokens.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusM),
          ),
          textStyle: const TextStyle(
            fontFamily: AppTokens.fontFamily,
            fontSize: AppTokens.fontSizeBase,
            fontWeight: AppTokens.fontWeightSemiBold,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTokens.primary,
          textStyle: const TextStyle(
            fontFamily: AppTokens.fontFamily,
            fontSize: AppTokens.fontSizeBase,
            fontWeight: AppTokens.fontWeightSemiBold,
          ),
        ),
      ),

      // ── Input / TextField ────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spacing16,
          vertical: AppTokens.spacing16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
          borderSide: const BorderSide(color: AppTokens.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
          borderSide: const BorderSide(color: AppTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
          borderSide: const BorderSide(color: AppTokens.error),
        ),
        hintStyle: const TextStyle(
          color: AppTokens.grey400,
          fontSize: AppTokens.fontSizeBase,
        ),
        labelStyle: const TextStyle(
          color: AppTokens.grey600,
          fontSize: AppTokens.fontSizeBase,
        ),
      ),

      // ── Text ─────────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppTokens.fontSize4xl,
          fontWeight: AppTokens.fontWeightBold,
          color: AppTokens.lightOnBackground,
        ),
        displayMedium: TextStyle(
          fontSize: AppTokens.fontSize3xl,
          fontWeight: AppTokens.fontWeightBold,
          color: AppTokens.lightOnBackground,
        ),
        headlineLarge: TextStyle(
          fontSize: AppTokens.fontSize2xl,
          fontWeight: AppTokens.fontWeightBold,
          color: AppTokens.lightOnBackground,
        ),
        headlineMedium: TextStyle(
          fontSize: AppTokens.fontSizeXl,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: AppTokens.lightOnBackground,
        ),
        headlineSmall: TextStyle(
          fontSize: AppTokens.fontSizeLg,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: AppTokens.lightOnBackground,
        ),
        titleLarge: TextStyle(
          fontSize: AppTokens.fontSizeMd,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: AppTokens.lightOnBackground,
        ),
        titleMedium: TextStyle(
          fontSize: AppTokens.fontSizeBase,
          fontWeight: AppTokens.fontWeightMedium,
          color: AppTokens.lightOnBackground,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTokens.fontSizeMd,
          fontWeight: AppTokens.fontWeightRegular,
          color: AppTokens.lightOnSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTokens.fontSizeBase,
          fontWeight: AppTokens.fontWeightRegular,
          color: AppTokens.lightOnSurface,
        ),
        bodySmall: TextStyle(
          fontSize: AppTokens.fontSizeSm,
          fontWeight: AppTokens.fontWeightRegular,
          color: AppTokens.grey500,
        ),
        labelLarge: TextStyle(
          fontSize: AppTokens.fontSizeBase,
          fontWeight: AppTokens.fontWeightSemiBold,
          color: AppTokens.lightOnBackground,
        ),
        labelMedium: TextStyle(
          fontSize: AppTokens.fontSizeSm,
          fontWeight: AppTokens.fontWeightMedium,
          color: AppTokens.grey600,
        ),
        labelSmall: TextStyle(
          fontSize: AppTokens.fontSizeXs,
          fontWeight: AppTokens.fontWeightMedium,
          color: AppTokens.grey500,
        ),
      ),

      // ── Bottom Navigation ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTokens.lightBackground,
        indicatorColor: AppTokens.primary.withOpacity(0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppTokens.primary, size: 24);
          }
          return const IconThemeData(color: AppTokens.grey400, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: AppTokens.fontSizeXs,
              fontWeight: AppTokens.fontWeightSemiBold,
              color: AppTokens.primary,
            );
          }
          return const TextStyle(
            fontSize: AppTokens.fontSizeXs,
            color: AppTokens.grey400,
          );
        }),
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppTokens.grey200,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.grey900,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: AppTokens.fontFamily,
          fontSize: AppTokens.fontSizeBase,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData dark() {
    return light().copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTokens.darkBackground,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppTokens.primaryLight,
        onPrimary: AppTokens.darkBackground,
        primaryContainer: AppTokens.primaryDark,
        onPrimaryContainer: AppTokens.primaryLight,
        secondary: AppTokens.accent,
        onSecondary: AppTokens.darkBackground,
        secondaryContainer: AppTokens.accent.withOpacity(0.2),
        onSecondaryContainer: AppTokens.accent,
        surface: AppTokens.darkSurface,
        onSurface: AppTokens.darkOnSurface,
        surfaceContainerHighest: AppTokens.darkSurfaceVariant,
        error: AppTokens.error,
        onError: Colors.white,
        errorContainer: AppTokens.error.withOpacity(0.2),
        onErrorContainer: AppTokens.error,
        outline: AppTokens.grey600,
        outlineVariant: AppTokens.grey700,
        shadow: Colors.black,
        scrim: Colors.black,
      ),
    );
  }
}
