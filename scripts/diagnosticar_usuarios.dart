import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para diagnosticar y sincronizar usuarios
/// Ejecutar con: dart --packages=.dart_tool/package_config.json scripts/diagnosticar_usuarios.dart
void main() async {
  print('🔍 Diagnosticando usuarios...');

  try {
    // Cargar variables de entorno
    await dotenv.load(fileName: '.env');
    
    // Inicializar Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    
    final supabase = Supabase.instance.client;
    print('✅ Conectado a Supabase');

    // 1. Verificar usuarios en Auth
    print('\n📧 USUARIOS EN AUTHENTICATION:');
    print('(Necesitas permisos de admin para ver esto, si falla es normal)');
    
    // 2. Verificar usuarios en tabla
    print('\n👥 USUARIOS EN TABLA "usuarios":');
    try {
      final usuariosTabla = await supabase
          .from('usuarios')
          .select('id, email, nombre, rol, esta_activo');
      
      if (usuariosTabla.isEmpty) {
        print('❌ ¡No hay usuarios en la tabla "usuarios"!');
        print('   Necesitas ejecutar el SQL: datos_prueba_actualizado.sql');
      } else {
        for (final usuario in usuariosTabla) {
          final activo = usuario['esta_activo'] ? '✅' : '❌';
          print('$activo ${usuario['email']} (${usuario['rol']})');
        }
      }
    } catch (e) {
      print('❌ Error consultando tabla usuarios: $e');
    }

    // 3. Intentar login de prueba
    print('\n🔐 PROBANDO LOGIN:');
    try {
      final loginResult = await supabase.auth.signInWithPassword(
        email: 'admin@test.com',
        password: 'password123',
      );
      
      if (loginResult.user != null) {
        print('✅ Login Auth exitoso para admin@test.com');
        print('   User ID: ${loginResult.user!.id}');
        
        // Verificar si existe en tabla
        final usuarioEnTabla = await supabase
            .from('usuarios')
            .select()
            .eq('id', loginResult.user!.id)
            .maybeSingle();
        
        if (usuarioEnTabla != null) {
          print('✅ Usuario encontrado en tabla usuarios');
          print('   Nombre: ${usuarioEnTabla['nombre']}');
          print('   Activo: ${usuarioEnTabla['esta_activo']}');
        } else {
          print('❌ Usuario NO encontrado en tabla usuarios');
          print('   Este es el problema que tienes');
        }
        
        // Cerrar sesión
        await supabase.auth.signOut();
      } else {
        print('❌ Login Auth falló para admin@test.com');
      }
    } catch (e) {
      print('❌ Error en login de prueba: $e');
    }

    print('\n🛠️  SOLUCIONES:');
    print('1. Si no hay usuarios en la tabla → Ejecutar datos_prueba_actualizado.sql');
    print('2. Si login Auth falla → Crear usuarios en Supabase Authentication');
    print('3. Si login Auth funciona pero no encuentra en tabla → Sincronizar usuarios');
    
  } catch (e) {
    print('❌ Error general: $e');
    exit(1);
  }
}