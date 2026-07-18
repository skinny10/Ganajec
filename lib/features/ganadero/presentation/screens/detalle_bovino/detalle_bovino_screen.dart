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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<DetalleBovinoViewModel>();
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: cs.surface,
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
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero banner + card ───────────────────────────
                      SizedBox(
                        height: topPad + 268,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Farm background image
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: topPad + 190,
                              child: Image.asset(
                                'assets/images/fondo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Gradient overlay at bottom of image
                            Positioned(
                              left: 0,
                              right: 0,
                              top: topPad + 100,
                              height: 90,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      cs.surface.withOpacity(0),
                                      cs.surface.withOpacity(0.15),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Back button
                            Positioned(
                              top: topPad + 10,
                              left: 8,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: cs.outlineVariant),
                                  ),
                                  child: Icon(Icons.chevron_left,
                                      color: cs.onSurface, size: 20),
                                ),
                              ),
                            ),
                            // Title
                            Positioned(
                              top: topPad + 10,
                              left: 56,
                              right: 56,
                              child: SizedBox(
                                height: 38,
                                child: Center(
                                  child: Text(
                                    'Detalle del animal',
                                    style: tt.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Edit button
                            Positioned(
                              top: topPad + 10,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => context.push(
                                    AppRoutes.editarBovino,
                                    extra: widget.animal),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: cs.outlineVariant),
                                  ),
                                  child: Icon(Icons.edit_outlined,
                                      color: cs.onSurface, size: 16),
                                ),
                              ),
                            ),
                            // Hero card (overlaps image bottom)
                            Positioned(
                              top: topPad + 136,
                              left: 16,
                              right: 16,
                              bottom: 0,
                              child: DetalleAnimalHero(
                                  animal: widget.animal, vm: vm),
                            ),
                          ],
                        ),
                      ),
                      // ── Info grid ────────────────────────────────────
                      const SizedBox(height: 4),
                      DetalleInfoGrid(animal: widget.animal, vm: vm),
                      // ── Tab bar ──────────────────────────────────────
                      DetalleTabBar(
                        selectedIndex: _selectedTab,
                        onTabChanged: (i) =>
                            setState(() => _selectedTab = i),
                      ),
                      // ── Tab content ──────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: switch (_selectedTab) {
                          0 => DetallePrediccionesTab(
                              key: const ValueKey('predicciones'),
                              predicciones: vm.predicciones,
                            ),
                          _ => DetalleGraficasTab(
                              key: const ValueKey('graficas'),
                              graficas: vm.graficas,
                            ),
                        },
                      ),
                      // ── Footer landscape ─────────────────────────────
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/footer.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                      const SizedBox(height: 16),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
