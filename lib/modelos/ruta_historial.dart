import 'dart:convert';

/// Modelo para la tabla rutas_historial
class RutaHistorial {
  final String id;
  final String usuarioId;
  final double origenLat;
  final double origenLon;
  final double destinoLat;
  final double destinoLon;
  final Map<String, dynamic> geojsonRuta;
  final double? distanciaKm;
  final int? duracionEstimadaMin;
  final int? seguridadPromedio;
  final DateTime createdAt;

  RutaHistorial({
    required this.id,
    required this.usuarioId,
    required this.origenLat,
    required this.origenLon,
    required this.destinoLat,
    required this.destinoLon,
    required this.geojsonRuta,
    this.distanciaKm,
    this.duracionEstimadaMin,
    this.seguridadPromedio,
    required this.createdAt,
  });

  /// Crear RutaHistorial desde JSON (respuesta de Supabase)
  factory RutaHistorial.fromJson(Map<String, dynamic> json) {
    return RutaHistorial(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      origenLat: (json['origen_lat'] as num).toDouble(),
      origenLon: (json['origen_lon'] as num).toDouble(),
      destinoLat: (json['destino_lat'] as num).toDouble(),
      destinoLon: (json['destino_lon'] as num).toDouble(),
      geojsonRuta: json['geojson_ruta'] is String 
          ? jsonDecode(json['geojson_ruta'] as String)
          : json['geojson_ruta'] as Map<String, dynamic>,
      distanciaKm: (json['distancia_km'] as num?)?.toDouble(),
      duracionEstimadaMin: json['duracion_estimada_min'] as int?,
      seguridadPromedio: json['seguridad_promedio'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir RutaHistorial a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'origen_lat': origenLat,
      'origen_lon': origenLon,
      'destino_lat': destinoLat,
      'destino_lon': destinoLon,
      'geojson_ruta': geojsonRuta,
      'distancia_km': distanciaKm,
      'duracion_estimada_min': duracionEstimadaMin,
      'seguridad_promedio': seguridadPromedio,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear copia de la ruta con campos modificados
  RutaHistorial copyWith({
    String? id,
    String? usuarioId,
    double? origenLat,
    double? origenLon,
    double? destinoLat,
    double? destinoLon,
    Map<String, dynamic>? geojsonRuta,
    double? distanciaKm,
    int? duracionEstimadaMin,
    int? seguridadPromedio,
    DateTime? createdAt,
  }) {
    return RutaHistorial(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      origenLat: origenLat ?? this.origenLat,
      origenLon: origenLon ?? this.origenLon,
      destinoLat: destinoLat ?? this.destinoLat,
      destinoLon: destinoLon ?? this.destinoLon,
      geojsonRuta: geojsonRuta ?? this.geojsonRuta,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      duracionEstimadaMin: duracionEstimadaMin ?? this.duracionEstimadaMin,
      seguridadPromedio: seguridadPromedio ?? this.seguridadPromedio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtener coordenadas de origen
  List<double> get coordenadasOrigen => [origenLat, origenLon];

  /// Obtener coordenadas de destino
  List<double> get coordenadasDestino => [destinoLat, destinoLon];

  /// Obtener puntos de la ruta desde GeoJSON
  List<List<double>> get puntosRuta {
    try {
      if (geojsonRuta['type'] == 'LineString') {
        final coordinates = geojsonRuta['coordinates'] as List;
        return coordinates.map((coord) => [
          (coord[1] as num).toDouble(), // lat
          (coord[0] as num).toDouble(), // lon
        ]).toList();
      } else if (geojsonRuta['type'] == 'FeatureCollection') {
        final features = geojsonRuta['features'] as List;
        final List<List<double>> allPoints = [];
        
        for (final feature in features) {
          if (feature['geometry']['type'] == 'LineString') {
            final coordinates = feature['geometry']['coordinates'] as List;
            allPoints.addAll(coordinates.map((coord) => [
              (coord[1] as num).toDouble(), // lat
              (coord[0] as num).toDouble(), // lon
            ]));
          }
        }
        return allPoints;
      }
    } catch (e) {
      print('Error procesando GeoJSON: $e');
    }
    return [];
  }

  /// Obtener tipo de ruta basado en seguridad
  TipoRuta get tipoRuta {
    if (seguridadPromedio == null) return TipoRuta.equilibrada;
    
    if (seguridadPromedio! >= 8) {
      return TipoRuta.guardian;
    } else if (seguridadPromedio! >= 6) {
      return TipoRuta.equilibrada;
    } else {
      return TipoRuta.rapida;
    }
  }

  /// Obtener nombre legible de la ruta
  String get nombreRuta {
    switch (tipoRuta) {
      case TipoRuta.guardian:
        return 'Ruta Guardián';
      case TipoRuta.equilibrada:
        return 'Ruta Equilibrada';
      case TipoRuta.rapida:
        return 'Ruta Rápida';
    }
  }

  /// Obtener color de la ruta
  String get colorRuta {
    switch (tipoRuta) {
      case TipoRuta.guardian:
        return '#FFD600'; // Amarillo/Dorado
      case TipoRuta.equilibrada:
        return '#00CFFF'; // Azul cian
      case TipoRuta.rapida:
        return '#1DE9B6'; // Verde menta
    }
  }

  /// Obtener texto de duración formateado
  String get duracionTexto {
    if (duracionEstimadaMin == null) return 'N/A';
    return '$duracionEstimadaMin min';
  }

  /// Obtener texto de distancia formateado
  String get distanciaTexto {
    if (distanciaKm == null) return 'N/A';
    return '${distanciaKm!.toStringAsFixed(1)} km';
  }

  /// Obtener porcentaje de iluminación formateado
  String get iluminacionTexto {
    if (seguridadPromedio == null) return 'N/A';
    return '${(seguridadPromedio! * 10)}%';
  }

  @override
  String toString() {
    return 'RutaHistorial(id: $id, origen: [$origenLat, $origenLon], destino: [$destinoLat, $destinoLon], distancia: ${distanciaKm}km)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RutaHistorial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum para tipos de ruta
enum TipoRuta {
  guardian,
  equilibrada,
  rapida;

  String get displayName {
    switch (this) {
      case TipoRuta.guardian:
        return 'Guardián';
      case TipoRuta.equilibrada:
        return 'Equilibrada';
      case TipoRuta.rapida:
        return 'Rápida';
    }
  }
}