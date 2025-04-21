import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final _baseTextStyle = GoogleFonts.plusJakartaSans(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.normal,
  );

  // Headings
  static final displayLarge = _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static final displayMedium = _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final displaySmall = _baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Titles
  static final titleLarge = _baseTextStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final titleMedium = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Body text
  static final bodyLarge = _baseTextStyle.copyWith(
    fontSize: 16,
    height: 1.5,
  );

  static final bodyMedium = _baseTextStyle.copyWith(
    fontSize: 14,
    height: 1.5,
  );

  static final bodySmall = _baseTextStyle.copyWith(
    fontSize: 12,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Labels
  static final labelSmall = _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // Financial/billing specific styles
  static final amountLarge = _baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static final amountMedium = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static final tableHeader = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static final tableCell = _baseTextStyle.copyWith(
    fontSize: 14,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
