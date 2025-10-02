/// Modelo para la tabla reportes
class Reporte {
  final String id;
  final String usuarioId;
  final String titulo;
  final String? descripcion;
  final double lat;
  final double lon;
  final String? urlEvidencia;
  final EstadoReporte estado;
  final DateTime createdAt;

  Reporte({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    this.descripcion,
    required this.lat,
    required this.lon,
    this.urlEvidencia,
    required this.estado,
    required this.createdAt,
  });

  /// Crear Reporte desde JSON (respuesta de Supabase)
  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      urlEvidencia: json['url_evidencia'] as String?,
      estado: EstadoReporte.fromString(json['estado'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir Reporte a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'descripcion': descripcion,
      'lat': lat,
      'lon': lon,
      'url_evidencia': urlEvidencia,
      'estado': estado.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear copia del reporte con campos modificados
  Reporte copyWith({
    String? id,
    String? usuarioId,
    String? titulo,
    String? descripcion,
    double? lat,
    double? lon,
    String? urlEvidencia,
    EstadoReporte? estado,
    DateTime? createdAt,
  }) {
    return Reporte(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      urlEvidencia: urlEvidencia ?? this.urlEvidencia,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Obtener coordenadas como LatLng para flutter_map
  get coordenadas => [lat, lon];

  /// Obtener icono según el tipo de reporte
  String get icono {
    if (titulo.toLowerCase().contains('foco') || titulo.toLowerCase().contains('luz')) {
      return '💡';
    } else if (titulo.toLowerCase().contains('oscur')) {
      return '🌙';
    } else if (titulo.toLowerCase().contains('sospech')) {
      return '👥';
    } else if (titulo.toLowerCase().contains('banquet') || titulo.toLowerCase().contains('peligro')) {
      return '🚧';
    } else if (titulo.toLowerCase().contains('polici')) {
      return '👮';
    }
    return '📍';
  }

  /// Obtener color según el estado
  String get colorEstado {
    switch (estado) {
      case EstadoReporte.nuevo:
        return '#FFA726'; // Naranja
      case EstadoReporte.enProceso:
        return '#42A5F5'; // Azul
      case EstadoReporte.resuelto:
        return '#66BB6A'; // Verde
      case EstadoReporte.rechazado:
        return '#EF5350'; // Rojo
    }
  }

  @override
  String toString() {
    return 'Reporte(id: $id, titulo: $titulo, estado: ${estado.value}, lat: $lat, lon: $lon)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reporte && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum para estados de reporte
enum EstadoReporte {
  nuevo('nuevo'),
  enProceso('en_proceso'),
  resuelto('resuelto'),
  rechazado('rechazado');

  const EstadoReporte(this.value);
  final String value;

  static EstadoReporte fromString(String value) {
    return EstadoReporte.values.firstWhere(
      (estado) => estado.value == value,
      orElse: () => EstadoReporte.nuevo,
    );
  }

  String get displayName {
    switch (this) {
      case EstadoReporte.nuevo:
        return 'Nuevo';
      case EstadoReporte.enProceso:
        return 'En Proceso';
      case EstadoReporte.resuelto:
        return 'Resuelto';
      case EstadoReporte.rechazado:
        return 'Rechazado';
    }
  }
}