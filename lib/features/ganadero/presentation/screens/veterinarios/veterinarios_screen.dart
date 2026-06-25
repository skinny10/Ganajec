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
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kGreen = Color(0xFF2E7D32);
  static const _kGreenLight = Color(0xFFE8F5EF);
  static const _kRed = Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VeterinarioViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VeterinarioViewModel>();

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
        title: const Text(
          'Veterinarios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<VeterinarioViewModel>().cargar(),
            icon: const Icon(Icons.refresh_outlined,
                color: _kTextSecondary, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Asociar vet ya existente
          FloatingActionButton.extended(
            heroTag: 'fab_asociar',
            onPressed: () => _mostrarAsociarExistente(context),
            backgroundColor: Colors.white,
            foregroundColor: _kGreen,
            elevation: 2,
            icon: const Icon(Icons.link, size: 18),
            label: const Text('Asociar existente',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 10),
          // Crear nuevo
          FloatingActionButton.extended(
            heroTag: 'fab_nuevo',
            onPressed: () => _mostrarFormulario(context, null),
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar veterinario',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
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
            style: TextButton.styleFrom(foregroundColor: _kRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final err =
          await context.read<VeterinarioViewModel>().eliminar(vet.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err != null ? err : '${vet.nombre} eliminado'),
            backgroundColor: err != null ? _kRed : _kGreen,
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

  static const _kGreen = Color(0xFF2E7D32);
  static const _kRed = Color(0xFFC0392B);

  const _VetTile({
    required this.vet,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E5DC)),
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
                      color: const Color(0xFFE8F5EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        color: _kGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vet.nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (vet.lugar.isNotEmpty)
                          Text(
                            vet.lugar,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF888880)),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_outlined,
                        color: Color(0xFF888880), size: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onSelected: (v) {
                      if (v == 'editar') onEditar();
                      if (v == 'eliminar') onEliminar();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(children: [
                          Icon(Icons.edit_outlined,
                              size: 16, color: Color(0xFF1A1A1A)),
                          SizedBox(width: 8),
                          Text('Editar',
                              style: TextStyle(fontSize: 13)),
                        ]),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              size: 16, color: _kRed),
                          SizedBox(width: 8),
                          Text('Eliminar',
                              style: TextStyle(
                                  fontSize: 13, color: _kRed)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Teléfono
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
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAF7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8E5DC)),
                  ),
                  child: Text(
                    vet.notas!,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF888880)),
                  ),
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
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF888880)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF555550)),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.copy_outlined,
                size: 12, color: Color(0xFF2E7D32)),
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
                color: const Color(0xFFE8F5EF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.medical_services_outlined,
                  color: Color(0xFF2E7D32), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin veterinarios registrados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Agrega el veterinario de tu rancho\npara tener sus datos a la mano.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF888880)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Formulario (modal bottom sheet) ──────────────────────────────────────────

class _VetFormModal extends StatefulWidget {
  final VeterinarioInfo? vet; // null = crear nuevo

  const _VetFormModal({this.vet});

  @override
  State<_VetFormModal> createState() => _VetFormModalState();
}

class _VetFormModalState extends State<_VetFormModal> {
  static const _kGreen = Color(0xFF2E7D32);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kRed = Color(0xFFC0392B);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _ubicacion;
  late final TextEditingController _lugar;
  late final TextEditingController _notas;

  bool get _esEdicion => widget.vet != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vet;
    _nombre = TextEditingController(text: v?.nombre ?? '');
    _telefono = TextEditingController(text: v?.telefono ?? '');
    _ubicacion = TextEditingController(text: v?.ubicacion ?? '');
    _lugar = TextEditingController(text: v?.lugar ?? '');
    _notas = TextEditingController(text: v?.notas ?? '');
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
    final vm = context.read<VeterinarioViewModel>();

    String? err;
    if (_esEdicion) {
      err = await vm.editar(
        widget.vet!.id,
        nombre: _nombre.text.trim(),
        telefono: _telefono.text.trim(),
        ubicacion: _ubicacion.text.trim(),
        lugar: _lugar.text.trim(),
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
    } else {
      err = await vm.crear(
        nombre: _nombre.text.trim(),
        telefono: _telefono.text.trim(),
        ubicacion: _ubicacion.text.trim(),
        lugar: _lugar.text.trim(),
        notas: _notas.text.trim().isEmpty ? null : _notas.text.trim(),
      );
    }

    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: _kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VeterinarioViewModel>();
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _esEdicion ? 'Editar veterinario' : 'Agregar veterinario',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
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
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: _kBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Color(0xFF888880))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: vm.guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: vm.guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _esEdicion ? 'Guardar' : 'Agregar',
                                style: const TextStyle(
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
  static const _kGreen = Color(0xFF2E7D32);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kRed = Color(0xFFC0392B);

  VeterinarioInfo? _seleccionado;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VeterinarioViewModel>();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: _kBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Asociar veterinario existente',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Los marcados como "Ya en este rancho" no pueden seleccionarse.',
            style: TextStyle(fontSize: 13, color: Color(0xFF888880)),
          ),
          const SizedBox(height: 16),

          // Lista de todos los vets del dueño
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
                      ? const Color(0xFFF5F5F5)
                      : sel
                          ? const Color(0xFFE8F5EF)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: yaAsociado
                        ? const Color(0xFFE0E0E0)
                        : sel
                            ? _kGreen
                            : _kBorder,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medical_services_outlined,
                        color: yaAsociado
                            ? const Color(0xFFBBBBB8)
                            : sel
                                ? _kGreen
                                : const Color(0xFF888880),
                        size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.nombre,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: yaAsociado
                                      ? const Color(0xFFBBBBB8)
                                      : sel
                                          ? _kGreen
                                          : const Color(0xFF1A1A1A))),
                          Text(v.telefono,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: yaAsociado
                                      ? const Color(0xFFCCCCC8)
                                      : const Color(0xFF888880))),
                        ],
                      ),
                    ),
                    if (yaAsociado)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Ya en este rancho',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _kGreen),
                        ),
                      )
                    else if (sel)
                      const Icon(Icons.check_circle,
                          color: _kGreen, size: 18),
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
                    side: const BorderSide(color: _kBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Color(0xFF888880))),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                backgroundColor: _kRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: vm.guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Asociar',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555550),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E5DC)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Color(0xFFB0AEA8), fontSize: 13),
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
