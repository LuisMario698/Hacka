import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio principal para manejar la conexión y operaciones con Supabase
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();

  /// Cliente de Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Usuario autenticado actual
  User? get currentUser => client.auth.currentUser;

  /// ID del usuario actual
  String? get currentUserId => currentUser?.id;

  /// Está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Inicializar Supabase
  static Future<void> initialize() async {
    try {
      // Cargar variables de entorno
      await dotenv.load(fileName: ".env");
      
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('Variables de entorno de Supabase no encontradas');
      }

      // Inicializar Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      if (kDebugMode) {
        print('✅ Supabase inicializado correctamente');
        print('URL: $supabaseUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando Supabase: $e');
      }
      rethrow;
    }
  }

  /// Escuchar cambios en la autenticación
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      if (kDebugMode) {
        print('✅ Sesión cerrada exitosamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cerrando sesión: $e');
      }
      rethrow;
    }
  }

  /// Registrar nuevo usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? nombre,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'nombre': nombre},
      );
      
      if (kDebugMode) {
        print('✅ Usuario registrado: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error registrando usuario: $e');
      }
      rethrow;
    }
  }

  /// Iniciar sesión
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (kDebugMode) {
        print('✅ Usuario autenticado: ${response.user?.email}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error iniciando sesión: $e');
      }
      rethrow;
    }
  }

  /// Recuperar contraseña
  Future<void> resetPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      if (kDebugMode) {
        print('✅ Email de recuperación enviado a: $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enviando email de recuperación: $e');
      }
      rethrow;
    }
  }

  /// Verificar conexión a la base de datos
  Future<bool> testConnection() async {
    try {
      // Intentar hacer una consulta simple
      final response = await client
          .from('usuarios')
          .select('count')
          .limit(1);
      
      if (kDebugMode) {
        print('✅ Conexión a base de datos exitosa');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error de conexión a base de datos: $e');
      }
      return false;
    }
  }

  /// Manejar errores de Supabase
  String handleSupabaseError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Credenciales inválidas. Verifica tu email y contraseña.';
        case 'Email not confirmed':
          return 'Email no confirmado. Revisa tu bandeja de entrada.';
        case 'User already registered':
          return 'Este email ya está registrado.';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    } else if (error is PostgrestException) {
      return 'Error de base de datos: ${error.message}';
    } else {
      return 'Error desconocido: $error';
    }
  }

  /// Registrar nuevo usuario en nuestra tabla personalizada
  Future<Map<String, dynamic>?> signUpCustom({
    required String email,
    required String password,
    required String nombre,
    String? telefono,
  }) async {
    try {
      // Llamar a la función de base de datos para crear usuario
      final response = await client.rpc('crear_usuario', params: {
        'p_email': email,
        'p_password': password,
        'p_nombre': nombre,
        'p_telefono': telefono,
        'p_rol_id': 3, // Rol de usuario normal
      });

      if (kDebugMode) {
        print('✅ Usuario registrado en tabla personalizada: $email');
      }

      return response as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error registrando usuario personalizado: $e');
      }
      rethrow;
    }
  }

  /// Login con sistema personalizado (sin Supabase Auth)
  static Future<Map<String, dynamic>?> signInCustom(String email, String password) async {
    try {
      final response = await SupabaseService.instance.client.rpc('login_usuario', params: {
        'p_email': email,
        'p_password': password,
      });

      if (kDebugMode) {
        print('✅ Login exitoso: $email');
      }

      return response as Map<String, dynamic>?;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en login: $e');
      }
      return null;
    }
  }
}
