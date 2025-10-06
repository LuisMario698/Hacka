import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/servicios/supabase_service.dart';
import 'lib/servicios/usuario_service.dart';

/// Script simple para probar la conexión con Supabase
void main() async {
  print('🚀 Iniciando prueba de conexión a Supabase...');
  
  try {
    // Cargar variables de entorno
    await dotenv.load(fileName: '.env');
    print('✅ Variables de entorno cargadas');
    
    // Inicializar Supabase
    await SupabaseService.initialize();
    print('✅ Supabase inicializado correctamente');
    
    // Probar conexión obteniendo usuarios
    final usuarios = await UsuarioService.obtenerUsuarios();
    print('✅ Conexión exitosa - Usuarios encontrados: ${usuarios.length}');
    
    // Mostrar algunos detalles si hay usuarios
    if (usuarios.isNotEmpty) {
      print('📊 Primeros usuarios:');
      for (int i = 0; i < usuarios.length && i < 3; i++) {
        final usuario = usuarios[i];
        print('   - ${usuario.nombre} (${usuario.email})');
      }
    }
    
    print('🎉 ¡Prueba de conexión completada exitosamente!');
    
  } catch (e) {
    print('❌ Error en la prueba de conexión: $e');
  }
}