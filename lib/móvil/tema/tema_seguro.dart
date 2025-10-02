import 'package:flutter/material.dart';
import '../../servicios/theme_service.dart';

/// Define la paleta de colores que se adapta al tema seleccionado por el usuario.
/// Soporta tanto tema claro (accesible) como tema oscuro (original).
ThemeData temaSeguro({bool? isDarkMode}) {
  // Si no se especifica, usar la preferencia del ThemeService
  final themeService = ThemeService();
  final useDarkMode = isDarkMode ?? themeService.isDarkMode;
  
  if (useDarkMode) {
    return ThemeService.darkTheme;
  } else {
    return ThemeService.lightTheme;
  }
}
