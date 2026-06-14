enum RolUsuario { ganadero, dueno, veterinario, admin }

enum EstadoUsuario { activo, inactivo }

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final RolUsuario rol;
  final EstadoUsuario estado;
  final String? avatarUrl;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.estado,
    this.avatarUrl,
  });

  String get rolTexto {
    switch (rol) {
      case RolUsuario.ganadero:
        return 'Ganadero';
      case RolUsuario.dueno:
        return 'Dueño';
      case RolUsuario.veterinario:
        return 'Veterinario';
      case RolUsuario.admin:
        return 'Administrador';
    }
  }

  bool get estaActivo => estado == EstadoUsuario.activo;
}

class UsuarioStats {
  final int totalUsuarios;
  final int totalGanaderos;
  final int totalDuenos;
  final int totalVeterinarios;

  const UsuarioStats({
    required this.totalUsuarios,
    required this.totalGanaderos,
    required this.totalDuenos,
    required this.totalVeterinarios,
  });
}
