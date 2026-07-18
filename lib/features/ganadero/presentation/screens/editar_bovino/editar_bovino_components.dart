import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';

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
      r.contains('charolais') || r.contains('limousin') ||
      r.contains('brangus') || r.contains('angus')) {
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final edad = calcularEdad(animal.fechaNacimiento);
    final categoria = derivarCategoria(animal.sexo, edad);
    final esAlta = severidad.toLowerCase().contains('alta');

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
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
                  style: tt.titleSmall?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${animal.raza} · ${categoria.label} · ${animal.idExterno}',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: cs.outline,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: esAlta ? cs.errorContainer : cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              severidad,
              style: tt.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: esAlta ? cs.error : cs.tertiary,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: cs.secondary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✏️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tienes cambios sin guardar. Presiona Guardar para aplicarlos.',
              style: tt.bodySmall?.copyWith(
                fontSize: 11.5,
                color: cs.onSecondaryContainer,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: tt.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Campo de texto estilizado ────────────────────────────────────────────────

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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditarSectionLabel(label: label),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: tt.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: changed
                ? cs.primaryContainer.withOpacity(0.3)
                : cs.surfaceContainerLowest,
            prefixIcon: Icon(iconData, size: 16, color: cs.outline),
            hintStyle: tt.bodySmall?.copyWith(
              color: cs.outline,
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
                  color: changed ? cs.primary : cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(
                  color: changed ? cs.primary : cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: BorderSide(color: cs.onSurface, width: 1.5),
            ),
          ),
        ),
        if (changedHint != null && changed) ...[
          const SizedBox(height: 4),
          Text(
            changedHint!,
            style: tt.labelSmall?.copyWith(
              fontSize: 10.5,
              color: cs.onSecondaryContainer,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Selector de Raza ────────────────────────────────────────────────────────

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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditarSectionLabel(label: label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: changed
                  ? cs.primaryContainer.withOpacity(0.3)
                  : cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: changed ? cs.primary : cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 16, color: cs.outline),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: cs.outline),
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
    builder: (ctx) => _RazaSheetContent(
      current: current,
      onSelect: onSelect,
    ),
  );
}

class _RazaSheetContent extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _RazaSheetContent({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Seleccionar raza',
            style: tt.titleSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: cs.outline,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  ...entry.value.map((raza) => ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        dense: true,
                        title: Text(
                          raza,
                          style: tt.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: raza == current
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: raza == current
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        trailing: raza == current
                            ? Icon(Icons.check_rounded,
                                color: cs.tertiary, size: 18)
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
    );
  }
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.onSurface : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isSelected ? cs.onSurface : cs.outlineVariant,
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
                    style: tt.labelSmall?.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? cs.surface : cs.onSurface,
                    ),
                  ),
                  Text(
                    cat.desc,
                    style: tt.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      color: isSelected
                          ? cs.surface.withOpacity(0.6)
                          : cs.outline,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.tertiary : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cs.tertiary : cs.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Text(
          prop.label,
          style: tt.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isSelected ? cs.onTertiary : cs.onSurfaceVariant,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EditarSectionLabel(label: 'Fecha de nacimiento'),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: changed
                  ? cs.primaryContainer.withOpacity(0.3)
                  : cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: changed ? cs.primary : cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: cs.outline),
                const SizedBox(width: 10),
                Text(
                  formatFecha(value),
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 14,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¿Eliminar a $animalNombre?',
            style: tt.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Esta acción eliminará al bovino y todo su historial de predicciones y producción. No se puede deshacer.',
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
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
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
              onPressed: isDeleting ? null : onConfirm,
              child: isDeleting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.onError,
                      ),
                    )
                  : Text(
                      'Sí, eliminar bovino',
                      style: tt.labelLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.onSurface,
                side: BorderSide(color: cs.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: isDeleting ? null : onCancel,
              child: Text(
                'Cancelar',
                style: tt.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
