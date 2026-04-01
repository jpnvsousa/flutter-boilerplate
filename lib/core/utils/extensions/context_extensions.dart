import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  // ── Theme ─────────────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Media ─────────────────────────────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  bool get isKeyboardOpen => viewInsets.bottom > 0;

  // ── Breakpoints ───────────────────────────────────────────────────────────
  bool get isSmall => screenWidth < 375;
  bool get isMedium => screenWidth >= 375 && screenWidth < 768;
  bool get isLarge => screenWidth >= 768;

  // ── Navigation ────────────────────────────────────────────────────────────
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  void showSnackBar(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
    bool isError = false,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          duration: duration,
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }

  void showErrorSnackBar(String message) =>
      showSnackBar(message, isError: true);
}
