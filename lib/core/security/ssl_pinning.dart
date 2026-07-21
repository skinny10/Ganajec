import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

/// Configuración central de SSL Certificate Pinning para Ganajec.
///
/// El pinning verifica que el servidor con el que se comunica la app
/// tenga exactamente este certificado. Si un atacante intercepta la
/// conexión (Man-in-the-Middle), su certificado no coincidirá y la
/// comunicación es bloqueada automáticamente.
class SslPinning {
  SslPinning._();

  /// Dominio protegido
  static const String pinnedHost = 'ganajec.duckdns.org';

  /// SHA-256 fingerprint del certificado del servidor
  static const String sha256Fingerprint =
      'EB:DB:9F:FB:35:DA:E2:68:74:35:A0:E8:EC:CA:1F:D4:'
      'B1:1E:AD:5F:37:44:C4:1B:B3:57:B7:42:28:D7:0B:CA';

  // ── Validación para Dio (IOHttpClientAdapter.validateCertificate) ──────────

  /// Retorna true si el certificado es válido para el host dado.
  /// Llamar desde IOHttpClientAdapter.validateCertificate.
  static bool validar(X509Certificate? cert, String host, int port) {
    // Solo aplicar pinning al host de la API
    if (host != pinnedHost) return true;
    if (cert == null) return false;

    // Calcular SHA-256 del certificado DER
    final digest = sha256.convert(cert.der);
    final fingerprint = digest.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');

    return fingerprint == sha256Fingerprint;
  }

  // ── Verificación independiente (http_certificate_pinning) ─────────────────

  /// Verifica la conexión al servidor usando el paquete http_certificate_pinning.
  /// Retorna true si la conexión es segura.
  static Future<bool> verificarConexion() async {
    try {
      final resultado = await HttpCertificatePinning.check(
        serverURL: 'https://$pinnedHost',
        headerHttp: const {'Accept': 'application/json'},
        sha: SHA.SHA256,
        allowedSHAFingerprints: [sha256Fingerprint],
        timeout: 30,
      );
      return resultado.contains('CONNECTION_SECURE');
    } catch (_) {
      return false;
    }
  }

  // ── Diálogo de error MitM ─────────────────────────────────────────────────

  /// Muestra el diálogo de certificado no autorizado.
  static Future<void> mostrarDialogoError(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _PinningErrorDialog(),
    );
  }

  /// Determina si una excepción es un error de pinning.
  static bool esErrorDePinning(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('handshake') ||
        msg.contains('certificate') ||
        msg.contains('ssl') ||
        msg.contains('tls') ||
        msg.contains('pinning') ||
        msg.contains('connection closed');
  }
}

// ─── Diálogo de error ─────────────────────────────────────────────────────────

class _PinningErrorDialog extends StatelessWidget {
  const _PinningErrorDialog();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: cs.surface,
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.shield_rounded, color: cs.error, size: 32),
      ),
      title: Text(
        'Conexión bloqueada',
        textAlign: TextAlign.center,
        style: tt.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Certificado no autorizado',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Se detectó un posible ataque Man-in-the-Middle. '
            'La aplicación bloqueó la conexión para proteger tus datos.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 16),
          label: const Text('Cerrar'),
        ),
      ],
    );
  }
}
