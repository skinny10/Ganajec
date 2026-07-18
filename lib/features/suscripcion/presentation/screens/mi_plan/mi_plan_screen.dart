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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MiPlanViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<MiPlanViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.perfil),
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
          'Mi plan',
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
          : vm.status == MiPlanStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar el plan',
                  onRetry: () => context.read<MiPlanViewModel>().cargar(),
                )
              : _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, MiPlanViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final suscripcion = vm.suscripcion!;

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      children: [
        MiPlanHeroCard(suscripcion: suscripcion),
        MiPlanUsageCard(suscripcion: suscripcion),
        MiPlanFeaturesCard(plan: suscripcion.planActual),
        MiPlanTipCard(suscripcion: suscripcion),

        if (vm.planesUpgrade.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mejorar mi plan',
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
