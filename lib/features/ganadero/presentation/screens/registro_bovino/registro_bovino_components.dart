import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/app_strings.dart';

class RbTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? helper;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const RbTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.helper,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon),
            helperText: helper,
            helperMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class RbCategoriaSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const RbCategoriaSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _categorias = [
    (id: 'vaca', label: 'Vaca', sub: 'Hembra adulta', icon: Icons.female),
    (id: 'toro', label: 'Toro', sub: 'Macho adulto', icon: Icons.male),
    (id: 'becerra', label: 'Becerra', sub: 'Cría hembra', icon: Icons.female),
    (id: 'becerro', label: 'Becerro', sub: 'Cría macho', icon: Icons.male),
    (id: 'vaquilla', label: 'Vaquilla', sub: 'Hembra joven', icon: Icons.female),
    (id: 'novillo', label: 'Novillo', sub: 'Macho engorda', icon: Icons.male),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.categoriaAnimal,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.4,
          children: _categorias.map((c) {
            final isSelected = selected == c.id;
            return GestureDetector(
              onTap: () => onSelected(c.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.onSurface
                      : colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colors.onSurface
                        : colors.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 18,
                      color: isSelected
                          ? colors.surface
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            c.label,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? colors.surface
                                      : colors.onSurface,
                                ),
                          ),
                          Text(
                            c.sub,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isSelected
                                      ? colors.surfaceContainerHighest
                                      : colors.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class RbPropositoSelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const RbPropositoSelector({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  static const _propositos = [
    (id: 'leche', label: 'Leche', icon: Icons.water_drop_outlined),
    (id: 'carne', label: 'Carne / Engorda', icon: Icons.restaurant_outlined),
    (id: 'doble', label: 'Doble propósito', icon: Icons.sync_outlined),
    (id: 'cria', label: 'Cría / Reproducción', icon: Icons.child_care_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.proposito,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _propositos.map((p) {
            final isSelected = selected.contains(p.id);
            return GestureDetector(
              onTap: () => onToggle(p.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryContainer
                      : colors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colors.primary
                        : colors.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      p.icon,
                      size: 16,
                      color: isSelected
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p.label,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(
                            color: isSelected
                                ? colors.onPrimaryContainer
                                : colors.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class RbRazaDropdown extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const RbRazaDropdown({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _razas = [
    'Holstein',
    'Suizo',
    'Angus',
    'Brahman',
    'Simmental',
    'Hereford',
    'Charolais',
    'Limousin',
    'Cebuíno',
    'Criollo',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.raza,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          hint: Row(
            children: [
              Icon(Icons.schedule_outlined,
                  size: 18, color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(AppStrings.seleccionaRaza),
            ],
          ),
          decoration: const InputDecoration(),
          items: _razas
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? AppStrings.razaRequerida : null,
        ),
      ],
    );
  }
}

class RbEdadPesoRow extends StatelessWidget {
  final TextEditingController edadController;
  final TextEditingController pesoController;

  const RbEdadPesoRow({
    super.key,
    required this.edadController,
    required this.pesoController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.edadAnios,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: edadController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: AppStrings.edadHint,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return AppStrings.edadInvalida;
                  if (int.tryParse(v) == null) return AppStrings.edadInvalida;
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.pesoKg,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: AppStrings.pesoHint,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return AppStrings.pesoInvalido;
                  if (double.tryParse(v) == null) return AppStrings.pesoInvalido;
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}