import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/share/domain/entities/historial_item.dart';
import '../../viewmodels/historial_viewmodel.dart';
import 'historial_components.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HistorialViewModel>().cargar());
  }

  void _onCardTap(HistorialItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.enfermedad} · ${item.animalNombre}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<HistorialViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
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
          'Historial de predicciones',
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
          : vm.status == HistorialStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar el historial',
                  onRetry: () => context.read<HistorialViewModel>().cargar(),
                )
              : _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, HistorialViewModel vm) {
    final grupos = vm.grupos;
    final hasFilters = vm.filtroTipo != HistorialFiltroTipo.todos ||
        vm.animalFiltro != null ||
        vm.busqueda.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              HistorialFilterBar(vm: vm),
              HistorialQuickStats(
                alta: vm.countAlta,
                total: vm.countMes,
                sinEnfermedad: vm.countSinEnfermedad,
              ),
            ],
          ),
        ),

        if (vm.isEmpty)
          SliverToBoxAdapter(
            child: HistorialEmptyState(
              hasFilters: hasFilters,
              onLimpiar: () =>
                  context.read<HistorialViewModel>().limpiarFiltros(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => HistorialDateGroup(
                  grupo: grupos[index],
                  onTap: _onCardTap,
                ),
                childCount: grupos.length,
              ),
            ),
          ),
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
