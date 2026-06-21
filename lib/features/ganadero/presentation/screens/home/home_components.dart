import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/features/ganadero/presentation/widgets/alerta_banner.dart';
import 'package:ganajec/features/ganadero/presentation/widgets/animal_list_tile.dart';
import 'package:ganajec/features/ganadero/presentation/widgets/prediccion_tile.dart';
import 'package:ganajec/features/ganadero/presentation/widgets/resumen_card.dart';

class HomeResumen extends StatelessWidget {
  final Map<String, int> resumen;

  const HomeResumen({super.key, required this.resumen});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        ResumenCard(
          valor: '${resumen['total'] ?? 0}',
          etiqueta: 'Animales\nregistrados',
          icono: Icons.pets,
          color: colors.primary,
        ),
        const SizedBox(width: 10),
        ResumenCard(
          valor: '${resumen['en_buen_estado'] ?? 0}',
          etiqueta: 'En buen\nestado',
          icono: Icons.check_circle_outline,
          color: colors.tertiary,
        ),
        const SizedBox(width: 10),
        ResumenCard(
          valor: '${resumen['con_alertas'] ?? 0}',
          etiqueta: 'Con alertas\nactivas',
          icono: Icons.warning_amber_rounded,
          color: colors.error,
        ),
      ],
    );
  }
}

class HomeAlertas extends StatelessWidget {
  final List<Alerta> alertas;

  const HomeAlertas({super.key, required this.alertas});

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) return const SizedBox.shrink();
    return Column(
      children: alertas
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AlertaBanner(alerta: a),
              ))
          .toList(),
    );
  }
}

// ── Mi hato (ganadero) / Mis ranchos (dueño) ─────────────────────────────────

class HomeMiHato extends StatelessWidget {
  final List<Animal> animales;
  final List<Alerta> alertas;
  final VoidCallback onVerTodos;
  final void Function(Animal)? onAnimalTap;
  final bool esDueno;

  const HomeMiHato({
    super.key,
    required this.animales,
    required this.alertas,
    required this.onVerTodos,
    this.onAnimalTap,
    this.esDueno = false,
  });

  String _estadoAnimal(String animalId, List<Alerta> alertas) {
    final alerta = alertas.where((a) => a.animalId == animalId).toList();
    if (alerta.isEmpty) return 'Saludable';
    if (alerta.first.severidad == 'alta') return 'Severidad alta';
    return 'Observar';
  }

  /// Agrupa animales por rancho_nombre para la vista del dueño
  Map<String, List<Animal>> get _porRancho {
    final map = <String, List<Animal>>{};
    for (final a in animales) {
      final key = a.ranchoNombre.isNotEmpty ? a.ranchoNombre : 'Sin rancho';
      map.putIfAbsent(key, () => []).add(a);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              esDueno ? 'Mis ranchos' : 'Mi hato',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!esDueno)
              TextButton(
                onPressed: onVerTodos,
                child: const Text('Ver todos'),
              ),
          ],
        ),
        if (animales.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              esDueno
                  ? 'Aún no hay bovinos registrados en tus ranchos.'
                  : 'Aún no tienes animales registrados.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else if (esDueno)
          // ── Vista dueño: agrupado por rancho ──────────────────────────────
          ..._porRancho.entries.map((entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RanchoHeader(nombre: entry.key),
                  ...entry.value.map((a) => AnimalListTile(
                        animal: a,
                        estado: 'Saludable',
                        onTap: null, // dueño no navega al detalle del bovino
                      )),
                ],
              ))
        else
          // ── Vista ganadero: lista simple ──────────────────────────────────
          ...animales.map(
            (a) => AnimalListTile(
              animal: a,
              estado: _estadoAnimal(a.id, alertas),
              onTap: onAnimalTap != null ? () => onAnimalTap!(a) : null,
            ),
          ),
      ],
    );
  }
}

class _RanchoHeader extends StatelessWidget {
  final String nombre;
  const _RanchoHeader({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          const Text('🏡', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            nombre,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B4A2B),
                ),
          ),
        ],
      ),
    );
  }
}

class HomePredicciones extends StatelessWidget {
  final List<Prediccion> predicciones;
  final VoidCallback onVerHistorial;

  const HomePredicciones({
    super.key,
    required this.predicciones,
    required this.onVerHistorial,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Últimas predicciones',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onVerHistorial,
              child: const Text('Ver historial'),
            ),
          ],
        ),
        if (predicciones.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No hay predicciones recientes.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          )
        else
          ...predicciones.map((p) => PrediccionTile(prediccion: p)),
      ],
    );
  }
}
