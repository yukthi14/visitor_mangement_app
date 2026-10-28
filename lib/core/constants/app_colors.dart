import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
/// All colors must be sourced from here to maintain consistency.
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF1E5AE6);
  static const Color primaryDark = Color(0xFF1442B5);
  static const Color primaryLight = Color(0xFFEBF2FF);
  static const Color splashBg = Color(0xFF1E52D5);

  // Background and Surface
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Opacity variations
  static const Color whiteOpacity12 = Color(0x1FFFFFFF);
  static const Color whiteOpacity25 = Color(0x40FFFFFF);
  static const Color whiteOpacity54 = Color(0x8AFFFFFF);
  static const Color whiteOpacity70 = Color(0xB3FFFFFF);
  static const Color whiteOpacity85 = Color(0xD9FFFFFF);
  static const Color blackOpacity04 = Color(0x0A000000);
  static const Color blackOpacity54 = Color(0x8A000000);
  static const Color blackOpacity70 = Color(0xB3000000);

  // Text colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEEF2F6);

  // Input & Component backgrounds
  static const Color inputFill = Color(0xFFF8FAFC);
  static const Color inputFillDisabled = Color(0xFFF1F5F9);
  static const Color avatarBg = Color(0xFFE2E8F8);

  // Status Colors
  // Registered (Blue)
  static const Color statusRegisteredBg = Color(0xFFEBF2FF);
  static const Color statusRegisteredText = Color(0xFF1E5AE6);

  // Checked In (Green)
  static const Color statusCheckedInBg = Color(0xFFE6F8ED);
  static const Color statusCheckedInText = Color(0xFF16A34A);

  // Checked Out (Purple)
  static const Color statusCheckedOutBg = Color(0xFFF3EDFF);
  static const Color statusCheckedOutText = Color(0xFF7C3AED);

  // Metric Cards
  static const Color metricBlueBg = Color(0xFFEFF5FF);
  static const Color metricBlueBorder = Color(0xFFDBEAFE);
  static const Color metricBlueText = Color(0xFF1D4ED8);

  static const Color metricGreenBg = Color(0xFFF0FDF4);
  static const Color metricGreenBorder = Color(0xFFDCFCE7);
  static const Color metricGreenText = Color(0xFF15803D);

  static const Color metricPurpleBg = Color(0xFFFAF5FF);
  static const Color metricPurpleBorder = Color(0xFFF3E8FF);
  static const Color metricPurpleText = Color(0xFF7E22CE);

  // Success, Danger, Warning
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color dangerButton = Color(0xFFEA3D3D);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color warningBorder = Color(0xFFFFB74D);
  static const Color warningIcon = Color(0xFFF57C00);

  // Scanner & Camera
  static const Color scannerFrame = Color(0xFF38BDF8);

  // Chart & Visuals
  static const Color chartGrid = Color(0xFFE2E8F0);
  static const Color purpleLight = Color(0xFFC4B5FD);

  // Shimmer Effect Colors
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color shimmerCardBg = Color(0xFFF1F5F9);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkInputFill = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Dark Metric Cards
  static const Color metricBlueBgDark = Color(0xFF1E293B);
  static const Color metricBlueBorderDark = Color(0xFF2563EB);
  static const Color metricBlueTextDark = Color(0xFF60A5FA);

  static const Color metricGreenBgDark = Color(0xFF143026);
  static const Color metricGreenBorderDark = Color(0xFF16A34A);
  static const Color metricGreenTextDark = Color(0xFF4ADE80);

  static const Color metricPurpleBgDark = Color(0xFF291B3E);
  static const Color metricPurpleBorderDark = Color(0xFF9333EA);
  static const Color metricPurpleTextDark = Color(0xFFC084FC);

  // Dynamic Theme Helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceColor(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color backgroundColor(BuildContext context) =>
      isDark(context) ? darkBackground : background;

  static Color textPrimaryColor(BuildContext context) =>
      isDark(context) ? darkTextPrimary : textPrimary;

  static Color textSecondaryColor(BuildContext context) =>
      isDark(context) ? darkTextSecondary : textSecondary;

  static Color textMutedColor(BuildContext context) =>
      isDark(context) ? darkTextMuted : textMuted;

  static Color borderColor(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color cardBgColor(BuildContext context) =>
      isDark(context) ? darkCard : white;

  static Color inputFillColor(BuildContext context) =>
      isDark(context) ? darkInputFill : inputFill;

  static Color dividerColor(BuildContext context) =>
      isDark(context) ? darkDivider : divider;

  static Color avatarBgColor(BuildContext context) =>
      isDark(context) ? darkSurface : avatarBg;

  static Color disabledFillColor(BuildContext context) =>
      isDark(context) ? darkCard : inputFillDisabled;
}
