enum TipoAcceso { login, logout, consulta, modificacion, sistema }

class RegistroAuditoria {
  final String id;
  final String hora;
  final String nombreUsuario;
  final String accion;
  final String? detalle;
  final TipoAcceso tipo;
  final String? avatarUrl;

  const RegistroAuditoria({
    required this.id,
    required this.hora,
    required this.nombreUsuario,
    required this.accion,
    required this.tipo,
    this.detalle,
    this.avatarUrl,
  });

  String get iniciales {
    final partes = nombreUsuario.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombreUsuario.substring(0, 2).toUpperCase();
  }
}

class AuditoriaStats {
  final int totalAccesos;
  final String periodo;
  final int usuariosActivos;

  const AuditoriaStats({
    required this.totalAccesos,
    required this.periodo,
    required this.usuariosActivos,
  });
}
