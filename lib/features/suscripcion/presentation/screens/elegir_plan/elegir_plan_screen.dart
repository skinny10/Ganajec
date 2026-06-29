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
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ElegirPlanViewModel>().cargar());
  }

  Future<void> _abrirStripeSheet() async {
    final vm = context.read<ElegirPlanViewModel>();
    final plan = vm.planSeleccionadoObj;
    if (plan == null || plan.esGratuito) return;

    try {
      // 1. Obtener clientSecret desde tu API
      final clientSecret = await vm.obtenerClientSecret();
      if (clientSecret == null) return;

      // 2. Inicializar PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'GANAJEC',
          style: ThemeMode.light,
        ),
      );

      // 3. Mostrar PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Pago exitoso — confirmar suscripción en tu backend
      final ok = await vm.confirmarSuscripcion();
      if (!context.mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Suscripción al Plan ${plan.nombre} activada!'),
            backgroundColor: const Color(0xFF1D7A55),
            behavior: SnackBarBehavior.floating,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (context.mounted) context.go(AppRoutes.perfil);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? 'Error al confirmar la suscripción'),
            backgroundColor: const Color(0xFFC0392B),
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
            backgroundColor: const Color(0xFFC0392B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFC0392B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ElegirPlanViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.miPlan),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.chevron_left, color: _kTextPrimary, size: 20),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Elegir plan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(vm),
      bottomNavigationBar: _buildBottomCta(vm),
    );
  }

  Widget _buildContent(ElegirPlanViewModel vm) {
    final planActualTipo = vm.planActualTipo;

    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      children: [
        ElegirPlanPromoHeader(
          planActualNombre: vm.suscripcion?.planActual.nombre ?? 'Gratuito',
        ),
        ElegirPlanBillingToggle(
          isAnual: vm.esPagoAnual,
          onToggle: () => context.read<ElegirPlanViewModel>().togglePagoAnual(),
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
                onTap: () =>
                    context.read<ElegirPlanViewModel>().seleccionarPlan(plan.tipo),
              );
            }).toList(),
          ),
        ),
        const ElegirPlanGPlayInfo(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomCta(ElegirPlanViewModel vm) {
    final isGratuito = vm.planSeleccionadoObj?.esGratuito ?? false;
    final isActual = vm.planSeleccionado == vm.planActualTipo;
    final disabled = isActual || vm.isSubscribing;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAF7),
          border: Border(top: BorderSide(color: Color(0xFFE8E5DC))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTextPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kTextPrimary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.18),
                ),
                onPressed: disabled ? null : _abrirStripeSheet,
                child: vm.isSubscribing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isGratuito)
                            const Icon(Icons.shield_outlined, size: 16),
                          if (!isGratuito) const SizedBox(width: 8),
                          Text(
                            isActual ? 'Plan actual' : vm.textoPrecioBoton,
                            style: const TextStyle(
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
              const TextSpan(
                style: TextStyle(
                  fontSize: 10.5,
                  color: _kTextMuted,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  TextSpan(text: 'Al suscribirte aceptas los '),
                  TextSpan(
                    text: 'Términos de uso',
                    style: TextStyle(
                      color: Color(0xFF888880),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' y la '),
                  TextSpan(
                    text: 'Política de privacidad',
                    style: TextStyle(
                      color: Color(0xFF888880),
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