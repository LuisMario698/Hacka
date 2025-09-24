import 'package:flutter/material.dart';

/// Define la paleta de colores y el tema principal de la app móvil.
ThemeData temaSeguro() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF1B263B),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF1B263B),
      secondary: Color(0xFF415A77),
      background: Color(0xFF0D1B2A),
      surface: Color(0xFF1B263B),
      error: Color(0xFFE63946),
    ),
    scaffoldBackgroundColor: Color(0xFF0D1B2A),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1B263B),
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Color(0xFF1B263B),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF415A77),
    ),
  );
}
