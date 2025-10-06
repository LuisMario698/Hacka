import 'package:flutter/foundation.dart';
import '../modelos/modelos.dart';
import 'supabase_service.dart';

/// Servicio para operaciones CRUD con usuarios
class UsuarioService {
  static final SupabaseService _supabase = SupabaseService.instance;

  /// Obtener todos los usuarios con información de rol
  static Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .select('*, roles!usuarios_rol_id_fkey(nombre)')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        // Agregar rol_nombre desde el JOIN
        if (json['roles'] != null && json['roles'] is Map) {
          json['rol_nombre'] = json['roles']['nombre'];
        }
        return Usuario.fromJson(json);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo usuarios: $e');
      }
      rethrow;
    }
  }

  /// Obtener usuario por ID
  static Future<Usuario?> obtenerUsuarioPorId(String id) async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? Usuario.fromJson(response) : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo usuario por ID: $e');
      }
      rethrow;
    }
  }

  /// Obtener usuario actual autenticado (combina auth + tabla usuarios)
  static Future<Usuario?> obtenerUsuarioActual() async {
    try {
      final user = _supabase.client.auth.currentUser;
      if (user == null) return null;

      // Obtener datos adicionales de la tabla usuarios
      final response = await _supabase.client
          .from('usuarios')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        if (kDebugMode) {
          print('⚠️ Usuario autenticado pero no encontrado en tabla usuarios');
        }
        return null;
      }

      return Usuario.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo usuario actual: $e');
      }
      rethrow;
    }
  }

  /// Verificar si el usuario actual está activo y tiene permisos
  static Future<bool> usuarioTieneAcceso() async {
    try {
      final usuario = await obtenerUsuarioActual();
      return usuario != null && usuario.estaActivo;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando acceso del usuario: $e');
      }
      return false;
    }
  }

  /// Obtener usuario por email
  static Future<Usuario?> obtenerUsuarioPorEmail(String email) async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .select()
          .eq('email', email)
          .maybeSingle();

      return response != null ? Usuario.fromJson(response) : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo usuario por email: $e');
      }
      rethrow;
    }
  }

  /// Crear nuevo usuario en la tabla usuarios después del registro en auth
  static Future<Usuario> crearUsuario({
    required String id, // ID del usuario autenticado
    required String email,
    required String nombre,
    int rolId = 1, // 1 = usuario, 2 = moderador, 3 = administrador, 4 = super_admin
  }) async {
    try {
      final usuarioData = {
        'id': id,
        'email': email,
        'nombre': nombre,
        'rol_id': rolId,
        'esta_activo': true,
        // NO incluir password_hash - Supabase Auth lo maneja automáticamente
      };

      final response = await _supabase.client
          .from('usuarios')
          .insert(usuarioData)
          .select('*, roles!usuarios_rol_id_fkey(nombre)')
          .single();

      // Agregar rol_nombre desde el JOIN
      if (response['roles'] != null && response['roles'] is Map) {
        response['rol_nombre'] = response['roles']['nombre'];
      }

      final usuario = Usuario.fromJson(response);
      
      if (kDebugMode) {
        print('✅ Usuario creado: ${usuario.email}');
      }
      
      return usuario;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creando usuario: $e');
      }
      rethrow;
    }
  }

  /// Actualizar usuario
  static Future<Usuario> actualizarUsuario(String id, {
    String? nombre,
    String? email,
    int? rolId,
    bool? estaActivo,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (nombre != null) updateData['nombre'] = nombre;
      if (email != null) updateData['email'] = email;
      if (rolId != null) updateData['rol_id'] = rolId;
      if (estaActivo != null) updateData['esta_activo'] = estaActivo;

      final response = await _supabase.client
          .from('usuarios')
          .update(updateData)
          .eq('id', id)
          .select('*, roles!usuarios_rol_id_fkey(nombre)')
          .single();

      // Agregar rol_nombre desde el JOIN
      if (response['roles'] != null && response['roles'] is Map) {
        response['rol_nombre'] = response['roles']['nombre'];
      }

      final usuario = Usuario.fromJson(response);
      
      if (kDebugMode) {
        print('✅ Usuario actualizado: ${usuario.email}');
      }
      
      return usuario;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error actualizando usuario: $e');
      }
      rethrow;
    }
  }

  /// Desactivar usuario (soft delete)
  static Future<void> desactivarUsuario(String id) async {
    try {
      await _supabase.client
          .from('usuarios')
          .update({'esta_activo': false})
          .eq('id', id);

      if (kDebugMode) {
        print('✅ Usuario desactivado: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error desactivando usuario: $e');
      }
      rethrow;
    }
  }

  /// Eliminar usuario permanentemente
  static Future<void> eliminarUsuario(String id) async {
    try {
      await _supabase.client
          .from('usuarios')
          .delete()
          .eq('id', id);

      if (kDebugMode) {
        print('✅ Usuario eliminado: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error eliminando usuario: $e');
      }
      rethrow;
    }
  }

  /// Obtener usuarios activos
  static Future<List<Usuario>> obtenerUsuariosActivos() async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .select()
          .eq('esta_activo', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Usuario.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo usuarios activos: $e');
      }
      rethrow;
    }
  }

  /// Buscar usuarios por nombre
  static Future<List<Usuario>> buscarUsuariosPorNombre(String nombre) async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .select('*, roles!usuarios_rol_id_fkey(nombre)')
          .ilike('nombre', '%$nombre%')
          .eq('esta_activo', true)
          .order('nombre', ascending: true);

      return (response as List).map((json) {
        // Agregar rol_nombre desde el JOIN
        if (json['roles'] != null && json['roles'] is Map) {
          json['rol_nombre'] = json['roles']['nombre'];
        }
        return Usuario.fromJson(json);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error buscando usuarios por nombre: $e');
      }
      rethrow;
    }
  }

  /// Obtener todos los roles disponibles
  static Future<List<Rol>> obtenerRoles() async {
    try {
      final response = await _supabase.client
          .from('roles')
          .select()
          .order('id', ascending: true);

      return (response as List)
          .map((json) => Rol.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo roles: $e');
      }
      rethrow;
    }
  }

  /// Obtener estadísticas de usuarios (método simplificado)
  static Future<Map<String, int>> obtenerEstadisticasUsuarios() async {
    try {
      // Obtener todos los usuarios para calcular estadísticas
      final usuarios = await obtenerUsuarios();
      final usuariosActivos = usuarios.where((u) => u.estaActivo).toList();
      
      // Usuarios registrados hoy
      final hoy = DateTime.now();
      final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final registradosHoy = usuarios
          .where((u) => u.createdAt.isAfter(inicioHoy))
          .length;

      return {
        'total': usuarios.length,
        'activos': usuariosActivos.length,
        'registrados_hoy': registradosHoy,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estadísticas de usuarios: $e');
      }
      return {
        'total': 0,
        'activos': 0,
        'registrados_hoy': 0,
      };
    }
  }

  /// ========================================
  /// MÉTODOS DE CONTROL DE ACCESO
  /// ========================================

  /// Habilitar usuario (darle acceso)
  static Future<Usuario> habilitarUsuario(String usuarioId) async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .update({'esta_activo': true})
          .eq('id', usuarioId)
          .select()
          .single();

      if (kDebugMode) {
        print('✅ Usuario habilitado: $usuarioId');
      }

      return Usuario.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error habilitando usuario: $e');
      }
      rethrow;
    }
  }

  /// Deshabilitar usuario (bloquear acceso)
  static Future<Usuario> deshabilitarUsuario(String usuarioId) async {
    try {
      final response = await _supabase.client
          .from('usuarios')
          .update({'esta_activo': false})
          .eq('id', usuarioId)
          .select()
          .single();

      if (kDebugMode) {
        print('✅ Usuario deshabilitado: $usuarioId');
      }

      return Usuario.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deshabilitando usuario: $e');
      }
      rethrow;
    }
  }

  /// Cambiar rol de usuario
  static Future<Usuario> cambiarRolUsuario(String usuarioId, int nuevoRolId) async {
    try {
      // Validar que el rol sea válido (1-4)
      if (nuevoRolId < 1 || nuevoRolId > 4) {
        throw Exception('Rol inválido: $nuevoRolId');
      }

      final response = await _supabase.client
          .from('usuarios')
          .update({'rol_id': nuevoRolId})
          .eq('id', usuarioId)
          .select('*, roles!usuarios_rol_id_fkey(nombre)')
          .single();

      // Agregar rol_nombre desde el JOIN
      if (response['roles'] != null && response['roles'] is Map) {
        response['rol_nombre'] = response['roles']['nombre'];
      }

      if (kDebugMode) {
        print('✅ Rol cambiado para usuario: $usuarioId -> $nuevoRolId');
      }

      return Usuario.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cambiando rol de usuario: $e');
      }
      rethrow;
    }
  }

  /// Verificar si un usuario tiene un rol específico (por ID)
  static Future<bool> usuarioTieneRol(String usuarioId, int rolId) async {
    try {
      final usuario = await obtenerUsuarioPorId(usuarioId);
      return usuario?.rolId == rolId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando rol de usuario: $e');
      }
      return false;
    }
  }

  /// Verificar si el usuario actual es administrador (rol_id >= 3)
  static Future<bool> usuarioEsAdmin() async {
    try {
      final usuario = await obtenerUsuarioActual();
      return usuario?.esAdmin ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error verificando si usuario es admin: $e');
      }
      return false;
    }
  }

  /// Login personalizado que verifica tanto auth como tabla usuarios
  static Future<Usuario?> loginConControl(String email, String password) async {
    try {
      // 1. Autenticar en Supabase Auth
      final authResponse = await _supabase.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Credenciales inválidas');
      }

      // 2. Verificar que el usuario existe y está activo en tu tabla
      final usuario = await obtenerUsuarioPorId(authResponse.user!.id);
      
      if (usuario == null) {
        // Usuario existe en auth pero no en tu tabla
        await _supabase.client.auth.signOut();
        throw Exception('Usuario no encontrado en el sistema');
      }

      if (!usuario.estaActivo) {
        // Usuario existe pero está deshabilitado
        await _supabase.client.auth.signOut();
        throw Exception('Tu cuenta ha sido deshabilitada. Contacta al administrador');
      }

      if (kDebugMode) {
        print('✅ Login exitoso: ${usuario.email} (${usuario.rol})');
      }

      return usuario;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en login controlado: $e');
      }
      rethrow;
    }
  }
}