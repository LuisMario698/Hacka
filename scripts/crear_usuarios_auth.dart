import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para crear usuarios de prueba en Supabase Auth
/// Ejecutar con: dart --packages=.dart_tool/package_config.json scripts/crear_usuarios_auth.dart
void main() async {
  print('🔐 Creando usuarios de prueba en Supabase Auth...');

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

    // Usuarios a crear
    final usuarios = [
      {
        'email': 'admin@test.com',
        'password': 'password123',
        'id': '550e8400-e29b-41d4-a716-446655440001',
        'nombre': 'Administrador Sistema',
        'rol': 'administrador'
      },
      {
        'email': 'user1@test.com',
        'password': 'password123',
        'id': '550e8400-e29b-41d4-a716-446655440002',
        'nombre': 'María González',
        'rol': 'usuario'
      },
      {
        'email': 'user2@test.com',
        'password': 'password123',
        'id': '550e8400-e29b-41d4-a716-446655440003',
        'nombre': 'Juan Pérez',
        'rol': 'usuario'
      },
      {
        'email': 'user3@test.com',
        'password': 'password123',
        'id': '550e8400-e29b-41d4-a716-446655440004',
        'nombre': 'Ana Rodríguez',
        'rol': 'usuario'
      },
      {
        'email': 'user4@test.com',
        'password': 'password123',
        'id': '550e8400-e29b-41d4-a716-446655440005',
        'nombre': 'Carlos López',
        'rol': 'usuario'
      },
    ];

    print('👥 Creando ${usuarios.length} usuarios...');
    
    for (final userData in usuarios) {
      try {
        // Registrar usuario en Auth
        final authResponse = await supabase.auth.signUp(
          email: userData['email']!,
          password: userData['password']!,
        );
        
        if (authResponse.user != null) {
          print('✅ Usuario Auth creado: ${userData['email']}');
          
          // Verificar si el usuario ya existe en la tabla usuarios
          final existingUser = await supabase
              .from('usuarios')
              .select()
              .eq('email', userData['email']!)
              .maybeSingle();
          
          if (existingUser == null) {
            // Crear registro en tabla usuarios si no existe
            await supabase.from('usuarios').insert({
              'id': authResponse.user!.id, // Usar el ID generado por Auth
              'email': userData['email'],
              'password_hash': 'managed_by_supabase_auth',
              'nombre': userData['nombre'],
              'rol': userData['rol'],
              'esta_activo': true,
            });
            print('✅ Usuario tabla creado: ${userData['email']}');
          } else {
            print('ℹ️  Usuario ya existe en tabla: ${userData['email']}');
          }
          
        } else {
          print('❌ No se pudo crear usuario Auth: ${userData['email']}');
        }
        
        // Pequeña pausa entre creaciones
        await Future.delayed(Duration(milliseconds: 500));
        
      } catch (e) {
        if (e.toString().contains('already registered') || 
            e.toString().contains('User already registered')) {
          print('⚠️  Usuario ya existe: ${userData['email']}');
        } else {
          print('❌ Error creando ${userData['email']}: $e');
        }
      }
    }
    
    print('');
    print('🎉 ¡Proceso completado!');
    print('');
    print('🔐 Credenciales de prueba disponibles:');
    print('📧 admin@test.com | 🔑 password123');
    print('📧 user1@test.com | 🔑 password123');
    print('📧 user2@test.com | 🔑 password123');
    print('📧 user3@test.com | 🔑 password123');  
    print('📧 user4@test.com | 🔑 password123');
    print('');
    print('🚀 ¡Ahora puedes hacer login en tu app!');
    
  } catch (e) {
    print('❌ Error general: $e');
    exit(1);
  }
}