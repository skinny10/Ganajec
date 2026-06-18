import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

// ─── Paleta ──────────────────────────────────────────────────────────────────
const _kBg = Color(0xFFFAFAF7);
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE8E5DC);
const _kCream = Color(0xFFF5F3EE);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF888880);
const _kTextMuted = Color(0xFFAEADA6);
const _kGreen = Color(0xFF1D7A55);
const _kGreenLight = Color(0xFFE8F5EF);
const _kYellow = Color(0xFFB8860B);
const _kYellowLight = Color(0xFFFEF9E7);
const _kYellowBorder = Color(0xFFF7DC6F);
const _kRed = Color(0xFFC0392B);

// ─── Hero del plan activo ─────────────────────────────────────────────────────

class MiPlanHeroCard extends StatelessWidget {
  final SuscripcionInfo suscripcion;

  const MiPlanHeroCard({super.key, required this.suscripcion});

  @override
  Widget build(BuildContext context) {
    final p = suscripcion.planActual;
    final diasTexto = p.esGratuito ? '∞' : '${p.historialDias}';

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _kTextPrimary,
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
                color: Colors.white.withValues(alpha: 0.05),
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
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PLAN ACTIVO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.nombre,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.precioTexto,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 18),
              // 3-stat grid
              IntrinsicHeight(
                child: Row(
                  children: [
                    _Stat(value: suscripcion.bovinosTexto, label: 'Bovinos'),
                    const _StatDivider(),
                    _Stat(value: suscripcion.analisisTexto, label: 'Análisis este mes'),
                    const _StatDivider(),
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
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              color: Colors.white54,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: Colors.white12,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uso actual del plan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kTextPrimary,
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

  Color _barColor() {
    if (pct >= 0.9) return _kRed;
    if (pct >= 0.7) return _kYellow;
    return _kGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: _kTextSecondary, fontWeight: FontWeight.w400)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, color: _kTextPrimary, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            color: _kBorder,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, value, __) => FractionallySizedBox(
                widthFactor: value,
                alignment: Alignment.centerLeft,
                child: Container(color: _barColor()),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Funcionalidades incluidas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _kTextPrimary,
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
                          color: f.incluida ? _kGreenLight : _kCream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child:
                              Text(f.emoji, style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f.label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: f.incluida ? _kTextPrimary : _kTextMuted,
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
                  const Divider(height: 0, thickness: 0.5, indent: 16, endIndent: 16,
                      color: _kBorder),
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
    final disponibles = suscripcion.bovinosDisponibles;
    if (suscripcion.planActual.bovinosMax == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: _kYellowLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kYellowBorder),
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
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7A5C00),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Con el Plan Básico (\$149/mes) puedes registrar hato ilimitado y activar alertas push.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9A7A00),
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
    final isFeatured = plan.popular;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: isFeatured ? _kBg : _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFeatured ? _kTextPrimary : _kBorder,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _kTextPrimary,
                      ),
                    ),
                    if (plan.popular) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kYellowBorder,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Más popular',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7A5C00),
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
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Text(
                      'MXN / mes',
                      style: TextStyle(
                        fontSize: 10,
                        color: _kTextMuted,
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
                        const Text('✓',
                            style: TextStyle(
                                color: _kGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Text(
                          f.label,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _kTextSecondary,
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
