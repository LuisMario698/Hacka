/// Modelo para las lecturas de sensores
class Lectura {
  final int identificacion;
  final String nodoId;
  final double lux;
  final double ruido;
  final DateTime fecha;
  
  // Información adicional del nodo (opcional)
  String? nombreNodo;
  String? claveDispositivo;

  Lectura({
    required this.identificacion,
    required this.nodoId,
    required this.lux,
    required this.ruido,
    required this.fecha,
    this.nombreNodo,
    this.claveDispositivo,
  });

  /// Crear desde JSON de Supabase
  factory Lectura.fromJson(Map<String, dynamic> json) {
    return Lectura(
      identificacion: json['identificacion'] as int,
      nodoId: json['nodo_id'] as String,
      lux: (json['lux'] as num).toDouble(),
      ruido: (json['ruido'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
      nombreNodo: json['nombre_nodo'] as String?,
      claveDispositivo: json['clave_dispositivo'] as String?,
    );
  }

  /// Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'nodo_id': nodoId,
      'lux': lux,
      'ruido': ruido,
      'fecha': fecha.toIso8601String(),
    };
  }

  /// Evaluar nivel de luz
  String evaluarLuz() {
    if (lux < 50) return 'Baja';
    if (lux < 200) return 'Media';
    if (lux < 500) return 'Alta';
    return 'Muy Alta';
  }

  /// Evaluar nivel de ruido
  String evaluarRuido() {
    if (ruido < 40) return 'Silencioso';
    if (ruido < 60) return 'Moderado';
    if (ruido < 80) return 'Alto';
    return 'Muy Alto';
  }

  /// ¿Tiene alerta?
  bool tieneAlerta() {
    return lux < 50 || ruido > 80;
  }

  /// Tipo de alerta
  String? obtenerTipoAlerta() {
    if (lux < 50 && ruido > 80) return 'Luz baja y ruido alto';
    if (lux < 50) return 'Iluminación deficiente';
    if (ruido > 80) return 'Ruido excesivo';
    return null;
  }
}
