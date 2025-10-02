import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../modelos/modelos.dart';
import 'supabase_service.dart';

/// Servicio para operaciones CRUD con rutas_historial
class RutaHistorialService {
  static final SupabaseService _supabase = SupabaseService.instance;

  /// Crear nueva ruta en el historial
  static Future<RutaHistorial> crearRutaHistorial({
    required double origenLat,
    required double origenLon,
    required double destinoLat,
    required double destinoLon,
    required Map<String, dynamic> geojsonRuta,
    double? distanciaKm,
    int? duracionEstimadaMin,
    int? seguridadPromedio,
  }) async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      final rutaData = {
        'usuario_id': usuarioId,
        'origen_lat': origenLat,
        'origen_lon': origenLon,
        'destino_lat': destinoLat,
        'destino_lon': destinoLon,
        'geojson_ruta': geojsonRuta,
        'distancia_km': distanciaKm,
        'duracion_estimada_min': duracionEstimadaMin,
        'seguridad_promedio': seguridadPromedio,
      };

      final response = await _supabase.client
          .from('rutas_historial')
          .insert(rutaData)
          .select()
          .single();

      final ruta = RutaHistorial.fromJson(response);
      
      if (kDebugMode) {
        print('✅ Ruta guardada en historial: ${ruta.id}');
      }
      
      return ruta;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando ruta en historial: $e');
      }
      rethrow;
    }
  }

  /// Obtener historial de rutas del usuario actual
  static Future<List<RutaHistorial>> obtenerHistorialUsuario({
    int? limite,
    int? offset,
  }) async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      var query = _supabase.client
          .from('rutas_historial')
          .select()
          .eq('usuario_id', usuarioId)
          .order('created_at', ascending: false);

      if (limite != null) {
        query = query.limit(limite);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limite ?? 50) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => RutaHistorial.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo historial de rutas: $e');
      }
      rethrow;
    }
  }

  /// Obtener ruta específica por ID
  static Future<RutaHistorial?> obtenerRutaPorId(String id) async {
    try {
      final response = await _supabase.client
          .from('rutas_historial')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? RutaHistorial.fromJson(response) : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo ruta por ID: $e');
      }
      rethrow;
    }
  }

  /// Obtener rutas recientes del usuario (últimas 7 días)
  static Future<List<RutaHistorial>> obtenerRutasRecientes() async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      final fechaLimite = DateTime.now().subtract(const Duration(days: 7));

      final response = await _supabase.client
          .from('rutas_historial')
          .select()
          .eq('usuario_id', usuarioId)
          .gte('created_at', fechaLimite.toIso8601String())
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RutaHistorial.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo rutas recientes: $e');
      }
      rethrow;
    }
  }

  /// Obtener rutas en un área específica (para análisis de patrones)
  static Future<List<RutaHistorial>> obtenerRutasEnArea({
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
          .from('rutas_historial')
          .select()
          .or(
            'and(origen_lat.gte.${latCentro - latDelta},origen_lat.lte.${latCentro + latDelta},origen_lon.gte.${lonCentro - lonDelta},origen_lon.lte.${lonCentro + lonDelta}),'
            'and(destino_lat.gte.${latCentro - latDelta},destino_lat.lte.${latCentro + latDelta},destino_lon.gte.${lonCentro - lonDelta},destino_lon.lte.${lonCentro + lonDelta})'
          )
          .order('created_at', ascending: false);

      if (limite != null) {
        query = query.limit(limite);
      }

      final response = await query;

      return (response as List)
          .map((json) => RutaHistorial.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo rutas en área: $e');
      }
      rethrow;
    }
  }

  /// Eliminar ruta del historial
  static Future<void> eliminarRuta(String id) async {
    try {
      await _supabase.client
          .from('rutas_historial')
          .delete()
          .eq('id', id);

      if (kDebugMode) {
        print('✅ Ruta eliminada del historial: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error eliminando ruta: $e');
      }
      rethrow;
    }
  }

  /// Limpiar historial antiguo (más de X días)
  static Future<int> limpiarHistorialAntiguo({int diasAntiguedad = 30}) async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      final fechaLimite = DateTime.now().subtract(Duration(days: diasAntiguedad));

      final response = await _supabase.client
          .from('rutas_historial')
          .delete()
          .eq('usuario_id', usuarioId)
          .lt('created_at', fechaLimite.toIso8601String())
          .select();

      final eliminadas = (response as List).length;
      
      if (kDebugMode) {
        print('✅ Eliminadas $eliminadas rutas antiguas');
      }
      
      return eliminadas;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error limpiando historial antiguo: $e');
      }
      rethrow;
    }
  }

  /// Obtener estadísticas del historial de rutas del usuario
  static Future<Map<String, dynamic>> obtenerEstadisticasUsuario() async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener todas las rutas del usuario para calcular estadísticas
      final rutas = await obtenerHistorialUsuario();

      if (rutas.isEmpty) {
        return {
          'total_rutas': 0,
          'distancia_total_km': 0.0,
          'tiempo_total_min': 0,
          'seguridad_promedio': 0.0,
          'rutas_este_mes': 0,
        };
      }

      // Calcular estadísticas
      final totalRutas = rutas.length;
      final distanciaTotal = rutas
          .where((r) => r.distanciaKm != null)
          .fold(0.0, (sum, r) => sum + r.distanciaKm!);
      final tiempoTotal = rutas
          .where((r) => r.duracionEstimadaMin != null)
          .fold(0, (sum, r) => sum + r.duracionEstimadaMin!);
      final seguridadPromedio = rutas
          .where((r) => r.seguridadPromedio != null)
          .fold(0.0, (sum, r) => sum + r.seguridadPromedio!) / 
          rutas.where((r) => r.seguridadPromedio != null).length;

      // Rutas de este mes
      final inicioMes = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final rutasEsteMes = rutas
          .where((r) => r.createdAt.isAfter(inicioMes))
          .length;

      return {
        'total_rutas': totalRutas,
        'distancia_total_km': distanciaTotal,
        'tiempo_total_min': tiempoTotal,
        'seguridad_promedio': seguridadPromedio.isNaN ? 0.0 : seguridadPromedio,
        'rutas_este_mes': rutasEsteMes,
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estadísticas de rutas: $e');
      }
      return {
        'total_rutas': 0,
        'distancia_total_km': 0.0,
        'tiempo_total_min': 0,
        'seguridad_promedio': 0.0,
        'rutas_este_mes': 0,
      };
    }
  }

  /// Obtener rutas favoritas (más utilizadas) basadas en patrones
  static Future<List<Map<String, dynamic>>> obtenerRutasFavoritas({
    int limite = 5,
  }) async {
    try {
      final usuarioId = _supabase.currentUserId;
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener rutas agrupadas por área de origen y destino (simplificado)
      final rutas = await obtenerHistorialUsuario(limite: 100);
      
      // Agrupar rutas similares (mismo origen/destino aproximado)
      final rutasAgrupadas = <String, List<RutaHistorial>>{};
      
      for (final ruta in rutas) {
        // Crear clave basada en coordenadas redondeadas
        final claveOrigen = '${ruta.origenLat.toStringAsFixed(3)},${ruta.origenLon.toStringAsFixed(3)}';
        final claveDestino = '${ruta.destinoLat.toStringAsFixed(3)},${ruta.destinoLon.toStringAsFixed(3)}';
        final claveRuta = '$claveOrigen->$claveDestino';
        
        rutasAgrupadas[claveRuta] ??= [];
        rutasAgrupadas[claveRuta]!.add(ruta);
      }

      // Ordenar por frecuencia y crear resultado
      final rutasFavoritas = rutasAgrupadas.entries
          .map((entry) {
            final rutasGrupo = entry.value;
            final primera = rutasGrupo.first;
            
            return {
              'origen_lat': primera.origenLat,
              'origen_lon': primera.origenLon,
              'destino_lat': primera.destinoLat,
              'destino_lon': primera.destinoLon,
              'frecuencia': rutasGrupo.length,
              'distancia_promedio': rutasGrupo
                  .where((r) => r.distanciaKm != null)
                  .fold(0.0, (sum, r) => sum + r.distanciaKm!) / 
                  rutasGrupo.where((r) => r.distanciaKm != null).length,
              'ultima_vez': rutasGrupo
                  .map((r) => r.createdAt)
                  .reduce((a, b) => a.isAfter(b) ? a : b),
            };
          })
          .toList()
        ..sort((a, b) => (b['frecuencia'] as int).compareTo(a['frecuencia'] as int));

      return rutasFavoritas.take(limite).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo rutas favoritas: $e');
      }
      return [];
    }
  }
}