import 'package:flutter/material.dart';

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
const _kCow = Color(0xFF8B4A2B);
const _kCowLight = Color(0xFFF5EBE0);

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
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
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
                  color: _kCow,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4D8B4A2B),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    iniciales,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              // Botón editar avatar
              Positioned(
                bottom: -4,
                right: -4,
                child: GestureDetector(
                  onTap: onEditarPerfil,
                  child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _kTextPrimary,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                        color: const Color(0xFFFAFAF7), width: 2),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 10,
                    color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kCream,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Text(
                    '🐄 $plan',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _kTextSecondary,
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
  final VoidCallback? onUnirseRancho;   // si no tiene rancho
  final VoidCallback? onMisGanaderos;   // dueño: ver ganaderos
  final VoidCallback? onVerColegas;     // ganadero: ver colegas del rancho
  final String ganaderosBtnLabel;       // "Ver ganaderos del rancho"

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
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: _kCowLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D5C4)),
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
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: _kCow,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _tieneRancho
                          ? '$municipio, $estado'
                          : 'Únete o crea un rancho para comenzar',
                      style: TextStyle(
                        fontSize: 11,
                        color: _kCow.withOpacity(0.7),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dueño y bovinos — solo cuando tiene rancho
          if (_tieneRancho) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0xFFE8D5C4), height: 1),
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

          // Botón de acción
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
                  color: _kCow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kCow.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      onUnirseRancho != null
                          ? Icons.add_home_outlined
                          : Icons.people_outlined,
                      color: _kCow,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      onUnirseRancho != null
                          ? 'Unirse o crear rancho'
                          : onVerColegas != null
                              ? 'Ver colegas del rancho'
                              : ganaderosBtnLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _kCow,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF8B6914)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8B6914),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 7),
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _kTextMuted,
                letterSpacing: 0.08 * 10,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: children,
            ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE8E5DC), width: 0.5),
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDanger ? _kRed : _kTextPrimary,
                    ),
                  ),
                  if (desc != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      desc!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kTextMuted,
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
                style: const TextStyle(
                  fontSize: 12,
                  color: _kTextMuted,
                  fontWeight: FontWeight.w300,
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDanger ? _kRed : _kTextMuted,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFE8E5DC), width: 0.5),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _kTextPrimary,
                  ),
                ),
                if (desc != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    desc!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kTextMuted,
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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: value ? _kGreen : _kBorder,
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

// ─── Último separador transparente en la card (eliminar border-bottom) ────────
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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'GANAJEC · Versión 1.0.4 · Chiapas, México',
          style: TextStyle(
            fontSize: 11,
            color: _kTextMuted,
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
          const Text(
            '¿Cerrar sesión?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _kTextPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tendrás que volver a iniciar sesión para acceder a tu cuenta y al historial de tus bovinos.',
            style: const TextStyle(
              fontSize: 13,
              color: _kTextSecondary,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$nombreUsuario · $email',
            style: const TextStyle(
              fontSize: 11,
              color: _kTextMuted,
              fontWeight: FontWeight.w300,
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
              onPressed: isLoading ? null : onConfirm,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Sí, cerrar sesión',
                      style: TextStyle(
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
                foregroundColor: _kTextPrimary,
                side: const BorderSide(color: _kBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onPressed: isLoading ? null : onCancel,
              child: const Text(
                'Cancelar',
                style: TextStyle(
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
