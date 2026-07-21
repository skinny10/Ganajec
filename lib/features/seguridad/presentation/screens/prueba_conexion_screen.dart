import 'package:flutter/material.dart';
import 'package:ganajec/core/security/ssl_pinning.dart';

enum _Estado { idle, verificando, segura, bloqueada }

class PruebaConexionScreen extends StatefulWidget {
  const PruebaConexionScreen({super.key});

  @override
  State<PruebaConexionScreen> createState() => _PruebaConexionScreenState();
}

class _PruebaConexionScreenState extends State<PruebaConexionScreen> {
  _Estado _estado = _Estado.idle;

  Future<void> _probar() async {
    setState(() => _estado = _Estado.verificando);
    final segura = await SslPinning.verificarConexion();
    if (!mounted) return;
    setState(() => _estado = segura ? _Estado.segura : _Estado.bloqueada);
    if (!segura) {
      await SslPinning.mostrarDialogoError(context);
      setState(() => _estado = _Estado.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Prueba SSL Pinning',
            style: tt.titleMedium?.copyWith(
                fontSize: 16, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Ícono de estado ──────────────────────────────────────────
            _EstadoIcon(estado: _estado),
            const SizedBox(height: 28),

            // ── Texto descriptivo ────────────────────────────────────────
            Text(
              _titulo(_estado),
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _colorEstado(_estado, cs),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _subtitulo(_estado),
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // ── Info del certificado pinneado ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outlined, color: cs.primary, size: 16),
                      const SizedBox(width: 6),
                      Text('Certificado pinneado',
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Host: ${SslPinning.pinnedHost}',
                      style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    'SHA-256:\n${SslPinning.sha256Fingerprint}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontSize: 10,
                      fontFamily: 'monospace',
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Botón ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _estado == _Estado.verificando
                      ? cs.onSurface.withOpacity(0.5)
                      : cs.onSurface,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed:
                    _estado == _Estado.verificando ? null : _probar,
                icon: _estado == _Estado.verificando
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.wifi_protected_setup_rounded, size: 18),
                label: Text(
                  _estado == _Estado.verificando
                      ? 'Verificando...'
                      : 'Probar conexión',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titulo(_Estado e) => switch (e) {
        _Estado.idle => 'Listo para probar',
        _Estado.verificando => 'Verificando...',
        _Estado.segura => '¡Conexión segura!',
        _Estado.bloqueada => 'Conexión bloqueada',
      };

  String _subtitulo(_Estado e) => switch (e) {
        _Estado.idle =>
          'Presiona el botón para verificar que el servidor presenta el certificado correcto.',
        _Estado.verificando =>
          'Conectando con ${'ganajec.duckdns.org'} y validando el fingerprint SHA-256...',
        _Estado.segura =>
          'El certificado del servidor coincide con el fingerprint pinneado. No hay ataque MitM.',
        _Estado.bloqueada =>
          'El certificado no coincide. La conexión fue bloqueada para proteger tus datos.',
      };

  Color _colorEstado(_Estado e, ColorScheme cs) => switch (e) {
        _Estado.segura => const Color(0xFF2E7D32),
        _Estado.bloqueada => cs.error,
        _ => cs.onSurface,
      };
}

class _EstadoIcon extends StatelessWidget {
  final _Estado estado;
  const _EstadoIcon({required this.estado});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (icon, color, bg) = switch (estado) {
      _Estado.idle => (
          Icons.shield_outlined,
          cs.onSurfaceVariant,
          cs.surfaceContainerLowest
        ),
      _Estado.verificando => (
          Icons.sync_rounded,
          cs.primary,
          cs.primaryContainer
        ),
      _Estado.segura => (
          Icons.verified_user_rounded,
          const Color(0xFF2E7D32),
          const Color(0xFFE8F5E9)
        ),
      _Estado.bloqueada => (
          Icons.gpp_bad_rounded,
          cs.error,
          cs.errorContainer
        ),
    };

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 48),
    );
  }
}
