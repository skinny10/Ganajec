import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import '../../viewmodels/registrar_sintomas_viewmodel.dart';

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
const _kInputBg = Color(0xFFFDFCFA);

// ─── Mini card del animal seleccionado ───────────────────────────────────────

class SintomasAnimalCard extends StatelessWidget {
  final Animal animal;

  const SintomasAnimalCard({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _kRedLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🐄', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bovino seleccionado',
                  style: TextStyle(
                    fontSize: 10,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  animal.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _kTextPrimary,
                  ),
                ),
                Text(
                  '${animal.raza} · ${animal.idExterno}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: _kTextMuted, size: 18),
        ],
      ),
    );
  }
}

// ─── Título de sección ────────────────────────────────────────────────────────

class SintomasSectionTitle extends StatelessWidget {
  final String title;
  const SintomasSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _kTextPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─── Chip de síntoma ─────────────────────────────────────────────────────────

class SintomaChip extends StatelessWidget {
  final SintomaItem item;
  final bool selected;
  final VoidCallback onTap;

  const SintomaChip({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _kTextPrimary : _kInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kTextPrimary : _kBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: selected ? Colors.white : _kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grid de síntomas ─────────────────────────────────────────────────────────

class SintomasChipGrid extends StatelessWidget {
  final Set<String> seleccionados;
  final ValueChanged<String> onToggle;

  const SintomasChipGrid({
    super.key,
    required this.seleccionados,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SintomasSectionTitle(title: '¿Qué síntomas observas?'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: kSintomas
              .map((item) => SintomaChip(
                    item: item,
                    selected: seleccionados.contains(item.label),
                    onTap: () => onToggle(item.label),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        Text(
          '${seleccionados.length} síntoma${seleccionados.length == 1 ? '' : 's'} seleccionado${seleccionados.length == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 11,
            color: _kTextMuted,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ─── Tarjeta de contador +/− ──────────────────────────────────────────────────

class ContadorCard extends StatelessWidget {
  final String label;
  final String unit;
  final double value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const ContadorCard({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: _kTextMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CounterBtn(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
              ),
              Column(
                children: [
                  Text(
                    value.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: _kTextPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _kTextMuted,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
              _CounterBtn(
                icon: Icons.add_rounded,
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _kCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder),
        ),
        child: Icon(icon, size: 16, color: _kTextPrimary),
      ),
    );
  }
}

// ─── Tarjeta de temperatura ───────────────────────────────────────────────────

class TemperaturaCard extends StatelessWidget {
  final double temperatura;
  final TempBadge badge;
  final ValueChanged<double> onChanged;

  const TemperaturaCard({
    super.key,
    required this.temperatura,
    required this.badge,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TEMPERATURA CORPORAL',
                    style: TextStyle(
                      fontSize: 10,
                      color: _kTextMuted,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        temperatura.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _kTextPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 11,
                          color: _kTextMuted,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: badge.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: badge.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: _kTextPrimary,
              inactiveTrackColor: _kBorder,
              thumbColor: _kTextPrimary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              overlayColor: Color(0x1A1A1A1A),
            ),
            child: Slider(
              value: temperatura,
              min: 35.0,
              max: 42.0,
              divisions: 70,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('35°C Baja',
                  style: TextStyle(fontSize: 9, color: _kTextMuted)),
              Text('38–39°C Normal',
                  style: TextStyle(fontSize: 9, color: _kTextMuted)),
              Text('42°C Alta',
                  style: TextStyle(fontSize: 9, color: _kTextMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Preview de severidad ─────────────────────────────────────────────────────

class SeveridadPreview extends StatelessWidget {
  final SeveridadEstimada severidad;

  const SeveridadPreview({super.key, required this.severidad});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: severidad.bgColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: severidad.borderColor),
      ),
      child: Row(
        children: [
          Text(severidad.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    severidad.titulo,
                    key: ValueKey(severidad),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _kTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    severidad.descripcion,
                    key: ValueKey(severidad.descripcion),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kTextSecondary,
                      fontWeight: FontWeight.w300,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet de resultado ────────────────────────────────────────────────

class ResultadoAnalisisSheet extends StatelessWidget {
  final Prediccion resultado;
  final Animal animal;
  final VoidCallback onListo;

  const ResultadoAnalisisSheet({
    super.key,
    required this.resultado,
    required this.animal,
    required this.onListo,
  });

  String get _recomendacion {
    final e = resultado.enfermedad.toLowerCase();
    if (e.contains('mastitis')) {
      return 'Consulta al veterinario en menos de 24 horas. Revisa la ubre manualmente.';
    }
    if (e.contains('laminitis')) {
      return 'Monitorea de cerca durante 48 horas y registra cualquier cambio.';
    }
    return 'Continúa con la observación normal del animal.';
  }

  Color get _accentColor {
    final conf = resultado.confianza;
    if (conf >= 0.8 && !resultado.enfermedad.toLowerCase().contains('sin')) {
      return _kRed;
    }
    if (conf >= 0.65) return const Color(0xFFB8860B);
    return _kGreen;
  }

  @override
  Widget build(BuildContext context) {
    final esSano = resultado.enfermedad.toLowerCase().contains('sin');
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              Text(
                esSano ? '✅' : '🔬',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resultado del análisis',
                      style: TextStyle(
                        fontSize: 11,
                        color: _kTextMuted,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      resultado.enfermedad,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _accentColor,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Confianza
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3EE),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined,
                    size: 15, color: _kTextMuted),
                const SizedBox(width: 8),
                Text(
                  'Confianza del modelo: ${(resultado.confianza * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kTextSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Recomendación
          Text(
            '💡 ${ _recomendacion}',
            style: const TextStyle(
              fontSize: 13,
              color: _kTextSecondary,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
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
              onPressed: onListo,
              child: const Text(
                'Listo',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
