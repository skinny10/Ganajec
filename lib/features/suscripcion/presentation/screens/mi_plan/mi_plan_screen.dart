import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import '../../viewmodels/mi_plan_viewmodel.dart';
import 'mi_plan_components.dart';

class MiPlanScreen extends StatefulWidget {
  const MiPlanScreen({super.key});

  @override
  State<MiPlanScreen> createState() => _MiPlanScreenState();
}

class _MiPlanScreenState extends State<MiPlanScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MiPlanViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MiPlanViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.perfil),
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
          'Mi plan',
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
          : vm.status == MiPlanStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar el plan',
                  onRetry: () => context.read<MiPlanViewModel>().cargar(),
                )
              : _buildContent(vm),
    );
  }

  Widget _buildContent(MiPlanViewModel vm) {
    final suscripcion = vm.suscripcion!;
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      children: [
        // Hero negro
        MiPlanHeroCard(suscripcion: suscripcion),

        // Uso actual
        MiPlanUsageCard(suscripcion: suscripcion),

        // Funcionalidades
        MiPlanFeaturesCard(plan: suscripcion.planActual),

        // Tip de upgrade (solo si plan gratuito con límite de bovinos)
        MiPlanTipCard(suscripcion: suscripcion),

        // Sección "Mejorar mi plan"
        if (vm.planesUpgrade.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mejorar mi plan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                ...vm.planesUpgrade.map((plan) => MiPlanUpgradeMiniCard(
                      plan: plan,
                      onTap: () => context.push(
                        AppRoutes.elegirPlan,
                        extra: plan.tipo.name,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFC0392B), size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF888880))),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
