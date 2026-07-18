import 'package:flutter/material.dart';

// ─── Hero de perfil ───────────────────────────────────────────────────────────

class PerfilHeroCard extends StatelessWidget {
  final String iniciales;
  final String nombre;
  final String email;
  final String plan;
  final VoidCallback? onEditarPerfil;

  const PerfilHeroCard({
    super.key,
    required this.iniciales,
    required this.nombre,
    required this.email,
    required this.plan,
    this.onEditarPerfil,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    iniciales,
                    style: tt.titleMedium?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: GestureDetector(
                  onTap: onEditarPerfil,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: cs.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 10,
                      color: cs.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: tt.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.outline,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    '🐄 $plan',
                    style: tt.labelSmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
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

// ─── Card del rancho ──────────────────────────────────────────────────────────

class PerfilRanchoCard extends StatelessWidget {
  final String nombre;
  final String municipio;
  final String estado;
  final String duenoNombre;
  final int totalBovinos;
  final VoidCallback? onUnirseRancho;
  final VoidCallback? onMisGanaderos;
  final VoidCallback? onVerColegas;
  final String ganaderosBtnLabel;

  const PerfilRanchoCard({
    super.key,
    required this.nombre,
    required this.municipio,
    required this.estado,
    this.duenoNombre = '',
    required this.totalBovinos,
    this.onUnirseRancho,
    this.onMisGanaderos,
    this.onVerColegas,
    this.ganaderosBtnLabel = 'Ver ganaderos del rancho',
  });

  bool get _tieneRancho => nombre.isNotEmpty && nombre != '—';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tieneRancho ? nombre : 'Sin rancho asignado',
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _tieneRancho
                          ? '$municipio, $estado'
                          : 'Únete o crea un rancho para comenzar',
                      style: tt.bodySmall?.copyWith(
                        fontSize: 11,
                        color: cs.onPrimaryContainer.withOpacity(0.7),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_tieneRancho) ...[
            const SizedBox(height: 10),
            Divider(color: cs.primary.withOpacity(0.15), height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.person_outline,
                  label: duenoNombre.isNotEmpty
                      ? 'Dueño del rancho: $duenoNombre'
                      : 'Dueño del rancho',
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.pets_outlined,
                  label: '$totalBovinos bovinos',
                ),
              ],
            ),
          ],

          if (onUnirseRancho != null ||
              onMisGanaderos != null ||
              onVerColegas != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onUnirseRancho ?? onMisGanaderos ?? onVerColegas,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.primary.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      onUnirseRancho != null
                          ? Icons.add_home_outlined
                          : Icons.people_outlined,
                      color: cs.onPrimaryContainer,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      onUnirseRancho != null
                          ? 'Unirse o crear rancho'
                          : onVerColegas != null
                              ? 'Ver colegas del rancho'
                              : ganaderosBtnLabel,
                      style: tt.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.onPrimaryContainer),
        const SizedBox(width: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 11,
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─── Sección de ajustes ───────────────────────────────────────────────────────

class PerfilSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const PerfilSection({
    super.key,
    required this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 7),
            child: Text(
              label.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: cs.outline,
                letterSpacing: 0.08 * 10,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ─── Fila de ajuste con flecha ────────────────────────────────────────────────

class PerfilSettingRow extends StatelessWidget {
  final Widget icon;
  final String name;
  final String? desc;
  final String? trailingValue;
  final bool isDanger;
  final bool showChevron;
  final VoidCallback? onTap;

  const PerfilSettingRow({
    super.key,
    required this.icon,
    required this.name,
    this.desc,
    this.trailingValue,
    this.isDanger = false,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDanger ? cs.error : cs.onSurface,
                    ),
                  ),
                  if (desc != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      desc!,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 11,
                        color: cs.outline,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingValue != null)
              Text(
                trailingValue!,
                style: tt.bodySmall?.copyWith(
                  fontSize: 12,
                  color: cs.outline,
                  fontWeight: FontWeight.w300,
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDanger ? cs.error : cs.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Fila con toggle ──────────────────────────────────────────────────────────

class PerfilToggleRow extends StatelessWidget {
  final Widget icon;
  final String name;
  final String? desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const PerfilToggleRow({
    super.key,
    required this.icon,
    required this.name,
    this.desc,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: cs.outlineVariant, width: 0.5),
              ),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    desc!,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 11,
                      color: cs.outline,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _ToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: value ? cs.tertiary : cs.outlineVariant,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(9),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Ícono de ajuste ──────────────────────────────────────────────────────────

class SettingIcon extends StatelessWidget {
  final String emoji;
  final Color bg;

  const SettingIcon({super.key, required this.emoji, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}

// ─── Último separador transparente en la card ─────────────────────────────────
class PerfilRowLast extends StatelessWidget {
  final Widget child;
  const PerfilRowLast({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

// ─── Texto de versión ─────────────────────────────────────────────────────────

class PerfilVersionText extends StatelessWidget {
  const PerfilVersionText({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'GANAJEC · Versión 1.0.4 · Chiapas, México',
          style: tt.bodySmall?.copyWith(
            fontSize: 11,
            color: cs.outline,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}

// ─── Modal de cierre de sesión ────────────────────────────────────────────────

class PerfilLogoutModal extends StatelessWidget {
  final String nombreUsuario;
  final String email;
  final bool isLoading;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PerfilLogoutModal({
    super.key,
    required this.nombreUsuario,
    required this.email,
    required this.isLoading,
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
            '¿Cerrar sesión?',
            style: tt.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tendrás que volver a iniciar sesión para acceder a tu cuenta y al historial de tus bovinos.',
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$nombreUsuario · $email',
            style: tt.bodySmall?.copyWith(
              fontSize: 11,
              color: cs.outline,
              fontWeight: FontWeight.w300,
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
              onPressed: isLoading ? null : onConfirm,
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.onError,
                      ),
                    )
                  : Text(
                      'Sí, cerrar sesión',
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
              onPressed: isLoading ? null : onCancel,
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
