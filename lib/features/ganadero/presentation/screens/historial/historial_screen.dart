import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/historial_item.dart';
import 'package:ganajec/features/ganadero/presentation/screens/detalle_bovino/detalle_bovino_args.dart';
import '../../viewmodels/historial_viewmodel.dart';
import 'historial_components.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HistorialViewModel>().cargar());
  }

  void _onCardTap(HistorialItem item) {
    final animal = Animal(
      id: item.animalId,
      ranchoId: '',
      ganaderoId: '',
      nombre: item.animalNombre,
      raza: '',
      sexo: '',
      fechaNacimiento: DateTime(2000),
      pesoKg: 0,
      idExterno: item.animalIdExterno,
      creadoEn: item.fecha,
    );
    context.push(
      AppRoutes.detalleBovino,
      extra: DetalleBovinoArgs(animal: animal, soloLectura: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistorialViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.chevron_left,
                color: _kTextPrimary, size: 20),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Historial de predicciones',
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
          : vm.status == HistorialStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar el historial',
                  onRetry: () => context.read<HistorialViewModel>().cargar(),
                )
              : _buildContent(vm),
    );
  }

  Widget _buildContent(HistorialViewModel vm) {
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
              // Filtros (búsqueda + chips)
              HistorialFilterBar(vm: vm),
              // Quick stats
              HistorialQuickStats(
                alta: vm.countAlta,
                total: vm.countMes,
                sinEnfermedad: vm.countSinEnfermedad,
              ),
            ],
          ),
        ),

        // Lista o empty state
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFC0392B), size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF888880))),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
