import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';

// ─── Paleta ──────────────────────────────────────────────────────────────────
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE8E5DC);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF888880);
const _kTextMuted = Color(0xFFAEADA6);
const _kGreen = Color(0xFF1D7A55);
const _kGreenLight = Color(0xFFE8F5EF);
const _kRed = Color(0xFFC0392B);
const _kRedLight = Color(0xFFFDEDEC);
const _kCream = Color(0xFFF5F3EE);
const _kYellow = Color(0xFFB8860B);
const _kYellowLight = Color(0xFFFEF9E7);

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

// ─── Paleta por severidad ─────────────────────────────────────────────────────

Color _heroBg(String sev) => sev == 'alta'
    ? _kRedLight
    : sev == 'moderada'
        ? _kYellowLight
        : _kGreenLight;

Color _heroBorder(String sev) => sev == 'alta'
    ? const Color(0xFFF5C6C2)
    : sev == 'moderada'
        ? const Color(0xFFF7DC6F)
        : const Color(0xFFA8D5BC);

Color _heroAccent(String sev) => sev == 'alta'
    ? _kRed
    : sev == 'moderada'
        ? _kYellow
        : _kGreen;

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
    final p = widget.prediccion;
    final sev = severidadLabel(p);
    final accent = _heroAccent(sev);
    final sevTexto = sev == 'alta'
        ? 'Severidad alta'
        : sev == 'moderada'
            ? 'Severidad moderada'
            : 'Severidad leve';

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: _heroBg(sev),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _heroBorder(sev)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: badge + hora
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
              Text(
                _tiempoRelativo(p.fecha),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w300,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Nombre de enfermedad
          Text(
            p.enfermedad,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtituloDe(p.enfermedad),
            style: const TextStyle(
              fontSize: 13,
              color: _kTextSecondary,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Barra de confianza
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confianza del modelo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: accent,
                ),
              ),
              Text(
                '${(p.confianza * 100).toStringAsFixed(0)}%',
                style: TextStyle(
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
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _kRedLight,
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${animal.idExterno} · Temp: ${temperatura.toStringAsFixed(1)}°C · Leche: ${litrosLeche.toStringAsFixed(0)} L',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _tiempoRelativo(prediccion.fecha),
            style: const TextStyle(
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
              color: _kCream,
              borderColor: _kBorder,
              label: 'Formulario',
            ),
            const SizedBox(width: 10),
            _Leyenda(
              color: const Color(0xFFEEEDFE),
              borderColor: const Color(0xFFC8C5F0),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isNLP ? const Color(0xFFEEEDFE) : _kCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNLP ? const Color(0xFFC8C5F0) : _kBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: isNLP ? const Color(0xFF534AB7) : _kTextSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isNLP ? '· NLP' : '· form',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: isNLP
                  ? const Color(0xFF534AB7).withOpacity(0.7)
                  : _kTextMuted,
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
          style: const TextStyle(
            fontSize: 10,
            color: _kTextMuted,
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
    final preview = descripcion.length > 80
        ? '${descripcion.substring(0, 80)}…'
        : descripcion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFC8C5F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🧠', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF3C3489),
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'El módulo NLP procesó: '),
                  TextSpan(
                    text: '"$preview"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF534AB7),
                      fontWeight: FontWeight.w400,
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
    return Column(
      children: List.generate(alternativas.length, (i) {
        final alt = alternativas[i];
        return Container(
          margin: i < alternativas.length - 1
              ? const EdgeInsets.only(bottom: 8)
              : EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Text(
                '${i + 2}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _kTextMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alt.nombre,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alt.desc,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kTextMuted,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Mini barra
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3,
                        color: _kBorder,
                        child: FractionallySizedBox(
                          widthFactor: alt.probabilidad,
                          alignment: Alignment.centerLeft,
                          child: Container(color: _kTextMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(alt.probabilidad * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _kTextSecondary,
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
    final isAlta = severidad == 'alta';
    final accent = isAlta ? _kRed : severidad == 'moderada' ? _kYellow : _kGreen;
    final bg = isAlta ? _kRedLight : severidad == 'moderada' ? _kYellowLight : _kGreenLight;
    final border = isAlta
        ? const Color(0xFFF5C6C2)
        : severidad == 'moderada'
            ? const Color(0xFFF7DC6F)
            : const Color(0xFFA8D5BC);
    final textColor = isAlta
        ? const Color(0xFF7B241C)
        : severidad == 'moderada'
            ? const Color(0xFF7D6608)
            : const Color(0xFF1A4731);
    final titulo = isAlta
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
                isAlta ? '🚨' : severidad == 'moderada' ? '⚠️' : '✅',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
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
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    pasos[i],
                    style: TextStyle(
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _kCream,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ℹ️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 9),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 11,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  TextSpan(text: 'Este resultado es un '),
                  TextSpan(
                    text: 'soporte predictivo preliminar',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _kTextPrimary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
