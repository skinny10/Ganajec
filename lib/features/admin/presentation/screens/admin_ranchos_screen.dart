import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_ranchos_viewmodel.dart';

class AdminRanchosScreen extends StatefulWidget {
  const AdminRanchosScreen({super.key});

  @override
  State<AdminRanchosScreen> createState() => _AdminRanchosScreenState();
}

class _AdminRanchosScreenState extends State<AdminRanchosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminRanchosViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminRanchosViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left_rounded,
                color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Ranchos',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminRanchosViewModel>().cargar(),
            icon: Icon(Icons.refresh_outlined,
                color: cs.onSurfaceVariant, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<AdminRanchosViewModel>().cargar(),
              child: vm.ranchos.isEmpty
                  ? _EmptyState(
                      onRecargar: () =>
                          context.read<AdminRanchosViewModel>().cargar())
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 80),
                      itemCount: vm.ranchos.length,
                      itemBuilder: (_, i) {
                        final rancho = vm.ranchos[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: cs.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.landscape_outlined,
                                          color: cs.tertiary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            rancho.nombre,
                                            style: tt.bodyMedium?.copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${rancho.municipio}, ${rancho.estado}',
                                            style: tt.bodySmall?.copyWith(
                                              fontSize: 12,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _InfoChip(
                                      icon: Icons.person_outline,
                                      text: rancho.duenoNombre,
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoChip(
                                      icon: Icons.group_outlined,
                                      text: '${rancho.totalGanaderos} ganaderos',
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoChip(
                                      icon: Icons.pets_outlined,
                                      text: '${rancho.totalBovinos} bovinos',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: tt.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRecargar;
  const _EmptyState({required this.onRecargar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.landscape_outlined,
                  color: cs.tertiary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin ranchos registrados',
              style: tt.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aún no hay ranchos en el sistema.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
