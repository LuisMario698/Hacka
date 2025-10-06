import 'package:flutter/foundation.dart';
import '../modelos/nodo_model.dart';
import '../modelos/lectura_model.dart';
import 'supabase_service.dart';

/// Servicio para gestionar nodos/sensores IoT
class NodoService {
  static final SupabaseService _supabase = SupabaseService.instance;

  /// Obtener todos los nodos con su última lectura
  static Future<List<Nodo>> obtenerTodosLosNodos() async {
    try {
      if (kDebugMode) {
        print('🔍 Obteniendo todos los nodos...');
      }

      // Query para obtener nodos con su última lectura
      final response = await _supabase.client
          .from('nodos')
          .select('''
            *,
            ultima_lectura:lecturas(lux, ruido, fecha)
          ''')
          .order('created_at', ascending: false);

      if (kDebugMode) {
        print('📦 Respuesta de nodos: ${response.length} encontrados');
      }

      final List<Nodo> nodos = [];
      
      for (var nodoData in response) {
        final nodo = Nodo.fromJson(nodoData);
        
        // Agregar datos de última lectura si existe
        if (nodoData['ultima_lectura'] != null && 
            (nodoData['ultima_lectura'] as List).isNotEmpty) {
          final ultimaLectura = (nodoData['ultima_lectura'] as List).first;
          nodo.ultimoLux = (ultimaLectura['lux'] as num?)?.toDouble();
          nodo.ultimoRuido = (ultimaLectura['ruido'] as num?)?.toDouble();
          nodo.fechaUltimaLectura = DateTime.parse(ultimaLectura['fecha']);
        }
        
        nodos.add(nodo);
      }

      return nodos;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener nodos: $e');
      }
      rethrow;
    }
  }

  /// Obtener un nodo por ID
  static Future<Nodo?> obtenerNodoPorId(String id) async {
    try {
      final response = await _supabase.client
          .from('nodos')
          .select('*')
          .eq('id', id)
          .single();

      return Nodo.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener nodo $id: $e');
      }
      return null;
    }
  }

  /// Obtener nodos por estado
  static Future<List<Nodo>> obtenerNodosPorEstado(String estado) async {
    final todosLosNodos = await obtenerTodosLosNodos();
    
    return todosLosNodos.where((nodo) {
      return nodo.obtenerEstado() == estado;
    }).toList();
  }

  /// Obtener estadísticas de nodos
  static Future<Map<String, int>> obtenerEstadisticas() async {
    final nodos = await obtenerTodosLosNodos();
    
    int total = nodos.length;
    int online = 0;
    int offline = 0;
    int conAlerta = 0;
    
    for (var nodo in nodos) {
      final estado = nodo.obtenerEstado();
      if (estado == 'online') online++;
      if (estado == 'offline' || estado == 'sin_datos') offline++;
      if (estado == 'alerta') conAlerta++;
    }
    
    return {
      'total': total,
      'online': online,
      'offline': offline,
      'alerta': conAlerta,
    };
  }

  /// Crear nuevo nodo
  static Future<Nodo> crearNodo({
    required String nombre,
    required String claveDelDispositivo,
    required double latitud,
    required double longitud,
  }) async {
    try {
      if (kDebugMode) {
        print('➕ Creando nuevo nodo: $nombre');
      }

      final response = await _supabase.client
          .from('nodos')
          .insert({
            'nombre': nombre,
            'clave_del_dispositivo': claveDelDispositivo,
            'latitud': latitud,
            'longitud': longitud,
            'activo': true,
          })
          .select()
          .single();

      if (kDebugMode) {
        print('✅ Nodo creado exitosamente');
      }

      return Nodo.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al crear nodo: $e');
      }
      rethrow;
    }
  }

  /// Actualizar nodo
  static Future<Nodo> actualizarNodo({
    required String id,
    String? nombre,
    String? claveDelDispositivo,
    double? latitud,
    double? longitud,
    bool? activo,
  }) async {
    try {
      if (kDebugMode) {
        print('📝 Actualizando nodo: $id');
      }

      final Map<String, dynamic> updates = {};
      
      if (nombre != null) updates['nombre'] = nombre;
      if (claveDelDispositivo != null) updates['clave_del_dispositivo'] = claveDelDispositivo;
      if (latitud != null) updates['latitud'] = latitud;
      if (longitud != null) updates['longitud'] = longitud;
      if (activo != null) updates['activo'] = activo;

      final response = await _supabase.client
          .from('nodos')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      if (kDebugMode) {
        print('✅ Nodo actualizado exitosamente');
      }

      return Nodo.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al actualizar nodo: $e');
      }
      rethrow;
    }
  }

  /// Eliminar nodo
  static Future<void> eliminarNodo(String id) async {
    try {
      if (kDebugMode) {
        print('🗑️ Eliminando nodo: $id');
      }

      await _supabase.client
          .from('nodos')
          .delete()
          .eq('id', id);

      if (kDebugMode) {
        print('✅ Nodo eliminado exitosamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al eliminar nodo: $e');
      }
      rethrow;
    }
  }

  /// Cambiar estado activo de un nodo
  static Future<void> cambiarEstadoActivo(String id, bool activo) async {
    await actualizarNodo(id: id, activo: activo);
  }

  /// Obtener lecturas de un nodo
  static Future<List<Lectura>> obtenerLecturasDeNodo({
    required String nodoId,
    int limite = 100,
  }) async {
    try {
      if (kDebugMode) {
        print('📊 Obteniendo lecturas del nodo: $nodoId');
      }

      final response = await _supabase.client
          .from('lecturas')
          .select('''
            *,
            nodo:nodos(nombre, clave_del_dispositivo)
          ''')
          .eq('nodo_id', nodoId)
          .order('fecha', ascending: false)
          .limit(limite);

      final List<Lectura> lecturas = [];
      
      for (var lecturaData in response) {
        final lectura = Lectura.fromJson(lecturaData);
        
        // Agregar info del nodo si existe
        if (lecturaData['nodo'] != null) {
          final nodoData = lecturaData['nodo'];
          lectura.nombreNodo = nodoData['nombre'];
          lectura.claveDispositivo = nodoData['clave_del_dispositivo'];
        }
        
        lecturas.add(lectura);
      }

      if (kDebugMode) {
        print('✅ ${lecturas.length} lecturas obtenidas');
      }

      return lecturas;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener lecturas: $e');
      }
      rethrow;
    }
  }

  /// Obtener última lectura de un nodo
  static Future<Lectura?> obtenerUltimaLectura(String nodoId) async {
    try {
      final response = await _supabase.client
          .from('lecturas')
          .select('*')
          .eq('nodo_id', nodoId)
          .order('fecha', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      return Lectura.fromJson(response.first);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener última lectura: $e');
      }
      return null;
    }
  }

  /// Obtener lecturas recientes (últimas 24 horas)
  static Future<List<Lectura>> obtenerLecturasRecientes({int horas = 24}) async {
    try {
      final fechaLimite = DateTime.now().subtract(Duration(hours: horas));

      final response = await _supabase.client
          .from('lecturas')
          .select('''
            *,
            nodo:nodos(nombre, clave_del_dispositivo)
          ''')
          .gte('fecha', fechaLimite.toIso8601String())
          .order('fecha', ascending: false);

      final List<Lectura> lecturas = [];
      
      for (var lecturaData in response) {
        final lectura = Lectura.fromJson(lecturaData);
        
        if (lecturaData['nodo'] != null) {
          final nodoData = lecturaData['nodo'];
          lectura.nombreNodo = nodoData['nombre'];
          lectura.claveDispositivo = nodoData['clave_del_dispositivo'];
        }
        
        lecturas.add(lectura);
      }

      return lecturas;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener lecturas recientes: $e');
      }
      rethrow;
    }
  }

  /// Obtener lecturas con alertas
  static Future<List<Lectura>> obtenerLecturasConAlertas({int limite = 50}) async {
    try {
      // Obtener lecturas con luz baja O ruido alto
      final response = await _supabase.client
          .from('lecturas')
          .select('''
            *,
            nodo:nodos(nombre, clave_del_dispositivo)
          ''')
          .or('lux.lt.50,ruido.gt.80')
          .order('fecha', ascending: false)
          .limit(limite);

      final List<Lectura> lecturas = [];
      
      for (var lecturaData in response) {
        final lectura = Lectura.fromJson(lecturaData);
        
        if (lecturaData['nodo'] != null) {
          final nodoData = lecturaData['nodo'];
          lectura.nombreNodo = nodoData['nombre'];
          lectura.claveDispositivo = nodoData['clave_del_dispositivo'];
        }
        
        lecturas.add(lectura);
      }

      return lecturas;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener lecturas con alertas: $e');
      }
      rethrow;
    }
  }

  /// Crear nueva lectura (para pruebas o inserción manual)
  static Future<Lectura> crearLectura({
    required String nodoId,
    required double lux,
    required double ruido,
  }) async {
    try {
      final response = await _supabase.client
          .from('lecturas')
          .insert({
            'nodo_id': nodoId,
            'lux': lux,
            'ruido': ruido,
          })
          .select()
          .single();

      return Lectura.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al crear lectura: $e');
      }
      rethrow;
    }
  }
}
