/// Modelo para la tabla usuarios
class Usuario {
  final String id;
  final String email;
  final String? nombre;
  final String rol;
  final bool estaActivo;
  final DateTime createdAt;

  Usuario({
    required this.id,
    required this.email,
    this.nombre,
    required this.rol,
    required this.estaActivo,
    required this.createdAt,
  });

  /// Crear Usuario desde JSON (respuesta de Supabase)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String?,
      rol: json['rol'] as String,
      estaActivo: json['esta_activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir Usuario a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'rol': rol,
      'esta_activo': estaActivo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crear copia del usuario con campos modificados
  Usuario copyWith({
    String? id,
    String? email,
    String? nombre,
    String? rol,
    bool? estaActivo,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      estaActivo: estaActivo ?? this.estaActivo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, email: $email, nombre: $nombre, rol: $rol, estaActivo: $estaActivo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum para roles de usuario
enum RolUsuario {
  admin('admin'),
  usuario('usuario');

  const RolUsuario(this.value);
  final String value;

  static RolUsuario fromString(String value) {
    return RolUsuario.values.firstWhere(
      (rol) => rol.value == value,
      orElse: () => RolUsuario.usuario,
    );
  }
}