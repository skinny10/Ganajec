import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';

// ─── Promo header ─────────────────────────────────────────────────────────────

class ElegirPlanPromoHeader extends StatelessWidget {
  final String planActualNombre;

  const ElegirPlanPromoHeader({super.key, required this.planActualNombre});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: cs.onSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEJORA TU EXPERIENCIA',
                style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.surface.withOpacity(0.6),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Desbloquea todo\nGANAJEC',
                style: tt.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: cs.surface,
                  letterSpacing: -0.6,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Alertas automáticas, historial extendido y reportes para tu hato.',
                style: tt.bodySmall?.copyWith(
                  fontSize: 12.5,
                  color: cs.surface.withOpacity(0.65),
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🐄 Actualmente en Plan $planActualNombre',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.surface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Toggle mensual / anual ───────────────────────────────────────────────────

class ElegirPlanBillingToggle extends StatelessWidget {
  final bool isAnual;
  final VoidCallback onToggle;

  const ElegirPlanBillingToggle({
    super.key,
    required this.isAnual,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (tt.bodyMedium ?? const TextStyle()).copyWith(
              fontSize: 13,
              fontWeight: isAnual ? FontWeight.w400 : FontWeight.w500,
              color: isAnual ? cs.onSurfaceVariant : cs.onSurface,
            ),
            child: const Text('Mensual'),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 26,
              decoration: BoxDecoration(
                color: cs.onSurface,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment:
                    isAnual ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (tt.bodyMedium ?? const TextStyle()).copyWith(
              fontSize: 13,
              fontWeight: isAnual ? FontWeight.w500 : FontWeight.w400,
              color: isAnual ? cs.onSurface : cs.onSurfaceVariant,
            ),
            child: const Text('Anual'),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isAnual ? 1.0 : 0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.tertiary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Ahorra 20%',
                style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cs.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de plan seleccionable ───────────────────────────────────────────

class ElegirPlanCard extends StatelessWidget {
  final Plan plan;
  final bool isSelected;
  final bool isActual;
  final bool isAnual;
  final VoidCallback onTap;

  const ElegirPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.isActual,
    required this.isAnual,
    required this.onTap,
  });

  String _formatNum(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final precio = isAnual ? plan.precioAnualMensual : plan.precioMensual;
    final isPopular = plan.popular;

    Color borderColor = cs.outlineVariant;
    if (isSelected && !isActual) borderColor = cs.onSurface;
    if (isPopular && isSelected) borderColor = cs.primary;
    if (isActual) borderColor = cs.outlineVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActual ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected && !isActual ? 1.5 : 1,
          ),
          boxShadow: isSelected && !isActual
              ? [BoxShadow(color: cs.onSurface.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: nombre + precio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.nombre,
                            style: tt.titleSmall?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.descripcion,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: cs.outline,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.esGratuito ? '\$0' : '\$${_formatNum(precio)}',
                          style: tt.titleMedium?.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.6,
                          ),
                        ),
                        Text(
                          plan.esGratuito ? '/ siempre' : '/ mes',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 10.5,
                            color: cs.outline,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (isAnual && !plan.esGratuito)
                          Text(
                            '\$${_formatNum(plan.precioAnual)} / año',
                            style: tt.labelSmall?.copyWith(
                              fontSize: 10,
                              color: cs.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Features
                ...plan.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            alignment: Alignment.center,
                            child: Text(
                              f.incluida ? '✓' : '🔒',
                              style: TextStyle(
                                fontSize: f.incluida ? 12 : 11,
                                color: f.incluida ? cs.tertiary : cs.outline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            f.label,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    )),
                // Radio row
                const SizedBox(height: 12),
                Container(
                  height: 0.5,
                  color: cs.outlineVariant,
                  margin: const EdgeInsets.only(bottom: 10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Radio button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? cs.onSurface : cs.outlineVariant,
                          width: 1.5,
                        ),
                        color: isSelected ? cs.onSurface : Colors.transparent,
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1.0 : 0.0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cs.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      isActual
                          ? 'Plan actual'
                          : isSelected
                              ? 'Seleccionado'
                              : plan.esGratuito
                                  ? 'Continuar gratis'
                                  : 'Seleccionar ${plan.nombre}',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Badge popular o actual
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Más popular',
                    style: tt.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              )
            else if (isActual)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    'Plan actual',
                    style: tt.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: cs.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Info Google Play ─────────────────────────────────────────────────────────

class ElegirPlanGPlayInfo extends StatelessWidget {
  const ElegirPlanGPlayInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('▶️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: tt.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'El pago se procesa de forma segura a través de '),
                  TextSpan(
                    text: 'Google Play Billing',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                  const TextSpan(
                    text:
                        '. Tu suscripción se renueva automáticamente. Cancela cuando quieras desde la configuración de Google Play.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Google Play Billing Sheet ────────────────────────────────────────────────

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

  String _formatNum(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final precio = isAnual ? plan.precioAnual : plan.precioMensual;
    final periodo = isAnual ? 'año' : 'mes';

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 14, bottom: 0),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header (simula Google Play)
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
                      'Google Play',
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
                  '\$${_formatNum(precio)} MXN / $periodo · Se renueva automáticamente',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                // Cuenta
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
                            'JP',
                            style: tt.labelSmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Juan Pérez',
                              style: tt.bodySmall?.copyWith(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface)),
                          Text('juan@gmail.com',
                              style: tt.labelSmall?.copyWith(
                                  fontSize: 11,
                                  color: cs.outline,
                                  fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // Método de pago
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Text('💳', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Visa •••• 4242',
                            style: tt.bodySmall?.copyWith(
                                fontSize: 12.5, color: cs.onSurface)),
                      ),
                      Text('Cambiar',
                          style: tt.labelSmall?.copyWith(
                              fontSize: 12,
                              color: cs.primary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Divider(height: 1, color: cs.outlineVariant),
                const SizedBox(height: 12),
                // Términos
                Text(
                  'Se cobrará \$${_formatNum(precio)} MXN en la próxima fecha de facturación y cada $periodo a partir de entonces. Puedes cancelar en cualquier momento desde Suscripciones de Google Play.',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 10.5,
                    color: cs.outline,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                // Botón confirmar
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
