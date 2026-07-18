import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

// ─── Hero del plan activo ─────────────────────────────────────────────────────

class MiPlanHeroCard extends StatelessWidget {
  final SuscripcionInfo suscripcion;

  const MiPlanHeroCard({super.key, required this.suscripcion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = suscripcion.planActual;
    final diasTexto = p.esGratuito ? '∞' : '${p.historialDias}';

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: cs.onSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decoración de fondo
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface.withOpacity(0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLAN ACTIVO',
                style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.surface.withOpacity(0.54),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.nombre,
                style: tt.headlineSmall?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: cs.surface,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.precioTexto,
                style: tt.bodySmall?.copyWith(
                  fontSize: 13,
                  color: cs.surface.withOpacity(0.6),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 18),
              // 3-stat grid
              IntrinsicHeight(
                child: Row(
                  children: [
                    _Stat(value: suscripcion.bovinosTexto, label: 'Bovinos'),
                    _StatDivider(color: cs.surface.withOpacity(0.12)),
                    _Stat(value: suscripcion.analisisTexto, label: 'Análisis este mes'),
                    _StatDivider(color: cs.surface.withOpacity(0.12)),
                    _Stat(value: diasTexto, label: 'Días restantes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.surface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: tt.labelSmall?.copyWith(
              fontSize: 9.5,
              color: cs.surface.withOpacity(0.54),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final Color color;
  const _StatDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}

// ─── Card de uso actual ───────────────────────────────────────────────────────

class MiPlanUsageCard extends StatelessWidget {
  final SuscripcionInfo suscripcion;

  const MiPlanUsageCard({super.key, required this.suscripcion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uso actual del plan',
            style: tt.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          _UsageRow(
            label: 'Bovinos registrados',
            value: suscripcion.bovinosTexto,
            pct: suscripcion.bovinosPct,
          ),
          const SizedBox(height: 12),
          _UsageRow(
            label: 'Análisis este mes',
            value: suscripcion.analisisTexto,
            pct: suscripcion.analisisPct,
          ),
          const SizedBox(height: 12),
          _UsageRow(
            label: 'Historial guardado',
            value: suscripcion.historialTexto,
            pct: 1.0,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final String label;
  final String value;
  final double pct;

  const _UsageRow({required this.label, required this.value, required this.pct});

  Color _barColor(ColorScheme cs) {
    if (pct >= 0.9) return cs.error;
    if (pct >= 0.7) return cs.secondary;
    return cs.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w400)),
            Text(value,
                style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            color: cs.outlineVariant,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, value, __) => FractionallySizedBox(
                widthFactor: value,
                alignment: Alignment.centerLeft,
                child: Container(color: _barColor(cs)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Card de funcionalidades ──────────────────────────────────────────────────

class MiPlanFeaturesCard extends StatelessWidget {
  final Plan plan;

  const MiPlanFeaturesCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Funcionalidades incluidas',
              style: tt.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
          ...List.generate(plan.features.length, (i) {
            final f = plan.features[i];
            final isLast = i == plan.features.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: f.incluida
                              ? cs.tertiaryContainer
                              : cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(f.emoji,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f.label,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: f.incluida ? cs.onSurface : cs.outline,
                          ),
                        ),
                      ),
                      Text(
                        f.incluida ? '✅' : '🔒',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 0,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: cs.outlineVariant),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Tip de renovación ────────────────────────────────────────────────────────

class MiPlanTipCard extends StatelessWidget {
  final SuscripcionInfo suscripcion;

  const MiPlanTipCard({super.key, required this.suscripcion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final disponibles = suscripcion.bovinosDisponibles;
    if (suscripcion.planActual.bovinosMax == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.secondary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes $disponibles ${disponibles == 1 ? 'bovino disponible' : 'bovinos disponibles'}',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Con el Plan Básico (\$149/mes) puedes registrar hato ilimitado y activar alertas push.',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    color: cs.onSecondaryContainer.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                    height: 1.5,
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

// ─── Mini tarjeta de plan para upgrade ───────────────────────────────────────

class MiPlanUpgradeMiniCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onTap;

  const MiPlanUpgradeMiniCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isFeatured = plan.popular;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: isFeatured ? cs.surface : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFeatured ? cs.onSurface : cs.outlineVariant,
            width: isFeatured ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      plan.nombre,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    if (plan.popular) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Más popular',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${plan.precioMensual.toLocaleString()}',
                      style: tt.titleSmall?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'MXN / mes',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        color: cs.outline,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...plan.features
                .where((f) => f.incluida)
                .take(3)
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text('✓',
                            style: TextStyle(
                                color: cs.tertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Text(
                          f.label,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

extension on int {
  String toLocaleString() =>
      toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
}
