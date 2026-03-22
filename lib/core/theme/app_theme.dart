import 'package:flutter/material.dart';

/// App Theme - Light and Dark Themes for LifeSync
/// 
/// Design Philosophy:
/// - Clean, minimal design
/// - Calming colors (indigo/purple accent)
/// - High contrast for readability
/// - Consistent spacing and typography

class AppTheme {
  // ==================== COLORS ====================
  
  // Primary Colors
  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF818CF8);
  
  // Secondary Colors
  static const Color secondaryLight = Color(0xFF7C3AED);
  static const Color secondaryDark = Color(0xFFA78BFA);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentYellow = Color(0xFFEAB308);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F172A);
  
  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // ==================== LIGHT THEME ====================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.light(
        primary: primaryLight,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE0E7FF),
        secondary: secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFEDE9FE),
        tertiary: secondaryLight,
        error: accentRed,
        surface: surfaceLight,
        onSurface: const Color(0xFF0F172A),
        surfaceContainerHighest: const Color(0xFFF1F5F9),
      ),
      
      scaffoldBackgroundColor: backgroundLight,
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceLight,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: surfaceLight,
        selectedItemColor: primaryLight,
        unselectedItemColor: Color(0xFF64748B),
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // ==================== DARK THEME ====================
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        onPrimary: const Color(0xFF1E1B4B),
        primaryContainer: const Color(0xFF312E81),
        secondary: secondaryDark,
        onSecondary: const Color(0xFF2E1065),
        tertiary: secondaryDark,
        error: const Color(0xFFF87171),
        surface: surfaceDark,
        onSurface: const Color(0xFFF8FAFC),
        surfaceContainerHighest: const Color(0xFF334155),
      ),
      
      scaffoldBackgroundColor: backgroundDark,
      
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF8FAFC),
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceDark,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: surfaceDark,
        selectedItemColor: primaryDark,
        unselectedItemColor: Color(0xFF94A3B8),
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: surfaceDark,
      ),
      
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // ==================== HELPER METHODS ====================
  
  /// Get entry type color
  static Color getEntryTypeColor(String type) {
    const colors = {
      'note': Color(0xFF3B82F6),
      'mood': Color(0xFFEAB308),
      'photo': Color(0xFFA855F7),
      'audio': Color(0xFFEC4899),
      'workout': Color(0xFF22C55E),
      'gratitude': Color(0xFFF43F5E),
      'goal': Color(0xFF6366F1),
      'checkin': Color(0xFF14B8A6),
    };
    return colors[type] ?? const Color(0xFF64748B);
  }
  
  /// Get streak color
  static Color getStreakColor(int streak) {
    if (streak >= 30) return const Color(0xFFEF4444);
    if (streak >= 14) return const Color(0xFFF97316);
    if (streak >= 7) return const Color(0xFFEAB308);
    if (streak >= 3) return const Color(0xFF22C55E);
    return const Color(0xFF64748B);
  }
  
  /// Get mood color (1-5)
  static Color getMoodColor(int mood) {
    const colors = {
      1: Color(0xFFEF4444),
      2: Color(0xFFF97316),
      3: Color(0xFFEAB308),
      4: Color(0xFF22C55E),
      5: Color(0xFF10B981),
    };
    return colors[mood] ?? const Color(0xFF64748B);
  }
}
