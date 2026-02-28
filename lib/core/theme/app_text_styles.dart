import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// All text styles are static final — computed ONCE at startup,
/// never re-allocated on every build() frame.
class AppTextStyles {
  AppTextStyles._();

  // --- Display / Heading (Inter) ---
  static final TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static final TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static final TextStyle heading1 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static final TextStyle heading2 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle heading3 = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- Body (Inter) ---
  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static final TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  static final TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static final TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textOnPrimary,
  );

  static final TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: AppColors.textOnPrimary,
  );

  // --- Code (JetBrains Mono) ---
  static final TextStyle code = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static final TextStyle codeMedium = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static final TextStyle codeBold = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle codeSmall = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static final TextStyle lineNumber = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.lineNumbers,
  );

  // --- Syntax ---
  static final TextStyle syntaxKey = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxKey,
    height: 1.6,
  );

  static final TextStyle syntaxString = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxString,
    height: 1.6,
  );

  static final TextStyle syntaxNumber = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxNumber,
    height: 1.6,
  );

  static final TextStyle syntaxBool = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxBool,
    height: 1.6,
  );
}
