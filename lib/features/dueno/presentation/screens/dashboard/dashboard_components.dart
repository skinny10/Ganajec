import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/kpi_card.dart';
import '../../widgets/caso_critico_tile.dart';
import '../../widgets/ganadero_avatar_chip.dart';

class DashboardHeader extends StatelessWidget {
  final String nombreDueno;
  final String nombreRancho;
  final String iniciales;

  const DashboardHeader({
    super.key,
    required this.nombreDueno,
    required this.nombreRancho,
    required this.iniciales,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buenos d\u00edas,',
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              nombreDueno,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.home, size: 14, color: colors.primary),
                const SizedBox(width: 4),
                Text(
                  nombreRancho,
                  style: TextStyle(fontSize: 13, color: colors.primary),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primary,
              child: Text(
                iniciales,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final dashboard = vm.dashboard!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        KpiCard(
          valor: '${dashboard.totalAnimales}',
          etiqueta: 'Bovinos en el rancho',
          icono: const Text('\ud83d\udc04', style: TextStyle(fontSize: 24)),
          badge: 'Total',
          badgeColor: const Color(0xFF805611),
        ),
        KpiCard(
          valor: '${dashboard.animalesConAlerta}',
          etiqueta: 'Con alertas activas',
          icono: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFF9A825), size: 24),
          badge: '+${dashboard.animalesConAlerta}',
          badgeColor: const Color(0xFFBA1A1A),
        ),
        KpiCard(
          valor: '${dashboard.animalesSanos}',
          etiqueta: 'En buen estado',
          icono: const Icon(Icons.check_circle_outline,
              color: Color(0xFF4CAF50), size: 24),
          badge: '+3',
          badgeColor: const Color(0xFF4CAF50),
        ),
        KpiCard(
          valor: '${dashboard.ganadoresEnCampo}',
          etiqueta: 'Ganaderos en campo',
          icono: const Icon(Icons.person_outline,
              color: Color(0xFF805611), size: 24),
          badge: 'Activos',
          badgeColor: const Color(0xFF805611),
        ),
      ],
    );
  }
}

class SeccionCasosCriticos extends StatelessWidget {
  const SeccionCasosCriticos({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final casos = vm.dashboard!.casosCriticos.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Casos cr\u00edticos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...casos.map((c) => CasoCriticoTile(caso: c)),
      ],
    );
  }
}

class SeccionGanaderos extends StatelessWidget {
  const SeccionGanaderos({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final ganaderos = vm.dashboard!.ganaderos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis ganaderos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ganaderos
                .map(
                  (g) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GanaderoAvatarChip(
                      ganadero: g,
                      onTap: () {},
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
