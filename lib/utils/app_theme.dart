import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary brand color - MonShift teal/turquoise
  static Color primaryColor = const Color(0xFF58B7B3); 
  
  // Secondary colors
  static Color secondaryColor = const Color(0xFFFFA62B); // Orange accent for CTAs
  static Color accentText = const Color(0xFF333333); // Dark gray for headings
  
  // Neutral colors
  static Color darkGrey = const Color(0xFF333333); // Dark gray text color
  static Color mediumGrey = const Color(0xFF757575); // Medium gray for secondary text
  static Color lightGrey = const Color(0xFFF5F5F5); // Background, form fields
  static Color surfaceColor = const Color(0xFFFFFFFF); // Card surfaces
  
  // Dark theme colors
  static Color darkSurface = const Color(0xFF1E2429); // Dark gray for widgets in dark mode
  static Color darkBackground = const Color(0xFF000000); // Pure black for dark mode background
  
  // Semantic colors
  static Color success = const Color(0xFF4CAF50);
  static Color warning = const Color(0xFFFFA62B); // Using the accent orange for warnings
  static Color error = const Color(0xFFF44336);
  static Color info = const Color(0xFF58B7B3); // Using primary color for info
  
  // Spacing system - reduced for tighter UI
  static const double spacing_xs = 2.0;
  
  // Backward compatibility for old color names
  static Color get fMainColor => primaryColor;
  static Color get fdarkBlue => darkSurface;
  static const double spacing_sm = 6.0;
  static const double spacing_md = 12.0;
  static const double spacing_lg = 18.0;
  static const double spacing_xl = 24.0;
  static const double spacing_xxl = 36.0;
  
  // Border radius - updated for MonShift rounded style
  static const double radius_sm = 8.0;
  static const double radius_md = 16.0;
  static const double radius_lg = 24.0;
  static const double radius_xl = 32.0;
  static const double radius_circle = 100.0;
  
  // Shadows - softer for MonShift clean look
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 3),
      spreadRadius: 1,
    ),
  ];
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: lightGrey,
      error: error,
    ),
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: darkGrey),
      titleTextStyle: GoogleFonts.poppins(
        color: darkGrey,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    brightness: Brightness.light,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: mediumGrey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 4,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_lg)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: BorderSide(color: primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_sm)),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_lg)),
    ),
    dividerTheme: DividerThemeData(
      color: lightGrey,
      thickness: 1,
      space: spacing_md,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor, // Using orange accent for buttons
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_md)),
        minimumSize: const Size(120, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_md)),
        minimumSize: const Size(120, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_md)),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(primaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: error, width: 1),
      ),
      hintStyle: TextStyle(color: mediumGrey, fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightGrey,
      selectedColor: primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: darkGrey),
      secondaryLabelStyle: TextStyle(color: primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_circle)),
    ),
    textTheme: _buildTextTheme(),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      background: darkBackground,
      error: error,
    ),
    scaffoldBackgroundColor: darkBackground,
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground, // Pure black background for AppBar
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white), // White icons
      actionsIconTheme: const IconThemeData(color: Colors.white), // White action icons
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      backgroundColor: darkBackground, // Pure black background for navigation
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white60),
    ),
    cardTheme: CardTheme(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius_lg)),
      shadowColor: Colors.white.withOpacity(0.05),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: darkBackground,
      elevation: 4.0,
      textStyle: const TextStyle(color: Colors.white),
      iconColor: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
      thickness: 1,
      space: spacing_md,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius_md),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      suffixIconColor: Colors.white70,
      prefixIconColor: Colors.white70,
    ),
    textTheme: _buildTextTheme(isDark: true),
  );

  // Build consistent text theme
  static TextTheme _buildTextTheme({bool isDark = false}) {
    final baseTextColor = isDark ? Colors.white : darkGrey; // White in dark mode, dark gray in light mode
    final secondaryTextColor = isDark ? Colors.white70 : mediumGrey; // Slightly transparent white in dark mode
    final accentTextColor = isDark ? Colors.white : accentText; // Pure white for important text in dark mode

    return GoogleFonts.interTextTheme( // Using Inter font for MonShift style
      TextTheme(
        displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accentTextColor),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: accentTextColor),
        displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentTextColor),
        
        headlineLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: accentTextColor),
        headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: accentTextColor),
        headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: accentTextColor),
        
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: baseTextColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: baseTextColor),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: baseTextColor),
        
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: baseTextColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: baseTextColor),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: secondaryTextColor),
        
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: baseTextColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: baseTextColor),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: secondaryTextColor),
      ),
    );
  }
}
