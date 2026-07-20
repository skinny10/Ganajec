class AuditLog {
  final String usuarioNombre;
  final String accion;
  final String entidadAfectada;
  final String creadoEn;

  const AuditLog({
    required this.usuarioNombre,
    required this.accion,
    required this.entidadAfectada,
    required this.creadoEn,
  });

  factory AuditLog.fromJson(Map<String, dynamic> j) => AuditLog(
        usuarioNombre: j['usuario_nombre'] as String? ?? '—',
        accion: j['accion'] as String? ?? '—',
        entidadAfectada: j['entidad_afectada'] as String? ?? '—',
        creadoEn: j['creado_en'] as String? ?? '',
      );
}

class SistemaEstado {
  final int totalUsuarios;
  final int totalRanchos;
  final int totalBovinos;
  final int usuariosActivos;
  final List<AuditLog> logs;

  const SistemaEstado({
    required this.totalUsuarios,
    required this.totalRanchos,
    required this.totalBovinos,
    required this.usuariosActivos,
    this.logs = const [],
  });

  factory SistemaEstado.fromJson(Map<String, dynamic> j) => SistemaEstado(
        totalUsuarios: (j['estadisticas']?['total_usuarios'] as num?)?.toInt() ?? 0,
        totalRanchos: (j['estadisticas']?['total_ranchos'] as num?)?.toInt() ?? 0,
        totalBovinos: (j['estadisticas']?['total_bovinos'] as num?)?.toInt() ?? 0,
        usuariosActivos: (j['estadisticas']?['usuarios_activos'] as num?)?.toInt() ?? 0,
        logs: ((j['logs_auditoria'] as Map?)?['detalle'] as List? ?? [])
            .map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
