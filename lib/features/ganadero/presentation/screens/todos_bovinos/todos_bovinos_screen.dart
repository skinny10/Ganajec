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

  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kSurface = Color(0xFFFFFFFF);

  const TodosBovinosScreen({super.key, required this.args});

  String _estado(String id) {
    final a = args.alertas.where((x) => x.animalId == id).toList();
    if (a.isEmpty) return 'Saludable';
    if (a.first.severidad == 'alta') return 'Severidad alta';
    return 'Observar';
  }

  @override
  Widget build(BuildContext context) {
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
          'Mi hato (${args.animales.length})',
          style: const TextStyle(
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
      body: args.animales.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🐄', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No hay animales registrados',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary),
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
