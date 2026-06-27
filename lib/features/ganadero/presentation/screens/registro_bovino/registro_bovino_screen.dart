import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/constants/app_strings.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/registro_bovino_viewmodel.dart';
import 'registro_bovino_components.dart';

class RegistroBovinoScreen extends StatefulWidget {
  const RegistroBovinoScreen({super.key});

  @override
  State<RegistroBovinoScreen> createState() => _RegistroBovinoScreenState();
}

class _RegistroBovinoScreenState extends State<RegistroBovinoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _idAreteController = TextEditingController();
  final _edadController = TextEditingController();
  final _pesoController = TextEditingController();

  String? _categoriaSelected;
  List<String> _propositosSelected = ['leche'];
  String? _razaSelected;
  bool _edadEnMeses = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _idAreteController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  Future<void> _onRegistrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.categoriaRequerida)),
      );
      return;
    }
    final vm = context.read<RegistroBovinoViewModel>();
    await vm.registrar(
      nombre: _nombreController.text.trim(),
      idExterno: _idAreteController.text.trim(),
      categoria: _categoriaSelected!,
      // La API acepta un solo valor enum: leche|carne|doble|cria
      proposito: _propositosSelected.isNotEmpty
          ? _propositosSelected.first
          : 'leche',
      raza: _razaSelected ?? '',
      edad: int.tryParse(_edadController.text) ?? 0,
      pesoKg: double.tryParse(_pesoController.text) ?? 0,
      edadEnMeses: _edadEnMeses,
    );
    if (mounted && vm.status == RegistroStatus.success) {
      final nuevo = vm.createdAnimal;
      // Pop con el animal creado para que home lo reciba en .then()
      // y navegue al detalle sin romper el stack de rutas
      context.pop(nuevo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistroBovinoViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.registrarBovino),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                AppStrings.registraTuBovino,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              RbTextField(
                label: AppStrings.nombreAnimal,
                hint: AppStrings.nombreAnimalHint,
                controller: _nombreController,
                prefixIcon: Icons.favorite_border,
                validator: (v) => v == null || v.isEmpty
                    ? AppStrings.nombreRequerido
                    : null,
              ),
              const SizedBox(height: 16),
              RbTextField(
                label: AppStrings.idArete,
                hint: AppStrings.idAreteHint,
                controller: _idAreteController,
                prefixIcon: Icons.tag,
                helper: AppStrings.idAreteHelper,
              ),
              const SizedBox(height: 20),
              RbCategoriaSelector(
                selected: _categoriaSelected,
                onSelected: (v) => setState(() => _categoriaSelected = v),
              ),
              const SizedBox(height: 20),
              RbPropositoSelector(
                selected: _propositosSelected,
                onToggle: (v) => setState(() {
                  if (_propositosSelected.contains(v)) {
                    _propositosSelected.remove(v);
                  } else {
                    _propositosSelected.add(v);
                  }
                }),
              ),
              const SizedBox(height: 20),
              RbRazaDropdown(
                selected: _razaSelected,
                onChanged: (v) => setState(() => _razaSelected = v),
              ),
              const SizedBox(height: 16),
              RbEdadPesoRow(
                edadController: _edadController,
                pesoController: _pesoController,
                enMeses: _edadEnMeses,
                onToggleUnidad: () =>
                    setState(() => _edadEnMeses = !_edadEnMeses),
              ),
              const SizedBox(height: 16),
              if (vm.status == RegistroStatus.error &&
                  vm.errorMessage != null) ...[
                // reutilizamos el widget de error de auth
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    vm.errorMessage!,
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: Text(AppStrings.cancelar),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: vm.isLoading ? null : _onRegistrar,
                  child: vm.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppStrings.siguiente),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}