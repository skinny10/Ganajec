import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/suscripcion/presentation/viewmodels/elegir_plan_viewmodel.dart';
import 'package:ganajec/features/suscripcion/presentation/widgets/suscripcion_app_bar.dart';
import 'package:ganajec/features/suscripcion/presentation/screens/elegir_plan/widgets/elegir_plan_promo_header.dart';
import 'package:ganajec/features/suscripcion/presentation/screens/elegir_plan/widgets/elegir_plan_billing_toggle.dart';
import 'package:ganajec/features/suscripcion/presentation/screens/elegir_plan/widgets/elegir_plan_card.dart';
import 'package:ganajec/features/suscripcion/presentation/screens/elegir_plan/widgets/elegir_plan_gplay_info.dart';

class ElegirPlanScreen extends StatefulWidget {
  const ElegirPlanScreen({super.key});

  @override
  State<ElegirPlanScreen> createState() => _ElegirPlanScreenState();
}

class _ElegirPlanScreenState extends State<ElegirPlanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ElegirPlanViewModel>().cargar());
  }

  Future<void> _abrirStripeSheet() async {
    final cs = Theme.of(context).colorScheme;
    final vm = context.read<ElegirPlanViewModel>();
    final plan = vm.planSeleccionadoObj;
    if (plan == null || plan.esGratuito) return;

    final clientSecret = await vm.obtenerClientSecret();
    if (clientSecret == null) return;

    debugPrint('[Stripe] clientSecret=$clientSecret');

    try {
      debugPrint('[Stripe] initPaymentSheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GANAJEC',
          style: ThemeMode.light,
        ),
      );
      debugPrint('[Stripe] initPaymentSheet OK');
    } catch (e, st) {
      debugPrint('[Stripe] initPaymentSheet ERROR: $e');
      debugPrint('[Stripe] stackTrace: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al inicializar pago: $e'),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      debugPrint('[Stripe] presentPaymentSheet...');
      await Stripe.instance.presentPaymentSheet();
      debugPrint('[Stripe] presentPaymentSheet OK');
    } on StripeException catch (e) {
      debugPrint('[Stripe] presentPaymentSheet StripeException: ${e.error.code} - ${e.error.localizedMessage}');
      if (!mounted) return;
      if (e.error.code != FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el pago: ${e.error.localizedMessage}'),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    } catch (e, st) {
      debugPrint('[Stripe] presentPaymentSheet ERROR: $e');
      debugPrint('[Stripe] stackTrace: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al mostrar formulario de pago: $e'),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    debugPrint('[Stripe] confirmando suscripción...');
    final ok = await vm.confirmarSuscripcion();
    debugPrint('[Stripe] confirmarSuscripcion result=$ok');
    if (!mounted) return;

    if (ok) {
      final mensaje = vm.respuestaConfirmacion?['mensaje'] as String? ??
          '¡Suscripción al Plan ${plan.nombre} activada!';
      final features = plan.features
          .where((f) => f.incluida)
          .map((f) => '${f.emoji} ${f.label}')
          .toList();
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: cs.tertiary, size: 28),
              const SizedBox(width: 10),
              const Expanded(child: Text('Pago exitoso')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mensaje, style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 16),
                Text(
                  'Funciones desbloqueadas:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 16, color: cs.tertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(f, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.perfil);
              },
              child: const Text('Ir a Mi Plan'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Error al confirmar la suscripción'),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      vm.resetStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vm = context.watch<ElegirPlanViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const SuscripcionAppBar(
        title: 'Elegir plan',
        fallbackRoute: AppRoutes.miPlan,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, vm),
      bottomNavigationBar: _buildBottomCta(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, ElegirPlanViewModel vm) {
    final planActualTipo = vm.planActualTipo;

    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      children: [
        ElegirPlanPromoHeader(
          planActualNombre: vm.suscripcion?.planActual.nombre ?? 'Gratuito',
        ),
        ElegirPlanBillingToggle(
          isAnual: vm.esPagoAnual,
          onToggle: () =>
              context.read<ElegirPlanViewModel>().togglePagoAnual(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: vm.planes.map((plan) {
              final isSelected = vm.planSeleccionado == plan.tipo;
              final isActual = plan.tipo == planActualTipo;
              return ElegirPlanCard(
                key: ValueKey(plan.tipo),
                plan: plan,
                isSelected: isSelected,
                isActual: isActual,
                isAnual: vm.esPagoAnual,
                onTap: () => context
                    .read<ElegirPlanViewModel>()
                    .seleccionarPlan(plan.tipo),
              );
            }).toList(),
          ),
        ),
        const ElegirPlanGPlayInfo(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomCta(BuildContext context, ElegirPlanViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isGratuito = vm.planSeleccionadoObj?.esGratuito ?? false;
    final isActual = vm.planSeleccionado == vm.planActualTipo;
    final disabled = isActual || vm.isSubscribing;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.onSurface,
                  foregroundColor: cs.surface,
                  disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 4,
                  shadowColor: cs.onSurface.withValues(alpha: 0.18),
                ),
                onPressed: disabled ? null : _abrirStripeSheet,
                child: vm.isSubscribing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: cs.surface),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isGratuito)
                            const Icon(Icons.shield_outlined, size: 16),
                          if (!isGratuito) const SizedBox(width: 8),
                          Text(
                            isActual ? 'Plan actual' : vm.textoPrecioBoton,
                            style: tt.labelLarge?.copyWith(
                              color: cs.surface,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                style: tt.labelSmall?.copyWith(
                  fontSize: 10.5,
                  color: cs.outline,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  const TextSpan(text: 'Al suscribirte aceptas los '),
                  TextSpan(
                    text: 'Términos de uso',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' y la '),
                  TextSpan(
                    text: 'Política de privacidad',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
