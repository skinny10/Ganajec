class AdminUsuario {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final bool isActive;

  const AdminUsuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.isActive,
  });

  factory AdminUsuario.fromJson(Map<String, dynamic> j) => AdminUsuario(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? 'Sin nombre',
        email: j['email'] as String? ?? '',
        rol: j['rol'] as String? ?? 'sin_rol',
        isActive: j['is_active'] as bool? ?? j['activo'] as bool? ?? true,
      );
}
