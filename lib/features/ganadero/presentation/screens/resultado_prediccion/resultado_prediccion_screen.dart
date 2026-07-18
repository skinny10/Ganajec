import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'resultado_prediccion_args.dart';
import 'resultado_prediccion_components.dart';

class ResultadoPrediccionScreen extends StatefulWidget {
  final ResultadoPrediccionArgs args;

  const ResultadoPrediccionScreen({super.key, required this.args});

  @override
  State<ResultadoPrediccionScreen> createState() =>
      _ResultadoPrediccionScreenState();
}

class _ResultadoPrediccionScreenState extends State<ResultadoPrediccionScreen> {
  bool _guardado = false;

  ResultadoPrediccionArgs get _a => widget.args;

  Future<void> _guardar() async {
    setState(() => _guardado = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = _a.prediccion;
    final sev = severidadLabel(p);
    final sintomasNLP = sintomasNLPDe(_a.descripcion);
    final alternativas = alternativasDe(p.enfermedad);
    final pasos = pasosDe(p.enfermedad, _a.animal.nombre);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left, color: cs.onSurface, size: 20),
          ),
        ),
        title: Text(
          'Resultado del análisis',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          const SizedBox(height: 16),

          // ── Hero ──────────────────────────────────────────────────────────
          ResultadoHeroCard(prediccion: p),

          // ── Animal row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: ResultadoAnimalRow(
              animal: _a.animal,
              prediccion: p,
              temperatura: _a.temperatura,
              litrosLeche: _a.litrosLeche,
            ),
          ),
          const SizedBox(height: 20),

          // ── Síntomas detectados ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ResultadoSecTitle(title: 'Síntomas detectados'),
                ResultadoSintomasSection(
                  formulario: _a.sintomasFormulario,
                  nlp: sintomasNLP,
                ),
                const SizedBox(height: 12),
                if (_a.descripcion.trim().isNotEmpty)
                  ResultadoNLPBox(descripcion: _a.descripcion),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Diagnósticos alternativos ─────────────────────────────────────
          if (alternativas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ResultadoSecTitle(title: 'Diagnósticos alternativos'),
                  ResultadoAlternativas(alternativas: alternativas),
                ],
              ),
            ),
          if (alternativas.isNotEmpty) const SizedBox(height: 20),

          // ── Recomendaciones ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ResultadoSecTitle(title: 'Pasos recomendados'),
                ResultadoRecomendacion(pasos: pasos, severidad: sev),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Disclaimer ────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: ResultadoDisclaimer(),
          ),
        ],
      ),

      // ── Bottom CTAs ───────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ver historial
              GestureDetector(
                onTap: () => context.push(AppRoutes.historial),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Center(
                    child: Text(
                      'Ver historial de predicciones',
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Guardar predicción
              GestureDetector(
                onTap: _guardado ? null : _guardar,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _guardado ? cs.tertiary : cs.onSurface,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _guardado
                        ? Row(
                            key: const ValueKey('guardado'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check,
                                  color: cs.onTertiary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Predicción guardada',
                                style: tt.bodyMedium?.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onTertiary,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            key: const ValueKey('idle'),
                            'Guardar predicción',
                            style: tt.bodyMedium?.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: cs.surface,
                            ),
                          ),
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
