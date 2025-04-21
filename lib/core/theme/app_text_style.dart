import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get _baseTextStyle => GoogleFonts.plusJakartaSans();

  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF362828),
      );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF362828),
      );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
        fontSize: 14,
        color: const Color(0xFF362828),
      );

  static TextStyle get titleLarge => _baseTextStyle.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
        fontSize: 22,
        color: Colors.black,
      );

  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 14,
        color: Colors.black,
      );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 12,
        color: Colors.black54,
      );
}
