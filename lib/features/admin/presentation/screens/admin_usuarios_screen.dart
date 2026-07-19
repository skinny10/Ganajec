import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_usuarios_viewmodel.dart';
import 'package:ganajec/features/admin/domain/entities/admin_usuario.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AdminUsuariosViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminUsuariosViewModel>();
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
          'Usuarios',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<AdminUsuariosViewModel>().cargar(),
            icon: Icon(Icons.refresh_outlined,
                color: cs.onSurfaceVariant, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<AdminUsuariosViewModel>().cargar(),
              child: vm.usuarios.isEmpty
                  ? _EmptyState(
                      onRecargar: () =>
                          context.read<AdminUsuariosViewModel>().cargar())
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 80),
                      itemCount: vm.usuarios.length,
                      itemBuilder: (_, i) => _UsuarioTile(
                        usuario: vm.usuarios[i],
                        onEditar: () =>
                            _mostrarFormulario(context, vm.usuarios[i]),
                        onEliminar: () =>
                            _confirmarEliminar(context, vm.usuarios[i]),
                      ),
                    ),
            ),
    );
  }

  Future<void> _mostrarFormulario(
      BuildContext context, AdminUsuario usuario) async {
    print('Editando usuario ID: ${usuario.id}');
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<AdminUsuariosViewModel>(),
        child: _UsuarioFormModal(usuario: usuario),
      ),
    );
    if (context.mounted) {
      context.read<AdminUsuariosViewModel>().cargar();
    }
  }

  Future<void> _confirmarEliminar(
      BuildContext context, AdminUsuario usuario) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Deseas eliminar a ${usuario.nombre}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final err =
          await context.read<AdminUsuariosViewModel>().eliminarUsuario(usuario.id);
      if (context.mounted) {
        final cs2 = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err != null ? err : '${usuario.nombre} eliminado'),
            backgroundColor: err != null ? cs2.error : cs2.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _UsuarioTile extends StatelessWidget {
  final AdminUsuario usuario;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _UsuarioTile({
    required this.usuario,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final rolColor = usuario.rol == 'admin'
        ? cs.error
        : usuario.rol == 'dueno'
            ? cs.tertiary
            : cs.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rolColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    usuario.nombre.isNotEmpty
                        ? usuario.nombre[0].toUpperCase()
                        : '?',
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: rolColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombre,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      usuario.email,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: rolColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      usuario.rol.toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: rolColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: usuario.isActive
                          ? Colors.green.withOpacity(0.12)
                          : cs.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      usuario.isActive ? 'Activo' : 'Inactivo',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: usuario.isActive ? Colors.green : cs.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_outlined,
                        color: cs.onSurfaceVariant, size: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onSelected: (v) {
                      if (v == 'editar') onEditar();
                      if (v == 'eliminar') onEliminar();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(children: [
                          Icon(Icons.edit_outlined,
                              size: 16, color: cs.onSurface),
                          const SizedBox(width: 8),
                          Text('Editar',
                              style: tt.bodySmall?.copyWith(fontSize: 13)),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'eliminar',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              size: 16, color: cs.error),
                          const SizedBox(width: 8),
                          Text('Eliminar',
                              style: tt.bodySmall?.copyWith(
                                  fontSize: 13, color: cs.error)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRecargar;
  const _EmptyState({required this.onRecargar});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.people_outline, color: cs.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin usuarios registrados',
              style: tt.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aún no hay usuarios en el sistema.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsuarioFormModal extends StatefulWidget {
  final AdminUsuario usuario;
  const _UsuarioFormModal({required this.usuario});

  @override
  State<_UsuarioFormModal> createState() => _UsuarioFormModalState();
}

class _UsuarioFormModalState extends State<_UsuarioFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _email;
  late String _rol;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.usuario.nombre);
    _email = TextEditingController(text: widget.usuario.email);
    _rol = widget.usuario.rol;
    _isActive = widget.usuario.isActive;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    print('Guardando: nombre=${_nombre.text}, email=${_email.text}, rol=$_rol, activo=$_isActive');
    final vm = context.read<AdminUsuariosViewModel>();
    final err = await vm.editarUsuario(
      widget.usuario.id,
      nombre: _nombre.text.trim(),
      email: _email.text.trim(),
      rol: _rol,
      isActive: _isActive,
    );

    if (!mounted) return;
    if (err != null) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminUsuariosViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Editar usuario',
                  style: tt.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                _Campo(
                  label: 'Nombre *',
                  controller: _nombre,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                _Campo(
                  label: 'Email *',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Rol',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _rol,
                      items: const [
                        DropdownMenuItem(value: 'ganadero', child: Text('Ganadero')),
                        DropdownMenuItem(value: 'dueno', child: Text('Dueño')),
                        DropdownMenuItem(value: 'veterinario', child: Text('Veterinario')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (v) => setState(() => _rol = v ?? _rol),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Activo',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeColor: cs.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: cs.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Cancelar',
                            style: tt.labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: vm.guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.tertiary,
                          foregroundColor: cs.onTertiary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: vm.guardando
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: cs.onTertiary, strokeWidth: 2),
                              )
                            : Text('Guardar',
                                style: tt.labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Campo({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: tt.bodyMedium?.copyWith(
              fontSize: 14,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
