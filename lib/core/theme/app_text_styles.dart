import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  final BuildContext context;
  
  const AppTextStyles(this.context);

  Color get _primary => context.adaptiveTextPrimary;
  Color get _secondary => context.adaptiveTextSecondary;
  Color get _muted => context.isDarkMode ? AppColors.textMuted : AppColors.textSecondaryLight;
  Color get _onPrimary => AppColors.textOnPrimary;

  // --- Display / Heading (Inter) ---
  TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: _primary,
    letterSpacing: -0.5,
  );

  TextStyle get displayMedium => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: _primary,
    letterSpacing: -0.3,
  );

  TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: _primary,
    letterSpacing: -0.2,
  );

  TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: _primary,
  );

  TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: _primary,
  );

  // --- Body (Inter) ---
  TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: _secondary,
  );

  TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: _secondary,
  );

  TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: _muted,
  );

  TextStyle get label => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: _secondary,
    letterSpacing: 0.1,
  );

  TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: _muted,
    letterSpacing: 0.5,
  );

  TextStyle get caption => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _muted,
  );

  TextStyle get button => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: _onPrimary,
  );

  TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: _onPrimary,
  );

  // --- Code (JetBrains Mono) ---
  TextStyle get code => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: _primary,
    height: 1.6,
  );

  TextStyle get codeMedium => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: _primary,
  );

  TextStyle get codeBold => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: _primary,
  );

  TextStyle get codeSmall => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: _secondary,
    height: 1.5,
  );

  TextStyle get lineNumber => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.lineNumbers,
  );

  // --- Syntax ---
  TextStyle get syntaxKey => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxKey,
    height: 1.6,
  );

  TextStyle get syntaxString => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxString,
    height: 1.6,
  );

  TextStyle get syntaxNumber => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxNumber,
    height: 1.6,
  );

  TextStyle get syntaxBool => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: AppColors.syntaxBool,
    height: 1.6,
  );
}

extension AppTextStylesContext on BuildContext {
  AppTextStyles get textStyles => AppTextStyles(this);
}
