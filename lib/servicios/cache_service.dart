import 'dart:async';

/// Servicio de caché en memoria para optimizar el rendimiento
/// Reduce llamadas repetidas a la base de datos
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Almacenamiento en memoria con timestamps
  final Map<String, _CacheEntry> _cache = {};

  // Duración del caché por tipo de dato (en minutos)
  static const Map<String, int> _cacheDurations = {
    'sensores': 2, // Sensores: 2 minutos
    'estadisticas_sensores': 3, // Estadísticas: 3 minutos
    'reportes': 1, // Reportes: 1 minuto (más críticos)
    'usuarios': 5, // Usuarios: 5 minutos (cambian poco)
    'dashboard_metrics': 2, // Métricas del dashboard: 2 minutos
  };

  /// Obtener datos del caché si existen y no han expirado
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Verificar si ha expirado
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Guardar datos en el caché con duración automática
  void set<T>(String key, T data, {String? category}) {
    // Determinar duración según categoría
    int durationMinutes = 2; // Default: 2 minutos
    if (category != null && _cacheDurations.containsKey(category)) {
      durationMinutes = _cacheDurations[category]!;
    }

    final expiresAt = DateTime.now().add(Duration(minutes: durationMinutes));
    _cache[key] = _CacheEntry(data: data, expiresAt: expiresAt);
  }

  /// Invalidar (eliminar) una entrada específica del caché
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalidar todas las entradas de una categoría
  void invalidateCategory(String category) {
    _cache.removeWhere((key, _) => key.startsWith('$category:'));
  }

  /// Limpiar todo el caché
  void clear() {
    _cache.clear();
  }

  /// Limpiar entradas expiradas (limpieza periódica)
  void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => now.isAfter(entry.expiresAt));
  }

  /// Obtener tamaño del caché
  int get size => _cache.length;

  /// Verificar si una clave existe y es válida
  bool has(String key) {
    return get(key) != null;
  }
}

/// Entrada del caché con timestamp de expiración
class _CacheEntry {
  final dynamic data;
  final DateTime expiresAt;

  _CacheEntry({required this.data, required this.expiresAt});
}

/// Wrapper para funciones que consultan datos con caché automático
class CachedQuery<T> {
  final String key;
  final String category;
  final Future<T> Function() query;

  CachedQuery({
    required this.key,
    required this.category,
    required this.query,
  });

  /// Ejecutar consulta con caché automático
  Future<T> execute({bool forceRefresh = false}) async {
    final cache = CacheService();

    // Intentar obtener del caché si no se fuerza refresh
    if (!forceRefresh) {
      final cached = cache.get<T>(key);
      if (cached != null) {
        return cached;
      }
    }

    // Ejecutar consulta y guardar en caché
    final result = await query();
    cache.set(key, result, category: category);
    return result;
  }
}
