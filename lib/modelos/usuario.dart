/// Modelo para la tabla usuarios
class Usuario {
  final String id;
  final String email;
  final String nombre;
  final String? telefono;
  final String? avatarUrl;
  final int rolId;
  final String? rolNombre; // Desde JOIN con roles
  final bool estaActivo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? ultimoLogin;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.telefono,
    this.avatarUrl,
    required this.rolId,
    this.rolNombre,
    required this.estaActivo,
    required this.createdAt,
    this.updatedAt,
    this.ultimoLogin,
  });

  /// Crear Usuario desde JSON (respuesta de Supabase)
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      email: json['email'] as String,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      rolId: json['rol_id'] as int,
      rolNombre: json['rol_nombre'] as String?, // Puede venir de un JOIN
      estaActivo: json['esta_activo'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      ultimoLogin: json['ultimo_login'] != null
          ? DateTime.parse(json['ultimo_login'] as String)
          : null,
    );
  }

  /// Convertir Usuario a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'avatar_url': avatarUrl,
      'rol_id': rolId,
      'esta_activo': estaActivo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'ultimo_login': ultimoLogin?.toIso8601String(),
    };
  }

  /// Crear copia del usuario con campos modificados
  Usuario copyWith({
    String? id,
    String? email,
    String? nombre,
    String? telefono,
    String? avatarUrl,
    int? rolId,
    String? rolNombre,
    bool? estaActivo,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? ultimoLogin,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rolId: rolId ?? this.rolId,
      rolNombre: rolNombre ?? this.rolNombre,
      estaActivo: estaActivo ?? this.estaActivo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
    );
  }

  /// Helper: Obtener nombre del rol
  String get rol => rolNombre ?? _getRolName(rolId);

  /// Helper: Verificar si es administrador
  bool get esAdmin => rolId >= 3; // administrador (3) o super_admin (4)

  /// Helper: Verificar si es super admin
  bool get esSuperAdmin => rolId == 4;

  /// Helper: Verificar si es moderador
  bool get esModerador => rolId >= 2; // moderador (2), admin (3) o super_admin (4)

  static String _getRolName(int rolId) {
    switch (rolId) {
      case 1: return 'usuario';
      case 2: return 'moderador';
      case 3: return 'administrador';
      case 4: return 'super_admin';
      default: return 'usuario';
    }
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

/// Modelo para la tabla roles
class Rol {
  final int id;
  final String nombre;
  final String? descripcion;
  final List<String> permisos;

  Rol({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.permisos,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      permisos: json['permisos'] != null
          ? List<String>.from(json['permisos'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'permisos': permisos,
    };
  }
}