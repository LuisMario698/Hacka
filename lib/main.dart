import 'package:flutter/foundation.dart' show kIsWeb;
import 'móvil/main_movil.dart' as movil;
import 'web/main_web.dart' as web;

/// Punto de entrada principal de la aplicación
/// Detecta automáticamente la plataforma y carga la app correspondiente:
/// - Web: Dashboard administrativo
/// - Móvil: App de rutas seguras
void main() {
  if (kIsWeb) {
    // Ejecutar versión web (Dashboard administrativo)
    web.main();
  } else {
    // Ejecutar versión móvil (App de usuario)
    movil.main();
  }
}
