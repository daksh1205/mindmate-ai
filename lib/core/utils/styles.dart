import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppStyles {
  // Font Family
  static TextStyle get baseTextStyle => GoogleFonts.plusJakartaSans();

  // Headings
  static TextStyle get heading1 => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    color: AppColors.textWhite,
  );

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textWhite,
  );

  static TextStyle get heading3 => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.textWhite,
  );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textWhite70,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
  );

  // Button Text
  static TextStyle get buttonLarge => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  static TextStyle get buttonMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // Logo/Brand Text
  static TextStyle get logoText => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textWhite,
  );

  // Border Radius
  static BorderRadius get radiusSmall => BorderRadius.circular(16);
  static BorderRadius get radiusMedium => BorderRadius.circular(24);
  static BorderRadius get radiusLarge => BorderRadius.circular(32);
  static BorderRadius get radiusXLarge => BorderRadius.circular(40);
  static BorderRadius get radiusFull => BorderRadius.circular(9999);

  // Shadows
  static List<BoxShadow> get shadowSoft => [
    BoxShadow(color: AppColors.blackOverlay20, blurRadius: 10, spreadRadius: 0),
  ];

  static List<BoxShadow> get shadowMedium => [
    BoxShadow(color: AppColors.blackOverlay30, blurRadius: 30, spreadRadius: 5),
  ];

  // Input Decorations
  static InputDecoration getInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: AppColors.textWhite60,
        fontSize: 14,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.whiteOverlay10,
      border: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: AppColors.whiteOverlay10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: AppColors.whiteOverlay10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.primaryContent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: radiusMedium),
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  );

  static ButtonStyle get secondaryButtonStyle => TextButton.styleFrom(
    foregroundColor: AppColors.textWhite60,
    shape: RoundedRectangleBorder(borderRadius: radiusMedium),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  );
}
