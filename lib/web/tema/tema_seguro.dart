import 'package:flutter/material.dart';
import '../../servicios/theme_service.dart';

/// Define la paleta de colores que se adapta al tema seleccionado por el usuario.
/// Soporta tanto tema claro (accesible) como tema oscuro (original) para web.
ThemeData temaSeguro({bool? isDarkMode}) {
  // Si no se especifica, usar la preferencia del ThemeService
  final themeService = ThemeService();
  final useDarkMode = isDarkMode ?? themeService.isDarkMode;
  
  // Tema web con estilos específicos para dashboard
  final baseTheme = useDarkMode ? ThemeService.darkTheme : ThemeService.lightTheme;
  
  // Personalizar para web con tamaños más grandes
  return baseTheme.copyWith(
    appBarTheme: baseTheme.appBarTheme.copyWith(
      titleTextStyle: TextStyle(
        fontSize: 26, 
        fontWeight: FontWeight.w600, 
        color: Colors.white
      ),
      iconTheme: IconThemeData(color: Colors.white, size: 30),
    ),
    textTheme: baseTheme.textTheme.copyWith(
      headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(fontSize: 34),
      headlineMedium: baseTheme.textTheme.headlineMedium?.copyWith(fontSize: 30),
      titleLarge: baseTheme.textTheme.titleLarge?.copyWith(fontSize: 24),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(fontSize: 20),
      labelLarge: baseTheme.textTheme.labelLarge?.copyWith(fontSize: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: baseTheme.elevatedButtonTheme.style?.copyWith(
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 28, vertical: 18)),
        minimumSize: MaterialStateProperty.all(Size(140, 60)),
      ),
    ),
    cardTheme: baseTheme.cardTheme.copyWith(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    iconTheme: baseTheme.iconTheme.copyWith(size: 32),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: TextStyle(
        color: useDarkMode ? Colors.white : Color(0xFF212121),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: TextStyle(
        color: useDarkMode ? Colors.white70 : Color(0xFF424242),
        fontSize: 16,
      ),
      headingRowColor: MaterialStateProperty.all(
        useDarkMode ? Colors.white.withOpacity(0.1) : Color(0xFFE8F5E8)
      ),
      dataRowColor: MaterialStateProperty.all(
        useDarkMode ? Color(0xFF1B263B) : Colors.white
      ),
    ),
  );
}
