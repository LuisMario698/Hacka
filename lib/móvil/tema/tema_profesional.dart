import 'package:flutter/material.dart';

/// Sistema de colores profesional para Rutas Seguras
/// Paleta consistente para temas claro y oscuro
class SistemaColores {
  // Colores base de la marca
  static const Color primario = Color(0xFF1B5E20);          // Verde profesional
  static const Color primarioClaro = Color(0xFF4CAF50);     // Verde accesible
  static const Color primarioOscuro = Color(0xFF0D2818);    // Verde profundo
  
  static const Color secundario = Color(0xFF1565C0);        // Azul corporativo
  static const Color secundarioClaro = Color(0xFF42A5F5);   // Azul accesible
  static const Color secundarioOscuro = Color(0xFF0A3F7C);  // Azul profundo

  // Estados semánticos (consistentes en ambos temas)
  static const Color exito = Color(0xFF2E7D32);             // Verde éxito
  static const Color advertencia = Color(0xFFEF6C00);       // Naranja advertencia
  static const Color error = Color(0xFFC62828);             // Rojo error
  static const Color info = Color(0xFF1976D2);              // Azul información
  static const Color offline = Color(0xFF757575);           // Gris neutral
}

/// Paleta específica para tema claro
class PaletaClara {
  // Superficies
  static const Color fondo = Color(0xFFFAFAFA);             // Fondo principal
  static const Color superficie = Color(0xFFFFFFFF);        // Tarjetas y elementos
  static const Color superficieElevada = Color(0xFFFFFFFF); // Elementos elevados
  
  // Bordes y divisores
  static const Color borde = Color(0xFFE0E0E0);            // Bordes principales
  static const Color bordeHover = Color(0xFFBDBDBD);       // Bordes en hover
  static const Color divider = Color(0xFFE0E0E0);          // Líneas divisorias
  
  // Texto
  static const Color textoPrimario = Color(0xFF212121);     // Texto principal
  static const Color textoSecundario = Color(0xFF616161);   // Texto secundario
  static const Color textoTerciario = Color(0xFF9E9E9E);    // Texto auxiliar
  static const Color textoDeshabilitado = Color(0xFFBDBDBD); // Texto deshabilitado
  static const Color textoEnPrimario = Color(0xFFFFFFFF);   // Texto sobre primario
  
  // Estados de componentes
  static const Color hover = Color(0xFFF5F5F5);            // Estado hover
  static const Color seleccionado = Color(0xFFE8F5E8);     // Estado seleccionado
  static const Color deshabilitado = Color(0xFFF5F5F5);    // Estado deshabilitado
  
  // Sombras
  static const Color sombra = Color(0x1A000000);           // Sombras principales
  static const Color sombraElevada = Color(0x33000000);    // Sombras elevadas
}

/// Paleta específica para tema oscuro
class PaletaOscura {
  // Superficies
  static const Color fondo = Color(0xFF121212);             // Fondo principal
  static const Color superficie = Color(0xFF1E1E1E);        // Tarjetas y elementos
  static const Color superficieElevada = Color(0xFF2C2C2C); // Elementos elevados
  
  // Bordes y divisores
  static const Color borde = Color(0xFF404040);            // Bordes principales
  static const Color bordeHover = Color(0xFF525252);       // Bordes en hover
  static const Color divider = Color(0xFF404040);          // Líneas divisorias
  
  // Texto
  static const Color textoPrimario = Color(0xFFE0E0E0);     // Texto principal
  static const Color textoSecundario = Color(0xFFB3B3B3);   // Texto secundario
  static const Color textoTerciario = Color(0xFF8C8C8C);    // Texto auxiliar
  static const Color textoDeshabilitado = Color(0xFF595959); // Texto deshabilitado
  static const Color textoEnPrimario = Color(0xFFFFFFFF);   // Texto sobre primario
  
  // Estados de componentes
  static const Color hover = Color(0xFF2C2C2C);            // Estado hover
  static const Color seleccionado = Color(0xFF1A2E1A);     // Estado seleccionado
  static const Color deshabilitado = Color(0xFF2C2C2C);    // Estado deshabilitado
  
  // Sombras
  static const Color sombra = Color(0x40000000);           // Sombras principales
  static const Color sombraElevada = Color(0x60000000);    // Sombras elevadas
}

/// Gradientes del sistema
class GradientesSistema {
  // Gradientes para tema claro
  static const LinearGradient primarioClaro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SistemaColores.primario, SistemaColores.primarioClaro],
  );
  
  static const LinearGradient secundarioClaro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SistemaColores.secundario, SistemaColores.secundarioClaro],
  );
  
  static const LinearGradient fondoClaro = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [PaletaClara.fondo, PaletaClara.superficie],
  );

  // Gradientes para tema oscuro
  static const LinearGradient primarioOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SistemaColores.primarioOscuro, SistemaColores.primario],
  );
  
  static const LinearGradient secundarioOscuro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SistemaColores.secundarioOscuro, SistemaColores.secundario],
  );
  
  static const LinearGradient fondoOscuro = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [PaletaOscura.fondo, PaletaOscura.superficie],
  );
}

/// Clase principal para acceder a los colores según el tema activo
class PaletaProfesional {
  static bool _esTemaOscuro = false;
  
  static void setTemaOscuro(bool esOscuro) {
    _esTemaOscuro = esOscuro;
  }
  
  // Colores de marca (consistentes)
  static Color get primario => SistemaColores.primario;
  static Color get primarioClaro => SistemaColores.primarioClaro;
  static Color get secundario => SistemaColores.secundario;
  static Color get secundarioClaro => SistemaColores.secundarioClaro;
  
  // Estados semánticos (consistentes)
  static Color get seguro => SistemaColores.exito;
  static Color get precaucion => SistemaColores.advertencia;
  static Color get peligro => SistemaColores.error;
  static Color get info => SistemaColores.info;
  static Color get offline => SistemaColores.offline;
  
  // Superficies (adaptativas)
  static Color get fondoApp => _esTemaOscuro ? PaletaOscura.fondo : PaletaClara.fondo;
  static Color get superficie => _esTemaOscuro ? PaletaOscura.superficie : PaletaClara.superficie;
  static Color get fondoTarjeta => _esTemaOscuro ? PaletaOscura.superficie : PaletaClara.superficie;
  static Color get superficieElevada => _esTemaOscuro ? PaletaOscura.superficieElevada : PaletaClara.superficieElevada;
  
  // Bordes y divisores (adaptivos)
  static Color get divider => _esTemaOscuro ? PaletaOscura.divider : PaletaClara.divider;
  static Color get borde => _esTemaOscuro ? PaletaOscura.borde : PaletaClara.borde;
  static Color get bordeHover => _esTemaOscuro ? PaletaOscura.bordeHover : PaletaClara.bordeHover;
  
  // Texto (adaptivo)
  static Color get textoPrimario => _esTemaOscuro ? PaletaOscura.textoPrimario : PaletaClara.textoPrimario;
  static Color get textoSecundario => _esTemaOscuro ? PaletaOscura.textoSecundario : PaletaClara.textoSecundario;
  static Color get textoTerciario => _esTemaOscuro ? PaletaOscura.textoTerciario : PaletaClara.textoTerciario;
  static Color get textoDeshabilitado => _esTemaOscuro ? PaletaOscura.textoDeshabilitado : PaletaClara.textoDeshabilitado;
  static Color get textoBlanco => Colors.white;
  static Color get textoEnPrimario => _esTemaOscuro ? PaletaOscura.textoEnPrimario : PaletaClara.textoEnPrimario;
  
  // Estados (adaptivos)
  static Color get hover => _esTemaOscuro ? PaletaOscura.hover : PaletaClara.hover;
  static Color get seleccionado => _esTemaOscuro ? PaletaOscura.seleccionado : PaletaClara.seleccionado;
  static Color get deshabilitado => _esTemaOscuro ? PaletaOscura.deshabilitado : PaletaClara.deshabilitado;
  
  // Colores de superficie específicos para estados
  static Color get primarioSuave => _esTemaOscuro 
    ? SistemaColores.primario.withOpacity(0.2) 
    : SistemaColores.primario.withOpacity(0.1);
  static Color get secundarioSuave => _esTemaOscuro 
    ? SistemaColores.secundario.withOpacity(0.2) 
    : SistemaColores.secundario.withOpacity(0.1);
  
  // Sombras (adaptivas)
  static Color get sombraLigera => _esTemaOscuro ? PaletaOscura.sombra : PaletaClara.sombra;
  static Color get sombraMedia => _esTemaOscuro ? PaletaOscura.sombraElevada : PaletaClara.sombraElevada;
  static Color get sombraFuerte => _esTemaOscuro 
    ? const Color(0x80000000) 
    : const Color(0x4D000000);
  
  // Gradientes (adaptivos)
  static LinearGradient get gradientePrimario => _esTemaOscuro 
    ? GradientesSistema.primarioOscuro 
    : GradientesSistema.primarioClaro;
  static LinearGradient get gradienteSecundario => _esTemaOscuro 
    ? GradientesSistema.secundarioOscuro 
    : GradientesSistema.secundarioClaro;
  static LinearGradient get gradienteSutil => _esTemaOscuro 
    ? GradientesSistema.fondoOscuro 
    : GradientesSistema.fondoClaro;
}

/// Espaciado consistente siguiendo Material Design
class EspaciadoProfesional {
  static const double xs = 4.0;    // Extra pequeño
  static const double sm = 8.0;    // Pequeño
  static const double md = 16.0;   // Medio (base)
  static const double lg = 24.0;   // Grande
  static const double xl = 32.0;   // Extra grande
  static const double xxl = 48.0;  // Extra extra grande

  // Espaciado vertical específico
  static const double sectionSpacing = 32.0;     // Entre secciones
  static const double cardSpacing = 16.0;        // Entre tarjetas
  static const double elementSpacing = 12.0;     // Entre elementos
  static const double tightSpacing = 8.0;        // Espaciado compacto
}

/// Radios de borde profesionales
class RadiosProfesionales {
  static const double sm = 8.0;    // Pequeño
  static const double md = 12.0;   // Medio
  static const double lg = 16.0;   // Grande
  static const double xl = 20.0;   // Extra grande
  static const double pill = 50.0; // Tipo píldora
}

/// Sombras profesionales siguiendo Material Design 3.0
class SombrasProfesionales {
  static const List<BoxShadow> elevacion1 = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevacion2 = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevacion3 = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevacion4 = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}

/// Tipografía profesional y legible
class TipografiaProfesional {
  static const String fontFamily = 'SF Pro Display'; // Fallback a system font

  // Tamaños de texto siguiendo escala tipográfica
  static const double h1 = 32.0;   // Títulos principales
  static const double h2 = 28.0;   // Títulos de sección
  static const double h3 = 24.0;   // Subtítulos
  static const double h4 = 20.0;   // Títulos de tarjeta
  static const double body1 = 16.0; // Texto principal
  static const double body2 = 14.0; // Texto secundario
  static const double caption = 12.0; // Texto pequeño
  static const double button = 16.0; // Texto de botones

  // Alturas de línea para legibilidad
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;

  // Pesos de fuente
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// Constantes de animación
class AnimacionesProfesionales {
  static const Duration rapida = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration lenta = Duration(milliseconds: 350);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
}