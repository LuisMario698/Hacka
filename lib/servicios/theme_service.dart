import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el tema de la aplicación (claro/oscuro)
/// Persiste la preferencia del usuario y notifica cambios.
class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  static const String _themeKey = 'isDarkMode';

  /// Inicializa el servicio cargando la preferencia guardada
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  /// Cambia el tema y guarda la preferencia
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  /// Establece un tema específico
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
      notifyListeners();
    }
  }

  /// Tema claro accesible
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF2E7D32), // Verde oscuro accesible
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2E7D32), // Verde para seguridad
        secondary: Color(0xFF1976D2), // Azul para confianza
        background: Color(0xFFF5F5F5), // Gris muy claro para descanso visual
        surface: Color(0xFFFFFFFF), // Blanco puro para contraste
        error: Color(0xFFD32F2F), // Rojo accesible
        onPrimary: Color(0xFFFFFFFF), // Blanco sobre verde
        onSecondary: Color(0xFFFFFFFF), // Blanco sobre azul
        onBackground: Color(0xFF212121), // Negro suave sobre fondo
        onSurface: Color(0xFF212121), // Negro suave sobre superficies
        onError: Color(0xFFFFFFFF), // Blanco sobre rojo
      ),
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        elevation: 2,
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white, size: 28),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: Color(0xFF212121), fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Color(0xFF212121), fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Color(0xFF212121), fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Color(0xFF212121), fontSize: 18, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Color(0xFF212121), fontSize: 18),
        bodyMedium: TextStyle(color: Color(0xFF424242), fontSize: 16),
        labelLarge: TextStyle(color: Color(0xFF212121), fontSize: 16, fontWeight: FontWeight.w500),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Color(0xFF2E7D32),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: Size(120, 56),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      iconTheme: IconThemeData(
        color: Color(0xFF2E7D32),
        size: 28,
      ),
    );
  }

  /// Tema oscuro original
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF1B263B),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF1B263B),
        secondary: Color(0xFF415A77),
        background: Color(0xFF0D1B2A),
        surface: Color(0xFF1B263B),
        error: Color(0xFFE63946),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: Color(0xFF0D1B2A),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1B263B),
        elevation: 0,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white, size: 28),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
        labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: Color(0xFF1B263B),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF415A77),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF415A77),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: Size(120, 56),
        ),
      ),
      cardTheme: CardThemeData(
        color: Color(0xFF1B263B),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Retorna el tema actual según la preferencia del usuario
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
}