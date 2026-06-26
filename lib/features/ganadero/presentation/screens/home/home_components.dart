import 'dart:async';
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

class HomeAlertas extends StatefulWidget {
  final List<Alerta> alertas;

  const HomeAlertas({super.key, required this.alertas});

  @override
  State<HomeAlertas> createState() => _HomeAlertasState();
}

class _HomeAlertasState extends State<HomeAlertas> {
  bool _visible = false;
  Timer? _timer;
  // IDs de alertas ya mostradas en esta sesión — no vuelven a aparecer
  final Set<String> _alertasMostradas = {};

  @override
  void initState() {
    super.initState();
    _evaluarNuevas(widget.alertas);
  }

  @override
  void didUpdateWidget(HomeAlertas oldWidget) {
    super.didUpdateWidget(oldWidget);
    _evaluarNuevas(widget.alertas);
  }

  void _evaluarNuevas(List<Alerta> alertas) {
    if (alertas.isEmpty) return;
    final nuevas = alertas
        .map((a) => a.id)
        .where((id) => !_alertasMostradas.contains(id))
        .toSet();
    if (nuevas.isEmpty) return; // todas ya fueron mostradas
    _alertasMostradas.addAll(nuevas);
    setState(() => _visible = true);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alertas.isEmpty || !_visible) return const SizedBox.shrink();
    return Column(
      children: widget.alertas
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AlertaBanner(alerta: a),
              ))
          .toList(),
    );
  }
}

// ── Mi hato (ganadero) / Mis ranchos (dueño) ─────────────────────────────────

/// Número máximo de animales a mostrar en el home antes del "Ver todos".
const _kLimiteHato = 5;

class HomeMiHato extends StatelessWidget {
  final List<Animal> animales;
  final List<Alerta> alertas;
  final VoidCallback onVerTodos;
  final void Function(Animal)? onAnimalTap;
  final bool esDueno;
  /// Solo para dueño: llamado con la lista filtrada del rancho cuando el user
  /// toca "Ver todos" en un grupo de rancho concreto.
  final void Function(List<Animal>)? onVerRanchoTodos;

  const HomeMiHato({
    super.key,
    required this.animales,
    required this.alertas,
    required this.onVerTodos,
    this.onAnimalTap,
    this.esDueno = false,
    this.onVerRanchoTodos,
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
          // ── Vista dueño: agrupado por rancho, máx 5 por grupo ────────────
          ..._porRancho.entries.map((entry) {
            final todos = entry.value;
            final visibles = todos.take(_kLimiteHato).toList();
            final restantes = todos.length - visibles.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RanchoHeader(nombre: entry.key),
                ...visibles.map((a) => AnimalListTile(
                      animal: a,
                      estado: 'Saludable',
                      onTap: null,
                    )),
                if (restantes > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: Center(
                      child: TextButton(
                        onPressed: onVerRanchoTodos != null
                            ? () => onVerRanchoTodos!(todos)
                            : null,
                        child: Text(
                          'Ver los $restantes restantes',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          })
        else ...[
          // ── Vista ganadero: lista simple, máximo 5 ────────────────────────
          ...animales.take(_kLimiteHato).map(
            (a) => AnimalListTile(
              animal: a,
              estado: _estadoAnimal(a.id, alertas),
              onTap: onAnimalTap != null ? () => onAnimalTap!(a) : null,
            ),
          ),
          // "Ver todos" extra si hay más de 5
          if (animales.length > _kLimiteHato)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Center(
                child: TextButton(
                  onPressed: onVerTodos,
                  child: Text(
                    'Ver los ${animales.length - _kLimiteHato} restantes',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
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
