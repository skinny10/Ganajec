import '../../domain/entities/usuario.dart';

class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.email,
    required super.rol,
    required super.estado,
    super.avatarUrl,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      rol: RolUsuario.values.firstWhere((r) => r.name == json['rol']),
      estado: EstadoUsuario.values.firstWhere((e) => e.name == json['estado']),
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol.name,
      'estado': estado.name,
      'avatar_url': avatarUrl,
    };
  }
}
