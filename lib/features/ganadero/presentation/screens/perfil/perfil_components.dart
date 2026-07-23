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
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8A5230), Color(0xFF5C3820)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30, right: 20,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Contenido
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3D9BC),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 3),
                    ),
                    child: Center(
                      child: Text(
                        iniciales,
                        style: tt.titleMedium?.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5C3820),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2, right: -2,
                    child: GestureDetector(
                      onTap: onEditarPerfil,
                      child: Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.edit_rounded,
                            size: 10, color: Color(0xFF5C3820)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: tt.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🌱 $plan',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
  final bool isDueno;
  final VoidCallback? onUnirseRancho;
  final VoidCallback? onCrearRancho;
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
    this.isDueno = false,
    this.onUnirseRancho,
    this.onCrearRancho,
    this.onMisGanaderos,
    this.onVerColegas,
    this.ganaderosBtnLabel = 'Ver ganaderos del rancho',
  });

  bool get _tieneRancho => nombre.isNotEmpty && nombre != '—';

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(18),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8935A), Color(0xFFD85A30)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30, right: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -40, right: 30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Center(
                        child: Text('🏡', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tieneRancho ? nombre : (isDueno ? 'Sin rancho creado' : 'Sin rancho asignado'),
                          style: tt.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _tieneRancho
                              ? '📍 $municipio, $estado'
                              : (isDueno
                                  ? 'Crea tu rancho para comenzar'
                                  : 'Únete o crea un rancho para comenzar'),
                          style: tt.bodySmall?.copyWith(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),

              if (_tieneRancho) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '👤 Dueño',
                              style: tt.labelSmall?.copyWith(
                                fontSize: 10.5,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              duenoNombre.isNotEmpty ? duenoNombre : '—',
                              style: tt.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🐄 Bovinos',
                              style: tt.labelSmall?.copyWith(
                                fontSize: 10.5,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalBovinos activo${totalBovinos != 1 ? 's' : ''}',
                              style: tt.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (onUnirseRancho != null ||
                  onCrearRancho != null ||
                  onMisGanaderos != null ||
                  onVerColegas != null) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onCrearRancho ?? onUnirseRancho ?? onMisGanaderos ?? onVerColegas,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        onCrearRancho != null
                            ? '🏡 Crear rancho'
                            : onUnirseRancho != null
                                ? '🏡 Unirse a un rancho'
                                : onVerColegas != null
                                    ? '👥 Ver colegas del rancho'
                                    : '👥 $ganaderosBtnLabel',
                        style: tt.labelLarge?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD85A30),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFa08c7a),
                letterSpacing: 0.4,
              ),
            ),
          ),
          Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: 6),
                children[i],
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Fila de ajuste ───────────────────────────────────────────────────────────

class PerfilSettingRow extends StatelessWidget {
  final Widget icon;
  final String name;
  final String? desc;
  final String? trailingValue;
  final bool isDanger;
  final bool showChevron;
  final VoidCallback? onTap;
  final Color accentColor;

  const PerfilSettingRow({
    super.key,
    required this.icon,
    required this.name,
    this.desc,
    this.trailingValue,
    this.isDanger = false,
    this.showChevron = true,
    this.onTap,
    this.accentColor = const Color(0xFF8A5230),
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
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
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: isDanger
                          ? const Color(0xFFA32D2D)
                          : const Color(0xFF3d2b1f),
                    ),
                  ),
                  if (desc != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      desc!,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF8a7a6d),
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
                  color: const Color(0xFF8a7a6d),
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDanger
                    ? const Color(0xFFA32D2D)
                    : const Color(0xFFc9bfb2),
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
  final Color accentColor;

  const PerfilToggleRow({
    super.key,
    required this.icon,
    required this.name,
    this.desc,
    required this.value,
    required this.onChanged,
    this.isLast = false,
    this.accentColor = const Color(0xFF8A5230),
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF3d2b1f),
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    desc!,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF8a7a6d),
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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: value ? const Color(0xFF639922) : const Color(0xFFd8cfc3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment:
                value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
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
  final Color bg; // mantenido por compatibilidad, no se usa visualmente

  const SettingIcon({super.key, required this.emoji, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Text(emoji, style: const TextStyle(fontSize: 17));
  }
}

// ─── Compatibilidad ───────────────────────────────────────────────────────────
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'GANAJEC · Versión 1.0.4 · Chiapas, México',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: const Color(0xFFa08c7a),
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
