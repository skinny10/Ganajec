import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/suscripcion/presentation/shared/utils/format_utils.dart';

class GooglePlayBillingSheet extends StatelessWidget {
  final Plan plan;
  final bool isAnual;
  final bool isLoading;
  final VoidCallback onConfirm;

  const GooglePlayBillingSheet({
    super.key,
    required this.plan,
    required this.isAnual,
    required this.isLoading,
    required this.onConfirm,
  });

  String get _userName => TokenStorage.userName ?? 'Usuario';
  String get _userEmail => TokenStorage.email ?? '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final precio = isAnual ? plan.precioAnual : plan.precioMensual;
    final periodo = isAnual ? 'año' : 'mes';
    final initials = _userName.length >= 2
        ? _userName.substring(0, 2).toUpperCase()
        : _userName.toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 0),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('▶️', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Stripe',
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Plan ${plan.nombre}',
                  style: tt.titleSmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${formatNum(precio)} MXN / $periodo · Se renueva automáticamente',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: tt.labelSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: tt.bodySmall?.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                            if (_userEmail.isNotEmpty)
                              Text(
                                _userEmail,
                                style: tt.labelSmall?.copyWith(
                                  fontSize: 11,
                                  color: cs.outline,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Text('💳', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pago seguro con Stripe',
                          style: tt.bodySmall?.copyWith(
                            fontSize: 12.5,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  'Se cobrará \$${formatNum(precio)} MXN en la próxima fecha de facturación y cada $periodo a partir de entonces. Puedes cancelar en cualquier momento.',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 10.5,
                    color: cs.outline,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : onConfirm,
                    child: isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onPrimary,
                            ),
                          )
                        : Text(
                            'Suscribirse',
                            style: tt.labelLarge?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
