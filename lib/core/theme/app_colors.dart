import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF00D9F5);

  // Gradient stops
  static const Color gradientStart = Color(0xFF6C63FF);
  static const Color gradientEnd = Color(0xFF00D9F5);

  // Backgrounds
  static const Color background = Color(0xFF0D0D0D);
  static const Color backgroundAmoled = Color(0xFF000000);
  static const Color surface = Color(0xFF161616);
  static const Color surfaceElevated = Color(0xFF1C1C1C);
  static const Color card = Color(0xFF121212);
  static const Color cardBorder = Color(0x14FFFFFF); // 8% white

  // Text
  static const Color textPrimary = Color(0xFFE2E8F0);    // slate-200
  static const Color textSecondary = Color(0xFF94A3B8);  // slate-400
  static const Color textMuted = Color(0xFF475569);       // slate-600
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerAlt = Color(0xFFFF3D71);

  // HTTP Method colors
  static const Color methodGet = Color(0xFF10B981);
  static const Color methodPost = Color(0xFF3B82F6);
  static const Color methodPut = Color(0xFFF59E0B);
  static const Color methodPatch = Color(0xFFA78BFA);
  static const Color methodDelete = Color(0xFFEF4444);
  static const Color methodHead = Color(0xFF06B6D4);
  static const Color methodOptions = Color(0xFF8B5CF6);

  // HTTP status category colors
  static const Color status1xx = Color(0xFF94A3B8);
  static const Color status2xx = Color(0xFF10B981);
  static const Color status3xx = Color(0xFF3B82F6);
  static const Color status4xx = Color(0xFFF59E0B);
  static const Color status5xx = Color(0xFFEF4444);

  // Dividers
  static const Color divider = Color(0x0DFFFFFF); // 5% white
  static const Color dividerLight = Color(0x14FFFFFF); // 8% white

  // Neon glows
  static const Color glowPrimary = Color(0x336C63FF);
  static const Color glowSecondary = Color(0x3300D9F5);
  static const Color glowSuccess = Color(0x3310B981);
  static const Color glowDanger = Color(0x33EF4444);

  // Code editor
  static const Color codeBackground = Color(0xFF0A0A0A);
  static const Color lineNumbers = Color(0xFF4A5568);

  // Syntax highlighting
  static const Color syntaxKey = Color(0xFF569CD6);
  static const Color syntaxString = Color(0xFFCE9178);
  static const Color syntaxNumber = Color(0xFFB5CEA8);
  static const Color syntaxBool = Color(0xFFC586C0);
  static const Color syntaxNull = Color(0xFF569CD6);
  static const Color syntaxPunctuation = Color(0xFFD4D4D4);

  // Glass panel
  static Color get glassSurface => Colors.white.withOpacity(0.04);
  static Color get glassBorder => Colors.white.withOpacity(0.08);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0x1A000000); // 10% black
}

extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get adaptiveBackground => isDarkMode ? AppColors.background : AppColors.backgroundLight;
  Color get adaptiveSurface => isDarkMode ? AppColors.surface : AppColors.surfaceLight;
  Color get adaptiveCard => isDarkMode ? AppColors.card : AppColors.cardLight;
  Color get adaptiveCardBorder => isDarkMode ? AppColors.cardBorder : AppColors.cardBorderLight;
  Color get adaptiveTextPrimary => isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryLight;
  Color get adaptiveTextSecondary => isDarkMode ? AppColors.textSecondary : AppColors.textSecondaryLight;

  // Glass surfaces are tuned for dark UI by default; adapt them for light theme.
  Color get adaptiveGlassSurface =>
      isDarkMode ? AppColors.glassSurface : Colors.black.withOpacity(0.04);
  Color get adaptiveGlassBorder =>
      isDarkMode ? AppColors.glassBorder : Colors.black.withOpacity(0.08);

  // Common frosted/overlay backgrounds (app bars, sheets, toasts).
  Color get adaptiveOverlayBackground => adaptiveBackground.withOpacity(0.7);
  Color get adaptiveOverlaySurface =>
      adaptiveSurface.withOpacity(isDarkMode ? 0.85 : 0.95);

  // App bar header: solid in light theme (avoids black/washed blur), frosted in dark.
  Color get adaptiveAppBarBackground =>
      isDarkMode ? adaptiveBackground.withOpacity(0.85) : AppColors.surfaceLight;
}
