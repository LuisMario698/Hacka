import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script simple para crear y sincronizar usuario admin
/// Ejecutar con: dart --packages=.dart_tool/package_config.json scripts/crear_admin_simple.dart
void main() async {
  print('👑 Creando usuario administrador...');

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

    // Datos del admin
    const email = 'admin@test.com';
    const password = 'password123';
    const nombre = 'Administrador Sistema';

    print('\n🔐 Creando usuario en Authentication...');
    
    try {
      // 1. Crear usuario en Auth
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (authResponse.user != null) {
        print('✅ Usuario creado en Authentication');
        print('   ID: ${authResponse.user!.id}');
        print('   Email: ${authResponse.user!.email}');
        
        // 2. Crear en tabla usuarios
        try {
          await supabase.from('usuarios').insert({
            'id': authResponse.user!.id,
            'email': email,
            'password_hash': 'managed_by_auth',
            'nombre': nombre,
            'rol': 'administrador',
            'esta_activo': true,
          });
          print('✅ Usuario creado en tabla usuarios');
        } catch (e) {
          print('⚠️  Error creando en tabla usuarios: $e');
          print('   Pero el usuario en Auth sí se creó');
        }
        
      } else {
        print('❌ Error: No se pudo crear usuario en Authentication');
      }
      
    } catch (e) {
      if (e.toString().contains('already registered') || 
          e.toString().contains('User already registered')) {
        print('ℹ️  Usuario ya existe en Authentication');
        
        // Intentar login para obtener el ID
        try {
          final loginResponse = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          
          if (loginResponse.user != null) {
            print('✅ Login exitoso, ID: ${loginResponse.user!.id}');
            
            // Verificar si existe en tabla
            final existeEnTabla = await supabase
                .from('usuarios')
                .select()
                .eq('id', loginResponse.user!.id)
                .maybeSingle();
            
            if (existeEnTabla == null) {
              // Crear en tabla
              await supabase.from('usuarios').insert({
                'id': loginResponse.user!.id,
                'email': email,
                'password_hash': 'managed_by_auth',
                'nombre': nombre,
                'rol': 'administrador',
                'esta_activo': true,
              });
              print('✅ Usuario sincronizado con tabla usuarios');
            } else {
              print('✅ Usuario ya existe en tabla usuarios');
            }
            
            await supabase.auth.signOut();
          }
        } catch (loginError) {
          print('❌ Error en login: $loginError');
        }
      } else {
        print('❌ Error creando usuario: $e');
      }
    }

    print('\n🎉 Proceso completado!');
    print('\n🔐 Credenciales para probar:');
    print('📧 Email: admin@test.com');
    print('🔑 Password: password123');
    print('\n📱 Ahora puedes probar el login en tu app');
    
  } catch (e) {
    print('❌ Error general: $e');
    exit(1);
  }
}