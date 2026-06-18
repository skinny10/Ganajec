import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';

// ─── Paleta ──────────────────────────────────────────────────────────────────
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE8E5DC);
const _kCream = Color(0xFFF5F3EE);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF888880);
const _kTextMuted = Color(0xFFAEADA6);
const _kGreen = Color(0xFF1D7A55);
const _kCow = Color(0xFF8B4A2B);

// ─── Promo header ─────────────────────────────────────────────────────────────

class ElegirPlanPromoHeader extends StatelessWidget {
  final String planActualNombre;

  const ElegirPlanPromoHeader({super.key, required this.planActualNombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: _kTextPrimary,
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
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MEJORA TU EXPERIENCIA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white60,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Desbloquea todo\nGANAJEC',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.6,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Alertas automáticas, historial extendido y reportes para tu hato.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xA6FFFFFF), // ~65% white
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🐄 Actualmente en Plan $planActualNombre',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xCCFFFFFF), // ~80% white
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isAnual ? FontWeight.w400 : FontWeight.w500,
              color: isAnual ? _kTextSecondary : _kTextPrimary,
              fontFamily: 'DM Sans',
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
                color: _kTextPrimary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: isAnual ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isAnual ? FontWeight.w500 : FontWeight.w400,
              color: isAnual ? _kTextPrimary : _kTextSecondary,
              fontFamily: 'DM Sans',
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
                color: _kGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Ahorra 20%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
    final precio = isAnual ? plan.precioAnualMensual : plan.precioMensual;
    final isPopular = plan.popular;

    Color borderColor = _kBorder;
    if (isSelected && !isActual) borderColor = _kTextPrimary;
    if (isPopular && isSelected) borderColor = _kCow;
    if (isActual) borderColor = _kBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActual ? _kCream : _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected && !isActual ? 1.5 : 1,
          ),
          boxShadow: isSelected && !isActual
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))]
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
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _kTextPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.descripcion,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _kTextMuted,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40), // espacio para el badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.esGratuito ? '\$0' : '\$${_formatNum(precio)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _kTextPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        Text(
                          plan.esGratuito ? '/ siempre' : '/ mes',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: _kTextMuted,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (isAnual && !plan.esGratuito)
                          Text(
                            '\$${_formatNum(plan.precioAnual)} / año',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _kGreen,
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
                                color: f.incluida ? _kGreen : _kTextMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            f.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kTextSecondary,
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
                  color: _kBorder,
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
                          color: isSelected ? _kTextPrimary : _kBorder,
                          width: 1.5,
                        ),
                        color: isSelected ? _kTextPrimary : Colors.transparent,
                      ),
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1.0 : 0.0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? _kTextPrimary : _kTextSecondary,
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
                    color: _kCow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Más popular',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                    color: _kCream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kBorder),
                  ),
                  child: const Text(
                    'Plan actual',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _kTextMuted,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('▶️', style: TextStyle(fontSize: 20)),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 11.5,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  TextSpan(text: 'El pago se procesa de forma segura a través de '),
                  TextSpan(
                    text: 'Google Play Billing',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: _kTextPrimary),
                  ),
                  TextSpan(
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
    final precio = isAnual ? plan.precioAnual : plan.precioMensual;
    final periodo = isAnual ? 'año' : 'mes';

    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              color: _kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header (simula Google Play)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('▶️', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      'Google Play',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _kTextPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Plan ${plan.nombre}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${_formatNum(precio)} MXN / $periodo · Se renueva automáticamente',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kTextSecondary,
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
                    color: _kCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kCow,
                        ),
                        child: const Center(
                          child: Text(
                            'JP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Juan Pérez',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: _kTextPrimary)),
                          Text('juan@gmail.com',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _kTextMuted,
                                  fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // Método de pago
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('💳', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Visa •••• 4242',
                            style: TextStyle(
                                fontSize: 12.5, color: _kTextPrimary)),
                      ),
                      Text('Cambiar',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1A73E8),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Divider(height: 1, color: _kBorder),
                const SizedBox(height: 12),
                // Términos
                Text(
                  'Se cobrará \$${_formatNum(precio)} MXN en la próxima fecha de facturación y cada $periodo a partir de entonces. Puedes cancelar en cualquier momento desde Suscripciones de Google Play.',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: _kTextMuted,
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
                      backgroundColor: const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: isLoading ? null : onConfirm,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Suscribirse',
                            style: TextStyle(
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
