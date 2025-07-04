import 'package:flutter/material.dart';

class AppColors {
  // Colores modo claro
  static const Color primaryColor = Color(0xFF2E3A2F);
  static const Color secondaryColor = Color(0xFFF5F7F4);
  static const Color accentColor = Color(0xFF379D3A);
  static const Color accentLight = Color(0xFF81C784);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF5F5F5F);
  static const Color borderColor = Color(0xFFDDE2DC);
  static const Color shadowColor = Color(0x0D000000); // rgba(0, 0, 0, 0.05)

  // Colores modo oscuro
  static const Color primaryColorDark = Color(0xFFF5F7F4);
  static const Color secondaryColorDark = Color(0xFF111511);
  static const Color accentColorDark = Color(0xFF73D078);
  static const Color accentLightDark = Color(0xFFA5D6A7);
  static const Color backgroundDark = Color(0xFF111311);
  static const Color textPrimaryDark = Color(0xFFF0F3EF);
  static const Color textSecondaryDark = Color(0xFFAAB1A9);
  static const Color borderColorDark = Color(0xFF3C4A3E);
  static const Color shadowColorDark = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Esquema de colores principal
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.accentColor,
        surface: AppColors.backgroundLight,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.secondaryColor,
        onSecondary: AppColors.backgroundLight,
        outline: AppColors.borderColor,
        surfaceContainerHighest: AppColors.secondaryColor,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        elevation: 2,
        shadowColor: AppColors.shadowColor,
        titleTextStyle: const TextStyle(
          color: AppColors.secondaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.secondaryColor,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.backgroundLight,
        shadowColor: AppColors.shadowColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),

      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          foregroundColor: AppColors.backgroundLight,
          elevation: 2,
          shadowColor: AppColors.shadowColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Text Button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),

      // Icon Button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.accentColor,
        ),
      ),

      // Input Decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.accentColor, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textSecondary),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
        labelLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: AppColors.textSecondary),
        labelSmall: TextStyle(color: AppColors.textSecondary),
      ),

      // List Tile theme
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.accentColor,
      ),

      // Floating Action Button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentColor,
        foregroundColor: AppColors.backgroundLight,
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.backgroundLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryColor,
        contentTextStyle: const TextStyle(color: AppColors.secondaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Esquema de colores principal
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryColorDark,
        secondary: AppColors.accentColorDark,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.textPrimaryDark,
        onPrimary: AppColors.secondaryColorDark,
        onSecondary: AppColors.backgroundDark,
        outline: AppColors.borderColorDark,
        surfaceContainerHighest: AppColors.secondaryColorDark,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondaryColorDark,
        foregroundColor: AppColors.primaryColorDark,
        elevation: 2,
        shadowColor: AppColors.shadowColorDark,
        titleTextStyle: const TextStyle(
          color: AppColors.primaryColorDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primaryColorDark,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: AppColors.secondaryColorDark,
        shadowColor: AppColors.shadowColorDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderColorDark, width: 1),
        ),
      ),

      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColorDark,
          foregroundColor: AppColors.backgroundDark,
          elevation: 2,
          shadowColor: AppColors.shadowColorDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Text Button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentColorDark,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),

      // Icon Button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.accentColorDark,
        ),
      ),

      // Input Decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.secondaryColorDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.accentColorDark, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondaryDark),
        hintStyle: TextStyle(color: AppColors.textSecondaryDark),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark),
        labelLarge: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: AppColors.textSecondaryDark),
        labelSmall: TextStyle(color: AppColors.textSecondaryDark),
      ),

      // List Tile theme
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textPrimaryDark,
        iconColor: AppColors.accentColorDark,
      ),

      // Floating Action Button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentColorDark,
        foregroundColor: AppColors.backgroundDark,
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 16,
        ),
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondaryColorDark,
        contentTextStyle: const TextStyle(color: AppColors.primaryColorDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
