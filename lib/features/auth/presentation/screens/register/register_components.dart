import 'package:flutter/material.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_role_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers privados
// ─────────────────────────────────────────────────────────────────────────────

/// Encabezado de sección dentro de la card (fondo ligeramente coloreado).
class _DividerLabel extends StatelessWidget {
  final String text;
  const _DividerLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 7),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize:      10,
          fontWeight:    FontWeight.w500,
          color:         cs.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Fila de un campo dentro de la card.
class _FieldRow extends StatelessWidget {
  final String   label;
  final IconData icon;
  final Widget   field;
  final Widget?  trailing;
  final Widget?  extra;    // aparece bajo el input (ej: barras de fortaleza)
  final bool     isLast;

  const _FieldRow({
    required this.label,
    required this.icon,
    required this.field,
    this.trailing,
    this.extra,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: cs.outlineVariant, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize:      10,
              fontWeight:    FontWeight.w500,
              color:         cs.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: cs.outline, size: 15),
              const SizedBox(width: 9),
              Expanded(child: field),
              if (trailing != null) ...[const SizedBox(width: 6), trailing!],
            ],
          ),
          if (extra != null) ...[const SizedBox(height: 7), extra!],
        ],
      ),
    );
  }
}

/// Barras de fortaleza de contraseña.
class StrengthBars extends StatelessWidget {
  final int score;
  const StrengthBars({super.key, required this.score});

  Color _color(ColorScheme cs) {
    switch (score) {
      case 1: return cs.error;
      case 2: return cs.secondary;
      case 3: return cs.primary;
      case 4: return cs.tertiary;
      default: return cs.outlineVariant;
    }
  }

  String get _label {
    switch (score) {
      case 1: return 'Muy débil';
      case 2: return 'Débil';
      case 3: return 'Regular';
      case 4: return 'Fuerte';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final color = _color(cs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              height: 2.5,
              margin: EdgeInsets.only(right: i < 3 ? 3 : 0),
              decoration: BoxDecoration(
                color: i < score ? color : cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        if (score > 0) ...[
          const SizedBox(height: 3),
          Text(
            'Fortaleza: $_label',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              color:    color,
            ),
          ),
        ],
      ],
    );
  }
}

/// Decoración base: input transparente dentro de la card.
InputDecoration _transparentDeco(ColorScheme cs, TextTheme tt, String hint) => InputDecoration(
  isDense:   true,
  filled:    false,
  hintText:  hint,
  hintStyle: tt.bodyMedium?.copyWith(
    color:      cs.outline,
    fontWeight: FontWeight.w300,
  ),
  errorStyle: tt.labelSmall?.copyWith(
    fontSize: 10,
    color:    cs.error,
    height:   1.4,
  ),
  contentPadding:     EdgeInsets.zero,
  border:             InputBorder.none,
  enabledBorder:      InputBorder.none,
  focusedBorder:      InputBorder.none,
  errorBorder:        InputBorder.none,
  focusedErrorBorder: InputBorder.none,
);

// ─────────────────────────────────────────────────────────────────────────────
// Card agrupada de todos los campos
// ─────────────────────────────────────────────────────────────────────────────
class RegisterFieldsCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool         obscurePassword;
  final bool         obscureConfirm;
  final int          strengthScore;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  const RegisterFieldsCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.strengthScore,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Estilo común para el texto tecleado en los inputs
    final inputStyle = tt.bodyMedium?.copyWith(color: cs.onSurface);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Información personal ──────────────────────────────────────
          const _DividerLabel('Información personal'),

          _FieldRow(
            label:  'Nombre completo',
            icon:   Icons.person_outline,
            isLast: false,
            trailing: ListenableBuilder(
              listenable: nameController,
              builder: (_, __) => nameController.text.isNotEmpty
                  ? Icon(Icons.check_rounded, color: cs.tertiary, size: 14)
                  : const SizedBox.shrink(),
            ),
            field: TextFormField(
              controller:         nameController,
              textCapitalization: TextCapitalization.words,
              style:              inputStyle,
              decoration: _transparentDeco(cs, tt, 'Tu nombre completo'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
            ),
          ),

          _FieldRow(
            label:  'Correo electrónico',
            icon:   Icons.mail_outline_rounded,
            isLast: true,
            trailing: ListenableBuilder(
              listenable: emailController,
              builder: (_, __) => emailController.text.contains('@')
                  ? Icon(Icons.check_rounded, color: cs.tertiary, size: 14)
                  : const SizedBox.shrink(),
            ),
            field: TextFormField(
              controller:   emailController,
              keyboardType: TextInputType.emailAddress,
              style:        inputStyle,
              decoration:   _transparentDeco(cs, tt, 'correo@ejemplo.com'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa tu correo';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              },
            ),
          ),

          // ── Seguridad ─────────────────────────────────────────────────
          const _DividerLabel('Seguridad'),

          _FieldRow(
            label:  'Contraseña',
            icon:   Icons.lock_outline_rounded,
            isLast: false,
            trailing: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: cs.outline,
                size: 16,
              ),
            ),
            extra: strengthScore > 0
                ? StrengthBars(score: strengthScore)
                : null,
            field: TextFormField(
              controller:  passwordController,
              obscureText: obscurePassword,
              style:       inputStyle,
              decoration:  _transparentDeco(cs, tt, 'Mínimo 8 caracteres'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                if (v.length < 8) return 'Mínimo 8 caracteres';
                return null;
              },
            ),
          ),

          _FieldRow(
            label:  'Confirmar contraseña',
            icon:   Icons.lock_outline_rounded,
            isLast: true,
            trailing: GestureDetector(
              onTap: onToggleConfirm,
              child: Icon(
                obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: cs.outline,
                size: 16,
              ),
            ),
            field: TextFormField(
              controller:  confirmController,
              obscureText: obscureConfirm,
              style:       inputStyle,
              decoration:  _transparentDeco(cs, tt, 'Repite tu contraseña'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                if (v != passwordController.text)
                  return 'Las contraseñas no coinciden';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selector de rol
// ─────────────────────────────────────────────────────────────────────────────
class RegisterRoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RegisterRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  static const _roles = [
    (
      role:        'ganadero',
      label:       'Ganadero',
      description: 'Registro mis animales y recibo alertas de salud del hato.',
      icon:        Icons.home_outlined,
    ),
    (
      role:        'dueno',
      label:       'Dueño del rancho',
      description: 'Superviso el hato completo y coordino a mi equipo.',
      icon:        Icons.monitor_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECCIONA TU ROL',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize:      10,
            fontWeight:    FontWeight.w500,
            color:         cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        ..._roles.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AuthRoleCard(
            role:        r.label,
            description: r.description,
            icon:        r.icon,
            selected:    selectedRole == r.role,
            onTap:       () => onRoleChanged(r.role),
          ),
        )),
      ],
    );
  }
}
