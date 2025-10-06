import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'móvil/main_movil.dart' as movil;
import 'web/main_web.dart' as web;

void main() {
  if (kIsWeb) {
    // Ejecutar versión web 
    web.main();
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    exit(0); // No soportado en escritorio
  } else {
    // Ejecutar versión móvil
    movil.main();
  }
}
