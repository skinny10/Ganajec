import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../../viewmodels/editar_bovino_viewmodel.dart';
import 'editar_bovino_components.dart';

class EditarBovinoScreen extends StatefulWidget {
  final Animal animal;

  const EditarBovinoScreen({super.key, required this.animal});

  @override
  State<EditarBovinoScreen> createState() => _EditarBovinoScreenState();
}

class _EditarBovinoScreenState extends State<EditarBovinoScreen> {
  // ── Controllers ─────────────────────────────────────────────────────────────
  late TextEditingController _nombreCtrl;
  late TextEditingController _idExternoCtrl;
  late TextEditingController _pesoCtrl;
  late TextEditingController _notasCtrl;

  // ── Estado mutable del formulario ────────────────────────────────────────────
  late String _raza;
  late DateTime _fechaNacimiento;
  late CategoriaAnimal _categoria;
  late PropositoAnimal _proposito;

  // ── Tracking de cambios ──────────────────────────────────────────────────────
  final Set<String> _changedFields = {};
  bool get _hasChanges => _changedFields.isNotEmpty;

  // ── Severidad derivada de la sesión anterior (pasada como extra opcional) ────
  String _severidad = 'Normal';

  // ── Constantes de color ──────────────────────────────────────────────────────
  static const _kBg = Color(0xFFFAF9F6);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kGreen = Color(0xFF1D7A55);
  static const _kRed = Color(0xFFC0392B);
  static const _kRedLight = Color(0xFFFDEDEC);
  static const _kSurface = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    final edad = calcularEdad(a.fechaNacimiento);

    _nombreCtrl = TextEditingController(text: a.nombre);
    _idExternoCtrl = TextEditingController(text: a.idExterno);
    _pesoCtrl = TextEditingController(text: a.pesoKg.toStringAsFixed(0));
    _notasCtrl = TextEditingController();

    _raza = a.raza;
    _fechaNacimiento = a.fechaNacimiento;
    _categoria = derivarCategoria(a.sexo, edad);
    _proposito = derivarProposito(a.raza);

    // Escuchar cambios en TextField
    _nombreCtrl.addListener(() => _trackChange('nombre', _nombreCtrl.text, a.nombre));
    _idExternoCtrl.addListener(() => _trackChange('idExterno', _idExternoCtrl.text, a.idExterno));
    _pesoCtrl.addListener(() => _trackChange('peso', _pesoCtrl.text, a.pesoKg.toStringAsFixed(0)));
    _notasCtrl.addListener(() => _trackChange('notas', _notasCtrl.text, ''));
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _idExternoCtrl.dispose();
    _pesoCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _trackChange(String field, String current, String original) {
    setState(() {
      if (current != original) {
        _changedFields.add(field);
      } else {
        _changedFields.remove(field);
      }
    });
  }

  void _setCategoria(CategoriaAnimal cat) {
    final edad = calcularEdad(widget.animal.fechaNacimiento);
    final original = derivarCategoria(widget.animal.sexo, edad);
    setState(() {
      _categoria = cat;
      if (cat != original) {
        _changedFields.add('categoria');
      } else {
        _changedFields.remove('categoria');
      }
    });
  }

  void _setProposito(PropositoAnimal prop) {
    final original = derivarProposito(widget.animal.raza);
    setState(() {
      _proposito = prop;
      if (prop != original) {
        _changedFields.add('proposito');
      } else {
        _changedFields.remove('proposito');
      }
    });
  }

  void _setRaza(String raza) {
    setState(() {
      _raza = raza;
      if (raza != widget.animal.raza) {
        _changedFields.add('raza');
        // Actualizar propósito derivado automáticamente
        _proposito = derivarProposito(raza);
      } else {
        _changedFields.remove('raza');
      }
    });
  }

  void _setFecha(DateTime fecha) {
    setState(() {
      _fechaNacimiento = fecha;
      if (fecha != widget.animal.fechaNacimiento) {
        _changedFields.add('fechaNacimiento');
        // Actualizar categoría derivada
        final edad = calcularEdad(fecha);
        _categoria = derivarCategoria(widget.animal.sexo, edad);
      } else {
        _changedFields.remove('fechaNacimiento');
      }
    });
  }

  void _cancelar() {
    final a = widget.animal;
    final edad = calcularEdad(a.fechaNacimiento);
    setState(() {
      _nombreCtrl.text = a.nombre;
      _idExternoCtrl.text = a.idExterno;
      _pesoCtrl.text = a.pesoKg.toStringAsFixed(0);
      _notasCtrl.text = '';
      _raza = a.raza;
      _fechaNacimiento = a.fechaNacimiento;
      _categoria = derivarCategoria(a.sexo, edad);
      _proposito = derivarProposito(a.raza);
      _changedFields.clear();
    });
  }

  Future<void> _guardar() async {
    // Validar peso
    final pesoRaw = _pesoCtrl.text.trim().replaceAll(',', '.');
    final peso = double.tryParse(pesoRaw);
    if (_nombreCtrl.text.trim().isEmpty) {
      _showError('El nombre no puede estar vacío.');
      return;
    }
    if (peso == null || peso <= 0) {
      _showError('Ingresa un peso válido en kg.');
      return;
    }

    final vm = context.read<EditarBovinoViewModel>();
    final actualizado = widget.animal.copyWith(
      nombre: _nombreCtrl.text.trim(),
      idExterno: _idExternoCtrl.text.trim(),
      pesoKg: peso,
      raza: _raza,
      fechaNacimiento: _fechaNacimiento,
      categoria: _categoria.name,
      proposito: _proposito.name,
    );

    final ok = await vm.guardar(actualizado);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Animal actualizado correctamente'),
          backgroundColor: Color(0xFF1D7A55),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.home);
    } else {
      _showError(vm.error ?? 'Error al guardar. Intenta de nuevo.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _kRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarModalEliminar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer<EditarBovinoViewModel>(
        builder: (ctx, vm, _) => EditarDeleteModal(
          animalNombre: widget.animal.nombre,
          isDeleting: vm.isDeleting,
          onConfirm: () async {
            final ok = await vm.eliminar(widget.animal.id);
            if (!mounted) return;
            Navigator.of(ctx).pop();
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '🗑️ ${widget.animal.nombre} eliminada del hato.'),
                  backgroundColor: _kRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.go(AppRoutes.home);
            } else {
              _showError(vm.error ?? 'Error al eliminar.');
            }
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(2000),
      lastDate: now,
      locale: const Locale('es', 'MX'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A1A1A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) _setFecha(picked);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditarBovinoViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(vm),
      body: vm.isBusy
          ? _buildLoading(vm)
          : _buildForm(),
      bottomNavigationBar: _hasChanges
          ? _buildBottomCta(vm)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(EditarBovinoViewModel vm) {
    return AppBar(
      backgroundColor: _kSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF1A1A1A)),
        onPressed: vm.isBusy ? null : () => context.pop(),
      ),
      centerTitle: true,
      title: const Text(
        'Editar bovino',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _kBorder),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              size: 20, color: Color(0xFFC0392B)),
          onPressed: vm.isBusy ? null : _mostrarModalEliminar,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildLoading(EditarBovinoViewModel vm) {
    final msg = vm.isSaving ? 'Guardando cambios…' : 'Eliminando bovino…';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF1A1A1A),
            strokeWidth: 2,
          ),
          const SizedBox(height: 14),
          Text(
            msg,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888880),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini card del animal
          EditarMiniCard(
            animal: widget.animal,
            severidad: _severidad,
          ),

          // Banner de cambios sin guardar
          if (_hasChanges) const EditarChangeBanner(),

          // Formulario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Nombre ──────────────────────────────────────────────────
                EditarTextField(
                  label: 'Nombre del bovino',
                  controller: _nombreCtrl,
                  iconData: Icons.label_outline_rounded,
                  changed: _changedFields.contains('nombre'),
                  changedHint: 'Antes: ${widget.animal.nombre}',
                ),
                const SizedBox(height: 18),

                // ── ID Externo ───────────────────────────────────────────────
                EditarTextField(
                  label: 'ID / Arete',
                  controller: _idExternoCtrl,
                  iconData: Icons.tag_rounded,
                  changed: _changedFields.contains('idExterno'),
                  changedHint: 'Antes: ${widget.animal.idExterno}',
                ),
                const SizedBox(height: 22),

                // ── Categoría ────────────────────────────────────────────────
                EditarCategoriaGrid(
                  selected: _categoria,
                  onSelect: _setCategoria,
                ),
                const SizedBox(height: 22),

                // ── Propósito ────────────────────────────────────────────────
                EditarPropositoPills(
                  selected: _proposito,
                  onSelect: _setProposito,
                ),
                const SizedBox(height: 22),

                // ── Raza ─────────────────────────────────────────────────────
                EditarRazaField(
                  label: 'Raza',
                  value: _raza,
                  changed: _changedFields.contains('raza'),
                  onTap: () => showRazaSheet(context, _raza, _setRaza),
                ),
                const SizedBox(height: 18),

                // ── Peso + Fecha en Row ──────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Peso
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const EditarSectionLabel(label: 'Peso (kg)'),
                          TextField(
                            controller: _pesoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d.,]')),
                            ],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: _changedFields.contains('peso')
                                  ? const Color(0xFFFEFDF5)
                                  : const Color(0xFFFDFCFA),
                              prefixIcon: const Icon(
                                  Icons.monitor_weight_outlined,
                                  size: 16,
                                  color: Color(0xFFAEADA6)),
                              suffixText: 'kg',
                              suffixStyle: const TextStyle(
                                color: Color(0xFFAEADA6),
                                fontSize: 12,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide(
                                  color: _changedFields.contains('peso')
                                      ? const Color(0xFFF39C12)
                                      : const Color(0xFFE8E5DC),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: BorderSide(
                                  color: _changedFields.contains('peso')
                                      ? const Color(0xFFF39C12)
                                      : const Color(0xFFE8E5DC),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: const BorderSide(
                                    color: Color(0xFF1A1A1A), width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Fecha de nacimiento
                    Expanded(
                      child: EditarFechaField(
                        value: _fechaNacimiento,
                        changed: _changedFields.contains('fechaNacimiento'),
                        onTap: _seleccionarFecha,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Notas ────────────────────────────────────────────────────
                EditarTextField(
                  label: 'Notas / Observaciones',
                  controller: _notasCtrl,
                  iconData: Icons.notes_rounded,
                  maxLines: 3,
                  changed: _changedFields.contains('notas'),
                ),
                // Espacio para el bottom bar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(EditarBovinoViewModel vm) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        16,
        18,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          // Cancelar
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kTextPrimary,
                  side: const BorderSide(color: _kBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: vm.isBusy ? null : _cancelar,
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Guardar
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTextPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 0,
                ),
                onPressed: vm.isBusy ? null : _guardar,
                child: vm.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_rounded, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Guardar cambios',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
