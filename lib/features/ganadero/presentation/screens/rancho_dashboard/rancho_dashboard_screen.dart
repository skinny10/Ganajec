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
  static const _kBg = Color(0xFFFAFAF7);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kTextMuted = Color(0xFFAEADA6);
  static const _kGreen = Color(0xFF1D7A55);
  static const _kGreenLight = Color(0xFFE8F5EF);

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<RanchoDashboardViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RanchoDashboardViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
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
        title: Text(
          vm.rancho.nombre,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
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
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: _kTextPrimary, size: 16),
              ),
            ),
          IconButton(
            onPressed: () =>
                context.read<RanchoDashboardViewModel>().cargar(),
            icon: const Icon(Icons.refresh_outlined,
                color: _kTextSecondary, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
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
    return RefreshIndicator(
      onRefresh: () =>
          context.read<RanchoDashboardViewModel>().cargar(),
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 40),
        children: [
          // Card info del rancho
          _RanchoInfoCard(rancho: vm.rancho),

          const SizedBox(height: 16),

          // Sección bovinos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bovinos (${vm.bovinos.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextSecondary,
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

  static const _kBorder = Color(0xFFE8E5DC);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kGreen = Color(0xFF1D7A55);
  static const _kGreenLight = Color(0xFFE8F5EF);

  const _RanchoInfoCard({required this.rancho});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kGreenLight,
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
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        '${rancho.municipio}, ${rancho.estado}',
                        style: const TextStyle(
                            fontSize: 12, color: _kTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 0, thickness: 0.5, color: _kBorder),
            const SizedBox(height: 14),
            // Código
            const Text(
              'CÓDIGO DE INVITACIÓN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _kTextSecondary,
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
                  color: _kGreenLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _kGreen.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rancho.codigoInvitacion,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: _kGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.copy_outlined,
                        color: _kGreen, size: 16),
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

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kTextMuted = Color(0xFFAEADA6);

  const _BovinoTile({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3EE),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kTextPrimary,
                    ),
                  ),
                  Text(
                    '${animal.raza} · ${animal.idExterno}',
                    style: const TextStyle(
                        fontSize: 11.5, color: _kTextSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${animal.pesoKg.toStringAsFixed(0)} kg',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kTextPrimary,
                  ),
                ),
                Text(
                  animal.sexo,
                  style: const TextStyle(
                      fontSize: 11, color: _kTextMuted),
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
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Text('🐄', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            'Sin bovinos registrados en este rancho',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Los ganaderos que se unan al rancho podrán registrar su hato.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF888880)),
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
                onPressed: onRetry,
                child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
