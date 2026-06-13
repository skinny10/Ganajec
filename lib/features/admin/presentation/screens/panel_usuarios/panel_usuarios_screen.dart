import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/admin/domain/entities/usuario.dart';
import '../../viewmodels/panel_usuarios_viewmodel.dart';
import 'panel_usuarios_components.dart';

class PanelUsuariosScreen extends StatefulWidget {
  const PanelUsuariosScreen({super.key});

  @override
  State<PanelUsuariosScreen> createState() => _PanelUsuariosScreenState();
}

class _PanelUsuariosScreenState extends State<PanelUsuariosScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PanelUsuariosViewModel>().cargarUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PanelUsuariosViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _buildBody(vm),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(PanelUsuariosViewModel vm) {
    if (vm.state == PanelUsuariosState.loading ||
        vm.state == PanelUsuariosState.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.state == PanelUsuariosState.error) {
      return Center(child: Text('Error: ${vm.errorMessage}'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PanelUsuariosHeader(),
          const SizedBox(height: 20),
          const Text(
            'Panel de Usuarios',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Gestiona los usuarios del sistema',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          const KpiUsuariosGrid(),
          const SizedBox(height: 16),
          _buildSearchBar(vm),
          const SizedBox(height: 12),
          const FiltrosTabs(),
          const SizedBox(height: 16),
          const ListaUsuarios(),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 200,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _showAddUsuarioSheet,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Agregar usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A2C0A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSearchBar(PanelUsuariosViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: vm.buscar,
            decoration: InputDecoration(
              hintText: 'Buscar usuario...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.tune, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRolChip(String label,
      {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4A2C0A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF4A2C0A)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _showAddUsuarioSheet() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    RolUsuario? selectedRol;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Agregar usuario',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Rol',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRolChip(
                        'Ganadero',
                        selected: selectedRol == RolUsuario.ganadero,
                        onTap: () =>
                            setSheetState(() => selectedRol = RolUsuario.ganadero),
                      ),
                      const SizedBox(width: 8),
                      _buildRolChip(
                        'Due\u00f1o',
                        selected: selectedRol == RolUsuario.dueno,
                        onTap: () =>
                            setSheetState(() => selectedRol = RolUsuario.dueno),
                      ),
                      const SizedBox(width: 8),
                      _buildRolChip(
                        'Veterinario',
                        selected: selectedRol == RolUsuario.veterinario,
                        onTap: () => setSheetState(
                            () => selectedRol = RolUsuario.veterinario),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.isNotEmpty &&
                            emailCtrl.text.isNotEmpty &&
                            selectedRol != null) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.people_outline), label: 'Usuarios'),
        BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined), label: 'Roles'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined), label: 'Auditor\u00eda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: 'Config'),
      ],
    );
  }
}
