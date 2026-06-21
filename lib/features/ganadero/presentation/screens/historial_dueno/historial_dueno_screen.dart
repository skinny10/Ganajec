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
  static const _kBg          = Color(0xFFFAFAF7);
  static const _kBorder      = Color(0xFFE8E5DC);
  static const _kSurface     = Color(0xFFFFFFFF);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted   = Color(0xFFAEADA6);
  static const _kCow         = Color(0xFF8B4A2B);
  static const _kCowLight    = Color(0xFFF5EBE0);
  static const _kGreen       = Color(0xFF1D7A55);
  static const _kGreenLight  = Color(0xFFE8F5EF);

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
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.chevron_left_rounded,
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
          : vm.status == HistorialDuenoStatus.error
              ? _ErrorState(
                  message: vm.error ?? 'Error al cargar',
                  onRetry: () => vm.cargar(),
                )
              : _buildContent(vm),
    );
  }

  Widget _buildContent(HistorialDuenoViewModel vm) {
    return CustomScrollView(
      slivers: [
        // ── Buscador ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Column(
              children: [
                // Búsqueda
                Container(
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: vm.setBusqueda,
                    style: const TextStyle(fontSize: 13, color: _kTextPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Buscar bovino, ganadero, rancho…',
                      hintStyle:
                          TextStyle(color: _kTextMuted, fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          color: _kTextMuted, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Quick stats
                Row(
                  children: [
                    _StatChip(
                      label: '${vm.totalRegistros} registros',
                      icon: Icons.list_alt_outlined,
                      color: _kCow,
                      bg: _kCowLight,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: '${vm.totalAlta} alertas altas',
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFC0392B),
                      bg: const Color(0xFFFDEDEC),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),

        // ── Lista jerárquica ─────────────────────────────────────────────────
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

  static const _kCow      = Color(0xFF8B4A2B);
  static const _kCowLight = Color(0xFFF5EBE0);
  static const _kBorder   = Color(0xFFE8E5DC);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera de rancho
        Container(
          margin: const EdgeInsets.only(top: 16, bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _kCowLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8D5C4)),
          ),
          child: Row(
            children: [
              const Text('🏡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rancho.ranchoNombre,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kCow,
                  ),
                ),
              ),
              Text(
                '${rancho.totalGanaderos} ganadero${rancho.totalGanaderos == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 11,
                  color: _kCow.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // Ganaderos
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

  static const _kGreen      = Color(0xFF1D7A55);
  static const _kGreenLight = Color(0xFFE8F5EF);
  static const _kBorder     = Color(0xFFE8E5DC);
  static const _kTextMuted  = Color(0xFFAEADA6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera ganadero
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            margin: const EdgeInsets.only(left: 12, bottom: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _kGreenLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _kGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      widget.ganadero.ganaderoNombre.isNotEmpty
                          ? widget.ganadero.ganaderoNombre[0].toUpperCase()
                          : 'G',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.ganadero.ganaderoNombre,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kGreen,
                    ),
                  ),
                ),
                Text(
                  '${widget.ganadero.totalBovinos} bovino${widget.ganadero.totalBovinos == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 10, color: _kGreen),
                ),
                const SizedBox(width: 6),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: _kGreen,
                ),
              ],
            ),
          ),
        ),
        // Bovinos
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

  static const _kSurface    = Color(0xFFFFFFFF);
  static const _kBorder     = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted   = Color(0xFFAEADA6);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          // Cabecera bovino
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                          ),
                        ),
                        Text(
                          '${widget.bovino.categoria} · ${widget.bovino.totalRegistros} registro${widget.bovino.totalRegistros == 1 ? '' : 's'}',
                          style: const TextStyle(
                              fontSize: 11, color: _kTextMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _kTextMuted,
                  ),
                ],
              ),
            ),
          ),
          // Registros (expandibles)
          if (_expanded && widget.bovino.registros.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFE8E5DC)),
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

  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted   = Color(0xFFAEADA6);

  Color _severidadColor(String? sev) {
    switch (sev) {
      case 'alta':     return const Color(0xFFC0392B);
      case 'media':    return const Color(0xFFE67E22);
      default:         return const Color(0xFF1D7A55);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severidadColor(registro.severidad);
    final fecha = registro.registradoEn;
    final fechaStr =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year} '
        '${fecha.hour.toString().padLeft(2, '0')}:'
        '${fecha.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de severidad
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      Text(
                        '${registro.confianzaPct}% conf.',
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
                Text(
                  registro.textoLibre,
                  style: const TextStyle(
                      fontSize: 11, color: _kTextPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fechaStr,
                  style:
                      const TextStyle(fontSize: 10, color: _kTextMuted),
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
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: color),
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📋', style: TextStyle(fontSize: 40)),
            SizedBox(height: 16),
            Text(
              'Sin historial aún',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A)),
            ),
            SizedBox(height: 6),
            Text(
              'Aún no hay registros de síntomas en tus ranchos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF888880)),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888880))),
            const SizedBox(height: 16),
            TextButton(
                onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
