import 'dart:math' as math;

/// Modelo para la tabla nodos (sensores físicos)
class Nodo {
  final String id;
  final String nombre;
  final double lat;
  final double lon;
  final String deviceKey;
  final bool activo;
  final DateTime createdAt;

  Nodo({
    required this.id,
    required this.nombre,
    required this.lat,
    required this.lon,
    required this.deviceKey,
    required this.activo,
    required this.createdAt,
  });

  /// Crear Nodo desde JSON (respuesta de Supabase)
  factory Nodo.fromJson(Map<String, dynamic> json) {
    return Nodo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      deviceKey: json['device_key'] as String,
      activo: json['activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir Nodo a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'lat': lat,
      'lon': lon,
      'device_key': deviceKey,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear copia del nodo con campos modificados
  Nodo copyWith({
    String? id,
    String? nombre,
    double? lat,
    double? lon,
    String? deviceKey,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Nodo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      deviceKey: deviceKey ?? this.deviceKey,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtener coordenadas como LatLng para flutter_map
  get coordenadas => [lat, lon];

  /// Calcular distancia aproximada a otro punto (en metros)
  double distanciaA(double otherLat, double otherLon) {
    const double radioTierra = 6371000; // metros
    final double dLat = _gradosARadianes(otherLat - lat);
    final double dLon = _gradosARadianes(otherLon - lon);
    
    final double a = (dLat / 2) * (dLat / 2) +
        _gradosARadianes(lat) * _gradosARadianes(otherLat) *
        (dLon / 2) * (dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * (3.14159265359 / 180);
  }

  @override
  String toString() {
    return 'Nodo(id: $id, nombre: $nombre, lat: $lat, lon: $lon, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Nodo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}