import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/admin/domain/entities/usuario.dart';
import '../../viewmodels/panel_usuarios_viewmodel.dart';
import '../../widgets/kpi_usuario_card.dart';
import '../../widgets/usuario_list_tile.dart';

class PanelUsuariosHeader extends StatelessWidget {
  const PanelUsuariosHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(Icons.menu, size: 28),
        Stack(
          children: [
            const Icon(Icons.notifications_outlined, size: 28),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class KpiUsuariosGrid extends StatelessWidget {
  const KpiUsuariosGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PanelUsuariosViewModel>();
    final stats = vm.stats!;

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      childAspectRatio: 0.9,
      children: [
        KpiUsuarioCard(
          valor: '${stats.totalUsuarios}',
          etiqueta: 'Total',
        ),
        KpiUsuarioCard(
          valor: '${stats.totalGanaderos}',
          etiqueta: 'Ganaderos',
          colorValor: const Color(0xFFE65100),
        ),
        KpiUsuarioCard(
          valor: '${stats.totalDuenos}',
          etiqueta: 'Due\u00f1os',
          colorValor: const Color(0xFFE65100),
        ),
        KpiUsuarioCard(
          valor: '${stats.totalVeterinarios}',
          etiqueta: 'Veterinarios',
          colorValor: const Color(0xFFE65100),
        ),
      ],
    );
  }
}

class FiltrosTabs extends StatelessWidget {
  const FiltrosTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PanelUsuariosViewModel>();

    final tabs = [
      {'label': 'Todos', 'rol': null},
      {'label': 'Ganaderos', 'rol': RolUsuario.ganadero},
      {'label': 'Due\u00f1os', 'rol': RolUsuario.dueno},
      {'label': 'Veterinarios', 'rol': RolUsuario.veterinario},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((tab) {
          final isActive = vm.filtroRol == tab['rol'];
          return GestureDetector(
            onTap: () => vm.filtrarPorRol(tab['rol'] as RolUsuario?),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                tab['label'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ListaUsuarios extends StatelessWidget {
  const ListaUsuarios({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PanelUsuariosViewModel>();
    final usuarios = vm.usuariosFiltrados;

    if (usuarios.isEmpty) {
      return const Center(child: Text('No se encontraron usuarios'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: usuarios.length,
      itemBuilder: (context, index) => UsuarioListTile(
        usuario: usuarios[index],
        onTap: () {},
      ),
    );
  }
}
