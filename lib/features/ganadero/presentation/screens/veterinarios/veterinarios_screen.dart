import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/veterinario_viewmodel.dart';

class VeterinariosScreen extends StatefulWidget {
  const VeterinariosScreen({super.key});

  @override
  State<VeterinariosScreen> createState() => _VeterinariosScreenState();
}

class _VeterinariosScreenState extends State<VeterinariosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VeterinarioViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VeterinarioViewModel>();
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
          'Veterinarios',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<VeterinarioViewModel>().cargar(),
            icon: Icon(Icons.refresh_outlined,
                color: cs.onSurfaceVariant, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(context, null),
        backgroundColor: cs.tertiary,
        foregroundColor: cs.onTertiary,
        icon: const Icon(Icons.add, size: 18),
        label: Text('Agregar veterinario',
            style: tt.labelMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<VeterinarioViewModel>().cargar(),
              child: vm.vets.isEmpty
                  ? _EmptyState(
                      onAgregar: () => _mostrarFormulario(context, null))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 100),
                      itemCount: vm.vets.length,
                      itemBuilder: (_, i) => _VetTile(
                        vet: vm.vets[i],
                        onEditar: () =>
                            _mostrarFormulario(context, vm.vets[i]),
                        onEliminar: () =>
                            _confirmarEliminar(context, vm.vets[i]),
                      ),
                    ),
            ),
    );
  }

  Future<void> _mostrarFormulario(
      BuildContext context, VeterinarioInfo? vet) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<VeterinarioViewModel>(),
        child: _VetFormModal(vet: vet),
      ),
    );
  }

  Future<void> _mostrarAsociarExistente(BuildContext context) async {
    final vm = context.read<VeterinarioViewModel>();
    final idsActuales = vm.vets.map((v) => v.id).toSet();

    final todos = await vm.listarTodos();
    if (!mounted) return;

    if (todos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes veterinarios creados aún. Crea uno nuevo.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: _AsociarVetModal(
          todos: todos,
          idsActuales: idsActuales,
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(
      BuildContext context, VeterinarioInfo vet) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar veterinario'),
        content: Text(
          '¿Deseas eliminar a ${vet.nombre}? Esta acción no se puede deshacer.',
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
          await context.read<VeterinarioViewModel>().eliminar(vet.id);
      if (context.mounted) {
        final cs2 = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err != null ? err : '${vet.nombre} eliminado'),
            backgroundColor: err != null ? cs2.error : cs2.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── VetTile ──────────────────────────────────────────────────────────────────

class _VetTile extends StatelessWidget {
  final VeterinarioInfo vet;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _VetTile({
    required this.vet,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.medical_services_outlined,
                        color: cs.tertiary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vet.nombre,
                          style: tt.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        if (vet.lugar.isNotEmpty)
                          Text(
                            vet.lugar,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_outlined,
                        color: cs.onSurfaceVariant, size: 20),
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
              const SizedBox(height: 12),
              _InfoChip(
                icon: Icons.phone_outlined,
                text: vet.telefono,
                onTap: () => Clipboard.setData(
                    ClipboardData(text: vet.telefono)),
              ),
              if (vet.ubicacion.isNotEmpty) ...[
                const SizedBox(height: 6),
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  text: vet.ubicacion,
                ),
              ],
              if (vet.notas != null && vet.notas!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    vet.notas!,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              if (vet.ranchos.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: vet.ranchos
                      .map((r) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cs.tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: cs.tertiary.withOpacity(0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🏡',
                                    style: TextStyle(fontSize: 10)),
                                const SizedBox(width: 4),
                                Text(
                                  r.nombre,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onTertiaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _InfoChip({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.copy_outlined, size: 12, color: cs.tertiary),
          ],
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAgregar;
  const _EmptyState({required this.onAgregar});

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
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.medical_services_outlined,
                  color: cs.tertiary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin veterinarios registrados',
              style: tt.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Agrega el veterinario de tu rancho\npara tener sus datos a la mano.',
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

// ── Formulario (modal bottom sheet) ──────────────────────────────────────────

class _VetFormModal extends StatefulWidget {
  final VeterinarioInfo? vet;

  const _VetFormModal({this.vet});

  @override
  State<_VetFormModal> createState() => _VetFormModalState();
}

class _VetFormModalState extends State<_VetFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _ubicacion;
  late final TextEditingController _lugar;
  late final TextEditingController _notas;
  String? _ranchoIdSeleccionado;

  bool get _esEdicion => widget.vet != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vet;
    _nombre   = TextEditingController(text: v?.nombre   ?? '');
    _telefono = TextEditingController(text: v?.telefono ?? '');
    _ubicacion= TextEditingController(text: v?.ubicacion?? '');
    _lugar    = TextEditingController(text: v?.lugar    ?? '');
    _notas    = TextEditingController(text: v?.notas    ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _ubicacion.dispose();
    _lugar.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final cs = Theme.of(context).colorScheme;
    if (!_esEdicion && _ranchoIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona un rancho para el veterinario'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.error,
        ),
      );
      return;
    }
    final vm = context.read<VeterinarioViewModel>();

    String? err;
    if (_esEdicion) {
      err = await vm.editar(
        widget.vet!.id,
        nombre:    _nombre.text.trim(),
        telefono:  _telefono.text.trim(),
        ubicacion: _ubicacion.text.trim(),
        lugar:     _lugar.text.trim(),
        notas:     _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
    } else {
      err = await vm.crear(
        nombre:    _nombre.text.trim(),
        telefono:  _telefono.text.trim(),
        ubicacion: _ubicacion.text.trim(),
        lugar:     _lugar.text.trim(),
        notas:     _notas.text.trim().isEmpty ? null : _notas.text.trim(),
        ranchoId:  _ranchoIdSeleccionado,
      );
    }

    if (!mounted) return;
    if (err != null) {
      final cs2 = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: cs2.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm  = context.watch<VeterinarioViewModel>();
    final cs  = Theme.of(context).colorScheme;
    final tt  = Theme.of(context).textTheme;
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
                  _esEdicion ? 'Editar veterinario' : 'Agregar veterinario',
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
                  hint: 'Dr. Ramírez',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                _Campo(
                  label: 'Teléfono *',
                  controller: _telefono,
                  hint: '9611234567',
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                _Campo(
                  label: 'Lugar / Ciudad',
                  controller: _lugar,
                  hint: 'Tuxtla',
                ),
                const SizedBox(height: 12),
                _Campo(
                  label: 'Ubicación / Referencia',
                  controller: _ubicacion,
                  hint: 'Al lado de la farmacia',
                ),
                const SizedBox(height: 12),
                _Campo(
                  label: 'Notas',
                  controller: _notas,
                  hint: 'Disponible lunes a sábado...',
                  maxLines: 3,
                ),
                if (!_esEdicion) ...[
                  const SizedBox(height: 12),
                  _DropdownRanchoVet(
                    ranchos: vm.ranchosDisponibles,
                    seleccionadoId: _ranchoIdSeleccionado,
                    onChanged: (id) =>
                        setState(() => _ranchoIdSeleccionado = id),
                  ),
                ],
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
                            style: tt.labelMedium?.copyWith(
                                color: cs.onSurfaceVariant)),
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
                            : Text(
                                _esEdicion ? 'Guardar' : 'Agregar',
                                style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600),
                              ),
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

// ── Modal para asociar vet existente ─────────────────────────────────────────

class _AsociarVetModal extends StatefulWidget {
  final List<VeterinarioInfo> todos;
  final Set<String> idsActuales;
  const _AsociarVetModal({required this.todos, required this.idsActuales});

  @override
  State<_AsociarVetModal> createState() => _AsociarVetModalState();
}

class _AsociarVetModalState extends State<_AsociarVetModal> {
  VeterinarioInfo? _seleccionado;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VeterinarioViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
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
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Asociar veterinario existente',
            style: tt.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Los marcados como "Ya en este rancho" no pueden seleccionarse.',
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          ...widget.todos.map((v) {
            final yaAsociado = widget.idsActuales.contains(v.id);
            final sel = _seleccionado?.id == v.id;

            return GestureDetector(
              onTap: yaAsociado ? null : () => setState(() => _seleccionado = v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: yaAsociado
                      ? cs.surfaceContainerLow
                      : sel
                          ? cs.tertiaryContainer
                          : cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: yaAsociado
                        ? cs.outlineVariant
                        : sel
                            ? cs.tertiary
                            : cs.outlineVariant,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medical_services_outlined,
                        color: yaAsociado
                            ? cs.outline
                            : sel
                                ? cs.tertiary
                                : cs.onSurfaceVariant,
                        size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.nombre,
                              style: tt.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: yaAsociado
                                      ? cs.outline
                                      : sel
                                          ? cs.tertiary
                                          : cs.onSurface)),
                          Text(v.telefono,
                              style: tt.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: yaAsociado
                                      ? cs.outline
                                      : cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (yaAsociado)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Ya en este rancho',
                          style: tt.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: cs.tertiary),
                        ),
                      )
                    else if (sel)
                      Icon(Icons.check_circle, color: cs.tertiary, size: 18),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
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
                      style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (_seleccionado == null || vm.guardando)
                      ? null
                      : () async {
                          final err = await context
                              .read<VeterinarioViewModel>()
                              .asociarExistente(_seleccionado!.id);
                          if (!mounted) return;
                          if (err != null) {
                            final cs2 = Theme.of(context).colorScheme;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: cs2.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
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
                      : Text('Asociar',
                          style: tt.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dropdown selector de rancho ───────────────────────────────────────────────

class _DropdownRanchoVet extends StatelessWidget {
  final List<VetRanchoRef> ranchos;
  final String? seleccionadoId;
  final void Function(String?) onChanged;

  const _DropdownRanchoVet({
    required this.ranchos,
    required this.seleccionadoId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rancho *',
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
          child: ranchos.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'No hay ranchos disponibles',
                    style: tt.bodySmall?.copyWith(
                      fontSize: 13,
                      color: cs.outline,
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: seleccionadoId,
                    hint: Text(
                      'Selecciona un rancho',
                      style: tt.bodySmall?.copyWith(
                        fontSize: 13,
                        color: cs.outline,
                      ),
                    ),
                    items: ranchos
                        .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(
                                r.nombre,
                                style: tt.bodyMedium?.copyWith(fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
        ),
      ],
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Campo({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
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
            maxLines: maxLines,
            validator: validator,
            style: tt.bodyMedium?.copyWith(
              fontSize: 14,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: tt.bodySmall?.copyWith(
                color: cs.outline,
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
