import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/detalle_bovino_viewmodel.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'detalle_bovino_components.dart';

class DetalleBovinoScreen extends StatefulWidget {
  final Animal animal;

  const DetalleBovinoScreen({super.key, required this.animal});

  @override
  State<DetalleBovinoScreen> createState() => _DetalleBovinoScreenState();
}

class _DetalleBovinoScreenState extends State<DetalleBovinoScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<DetalleBovinoViewModel>().cargarDatos(widget.animal.id));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleBovinoViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAF7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8E5DC)),
            ),
            child: const Icon(Icons.chevron_left,
                color: Color(0xFF1A1A1A), size: 20),
          ),
        ),
        title: const Text(
          'Detalle del animal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () =>
                context.push(AppRoutes.editarBovino, extra: widget.animal),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E5DC)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.edit_outlined,
                    color: Color(0xFF1A1A1A), size: 16),
              ),
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.status == DetalleBovinoStatus.error
              ? _ErrorView(
                  message: vm.errorMessage ?? 'Error desconocido',
                  onRetry: () => context
                      .read<DetalleBovinoViewModel>()
                      .cargarDatos(widget.animal.id),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero
                      DetalleAnimalHero(animal: widget.animal, vm: vm),
                      // Info grid
                      DetalleInfoGrid(animal: widget.animal, vm: vm),
                      // Tabs
                      DetalleTabBar(
                        selectedIndex: _selectedTab,
                        onTabChanged: (i) => setState(() => _selectedTab = i),
                      ),
                      // Contenido del tab
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: switch (_selectedTab) {
                          0 => DetalleProduccionTab(
                              key: const ValueKey('produccion'),
                              historial: vm.historial,
                            ),
                          1 => DetallePrediccionesTab(
                              key: const ValueKey('predicciones'),
                              predicciones: vm.predicciones,
                            ),
                          _ => DetalleGraficasTab(
                              key: const ValueKey('graficas'),
                              graficas: vm.graficas,
                            ),
                        },
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: DetalleBottomCta(
        animal: widget.animal,
        onRegistrarSintomas: () => context.push(
          AppRoutes.registrarSintomas,
          extra: widget.animal,
        ),
      ),
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
        padding: const EdgeInsets.all(24),
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
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
