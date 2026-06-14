import 'package:flutter/material.dart';
import '../../domain/entities/auditoria.dart';

class AuditoriaTimelineTile extends StatelessWidget {
  final RegistroAuditoria registro;
  final bool isLast;

  const AuditoriaTimelineTile({
    super.key,
    required this.registro,
    this.isLast = false,
  });

  Color _colorTipo(TipoAcceso tipo) {
    switch (tipo) {
      case TipoAcceso.login:
        return const Color(0xFF2E7D32);
      case TipoAcceso.logout:
        return const Color(0xFFC62828);
      case TipoAcceso.modificacion:
        return const Color(0xFFE65100);
      case TipoAcceso.consulta:
        return const Color(0xFF1565C0);
      case TipoAcceso.sistema:
        return const Color(0xFF6A1B9A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorTipo(registro.tipo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            SizedBox(
              width: 60,
              child: Text(
                registro.hora,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              width: 2,
              height: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                registro.iniciales,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${registro.nombreUsuario}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '  \u2022  ${registro.accion}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    registro.detalle ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Container(
              width: 2,
              height: 40,
              color: Colors.grey.shade300,
            ),
          ),
      ],
    );
  }
}
