/// Modelo para la tabla lecturas_sensor
class LecturaSensor {
  final int id;
  final DateTime fecha;
  final double luminosidad;
  final double ruido;

  LecturaSensor({
    required this.id,
    required this.fecha,
    required this.luminosidad,
    required this.ruido,
  });

  /// Crear LecturaSensor desde JSON (respuesta de Supabase)
  factory LecturaSensor.fromJson(Map<String, dynamic> json) {
    return LecturaSensor(
      id: json['id'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      luminosidad: (json['luminosidad'] as num).toDouble(),
      ruido: (json['ruido'] as num).toDouble(),
    );
  }

  /// Convertir LecturaSensor a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'luminosidad': luminosidad,
      'ruido': ruido,
    };
  }

  /// Crear copia de la lectura con campos modificados
  LecturaSensor copyWith({
    int? id,
    DateTime? fecha,
    double? luminosidad,
    double? ruido,
  }) {
    return LecturaSensor(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      luminosidad: luminosidad ?? this.luminosidad,
      ruido: ruido ?? this.ruido,
    );
  }

  /// Obtener nivel de luminosidad categorizado
  NivelLuminosidad get nivelLuminosidad {
    if (luminosidad >= 1000) {
      return NivelLuminosidad.muyAlto;
    } else if (luminosidad >= 500) {
      return NivelLuminosidad.alto;
    } else if (luminosidad >= 200) {
      return NivelLuminosidad.medio;
    } else if (luminosidad >= 50) {
      return NivelLuminosidad.bajo;
    } else {
      return NivelLuminosidad.muyBajo;
    }
  }

  /// Obtener nivel de ruido categorizado
  NivelRuido get nivelRuido {
    if (ruido >= 80) {
      return NivelRuido.muyAlto;
    } else if (ruido >= 70) {
      return NivelRuido.alto;
    } else if (ruido >= 60) {
      return NivelRuido.medio;
    } else if (ruido >= 50) {
      return NivelRuido.bajo;
    } else {
      return NivelRuido.muyBajo;
    }
  }

  /// Calcular puntaje de seguridad combinado (0-10)
  int get puntajeSeguridad {
    // La luminosidad contribuye 60% y el ruido 40%
    final puntajeLuz = _calcularPuntajeLuminosidad();
    final puntajeRuido = _calcularPuntajeRuido();
    
    final puntajeTotal = (puntajeLuz * 0.6) + (puntajeRuido * 0.4);
    return puntajeTotal.round().clamp(0, 10);
  }

  int _calcularPuntajeLuminosidad() {
    // Más luz = más seguro (hasta cierto punto)
    if (luminosidad >= 1000) return 10;
    if (luminosidad >= 500) return 9;
    if (luminosidad >= 300) return 8;
    if (luminosidad >= 200) return 7;
    if (luminosidad >= 100) return 6;
    if (luminosidad >= 50) return 4;
    if (luminosidad >= 20) return 2;
    return 0;
  }

  int _calcularPuntajeRuido() {
    // Menos ruido excesivo = más seguro, pero algo de ruido normal es bueno
    if (ruido >= 90) return 2; // Demasiado ruido
    if (ruido >= 80) return 4;
    if (ruido >= 70) return 6;
    if (ruido >= 60) return 8; // Nivel urbano normal
    if (ruido >= 50) return 7;
    if (ruido >= 40) return 5;
    if (ruido >= 30) return 3; // Demasiado silencioso puede ser sospechoso
    return 1;
  }

  /// Verificar si es una lectura nocturna (entre 20:00 y 06:00)
  bool get esNocturna {
    final hora = fecha.hour;
    return hora >= 20 || hora < 6;
  }

  /// Verificar si es una lectura reciente (menos de 1 hora)
  bool get esReciente {
    final diferencia = DateTime.now().difference(fecha);
    return diferencia.inHours < 1;
  }

  /// Obtener descripción de condiciones
  String get descripcionCondiciones {
    final luz = nivelLuminosidad.displayName;
    final sonido = nivelRuido.displayName;
    return 'Luz: $luz, Ruido: $sonido';
  }

  /// Verificar si las condiciones son favorables para caminar
  bool get condicionesFavorables {
    return puntajeSeguridad >= 6;
  }

  /// Obtener color representativo de la seguridad
  String get colorSeguridad {
    if (puntajeSeguridad >= 8) return '#4CAF50'; // Verde
    if (puntajeSeguridad >= 6) return '#FF9800'; // Naranja
    if (puntajeSeguridad >= 4) return '#FF5722'; // Rojo naranja
    return '#F44336'; // Rojo
  }

  /// Obtener emoji representativo
  String get emoji {
    if (puntajeSeguridad >= 8) return '✅';
    if (puntajeSeguridad >= 6) return '⚠️';
    if (puntajeSeguridad >= 4) return '⚠️';
    return '❌';
  }

  @override
  String toString() {
    return 'LecturaSensor(id: $id, fecha: $fecha, luminosidad: ${luminosidad}lx, ruido: ${ruido}dB, seguridad: $puntajeSeguridad/10)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LecturaSensor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum para niveles de luminosidad
enum NivelLuminosidad {
  muyBajo,
  bajo,
  medio,
  alto,
  muyAlto;

  String get displayName {
    switch (this) {
      case NivelLuminosidad.muyBajo:
        return 'Muy Oscuro';
      case NivelLuminosidad.bajo:
        return 'Oscuro';
      case NivelLuminosidad.medio:
        return 'Moderado';
      case NivelLuminosidad.alto:
        return 'Bien Iluminado';
      case NivelLuminosidad.muyAlto:
        return 'Muy Iluminado';
    }
  }
}

/// Enum para niveles de ruido
enum NivelRuido {
  muyBajo,
  bajo,
  medio,
  alto,
  muyAlto;

  String get displayName {
    switch (this) {
      case NivelRuido.muyBajo:
        return 'Muy Silencioso';
      case NivelRuido.bajo:
        return 'Silencioso';
      case NivelRuido.medio:
        return 'Moderado';
      case NivelRuido.alto:
        return 'Ruidoso';
      case NivelRuido.muyAlto:
        return 'Muy Ruidoso';
    }
  }
}