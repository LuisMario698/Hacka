import 'package:flutter/foundation.dart';
import '../servicios/supabase_service.dart';

/// Servicio de autenticación personalizado usando funciones SQL
class AuthService {
  static final SupabaseService _supabase = SupabaseService.instance;

  /// Login usando la función SQL personalizada
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 Intentando login: $email');
      }

      // Llamar a la función login_usuario de PostgreSQL
      final response = await _supabase.client.rpc(
        'login_usuario',
        params: {
          'p_email': email,
          'p_password': password,
        },
      );

      if (kDebugMode) {
        print('📦 Respuesta del servidor: $response');
      }

      // La función devuelve una lista con un elemento
      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('Credenciales inválidas');
      }

      // Obtener el primer resultado
      final userData = response is List ? response.first : response;

      if (kDebugMode) {
        print('✅ Login exitoso: ${userData['email']}');
      }

      return Map<String, dynamic>.from(userData);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en login: $e');
      }
      rethrow;
    }
  }

  /// Registrar nuevo usuario usando la función SQL personalizada
  static Future<String> registrar({
    required String email,
    required String password,
    required String nombre,
    int rolId = 1, // 1 = usuario normal por defecto
  }) async {
    try {
      if (kDebugMode) {
        print('📝 Registrando usuario: $email');
      }

      // Llamar a la función registrar_usuario de PostgreSQL
      final response = await _supabase.client.rpc(
        'registrar_usuario',
        params: {
          'p_email': email,
          'p_password': password,
          'p_nombre': nombre,
          'p_rol_id': rolId,
        },
      );

      if (response == null) {
        throw Exception('Error al crear el usuario');
      }

      final usuarioId = response.toString();

      if (kDebugMode) {
        print('✅ Usuario registrado: $email (ID: $usuarioId)');
      }

      return usuarioId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en registro: $e');
      }
      
      // Mejorar mensajes de error
      if (e.toString().contains('Email inválido')) {
        throw Exception('El formato del email no es válido');
      } else if (e.toString().contains('contraseña')) {
        throw Exception('La contraseña debe tener al menos 8 caracteres');
      } else if (e.toString().contains('ya está registrado')) {
        throw Exception('Este email ya está registrado');
      }
      
      rethrow;
    }
  }

  /// Obtener datos del usuario actual desde sesión local
  /// (Guardamos los datos después del login)
  static Map<String, dynamic>? _usuarioActual;

  static void guardarSesion(Map<String, dynamic> userData) {
    _usuarioActual = userData;
  }

  static Map<String, dynamic>? obtenerSesion() {
    return _usuarioActual;
  }

  static void cerrarSesion() {
    _usuarioActual = null;
  }

  static bool estaAutenticado() {
    return _usuarioActual != null;
  }

  static String? obtenerUsuarioId() {
    return _usuarioActual?['id'];
  }

  static String? obtenerEmail() {
    return _usuarioActual?['email'];
  }

  static String? obtenerNombre() {
    return _usuarioActual?['nombre'];
  }

  static int? obtenerRolId() {
    return _usuarioActual?['rol_id'];
  }

  static String? obtenerRolNombre() {
    return _usuarioActual?['rol_nombre'];
  }

  static bool esAdmin() {
    final rolId = obtenerRolId();
    return rolId != null && (rolId == 3 || rolId == 4); // admin o super_admin
  }

  static bool esModerador() {
    final rolId = obtenerRolId();
    return rolId != null && rolId >= 2; // moderador, admin o super_admin
  }

  /// Obtener datos actualizados del usuario desde la base de datos
  static Future<Map<String, dynamic>?> obtenerDatosUsuario(String usuarioId) async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .select('*, roles!inner(nombre, permisos)')
          .eq('id', usuarioId)
          .eq('esta_activo', true)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Transformar respuesta para que coincida con login_usuario
      final userData = {
        'id': response['id'],
        'email': response['email'],
        'nombre': response['nombre'],
        'rol_id': response['rol_id'],
        'rol_nombre': response['roles']['nombre'],
        'esta_activo': response['esta_activo'],
        'permisos': response['roles']['permisos'],
      };

      return userData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo datos de usuario: $e');
      }
      return null;
    }
  }

  /// Refrescar sesión actual
  static Future<bool> refrescarSesion() async {
    if (_usuarioActual == null) return false;

    try {
      final usuarioId = _usuarioActual!['id'];
      final datosActualizados = await obtenerDatosUsuario(usuarioId);
      
      if (datosActualizados != null) {
        _usuarioActual = datosActualizados;
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refrescando sesión: $e');
      }
      return false;
    }
  }
}
