import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../../viewmodels/registrar_sintomas_viewmodel.dart';
import 'registrar_sintomas_components.dart';
import '../resultado_prediccion/resultado_prediccion_args.dart';

class RegistrarSintomasScreen extends StatefulWidget {
  const RegistrarSintomasScreen({super.key});

  @override
  State<RegistrarSintomasScreen> createState() =>
      _RegistrarSintomasScreenState();
}

class _RegistrarSintomasScreenState extends State<RegistrarSintomasScreen> {
  late TextEditingController _descripcionCtrl;

  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kInputBg = Color(0xFFFDFCFA);

  @override
  void initState() {
    super.initState();
    _descripcionCtrl = TextEditingController();
    _descripcionCtrl.addListener(() {
      context
          .read<RegistrarSintomasViewModel>()
          .setDescripcion(_descripcionCtrl.text);
    });
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _analizarConIA() async {
    final vm = context.read<RegistrarSintomasViewModel>();
    final ok = await vm.analizarConIA();
    if (!mounted) return;

    if (ok && vm.resultado != null) {
      context.push(
        AppRoutes.resultadoPrediccion,
        extra: ResultadoPrediccionArgs(
          animal: vm.animal,
          prediccion: vm.resultado!,
          sintomasFormulario: vm.seleccionados.toList(),
          descripcion: vm.descripcion,
          temperatura: vm.temperatura,
          litrosLeche: vm.leche,
        ),
      );
    } else if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Error al analizar. Intenta de nuevo.'),
          backgroundColor: const Color(0xFFC0392B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      vm.resetStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrarSintomasViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: vm.isAnalyzing ? null : () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: _kTextPrimary, size: 20),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Registrar síntomas',
          style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animal card
            SintomasAnimalCard(animal: vm.animal),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Síntomas ────────────────────────────────────────────
                  SintomasChipGrid(
                    seleccionados: vm.seleccionados,
                    onToggle: (label) =>
                        context.read<RegistrarSintomasViewModel>().toggleSintoma(label),
                  ),
                  const SizedBox(height: 20),

                  // ── Datos del día ────────────────────────────────────────
                  const Text(
                    'Datos del día',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Contadores
                  Row(
                    children: [
                      Expanded(
                        child: ContadorCard(
                          label: 'Leche hoy',
                          unit: 'litros',
                          value: vm.leche,
                          onDecrement: () => context
                              .read<RegistrarSintomasViewModel>()
                              .incrementLeche(-1),
                          onIncrement: () => context
                              .read<RegistrarSintomasViewModel>()
                              .incrementLeche(1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ContadorCard(
                          label: 'Alimento',
                          unit: 'kg',
                          value: vm.alimento,
                          onDecrement: () => context
                              .read<RegistrarSintomasViewModel>()
                              .incrementAlimento(-1),
                          onIncrement: () => context
                              .read<RegistrarSintomasViewModel>()
                              .incrementAlimento(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Temperatura
                  TemperaturaCard(
                    temperatura: vm.temperatura,
                    badge: vm.tempBadge,
                    onChanged: (v) => context
                        .read<RegistrarSintomasViewModel>()
                        .setTemperatura(v),
                  ),
                  const SizedBox(height: 20),

                  // ── Descripción libre ────────────────────────────────────
                  const Text(
                    'Describe lo que ves',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Stack(
                    children: [
                      TextField(
                        controller: _descripcionCtrl,
                        maxLines: 4,
                        maxLength: 300,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: _kTextPrimary,
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _kInputBg,
                          hintText:
                              'Ej. la vaca no come desde ayer y se ve muy decaída, está parada sola en un rincón...',
                          hintStyle: const TextStyle(
                            color: _kTextMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                              38, 13, 13, 13),
                          counterStyle: const TextStyle(
                            fontSize: 10,
                            color: _kTextMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide:
                                const BorderSide(color: _kBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide:
                                const BorderSide(color: _kBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                                color: _kTextPrimary, width: 1.5),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 13,
                        top: 14,
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 15,
                          color: _kTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'El módulo NLP procesará tu descripción en español para extraer síntomas adicionales.',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _kTextMuted,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Severidad estimada ────────────────────────────────────
                  const Text(
                    'Severidad estimada',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SeveridadPreview(severidad: vm.severidad),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomCta(vm),
    );
  }

  Widget _buildBottomCta(RegistrarSintomasViewModel vm) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kTextPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.18),
              ),
              onPressed: vm.isAnalyzing ? null : _analizarConIA,
              child: vm.isAnalyzing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Analizando...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Analizar con IA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'El resultado estará listo en segundos',
            style: TextStyle(
              fontSize: 10.5,
              color: _kTextMuted,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
