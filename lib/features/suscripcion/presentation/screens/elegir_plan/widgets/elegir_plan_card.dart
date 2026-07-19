import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/features/suscripcion/presentation/shared/utils/format_utils.dart';

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
              ? [BoxShadow(color: cs.onSurface.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          plan.esGratuito ? '\$0' : '\$${formatNum(precio)}',
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
                            '\$${formatNum(plan.precioAnual)} / año',
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
                ...plan.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(
                              child: Text(
                                f.incluida ? '✓' : '🔒',
                                style: TextStyle(
                                  fontSize: f.incluida ? 12 : 11,
                                  color: f.incluida ? cs.tertiary : cs.outline,
                                  fontWeight: FontWeight.w500,
                                ),
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
                const SizedBox(height: 12),
                Container(
                  height: 0.5,
                  color: cs.outlineVariant,
                  margin: const EdgeInsets.only(bottom: 10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
