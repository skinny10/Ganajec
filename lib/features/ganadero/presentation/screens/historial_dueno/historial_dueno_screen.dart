import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../../viewmodels/historial_dueno_viewmodel.dart';

class HistorialDuenoScreen extends StatefulWidget {
  const HistorialDuenoScreen({super.key});

  @override
  State<HistorialDuenoScreen> createState() => _HistorialDuenoScreenState();
}

class _HistorialDuenoScreenState extends State<HistorialDuenoScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<HistorialDuenoViewModel>().cargar());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistorialDuenoViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
            child: Icon(Icons.chevron_left_rounded,
                color: cs.onSurface, size: 20),
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
          : vm.status == HistorialDuenoStatus.error
              ? _ErrorState(
                  message: vm.error ?? 'Error al cargar',
                  onRetry: () => vm.cargar(),
                )
              : _buildContent(vm, cs, tt),
    );
  }

  Widget _buildContent(HistorialDuenoViewModel vm, ColorScheme cs, TextTheme tt) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: vm.setBusqueda,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 13,
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar bovino, ganadero, rancho…',
                      hintStyle: tt.bodySmall?.copyWith(
                        color: cs.outline,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: cs.outline, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatChip(
                      label: '${vm.totalRegistros} registros',
                      icon: Icons.list_alt_outlined,
                      color: cs.primary,
                      bg: cs.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: '${vm.totalAlta} alertas altas',
                      icon: Icons.warning_amber_rounded,
                      color: cs.error,
                      bg: cs.errorContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),

        if (vm.isEmpty)
          const SliverFillRemaining(child: _EmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _RanchoSection(rancho: vm.ranchos[i]),
                childCount: vm.ranchos.length,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Sección por rancho ────────────────────────────────────────────────────────

class _RanchoSection extends StatelessWidget {
  final HistDuenoRancho rancho;
  const _RanchoSection({required this.rancho});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('🏡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rancho.ranchoNombre,
                  style: tt.labelMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
              Text(
                '${rancho.totalGanaderos} ganadero${rancho.totalGanaderos == 1 ? '' : 's'}',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11,
                  color: cs.primary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        ...rancho.ganaderos.map(
          (g) => _GanaderoSection(ganadero: g),
        ),
      ],
    );
  }
}

// ── Sección por ganadero (expansible) ─────────────────────────────────────────

class _GanaderoSection extends StatefulWidget {
  final HistDuenoGanadero ganadero;
  const _GanaderoSection({required this.ganadero});

  @override
  State<_GanaderoSection> createState() => _GanaderoSectionState();
}

class _GanaderoSectionState extends State<_GanaderoSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            margin: const EdgeInsets.only(left: 12, bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.tertiary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      widget.ganadero.ganaderoNombre.isNotEmpty
                          ? widget.ganadero.ganaderoNombre[0].toUpperCase()
                          : 'G',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.ganadero.ganaderoNombre,
                    style: tt.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.tertiary,
                    ),
                  ),
                ),
                Text(
                  '${widget.ganadero.totalBovinos} bovino${widget.ganadero.totalBovinos == 1 ? '' : 's'}',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 10,
                    color: cs.tertiary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: cs.tertiary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.ganadero.bovinos.map(
            (b) => Padding(
              padding: const EdgeInsets.only(left: 24),
              child: _BovinoCard(bovino: b),
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Card por bovino (expansible) ──────────────────────────────────────────────

class _BovinoCard extends StatefulWidget {
  final HistDuenoBovino bovino;
  const _BovinoCard({required this.bovino});

  @override
  State<_BovinoCard> createState() => _BovinoCardState();
}

class _BovinoCardState extends State<_BovinoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Text('🐄', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bovino.nombre,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          '${widget.bovino.categoria} · ${widget.bovino.totalRegistros} registro${widget.bovino.totalRegistros == 1 ? '' : 's'}',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 11,
                            color: cs.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: cs.outline,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && widget.bovino.registros.isNotEmpty) ...[
            Divider(height: 1, color: cs.outlineVariant),
            ...widget.bovino.registros.map(
              (r) => _RegistroTile(registro: r),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Tile de registro ──────────────────────────────────────────────────────────

class _RegistroTile extends StatelessWidget {
  final HistDuenoRegistro registro;
  const _RegistroTile({required this.registro});

  Color _severidadColor(String? sev, ColorScheme cs) {
    switch (sev) {
      case 'alta':  return cs.error;
      case 'media': return cs.secondary;
      default:      return cs.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _severidadColor(registro.severidad, cs);
    final fecha = registro.registradoEn;
    final fechaStr =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 40,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (registro.tienePrediccion) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          registro.enfermedad!,
                          style: tt.labelMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      Text(
                        '${registro.confianzaPct}% conf.',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                Text(
                  registro.textoLibre,
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fechaStr,
                  style: tt.labelSmall?.copyWith(
                    fontSize: 10,
                    color: cs.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Auxiliares ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            const Text('📋', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              'Sin historial aún',
              style: tt.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aún no hay registros de síntomas en tus ranchos.',
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

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
            const Text('⚠️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
