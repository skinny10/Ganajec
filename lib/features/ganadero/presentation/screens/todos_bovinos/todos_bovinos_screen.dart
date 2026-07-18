import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../../widgets/animal_list_tile.dart';

class TodosBovinosArgs {
  final List<Animal> animales;
  final List<Alerta> alertas;
  const TodosBovinosArgs({required this.animales, required this.alertas});
}

class TodosBovinosScreen extends StatelessWidget {
  final TodosBovinosArgs args;

  const TodosBovinosScreen({super.key, required this.args});

  String _estado(String id) {
    final a = args.alertas.where((x) => x.animalId == id).toList();
    if (a.isEmpty) return 'Saludable';
    if (a.first.severidad == 'alta') return 'Severidad alta';
    return 'Observar';
  }

  @override
  Widget build(BuildContext context) {
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
          'Mi hato (${args.animales.length})',
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
      body: args.animales.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🐄', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No hay animales registrados',
                    style: tt.titleSmall?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: args.animales.length,
              itemBuilder: (_, i) {
                final a = args.animales[i];
                return AnimalListTile(
                  animal: a,
                  estado: _estado(a.id),
                  onTap: () => context.push(
                    AppRoutes.detalleBovino,
                    extra: a,
                  ),
                );
              },
            ),
    );
  }
}
