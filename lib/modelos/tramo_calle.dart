import 'dart:math' as math;

/// Modelo para la tabla tramos_calle
class TramoCalle {
  final int id;
  final String? nombreCalle;
  final double latInicio;
  final double lonInicio;
  final double latFin;
  final double lonFin;
  final int nivelSeguridad;
  final DateTime? ultimaActualizacion;

  TramoCalle({
    required this.id,
    this.nombreCalle,
    required this.latInicio,
    required this.lonInicio,
    required this.latFin,
    required this.lonFin,
    required this.nivelSeguridad,
    this.ultimaActualizacion,
  });

  /// Crear TramoCalle desde JSON (respuesta de Supabase)
  factory TramoCalle.fromJson(Map<String, dynamic> json) {
    return TramoCalle(
      id: json['id'] as int,
      nombreCalle: json['nombre_calle'] as String?,
      latInicio: (json['lat_inicio'] as num).toDouble(),
      lonInicio: (json['lon_inicio'] as num).toDouble(),
      latFin: (json['lat_fin'] as num).toDouble(),
      lonFin: (json['lon_fin'] as num).toDouble(),
      nivelSeguridad: json['nivel_seguridad'] as int,
      ultimaActualizacion: json['ultima_actualizacion'] != null
          ? DateTime.parse(json['ultima_actualizacion'] as String)
          : null,
    );
  }

  /// Convertir TramoCalle a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_calle': nombreCalle,
      'lat_inicio': latInicio,
      'lon_inicio': lonInicio,
      'lat_fin': latFin,
      'lon_fin': lonFin,
      'nivel_seguridad': nivelSeguridad,
      'ultima_actualizacion': ultimaActualizacion?.toIso8601String(),
    };
  }

  /// Crear copia del tramo con campos modificados
  TramoCalle copyWith({
    int? id,
    String? nombreCalle,
    double? latInicio,
    double? lonInicio,
    double? latFin,
    double? lonFin,
    int? nivelSeguridad,
    DateTime? ultimaActualizacion,
  }) {
    return TramoCalle(
      id: id ?? this.id,
      nombreCalle: nombreCalle ?? this.nombreCalle,
      latInicio: latInicio ?? this.latInicio,
      lonInicio: lonInicio ?? this.lonInicio,
      latFin: latFin ?? this.latFin,
      lonFin: lonFin ?? this.lonFin,
      nivelSeguridad: nivelSeguridad ?? this.nivelSeguridad,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }

  /// Obtener coordenadas de inicio
  List<double> get coordenadasInicio => [latInicio, lonInicio];

  /// Obtener coordenadas de fin
  List<double> get coordenadasFin => [latFin, lonFin];

  /// Obtener punto central del tramo
  List<double> get coordenadasCentro => [
    (latInicio + latFin) / 2,
    (lonInicio + lonFin) / 2,
  ];

  /// Obtener línea completa como lista de coordenadas
  List<List<double>> get lineaCompleta => [
    [latInicio, lonInicio],
    [latFin, lonFin],
  ];

  /// Calcular longitud aproximada del tramo (en metros)
  double get longitud {
    const double radioTierra = 6371000; // metros
    final double dLat = _gradosARadianes(latFin - latInicio);
    final double dLon = _gradosARadianes(lonFin - lonInicio);
    
    final double a = (dLat / 2) * (dLat / 2) +
        _gradosARadianes(latInicio) * _gradosARadianes(latFin) *
        (dLon / 2) * (dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * (3.14159265359 / 180);
  }

  /// Obtener categoría de seguridad
  CategoriaSeguridad get categoriaSeguridad {
    if (nivelSeguridad >= 8) {
      return CategoriaSeguridad.alta;
    } else if (nivelSeguridad >= 6) {
      return CategoriaSeguridad.media;
    } else if (nivelSeguridad >= 4) {
      return CategoriaSeguridad.baja;
    } else {
      return CategoriaSeguridad.peligrosa;
    }
  }

  /// Obtener color basado en nivel de seguridad
  String get colorSeguridad {
    switch (categoriaSeguridad) {
      case CategoriaSeguridad.alta:
        return '#4CAF50'; // Verde
      case CategoriaSeguridad.media:
        return '#FF9800'; // Naranja
      case CategoriaSeguridad.baja:
        return '#FF5722'; // Rojo naranja
      case CategoriaSeguridad.peligrosa:
        return '#F44336'; // Rojo
    }
  }

  /// Obtener descripción de seguridad
  String get descripcionSeguridad {
    switch (categoriaSeguridad) {
      case CategoriaSeguridad.alta:
        return 'Muy seguro';
      case CategoriaSeguridad.media:
        return 'Moderadamente seguro';
      case CategoriaSeguridad.baja:
        return 'Poco seguro';
      case CategoriaSeguridad.peligrosa:
        return 'Peligroso';
    }
  }

  /// Obtener porcentaje de seguridad
  double get porcentajeSeguridad => (nivelSeguridad / 10.0) * 100;

  /// Verificar si el tramo necesita actualización (más de 24 horas)
  bool get necesitaActualizacion {
    if (ultimaActualizacion == null) return true;
    final diferencia = DateTime.now().difference(ultimaActualizacion!);
    return diferencia.inHours > 24;
  }

  /// Verificar si un punto está cercano a este tramo
  bool estaCercaDe(double lat, double lon, {double toleranciaMetros = 100}) {
    // Calcular distancia al punto más cercano en la línea
    final distancia = _distanciaAPunto(lat, lon);
    return distancia <= toleranciaMetros;
  }

  /// Calcular distancia mínima desde un punto a esta línea
  double _distanciaAPunto(double lat, double lon) {
    // Implementación simplificada usando distancia euclidiana proyectada
    final double A = lat - latInicio;
    final double B = lon - lonInicio;
    final double C = latFin - latInicio;
    final double D = lonFin - lonInicio;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;

    if (lenSq == 0) {
      // Punto inicio y fin son iguales
      return _calcularDistancia(lat, lon, latInicio, lonInicio);
    }

    double param = dot / lenSq;
    param = param.clamp(0.0, 1.0);

    final double xx = latInicio + param * C;
    final double yy = lonInicio + param * D;

    return _calcularDistancia(lat, lon, xx, yy);
  }

  double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const double radioTierra = 6371000; // metros
    final double dLat = _gradosARadianes(lat2 - lat1);
    final double dLon = _gradosARadianes(lon2 - lon1);
    
    final double a = (dLat / 2) * (dLat / 2) +
        _gradosARadianes(lat1) * _gradosARadianes(lat2) *
        (dLon / 2) * (dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return radioTierra * c;
  }

  @override
  String toString() {
    return 'TramoCalle(id: $id, nombre: $nombreCalle, seguridad: $nivelSeguridad/10)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TramoCalle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum para categorías de seguridad
enum CategoriaSeguridad {
  alta,
  media,
  baja,
  peligrosa;

  String get displayName {
    switch (this) {
      case CategoriaSeguridad.alta:
        return 'Alta';
      case CategoriaSeguridad.media:
        return 'Media';
      case CategoriaSeguridad.baja:
        return 'Baja';
      case CategoriaSeguridad.peligrosa:
        return 'Peligrosa';
    }
  }
}