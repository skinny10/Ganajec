import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';

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
const _kChanged = Color(0xFFF39C12);
const _kChangedBg = Color(0xFFFEFDF5);

// ─── Enums ───────────────────────────────────────────────────────────────────

enum CategoriaAnimal {
  vaca('Vaca', '🐄', 'Hembra adulta', 'hembra'),
  toro('Toro', '🐂', 'Macho adulto', 'macho'),
  becerra('Becerra', '🐮', 'Cría hembra', 'hembra'),
  becerro('Becerro', '🐃', 'Cría macho', 'macho'),
  vaquilla('Vaquilla', '🐄', 'Hembra joven', 'hembra'),
  novillo('Novillo', '🐂', 'Macho engorda', 'macho');

  final String label;
  final String emoji;
  final String desc;
  final String sexo;
  const CategoriaAnimal(this.label, this.emoji, this.desc, this.sexo);
}

enum PropositoAnimal {
  leche('🥛 Leche'),
  carne('🥩 Carne / Engorda'),
  doble('🔄 Doble propósito'),
  cria('🐣 Cría / Reproducción');

  final String label;
  const PropositoAnimal(this.label);
}

// ─── Razas agrupadas ─────────────────────────────────────────────────────────

const kRazasGrupadas = <String, List<String>>{
  'Leche / Doble propósito': [
    'Holstein',
    'Suizo Americano',
    'Pardo Suizo',
    'Simmental',
  ],
  'Carne / Trópico': [
    'Brahman',
    'Cebuíno / Cebú',
    'Charolais',
    'Limousin',
    'Brangus',
    'Simbrah',
  ],
  'Criollas / Locales': [
    'Criollo chiapaneco',
    'Mestizo',
  ],
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

CategoriaAnimal derivarCategoria(String sexo, int edad) {
  if (sexo == 'hembra') {
    if (edad < 1) return CategoriaAnimal.becerra;
    if (edad < 2) return CategoriaAnimal.vaquilla;
    return CategoriaAnimal.vaca;
  } else {
    if (edad < 2) return CategoriaAnimal.becerro;
    return CategoriaAnimal.toro;
  }
}

PropositoAnimal derivarProposito(String raza) {
  final r = raza.toLowerCase();
  if (r.contains('holstein') || r.contains('suizo') || r.contains('pardo')) {
    return PropositoAnimal.leche;
  }
  if (r.contains('brahman') || r.contains('cebú') || r.contains('cebuíno') ||
      r.contains('charolais') || r.contains('limousin') || r.contains('brangus') ||
      r.contains('angus')) {
    return PropositoAnimal.carne;
  }
  return PropositoAnimal.doble;
}

int calcularEdad(DateTime fechaNacimiento) {
  final now = DateTime.now();
  int years = now.year - fechaNacimiento.year;
  if (now.month < fechaNacimiento.month ||
      (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
    years--;
  }
  return years;
}

String formatFecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

// ─── Mini card del animal ─────────────────────────────────────────────────────

class EditarMiniCard extends StatelessWidget {
  final Animal animal;
  final String severidad;

  const EditarMiniCard({
    super.key,
    required this.animal,
    required this.severidad,
  });

  @override
  Widget build(BuildContext context) {
    final edad = calcularEdad(animal.fechaNacimiento);
    final categoria = derivarCategoria(animal.sexo, edad);
    final esAlta = severidad.toLowerCase().contains('alta');

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _kRedLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Center(
              child: Text('🐄', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${animal.raza} · ${categoria.label} · ${animal.idExterno}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: esAlta ? _kRedLight : _kGreenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severidad,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: esAlta ? _kRed : _kGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner de cambios sin guardar ───────────────────────────────────────────

class EditarChangeBanner extends StatelessWidget {
  const EditarChangeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9E7),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFF7DC6F)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✏️', style: TextStyle(fontSize: 14)),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tienes cambios sin guardar. Presiona Guardar para aplicarlos.',
              style: TextStyle(
                fontSize: 11.5,
                color: Color(0xFF7D6608),
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Etiqueta de sección ──────────────────────────────────────────────────────

class EditarSectionLabel extends StatelessWidget {
  final String label;
  const EditarSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _kTextSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Campo de texto estilizado ─────────────────────────────────────────────

class EditarTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData iconData;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool changed;
  final String? changedHint;

  const EditarTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.iconData,
    this.keyboardType,
    this.maxLines = 1,
    this.changed = false,
    this.changedHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditarSectionLabel(label: label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 14,
            color: _kTextPrimary,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: changed ? _kChangedBg : _kInputBg,
            prefixIcon: Icon(
              iconData,
              size: 16,
              color: _kTextMuted,
            ),
            hintStyle: const TextStyle(
              color: _kTextMuted,
              fontWeight: FontWeight.w300,
              fontSize: 14,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 13,
              vertical: maxLines > 1 ? 13 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                  color: changed ? _kChanged : _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                  color: changed ? _kChanged : _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                  color: _kTextPrimary, width: 1.5),
            ),
          ),
        ),
        if (changedHint != null && changed) ...[
          const SizedBox(height: 4),
          Text(
            changedHint!,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFFB7770D),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Selector de Raza (tappable → bottom sheet) ───────────────────────────

class EditarRazaField extends StatelessWidget {
  final String label;
  final String value;
  final bool changed;
  final VoidCallback onTap;

  const EditarRazaField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.changed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditarSectionLabel(label: label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: changed ? _kChangedBg : _kInputBg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: changed ? _kChanged : _kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_outlined,
                    size: 16, color: _kTextMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _kTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: _kTextMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet para seleccionar raza con grupos
void showRazaSheet(
    BuildContext context, String current, ValueChanged<String> onSelect) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Seleccionar raza',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: kRazasGrupadas.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _kTextMuted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  ...entry.value.map((raza) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4),
                        dense: true,
                        title: Text(
                          raza,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: raza == current
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: raza == current
                                ? _kTextPrimary
                                : _kTextSecondary,
                          ),
                        ),
                        trailing: raza == current
                            ? const Icon(Icons.check_rounded,
                                color: _kGreen, size: 18)
                            : null,
                        onTap: () {
                          onSelect(raza);
                          Navigator.of(context).pop();
                        },
                      )),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Grid de categoría ────────────────────────────────────────────────────────

class EditarCategoriaGrid extends StatelessWidget {
  final CategoriaAnimal selected;
  final ValueChanged<CategoriaAnimal> onSelect;

  const EditarCategoriaGrid({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditarSectionLabel(label: 'Categoría del animal'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          childAspectRatio: 3.0,
          children: CategoriaAnimal.values
              .map((cat) => _CatCard(
                    cat: cat,
                    isSelected: cat == selected,
                    onTap: () => onSelect(cat),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _CatCard extends StatelessWidget {
  final CategoriaAnimal cat;
  final bool isSelected;
  final VoidCallback onTap;

  const _CatCard({
    required this.cat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _kTextPrimary : _kInputBg,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isSelected ? _kTextPrimary : _kBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(cat.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : _kTextPrimary,
                    ),
                  ),
                  Text(
                    cat.desc,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: isSelected
                          ? Colors.white.withOpacity(0.6)
                          : _kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pills de propósito ───────────────────────────────────────────────────────

class EditarPropositoPills extends StatelessWidget {
  final PropositoAnimal selected;
  final ValueChanged<PropositoAnimal> onSelect;

  const EditarPropositoPills({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditarSectionLabel(label: 'Propósito'),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: PropositoAnimal.values
              .map((p) => _PropositoPill(
                    prop: p,
                    isSelected: p == selected,
                    onTap: () => onSelect(p),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _PropositoPill extends StatelessWidget {
  final PropositoAnimal prop;
  final bool isSelected;
  final VoidCallback onTap;

  const _PropositoPill({
    required this.prop,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _kGreen : _kInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _kGreen : _kBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          prop.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isSelected ? Colors.white : _kTextSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Campo de fecha ───────────────────────────────────────────────────────────

class EditarFechaField extends StatelessWidget {
  final DateTime value;
  final bool changed;
  final VoidCallback onTap;

  const EditarFechaField({
    super.key,
    required this.value,
    required this.onTap,
    this.changed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditarSectionLabel(label: 'Fecha de nacimiento'),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: changed ? _kChangedBg : _kInputBg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: changed ? _kChanged : _kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: _kTextMuted),
                const SizedBox(width: 10),
                Text(
                  formatFecha(value),
                  style: const TextStyle(
                    fontSize: 14,
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Modal de eliminación ─────────────────────────────────────────────────────

class EditarDeleteModal extends StatelessWidget {
  final String animalNombre;
  final bool isDeleting;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const EditarDeleteModal({
    super.key,
    required this.animalNombre,
    required this.isDeleting,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            '¿Eliminar a $animalNombre?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Esta acción eliminará al bovino y todo su historial de predicciones y producción. No se puede deshacer.',
            style: TextStyle(
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
                backgroundColor: _kRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
              onPressed: isDeleting ? null : onConfirm,
              child: isDeleting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Sí, eliminar bovino',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _kTextPrimary,
                side: const BorderSide(color: _kBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: isDeleting ? null : onCancel,
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
