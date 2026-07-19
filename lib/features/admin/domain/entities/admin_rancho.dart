class AdminRancho {
  final String id;
  final String nombre;
  final String municipio;
  final String estado;
  final String duenoNombre;
  final int totalGanaderos;
  final int totalBovinos;

  const AdminRancho({
    required this.id,
    required this.nombre,
    required this.municipio,
    required this.estado,
    required this.duenoNombre,
    required this.totalGanaderos,
    required this.totalBovinos,
  });

  factory AdminRancho.fromJson(Map<String, dynamic> j) => AdminRancho(
        id: j['id'] as String? ?? '',
        nombre: j['nombre'] as String? ?? '—',
        municipio: j['municipio'] as String? ?? '—',
        estado: j['estado'] as String? ?? '—',
        duenoNombre: j['dueno_nombre'] as String? ?? '—',
        totalGanaderos: (j['total_ganaderos'] as num?)?.toInt() ?? 0,
        totalBovinos: (j['total_bovinos'] as num?)?.toInt() ?? 0,
      );
}
