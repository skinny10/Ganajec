import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/features/suscripcion/presentation/viewmodels/elegir_plan_viewmodel.dart';
import 'elegir_plan_components.dart';

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

    try {
      final clientSecret = await vm.obtenerClientSecret();
      if (clientSecret == null) return;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GANAJEC',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final ok = await vm.confirmarSuscripcion();
      if (!context.mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Suscripción al Plan ${plan.nombre} activada!'),
            backgroundColor: cs.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) context.go(AppRoutes.perfil);
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
    } on StripeException catch (e) {
      if (!context.mounted) return;
      if (e.error.code != FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el pago: ${e.error.localizedMessage}'),
            backgroundColor: cs.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final cs2 = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: cs2.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<ElegirPlanViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.miPlan),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left, color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Elegir plan',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
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
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: cs.onSurface.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 4,
                  shadowColor: cs.onSurface.withOpacity(0.18),
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
                              color: Colors.white,
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
