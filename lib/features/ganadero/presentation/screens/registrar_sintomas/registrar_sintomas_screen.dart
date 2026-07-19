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
    final cs = Theme.of(context).colorScheme;
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
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      vm.resetStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<RegistrarSintomasViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: vm.isAnalyzing ? null : () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left_rounded,
                color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Registrar síntomas',
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
                    onToggle: (label) => context
                        .read<RegistrarSintomasViewModel>()
                        .toggleSintoma(label),
                  ),
                  const SizedBox(height: 20),

                  // ── Datos del día ────────────────────────────────────────
                  Text(
                    'Datos del día',
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                  Text(
                    'Describe lo que ves',
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                        style: tt.bodySmall?.copyWith(
                          fontSize: 13.5,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w300,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cs.surfaceContainerLowest,
                          hintText:
                              'Ej. la vaca no come desde ayer y se ve muy decaída, está parada sola en un rincón...',
                          hintStyle: tt.bodySmall?.copyWith(
                            color: cs.outline,
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(38, 13, 13, 13),
                          counterStyle: tt.labelSmall?.copyWith(
                            fontSize: 10,
                            color: cs.outline,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(color: cs.outlineVariant),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: BorderSide(color: cs.outlineVariant),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide:
                                BorderSide(color: cs.onSurface, width: 1.5),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 13,
                        top: 14,
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 15,
                          color: cs.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'El módulo NLP procesará tu descripción en español para extraer síntomas adicionales.',
                    style: tt.labelSmall?.copyWith(
                      fontSize: 10.5,
                      color: cs.outline,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Severidad estimada ────────────────────────────────────
                  Text(
                    'Severidad estimada',
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
      bottomNavigationBar: _buildBottomCta(context, vm),
    );
  }

  Widget _buildBottomCta(BuildContext context, RegistrarSintomasViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.onSurface,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 4,
                shadowColor: cs.onSurface.withOpacity(0.18),
              ),
              onPressed: vm.isAnalyzing ? null : _analizarConIA,
              child: vm.isAnalyzing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.surface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Analizando...',
                          style: tt.labelLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_rounded, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Analizar con IA',
                          style: tt.labelLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'El resultado estará listo en segundos',
            style: tt.labelSmall?.copyWith(
              fontSize: 10.5,
              color: cs.outline,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
