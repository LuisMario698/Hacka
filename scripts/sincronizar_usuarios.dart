import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para sincronizar usuarios entre Auth y tabla usuarios
/// Ejecutar con: dart --packages=.dart_tool/package_config.json scripts/sincronizar_usuarios.dart
void main() async {
  print('🔄 Sincronizando usuarios...');

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

    // Usuarios a crear/sincronizar
    final usuariosSync = [
      {
        'email': 'admin@test.com',
        'password': 'password123',
        'nombre': 'Administrador Sistema',
        'rol': 'administrador'
      },
      {
        'email': 'user1@test.com',
        'password': 'password123',
        'nombre': 'María González',
        'rol': 'usuario'
      },
    ];

    for (final userData in usuariosSync) {
      print('\n🔄 Procesando: ${userData['email']}');
      
      try {
        // 1. Intentar crear en Auth (si no existe)
        var authUser;
        try {
          final authResponse = await supabase.auth.signUp(
            email: userData['email']!,
            password: userData['password']!,
          );
          authUser = authResponse.user;
          if (authUser != null) {
            print('✅ Usuario creado en Auth: ${userData['email']}');
          }
        } catch (e) {
          if (e.toString().contains('already registered')) {
            print('ℹ️  Usuario ya existe en Auth, intentando login...');
            
            // Usuario ya existe, hacer login para obtener su ID
            final loginResponse = await supabase.auth.signInWithPassword(
              email: userData['email']!,
              password: userData['password']!,
            );
            authUser = loginResponse.user;
            print('✅ Login exitoso para: ${userData['email']}');
          } else {
            print('❌ Error con Auth: $e');
            continue;
          }
        }

        if (authUser == null) {
          print('❌ No se pudo obtener usuario de Auth');
          continue;
        }

        // 2. Verificar si existe en tabla usuarios
        final existeEnTabla = await supabase
            .from('usuarios')
            .select()
            .eq('id', authUser.id)
            .maybeSingle();

        if (existeEnTabla == null) {
          // 3. Crear en tabla usuarios
          await supabase.from('usuarios').insert({
            'id': authUser.id,
            'email': userData['email'],
            'password_hash': 'managed_by_auth',
            'nombre': userData['nombre'],
            'rol': userData['rol'],
            'esta_activo': true,
          });
          print('✅ Usuario creado en tabla: ${userData['email']}');
        } else {
          print('ℹ️  Usuario ya existe en tabla: ${userData['email']}');
        }

        // 4. Cerrar sesión para el siguiente usuario
        await supabase.auth.signOut();
        
        // Pausa entre usuarios
        await Future.delayed(Duration(milliseconds: 500));
        
      } catch (e) {
        print('❌ Error procesando ${userData['email']}: $e');
      }
    }

    print('\n🎉 Sincronización completada!');
    print('\n🔐 Credenciales disponibles:');
    print('📧 admin@test.com | 🔑 password123');
    print('📧 user1@test.com | 🔑 password123');
    
  } catch (e) {
    print('❌ Error general: $e');
    exit(1);
  }
}