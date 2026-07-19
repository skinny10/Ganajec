class SistemaEstado {
  final int totalUsuarios;
  final int totalRanchos;
  final int totalBovinos;
  final int usuariosActivos;

  const SistemaEstado({
    required this.totalUsuarios,
    required this.totalRanchos,
    required this.totalBovinos,
    required this.usuariosActivos,
  });

  factory SistemaEstado.fromJson(Map<String, dynamic> j) => SistemaEstado(
        totalUsuarios: (j['total_usuarios'] as num?)?.toInt() ?? 0,
        totalRanchos: (j['total_ranchos'] as num?)?.toInt() ?? 0,
        totalBovinos: (j['total_bovinos'] as num?)?.toInt() ?? 0,
        usuariosActivos: (j['usuarios_activos'] as num?)?.toInt() ?? 0,
      );
}
