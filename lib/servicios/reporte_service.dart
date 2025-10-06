import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../modelos/modelos.dart';
import 'supabase_service.dart';

/// Servicio para operaciones CRUD con reportes
class ReporteService {
  static final SupabaseService _supabase = SupabaseService.instance;

  /// Crear nuevo reporte
  static Future<Reporte> crearReporte({
    required String titulo,
    String? descripcion,
    required double lat,
    required double lon,
    String? urlEvidencia,
  }) async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      final reporteData = {
        'usuario_id': usuarioId,
        'titulo': titulo,
        'descripcion': descripcion,
        'lat': lat,
        'lon': lon,
        'url_evidencia': urlEvidencia,
        'estado': 'nuevo',
      };

      final response = await _supabase.client
          .from('reportes')
          .insert(reporteData)
          .select()
          .single();

      final reporte = Reporte.fromJson(response);
      
      if (kDebugMode) {
        print('✅ Reporte creado: ${reporte.titulo}');
      }
      
      return reporte;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creando reporte: $e');
      }
      rethrow;
    }
  }

  /// Obtener todos los reportes
  static Future<List<Reporte>> obtenerReportes({
    int? limite,
    EstadoReporte? estado,
  }) async {
    try {
      final response = await _supabase.client
          .from('reportes')
          .select()
          .order('created_at', ascending: false)
          .limit(limite ?? 1000);

      final reportes = (response as List)
          .map((json) => Reporte.fromJson(json))
          .toList();

      // Filtrar por estado si se especifica
      if (estado != null) {
        return reportes.where((reporte) => reporte.estado == estado).toList();
      }

      return reportes;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo reportes: $e');
      }
      rethrow;
    }
  }

  /// Obtener reportes del usuario actual
  static Future<List<Reporte>> obtenerReportesUsuario({
    int? limite,
  }) async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      var query = _supabase.client
          .from('reportes')
          .select()
          .eq('usuario_id', usuarioId)
          .order('created_at', ascending: false);

      if (limite != null) {
        query = query.limit(limite);
      }

      final response = await query;

      return (response as List)
          .map((json) => Reporte.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo reportes del usuario: $e');
      }
      rethrow;
    }
  }

  /// Obtener reporte por ID
  static Future<Reporte?> obtenerReportePorId(String id) async {
    try {
      final response = await _supabase.client
          .from('reportes')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? Reporte.fromJson(response) : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo reporte por ID: $e');
      }
      rethrow;
    }
  }

  /// Obtener reportes en un área específica
  static Future<List<Reporte>> obtenerReportesEnArea({
    required double latCentro,
    required double lonCentro,
    required double radioKm,
    int? limite,
  }) async {
    try {
      // Calcular bounding box aproximado
      final latDelta = radioKm / 111.0; // ~111 km por grado de latitud
      final lonDelta = radioKm / (111.0 * math.cos(latCentro * 3.14159 / 180.0));

      var query = _supabase.client
          .from('reportes')
          .select()
          .gte('lat', latCentro - latDelta)
          .lte('lat', latCentro + latDelta)
          .gte('lon', lonCentro - lonDelta)
          .lte('lon', lonCentro + lonDelta)
          .order('created_at', ascending: false);

      if (limite != null) {
        query = query.limit(limite);
      }

      final response = await query;

      return (response as List)
          .map((json) => Reporte.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo reportes en área: $e');
      }
      rethrow;
    }
  }

  /// Actualizar estado de reporte (solo para administradores)
  static Future<Reporte> actualizarEstadoReporte(
    String id,
    EstadoReporte nuevoEstado,
  ) async {
    try {
      final response = await _supabase.client
          .from('reportes')
          .update({'estado': nuevoEstado.value})
          .eq('id', id)
          .select()
          .single();

      final reporte = Reporte.fromJson(response);
      
      if (kDebugMode) {
        print('✅ Estado de reporte actualizado: ${reporte.id} -> ${nuevoEstado.value}');
      }
      
      return reporte;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error actualizando estado de reporte: $e');
      }
      rethrow;
    }
  }

  /// Actualizar reporte
  static Future<Reporte> actualizarReporte(
    String id, {
    String? titulo,
    String? descripcion,
    String? urlEvidencia,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (titulo != null) updateData['titulo'] = titulo;
      if (descripcion != null) updateData['descripcion'] = descripcion;
      if (urlEvidencia != null) updateData['url_evidencia'] = urlEvidencia;

      final response = await _supabase.client
          .from('reportes')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final reporte = Reporte.fromJson(response);
      
      if (kDebugMode) {
        print('✅ Reporte actualizado: ${reporte.titulo}');
      }
      
      return reporte;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error actualizando reporte: $e');
      }
      rethrow;
    }
  }

  /// Eliminar reporte
  static Future<void> eliminarReporte(String id) async {
    try {
      await _supabase.client
          .from('reportes')
          .delete()
          .eq('id', id);

      if (kDebugMode) {
        print('✅ Reporte eliminado: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error eliminando reporte: $e');
      }
      rethrow;
    }
  }

  /// Obtener estadísticas de reportes (método simplificado)
  static Future<Map<String, dynamic>> obtenerEstadisticasReportes() async {
    try {
      // Obtener todos los reportes para calcular estadísticas
      final reportes = await obtenerReportes();

      // Reportes por estado
      final estadisticasPorEstado = <String, int>{};
      for (final estado in EstadoReporte.values) {
        estadisticasPorEstado[estado.value] = reportes
            .where((r) => r.estado == estado)
            .length;
      }

      // Reportes de esta semana
      final inicioSemana = DateTime.now().subtract(const Duration(days: 7));
      final estaSemana = reportes
          .where((r) => r.createdAt.isAfter(inicioSemana))
          .length;

      // Reportes del usuario actual (si está autenticado)
      int reportesUsuario = 0;
      if (_supabase.currentUserId != null) {
        final reportesUsuarioActual = await obtenerReportesUsuario();
        reportesUsuario = reportesUsuarioActual.length;
      }

      return {
        'total': reportes.length,
        'esta_semana': estaSemana,
        'usuario_actual': reportesUsuario,
        'por_estado': estadisticasPorEstado,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estadísticas de reportes: $e');
      }
      return {
        'total': 0,
        'esta_semana': 0,
        'usuario_actual': 0,
        'por_estado': <String, int>{},
      };
    }
  }

  /// Buscar reportes por texto
  static Future<List<Reporte>> buscarReportes(String termino) async {
    try {
      final response = await _supabase.client
          .from('reportes')
          .select()
          .or('titulo.ilike.%$termino%,descripcion.ilike.%$termino%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Reporte.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error buscando reportes: $e');
      }
      rethrow;
    }
  }
}