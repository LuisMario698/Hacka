import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tema_profesional.dart';

/// Servicio para gestionar el tema de la aplicación
/// Maneja el cambio entre modo claro y oscuro con persistencia
class ServicioTema extends ChangeNotifier {
  static const String _keyTema = 'tema_oscuro';
  static const String _keyTamanoFuente = 'tamano_fuente';
  static const String _keyContrasteAlto = 'contraste_alto';
  
  bool _esTemaOscuro = false;
  double _factorTamanoFuente = 1.0;
  bool _contrasteAlto = false;
  
  // Singleton
  static final ServicioTema _instancia = ServicioTema._interno();
  factory ServicioTema() => _instancia;
  ServicioTema._interno();
  
  // Getters
  bool get esTemaOscuro => _esTemaOscuro;
  double get factorTamanoFuente => _factorTamanoFuente;
  bool get contrasteAlto => _contrasteAlto;
  
  /// Inicializar el servicio cargando preferencias guardadas
  Future<void> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    
    _esTemaOscuro = prefs.getBool(_keyTema) ?? false;
    _factorTamanoFuente = prefs.getDouble(_keyTamanoFuente) ?? 1.0;
    _contrasteAlto = prefs.getBool(_keyContrasteAlto) ?? false;
    
    // Actualizar el sistema de colores
    PaletaProfesional.setTemaOscuro(_esTemaOscuro);
    
    notifyListeners();
  }
  
  /// Cambiar entre tema claro y oscuro
  Future<void> cambiarTema([bool? forzarOscuro]) async {
    _esTemaOscuro = forzarOscuro ?? !_esTemaOscuro;
    
    // Actualizar el sistema de colores
    PaletaProfesional.setTemaOscuro(_esTemaOscuro);
    
    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTema, _esTemaOscuro);
    
    notifyListeners();
  }
  
  /// Cambiar el tamaño de fuente
  Future<void> cambiarTamanoFuente(double factor) async {
    _factorTamanoFuente = factor.clamp(0.8, 1.5);
    
    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTamanoFuente, _factorTamanoFuente);
    
    notifyListeners();
  }
  
  /// Alternar contraste alto
  Future<void> alternarContrasteAlto() async {
    _contrasteAlto = !_contrasteAlto;
    
    // Guardar preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyContrasteAlto, _contrasteAlto);
    
    notifyListeners();
  }
  
  /// Obtener el tema claro de la aplicación
  ThemeData get temaClaro {
    return _crearTema(false);
  }
  
  /// Obtener el tema oscuro de la aplicación
  ThemeData get temaOscuro {
    return _crearTema(true);
  }
  
  /// Obtener el tema actual basado en la configuración
  ThemeData get temaActual {
    return _esTemaOscuro ? temaOscuro : temaClaro;
  }
  
  /// Crear tema personalizado
  ThemeData _crearTema(bool esOscuro) {
    // Actualizar temporalmente el sistema de colores para obtener los colores correctos
    PaletaProfesional.setTemaOscuro(esOscuro);
    
    final ColorScheme esquemaColores = esOscuro
        ? ColorScheme.dark(
            primary: SistemaColores.primario,
            primaryContainer: SistemaColores.primarioOscuro,
            secondary: SistemaColores.secundario,
            secondaryContainer: SistemaColores.secundarioOscuro,
            surface: PaletaOscura.superficie,
            background: PaletaOscura.fondo,
            error: SistemaColores.error,
            onPrimary: PaletaOscura.textoEnPrimario,
            onSecondary: PaletaOscura.textoEnPrimario,
            onSurface: PaletaOscura.textoPrimario,
            onBackground: PaletaOscura.textoPrimario,
            onError: Colors.white,
            outline: PaletaOscura.borde,
            surfaceVariant: PaletaOscura.superficieElevada,
          )
        : ColorScheme.light(
            primary: SistemaColores.primario,
            primaryContainer: SistemaColores.primarioClaro,
            secondary: SistemaColores.secundario,
            secondaryContainer: SistemaColores.secundarioClaro,
            surface: PaletaClara.superficie,
            background: PaletaClara.fondo,
            error: SistemaColores.error,
            onPrimary: PaletaClara.textoEnPrimario,
            onSecondary: PaletaClara.textoEnPrimario,
            onSurface: PaletaClara.textoPrimario,
            onBackground: PaletaClara.textoPrimario,
            onError: Colors.white,
            outline: PaletaClara.borde,
            surfaceVariant: PaletaClara.superficie,
          );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquemaColores,
      brightness: esOscuro ? Brightness.dark : Brightness.light,
      
      // Configuración de fuentes
      fontFamily: TipografiaProfesional.fontFamily,
      textTheme: _crearTemaTexto(esOscuro),
      
      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: PaletaProfesional.superficie,
        foregroundColor: PaletaProfesional.textoPrimario,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: PaletaProfesional.textoPrimario,
          fontSize: TipografiaProfesional.h4 * _factorTamanoFuente,
          fontWeight: TipografiaProfesional.semibold,
          fontFamily: TipografiaProfesional.fontFamily,
        ),
        iconTheme: IconThemeData(
          color: PaletaProfesional.textoPrimario,
          size: 24,
        ),
      ),
      
      // Tarjetas
      cardTheme: CardThemeData(
        elevation: 0,
        color: PaletaProfesional.fondoTarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          side: BorderSide(color: PaletaProfesional.divider, width: 1),
        ),
        shadowColor: PaletaProfesional.sombraLigera,
        margin: EdgeInsets.symmetric(
          horizontal: EspaciadoProfesional.md,
          vertical: EspaciadoProfesional.sm,
        ),
      ),
      
      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: SistemaColores.primario,
          foregroundColor: Colors.white,
          disabledBackgroundColor: PaletaProfesional.deshabilitado,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: EspaciadoProfesional.lg,
            vertical: EspaciadoProfesional.md,
          ),
          textStyle: TextStyle(
            fontSize: TipografiaProfesional.button * _factorTamanoFuente,
            fontWeight: TipografiaProfesional.medium,
          ),
        ),
      ),
      
      // Botones con borde
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: SistemaColores.primario,
          side: BorderSide(color: SistemaColores.primario, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: EspaciadoProfesional.lg,
            vertical: EspaciadoProfesional.md,
          ),
          textStyle: TextStyle(
            fontSize: TipografiaProfesional.button * _factorTamanoFuente,
            fontWeight: TipografiaProfesional.medium,
          ),
        ),
      ),
      
      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SistemaColores.primario,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: EspaciadoProfesional.md,
            vertical: EspaciadoProfesional.sm,
          ),
          textStyle: TextStyle(
            fontSize: TipografiaProfesional.button * _factorTamanoFuente,
            fontWeight: TipografiaProfesional.medium,
          ),
        ),
      ),
      
      // Campos de entrada
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PaletaProfesional.superficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          borderSide: BorderSide(color: PaletaProfesional.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          borderSide: BorderSide(color: PaletaProfesional.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          borderSide: BorderSide(color: SistemaColores.primario, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.md),
          borderSide: BorderSide(color: SistemaColores.error, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: EspaciadoProfesional.md,
          vertical: EspaciadoProfesional.md,
        ),
      ),
      
      // Navegación inferior
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: PaletaProfesional.superficie,
        elevation: 8,
        selectedItemColor: SistemaColores.primario,
        unselectedItemColor: PaletaProfesional.textoTerciario,
      ),
      
      // Diálogos
      dialogTheme: DialogThemeData(
        backgroundColor: PaletaProfesional.superficie,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.lg),
        ),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PaletaProfesional.textoPrimario,
        contentTextStyle: TextStyle(
          color: PaletaProfesional.superficie,
          fontSize: TipografiaProfesional.body2 * _factorTamanoFuente,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiosProfesionales.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: PaletaProfesional.fondoApp,
    );
  }
  
  /// Crear tema de texto adaptativo
  TextTheme _crearTemaTexto(bool esOscuro) {
    final Color colorTexto = esOscuro ? PaletaOscura.textoPrimario : PaletaClara.textoPrimario;
    final Color colorTextoSecundario = esOscuro ? PaletaOscura.textoSecundario : PaletaClara.textoSecundario;
    final Color colorTextoTerciario = esOscuro ? PaletaOscura.textoTerciario : PaletaClara.textoTerciario;
    
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: TipografiaProfesional.h1 * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.bold,
        color: colorTexto,
        height: TipografiaProfesional.lineHeightTight,
      ),
      displayMedium: TextStyle(
        fontSize: TipografiaProfesional.h2 * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.semibold,
        color: colorTexto,
        height: TipografiaProfesional.lineHeightTight,
      ),
      displaySmall: TextStyle(
        fontSize: TipografiaProfesional.h3 * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.semibold,
        color: colorTexto,
        height: TipografiaProfesional.lineHeightNormal,
      ),
      headlineLarge: TextStyle(
        fontSize: TipografiaProfesional.h4 * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.medium,
        color: colorTexto,
        height: TipografiaProfesional.lineHeightNormal,
      ),
      bodyLarge: TextStyle(
        fontSize: TipografiaProfesional.body1 * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.regular,
        color: colorTexto,
        height: TipografiaProfesional.lineHeightRelaxed,
      ),
      bodyMedium: TextStyle(
        fontSize: TipografiaProfesional.body2 * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.regular,
        color: colorTextoSecundario,
        height: TipografiaProfesional.lineHeightRelaxed,
      ),
      bodySmall: TextStyle(
        fontSize: TipografiaProfesional.caption * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.regular,
        color: colorTextoTerciario,
        height: TipografiaProfesional.lineHeightNormal,
      ),
      labelLarge: TextStyle(
        fontSize: TipografiaProfesional.button * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.medium,
        color: colorTexto,
        height: TipografiaProfesional.lineHeightNormal,
      ),
      labelMedium: TextStyle(
        fontSize: TipografiaProfesional.body2 * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.medium,
        color: colorTextoSecundario,
        height: TipografiaProfesional.lineHeightNormal,
      ),
      labelSmall: TextStyle(
        fontSize: TipografiaProfesional.caption * _factorTamanoFuente,
        fontWeight: TipografiaProfesional.medium,
        color: colorTextoTerciario,
        height: TipografiaProfesional.lineHeightNormal,
      ),
    );
  }
  

}