import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primaryDark = Color(0xFF0A0E1A);
  static const Color _secondaryDark = Color(0xFF151923);
  static const Color _surfaceDark = Color(0xFF1A1F2E);
  static const Color _cardDark = Color(0xFF1E2538);
  
  static const Color _neonGreen = Color(0xFF00FF88);
  static const Color _neonOrange = Color(0xFFFF6B35);
  static const Color _neonBlue = Color(0xFF00D4FF);
  static const Color _neonPurple = Color(0xFFB832FF);
  
  static const Color _accentGreen = Color(0xFF2ECC71);
  static const Color _accentOrange = Color(0xFFE67E22);
  static const Color _accentRed = Color(0xFFE74C3C);
  static const Color _accentBlue = Color(0xFF3498DB);
  static const Color darkBackground = _primaryDark;
  static const Color surfaceColor = _surfaceDark;
  static const Color surfaceDark = _surfaceDark;
  static const Color primaryDark = _primaryDark;
  static const Color secondaryDark = _secondaryDark;
  static const Color cardDark = _cardDark;
  
  static const Color neonGreen = _neonGreen;
  static const Color neonOrange = _neonOrange;
  static const Color neonBlue = _neonBlue;
  static const Color neonPurple = _neonPurple;
  
  static const Color accentGreen = _accentGreen;
  static const Color accentOrange = _accentOrange;
  static const Color accentRed = _accentRed;
  static const Color accentBlue = _accentBlue;

  // Aliases for startup and legacy UI references
  static const Color darkSurface = surfaceDark;
  static const Color primaryColor = neonGreen;
  static const Color textSecondary = Color(0xB3FFFFFF);
  static const Color textTertiary = Color(0x80FFFFFF);
  static const List<Color> primaryGradient = [neonGreen, neonBlue];

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: _neonGreen,
      secondary: _neonOrange,
      surface: _surfaceDark,
      error: _accentRed,
      onPrimary: _primaryDark,
      onSecondary: _primaryDark,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: _primaryDark,
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: _secondaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: _cardDark,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _neonGreen.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _neonGreen,
        foregroundColor: _primaryDark,
        elevation: 0,
        shadowColor: _neonGreen.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _neonGreen,
        side: const BorderSide(color: _neonGreen, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _neonGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _neonGreen.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _neonGreen.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _neonGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accentRed, width: 2),
      ),
      labelStyle: const TextStyle(
        color: Colors.white70,
        fontFamily: 'Inter',
      ),
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontFamily: 'Inter',
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _secondaryDark,
      selectedItemColor: _neonGreen,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      titleSmall: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      bodySmall: TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      labelLarge: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      labelMedium: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
      labelSmall: TextStyle(
        color: Colors.white70,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.1),
      thickness: 1,
      space: 1,
    ),
    
    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _neonGreen;
        }
        return Colors.white54;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _neonGreen.withValues(alpha: 0.3);
        }
        return Colors.white.withValues(alpha: 0.1);
      }),
    ),
    
    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _neonGreen;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(_primaryDark),
      side: const BorderSide(color: _neonGreen, width: 2),
    ),
    
    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _neonGreen;
        }
        return Colors.white54;
      }),
    ),
    
    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _neonGreen,
      linearTrackColor: _surfaceDark,
      circularTrackColor: _surfaceDark,
    ),
    
    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: _neonGreen,
      inactiveTrackColor: _surfaceDark,
      thumbColor: _neonGreen,
      overlayColor: _neonGreen.withValues(alpha: 0.2),
      valueIndicatorColor: _neonGreen,
      valueIndicatorTextStyle: const TextStyle(
        color: _primaryDark,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: _surfaceDark,
      selectedColor: _neonGreen.withValues(alpha: 0.2),
      disabledColor: Colors.white.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'Inter',
      ),
      brightness: Brightness.dark,
      side: BorderSide(color: _neonGreen.withValues(alpha: 0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: _cardDark,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _neonGreen.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Inter',
      ),
    ),
    
    // FloatingActionButton Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _neonGreen,
      foregroundColor: _primaryDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );


}
