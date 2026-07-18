import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';

// ─── Helpers de datos ─────────────────────────────────────────────────────────

class AlternativaDiag {
  final String nombre;
  final String desc;
  final double probabilidad;
  const AlternativaDiag(this.nombre, this.desc, this.probabilidad);
}

String severidadLabel(Prediccion p) {
  if (p.enfermedad.toLowerCase().contains('sin')) return 'leve';
  if (p.confianza >= 0.8) return 'alta';
  return 'moderada';
}

String subtituloDe(String enfermedad) {
  final e = enfermedad.toLowerCase();
  if (e.contains('mastitis')) {
    return 'Inflamación de la glándula mamaria detectada a partir de síntomas clínicos y producción anómala.';
  }
  if (e.contains('laminitis')) {
    return 'Inflamación del tejido laminar del casco. Puede afectar la movilidad del animal.';
  }
  return 'El análisis no detectó patologías con alta probabilidad. Continúa la observación normal.';
}

List<AlternativaDiag> alternativasDe(String enfermedad) {
  final e = enfermedad.toLowerCase();
  if (e.contains('mastitis')) {
    return [
      const AlternativaDiag('Fiebre de leche',
          'Hipocalcemia postparto. Considerar si parió recientemente.', 0.38),
      const AlternativaDiag('Desplazamiento de abomaso',
          'Común en vacas lecheras de alta producción.', 0.18),
    ];
  }
  if (e.contains('laminitis')) {
    return [
      const AlternativaDiag('Acidosis ruminal',
          'Cambio brusco de dieta o exceso de concentrado.', 0.31),
      const AlternativaDiag('Artritis séptica',
          'Inflamación articular por infección bacteriana.', 0.15),
    ];
  }
  return [];
}

List<String> pasosDe(String enfermedad, String animalNombre) {
  final e = enfermedad.toLowerCase();
  if (e.contains('mastitis')) {
    return [
      'Separa a $animalNombre del resto del hato para evitar contagio y reducir estrés.',
      'Revisa la ubre: busca endurecimiento, calor o secreción anormal en algún cuarto.',
      'Contacta a un veterinario hoy. La mastitis severa requiere antibióticos y tratamiento intramamario.',
      'Registra la leche de cada cuarto por separado para identificar cuál está afectado.',
    ];
  }
  if (e.contains('laminitis')) {
    return [
      'Limita el movimiento del animal y evita superficies duras o resbaladizas.',
      'Revisa los cascos: busca calor, sensibilidad y postura anormal al estar parado.',
      'Consulta al herrador y al veterinario. Puede requerirse corrección podal.',
      'Ajusta la dieta reduciendo concentrado y aumentando forraje de buena calidad.',
    ];
  }
  return [
    'Continúa con la observación normal del animal.',
    'Mantén registros diarios de producción y temperatura.',
    'Repite el análisis si observas cambios en los próximos días.',
  ];
}

List<String> sintomasNLPDe(String descripcion) {
  final desc = descripcion.toLowerCase();
  final result = <String>[];
  if (desc.contains('come') || desc.contains('apetito') || desc.contains('inapetencia')) {
    result.add('Inapetencia');
  }
  if (desc.contains('decaída') || desc.contains('decaida') || desc.contains('decaimiento')) {
    result.add('Decaimiento');
  }
  if ((desc.contains('sola') || desc.contains('rincón') || desc.contains('rincon')) &&
      !result.contains('Aislamiento')) {
    result.add('Aislamiento');
  }
  if (desc.contains('fiebre') || desc.contains('caliente')) {
    result.add('Subfebril');
  }
  if (desc.contains('no se mueve') || desc.contains('moverse') || desc.contains('quieta')) {
    result.add('Quietud anormal');
  }
  return result;
}

String _tiempoRelativo(DateTime fecha) {
  final diff = DateTime.now().difference(fecha);
  if (diff.inSeconds < 60) return 'hace ${diff.inSeconds} seg';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  return 'hace ${diff.inHours} h';
}

// ─── Helpers de color por severidad (reciben ColorScheme) ────────────────────

Color _heroBg(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.errorContainer
    : sev == 'moderada'
        ? cs.secondaryContainer
        : cs.tertiaryContainer;

Color _heroBorder(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.error.withOpacity(0.3)
    : sev == 'moderada'
        ? cs.secondary.withOpacity(0.3)
        : cs.tertiary.withOpacity(0.3);

Color _heroAccent(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.error
    : sev == 'moderada'
        ? cs.secondary
        : cs.tertiary;

Color _heroTextColor(String sev, ColorScheme cs) => sev == 'alta'
    ? cs.onErrorContainer
    : sev == 'moderada'
        ? cs.onSecondaryContainer
        : cs.onTertiaryContainer;

// ─── Hero del resultado ───────────────────────────────────────────────────────

class ResultadoHeroCard extends StatefulWidget {
  final Prediccion prediccion;

  const ResultadoHeroCard({super.key, required this.prediccion});

  @override
  State<ResultadoHeroCard> createState() => _ResultadoHeroCardState();
}

class _ResultadoHeroCardState extends State<ResultadoHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = widget.prediccion;
    final sev = severidadLabel(p);
    final accent = _heroAccent(sev, cs);
    final sevTexto = sev == 'alta'
        ? 'Severidad alta'
        : sev == 'moderada'
            ? 'Severidad moderada'
            : 'Severidad leve';

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _heroBg(sev, cs),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _heroBorder(sev, cs)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FadeTransition(
                    opacity: _pulseAnim,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sevTexto,
                    style: tt.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
              Text(
                _tiempoRelativo(p.fecha),
                style: tt.labelSmall?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w300,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            p.enfermedad,
            style: tt.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtituloDe(p.enfermedad),
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confianza del modelo',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: accent,
                ),
              ),
              Text(
                '${(p.confianza * 100).toStringAsFixed(0)}%',
                style: tt.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: accent,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: accent.withOpacity(0.15),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: p.confianza),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (_, value, __) => FractionallySizedBox(
                  widthFactor: value,
                  alignment: Alignment.centerLeft,
                  child: Container(color: accent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fila del animal ──────────────────────────────────────────────────────────

class ResultadoAnimalRow extends StatelessWidget {
  final Animal animal;
  final Prediccion prediccion;
  final double temperatura;
  final double litrosLeche;

  const ResultadoAnimalRow({
    super.key,
    required this.animal,
    required this.prediccion,
    required this.temperatura,
    required this.litrosLeche,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🐄', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${animal.nombre} — ${animal.raza}',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${animal.idExterno} · Temp: ${temperatura.toStringAsFixed(1)}°C · Leche: ${litrosLeche.toStringAsFixed(0)} L',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    color: cs.outline,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _tiempoRelativo(prediccion.fecha),
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

// ─── Sección de síntomas detectados ──────────────────────────────────────────

class ResultadoSintomasSection extends StatelessWidget {
  final List<String> formulario;
  final List<String> nlp;

  const ResultadoSintomasSection({
    super.key,
    required this.formulario,
    required this.nlp,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            ...formulario.map((s) => _SintTag(label: s, isNLP: false)),
            ...nlp.map((s) => _SintTag(label: s, isNLP: true)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Leyenda(
              color: cs.surfaceContainerLow,
              borderColor: cs.outlineVariant,
              label: 'Formulario',
            ),
            const SizedBox(width: 10),
            _Leyenda(
              color: cs.secondaryContainer,
              borderColor: cs.secondary.withOpacity(0.5),
              label: 'Extraído por NLP',
            ),
          ],
        ),
      ],
    );
  }
}

class _SintTag extends StatelessWidget {
  final String label;
  final bool isNLP;

  const _SintTag({required this.label, required this.isNLP});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNLP ? cs.secondaryContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNLP ? cs.secondary.withOpacity(0.5) : cs.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: isNLP ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isNLP ? '· NLP' : '· form',
            style: tt.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isNLP
                  ? cs.onSecondaryContainer.withOpacity(0.7)
                  : cs.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _Leyenda({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 10,
            color: cs.outline,
          ),
        ),
      ],
    );
  }
}

// ─── Caja NLP ─────────────────────────────────────────────────────────────────

class ResultadoNLPBox extends StatelessWidget {
  final String descripcion;

  const ResultadoNLPBox({super.key, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    if (descripcion.trim().isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final preview = descripcion.length > 80
        ? '${descripcion.substring(0, 80)}…'
        : descripcion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cs.secondary.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🧠', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: tt.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'El módulo NLP procesó: '),
                  TextSpan(
                    text: '"$preview"',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const TextSpan(
                    text: ' — extrayendo señales clínicas adicionales.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Alternativas de diagnóstico ──────────────────────────────────────────────

class ResultadoAlternativas extends StatelessWidget {
  final List<AlternativaDiag> alternativas;

  const ResultadoAlternativas({super.key, required this.alternativas});

  @override
  Widget build(BuildContext context) {
    if (alternativas.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: List.generate(alternativas.length, (i) {
        final alt = alternativas[i];
        return Container(
          margin: i < alternativas.length - 1
              ? const EdgeInsets.only(bottom: 8)
              : EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Text(
                '${i + 2}',
                style: tt.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alt.nombre,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alt.desc,
                      style: tt.labelSmall?.copyWith(
                        fontSize: 11,
                        color: cs.outline,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3,
                        color: cs.outlineVariant,
                        child: FractionallySizedBox(
                          widthFactor: alt.probabilidad,
                          alignment: Alignment.centerLeft,
                          child: Container(color: cs.outline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(alt.probabilidad * 100).toStringAsFixed(0)}%',
                style: tt.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Tarjeta de recomendación ────────────────────────────────────────────────

class ResultadoRecomendacion extends StatelessWidget {
  final List<String> pasos;
  final String severidad;

  const ResultadoRecomendacion({
    super.key,
    required this.pasos,
    required this.severidad,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent    = _heroAccent(severidad, cs);
    final bg        = _heroBg(severidad, cs);
    final border    = _heroBorder(severidad, cs);
    final textColor = _heroTextColor(severidad, cs);
    final titulo = severidad == 'alta'
        ? 'Acción inmediata recomendada'
        : severidad == 'moderada'
            ? 'Monitoreo recomendado'
            : 'Observación preventiva';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                severidad == 'alta' ? '🚨' : severidad == 'moderada' ? '⚠️' : '✅',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: tt.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(pasos.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: cs.surface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    pasos[i],
                    style: tt.bodySmall?.copyWith(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Disclaimer ───────────────────────────────────────────────────────────────

class ResultadoDisclaimer extends StatelessWidget {
  const ResultadoDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: tt.labelSmall?.copyWith(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'Este resultado es un '),
                  TextSpan(
                    text: 'soporte predictivo preliminar',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ', no un diagnóstico clínico definitivo. Confirma siempre con un médico veterinario certificado antes de iniciar cualquier tratamiento.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Título de sección ────────────────────────────────────────────────────────

class ResultadoSecTitle extends StatelessWidget {
  final String title;
  const ResultadoSecTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: tt.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
