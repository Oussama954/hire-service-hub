import 'package:e_commerce/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A utility class that provides text styles using the app's color scheme
/// with appropriate gray colors for a clean, professional look
class AppTextStyles {
  // Primary styles (using dark gray)
  static TextStyle heading({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: isDark ? Colors.white : AppTheme.darkGrey,
  );
  
  static TextStyle subheading({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: isDark ? Colors.white : AppTheme.darkGrey,
  );
  
  static TextStyle body({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: isDark ? Colors.white70 : AppTheme.mediumGrey,
  );
  
  // Secondary styles (using medium gray)
  static TextStyle label({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? Colors.white70 : AppTheme.mediumGrey,
  );
  
  static TextStyle caption({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: isDark ? Colors.white60 : Colors.grey[500],
  );
  
  // Special styles
  static TextStyle price({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppTheme.accentText,
  );
  
  static TextStyle buttonText({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Status styles
  static TextStyle success({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.success,
  );
  
  static TextStyle error({bool isDark = false}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppTheme.error,
  );
}
