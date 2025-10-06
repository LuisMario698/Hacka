/// Modelo para los nodos/sensores IoT
class Nodo {
  final String id;
  final String nombre;
  final String claveDelDispositivo;
  final double latitud;
  final double longitud;
  final bool activo;
  final DateTime createdAt;
  
  // Datos de la última lectura (opcional)
  double? ultimoLux;
  double? ultimoRuido;
  DateTime? fechaUltimaLectura;
  
  Nodo({
    required this.id,
    required this.nombre,
    required this.claveDelDispositivo,
    required this.latitud,
    required this.longitud,
    required this.activo,
    required this.createdAt,
    this.ultimoLux,
    this.ultimoRuido,
    this.fechaUltimaLectura,
  });

  /// Crear desde JSON de Supabase
  factory Nodo.fromJson(Map<String, dynamic> json) {
    return Nodo(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      claveDelDispositivo: json['clave_del_dispositivo'] as String,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      activo: json['activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      ultimoLux: json['ultimo_lux'] != null ? (json['ultimo_lux'] as num).toDouble() : null,
      ultimoRuido: json['ultimo_ruido'] != null ? (json['ultimo_ruido'] as num).toDouble() : null,
      fechaUltimaLectura: json['fecha_ultima_lectura'] != null 
          ? DateTime.parse(json['fecha_ultima_lectura'] as String) 
          : null,
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'clave_del_dispositivo': claveDelDispositivo,
      'latitud': latitud,
      'longitud': longitud,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Estado del sensor basado en la última lectura
  String obtenerEstado() {
    if (!activo) return 'offline';
    
    if (fechaUltimaLectura == null) return 'sin_datos';
    
    final diferencia = DateTime.now().difference(fechaUltimaLectura!);
    
    // Si no hay lecturas en los últimos 15 minutos, está offline
    if (diferencia.inMinutes > 15) return 'offline';
    
    // Si hay alerta por luz baja o ruido alto
    if (ultimoLux != null && ultimoLux! < 50) return 'alerta';
    if (ultimoRuido != null && ultimoRuido! > 80) return 'alerta';
    
    return 'online';
  }

  /// Nivel de batería estimado (simulado basado en tiempo activo)
  int obtenerNivelBateria() {
    if (!activo || fechaUltimaLectura == null) return 0;
    
    final horasActivo = DateTime.now().difference(createdAt).inHours;
    // Batería disminuye ~1% por hora (máximo 100 horas)
    final bateria = 100 - (horasActivo % 100);
    return bateria.clamp(0, 100);
  }

  /// Copiar con modificaciones
  Nodo copyWith({
    String? id,
    String? nombre,
    String? claveDelDispositivo,
    double? latitud,
    double? longitud,
    bool? activo,
    DateTime? createdAt,
    double? ultimoLux,
    double? ultimoRuido,
    DateTime? fechaUltimaLectura,
  }) {
    return Nodo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      claveDelDispositivo: claveDelDispositivo ?? this.claveDelDispositivo,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      ultimoLux: ultimoLux ?? this.ultimoLux,
      ultimoRuido: ultimoRuido ?? this.ultimoRuido,
      fechaUltimaLectura: fechaUltimaLectura ?? this.fechaUltimaLectura,
    );
  }
}
