import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/colegas_viewmodel.dart';

class ColegasScreen extends StatefulWidget {
  const ColegasScreen({super.key});

  @override
  State<ColegasScreen> createState() => _ColegasScreenState();
}

class _ColegasScreenState extends State<ColegasScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kTextMuted = Color(0xFFAEADA6);
  static const _kGreen = Color(0xFF1D7A55);
  static const _kGreenLight = Color(0xFFE8F5EF);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ColegasViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ColegasViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : null,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: _kTextPrimary,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Colegas del rancho',
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
          : vm.status == ColegasStatus.error
              ? _ErrorState(
                  message: vm.error ?? 'Error al cargar',
                  onRetry: () => vm.cargar(),
                )
              : vm.colegas.isEmpty
                  ? _EmptyState()
                  : RefreshIndicator(
                      onRefresh: () => vm.cargar(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
                        itemCount: vm.colegas.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, i) =>
                            _ColegaCard(colega: vm.colegas[i]),
                      ),
                    ),
    );
  }
}

class _ColegaCard extends StatelessWidget {
  final ColegaItem colega;
  const _ColegaCard({required this.colega});

  static const _kBorder = Color(0xFFE8E5DC);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kGreen = Color(0xFF1D7A55);
  static const _kGreenLight = Color(0xFFE8F5EF);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Avatar con iniciales
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kGreenLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Center(
              child: Text(
                colega.iniciales,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _kGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colega.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ganadero',
                  style: TextStyle(
                    fontSize: 11,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _kGreenLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA5D6A7)),
            ),
            child: const Text(
              'Activo',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _kGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  static const _kTextSecondary = Color(0xFF888880);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👥', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            const Text(
              'Sin colegas aún',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Aún no hay otros ganaderos en tu rancho.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _kTextSecondary),
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888880),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
