import 'package:flutter/material.dart';
import '../../../domain/entities/alerta.dart';
import '../../../domain/entities/animal.dart';
import '../../../domain/entities/prediccion.dart';
import '../../widgets/alerta_banner.dart';
import '../../widgets/animal_list_tile.dart';
import '../../widgets/prediccion_tile.dart';
import '../../widgets/resumen_card.dart';

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

class HomeMiHato extends StatelessWidget {
  final List<Animal> animales;
  final List<Alerta> alertas;
  final VoidCallback onVerTodos;

  const HomeMiHato({
    super.key,
    required this.animales,
    required this.alertas,
    required this.onVerTodos,
  });

  String _estadoAnimal(String animalId, List<Alerta> alertas) {
    final alerta = alertas.where((a) => a.animalId == animalId).toList();
    if (alerta.isEmpty) return 'Saludable';
    if (alerta.first.severidad == 'alta') return 'Severidad alta';
    return 'Observar';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mi hato',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onVerTodos,
              child: const Text('Ver todos'),
            ),
          ],
        ),
        ...animales.map(
          (a) => AnimalListTile(
            animal: a,
            estado: _estadoAnimal(a.id, alertas),
          ),
        ),
      ],
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
        ...predicciones.map((p) => PrediccionTile(prediccion: p)),
      ],
    );
  }
}