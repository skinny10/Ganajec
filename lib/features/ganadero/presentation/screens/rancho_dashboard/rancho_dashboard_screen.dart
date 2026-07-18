import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/rancho_dashboard_viewmodel.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/mis_ganaderos_viewmodel.dart';
import 'package:ganajec/share/domain/entities/animal.dart';

class RanchoDashboardScreen extends StatefulWidget {
  const RanchoDashboardScreen({super.key});

  @override
  State<RanchoDashboardScreen> createState() =>
      _RanchoDashboardScreenState();
}

class _RanchoDashboardScreenState extends State<RanchoDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<RanchoDashboardViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RanchoDashboardViewModel>();
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
          vm.rancho.nombre,
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await context.push(
                AppRoutes.editarRancho,
                extra: vm.rancho,
              );
              if (context.mounted) {
                context.read<RanchoDashboardViewModel>().cargar();
              }
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(Icons.edit_outlined,
                  color: cs.onSurface, size: 16),
            ),
          ),
          IconButton(
            onPressed: () =>
                context.read<RanchoDashboardViewModel>().cargar(),
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
          : vm.status == RanchoDashboardStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar el rancho',
                  onRetry: () =>
                      context.read<RanchoDashboardViewModel>().cargar(),
                )
              : _buildContent(context, vm),
    );
  }

  Widget _buildContent(
      BuildContext context, RanchoDashboardViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<RanchoDashboardViewModel>().cargar(),
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 40),
        children: [
          _RanchoInfoCard(rancho: vm.rancho),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bovinos (${vm.bovinos.length})',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (vm.bovinos.isEmpty)
            const _EmptyBovinos()
          else
            ...vm.bovinos.map((b) => _BovinoTile(animal: b)),
        ],
      ),
    );
  }
}

// ── Rancho info card ──────────────────────────────────────────────────────────

class _RanchoInfoCard extends StatelessWidget {
  final RanchoInfo rancho;
  const _RanchoInfoCard({required this.rancho});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🏡', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rancho.nombre,
                        style: tt.titleMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
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
            const SizedBox(height: 16),
            Divider(height: 0, thickness: 0.5, color: cs.outlineVariant),
            const SizedBox(height: 14),
            Text(
              'CÓDIGO DE INVITACIÓN',
              style: tt.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: rancho.codigoInvitacion));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Código copiado'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: cs.tertiary.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rancho.codigoInvitacion,
                      style: tt.bodyLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: cs.tertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.copy_outlined,
                        color: cs.tertiary, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bovino tile ───────────────────────────────────────────────────────────────

class _BovinoTile extends StatelessWidget {
  final Animal animal;
  const _BovinoTile({required this.animal});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🐄', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.nombre,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${animal.raza} · ${animal.idExterno}',
                    style: tt.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${animal.pesoKg.toStringAsFixed(0)} kg',
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  animal.sexo,
                  style: tt.bodySmall?.copyWith(
                    fontSize: 11,
                    color: cs.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyBovinos extends StatelessWidget {
  const _EmptyBovinos();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('🐄', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Sin bovinos registrados en este rancho',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Los ganaderos que se unan al rancho podrán registrar su hato.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

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
                onPressed: onRetry,
                child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
