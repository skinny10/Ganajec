import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ganajec/core/network/token_storage.dart';

/// Shell responsivo: en pantallas ≥ 768 px muestra sidebar + contenido.
/// En móvil (< 768 px) devuelve [child] sin modificación.
class DesktopShell extends StatelessWidget {
  const DesktopShell({
    super.key,
    required this.child,
    this.currentPath = '/home',
  });

  final Widget child;
  final String currentPath;

  static const double _kBreakpoint = 768;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _kBreakpoint) return child;

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Row(
        children: [
          _SidebarNav(currentPath: currentPath),
          VerticalDivider(width: 1, thickness: 1, color: cs.outlineVariant),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _SidebarNav extends StatelessWidget {
  const _SidebarNav({required this.currentPath});

  final String currentPath;

  bool get _esDueno => TokenStorage.role == 'dueno';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final topPad = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: 230,
      child: Container(
        color: cs.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPad + 24),

            // ── Logo ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: cs.onSurface,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.agriculture_rounded,
                      color: cs.surface,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'GanaJec',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Nav items ────────────────────────────────────────────────
            ...(_esDueno ? _duenoItems : _ganaderoItems).map(
              (item) => _NavItem(
                icon: item.icon,
                label: item.label,
                isSelected: _isSelected(currentPath, item.route),
                onTap: () => context.go(item.route),
              ),
            ),

            // ── Registrar bovino (solo ganadero) ─────────────────────────
            if (!_esDueno) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.onSurface,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                    ),
                    onPressed: () => context.push('/registro-bovino'),
                    icon: const Icon(Icons.add, size: 17),
                    label: Text(
                      'Registrar bovino',
                      style: tt.labelMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // ── Usuario ───────────────────────────────────────────────────
            _UserFooter(esDueno: _esDueno),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  bool _isSelected(String currentPath, String route) {
    if (route == '/home') {
      return currentPath == '/home' || currentPath == '/';
    }
    return currentPath.startsWith(route);
  }

  List<_NavItemData> get _ganaderoItems => [
        const _NavItemData(Icons.home_rounded, 'Inicio', '/home'),
        const _NavItemData(Icons.notifications_outlined, 'Alertas', '/alertas'),
        const _NavItemData(Icons.bar_chart_outlined, 'Reportes', '/historial'),
        const _NavItemData(Icons.group_outlined, 'Colegas', '/colegas'),
        const _NavItemData(Icons.person_outline, 'Perfil', '/perfil'),
      ];

  List<_NavItemData> get _duenoItems => [
        const _NavItemData(Icons.home_rounded, 'Inicio', '/home'),
        const _NavItemData(Icons.notifications_outlined, 'Alertas', '/alertas'),
        const _NavItemData(Icons.bar_chart_outlined, 'Reportes', '/historial-dueno'),
        const _NavItemData(Icons.group_outlined, 'Mis Ganaderos', '/mis-ganaderos'),
        const _NavItemData(Icons.medical_services_outlined, 'Veterinarios', '/veterinarios'),
        const _NavItemData(Icons.workspace_premium_outlined, 'Mi Plan', '/mi-plan'),
        const _NavItemData(Icons.person_outline, 'Perfil', '/perfil'),
      ];
}

// ── User footer ───────────────────────────────────────────────────────────────

class _UserFooter extends StatelessWidget {
  const _UserFooter({required this.esDueno});
  final bool esDueno;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final name = TokenStorage.userName ?? 'Usuario';
    final initials =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    final role = esDueno ? 'Dueño' : 'Ganadero';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: tt.labelMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: cs.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    role,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
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

// ── Nav item ──────────────────────────────────────────────────────────────────

class _NavItemData {
  const _NavItemData(this.icon, this.label, this.route);
  final IconData icon;
  final String label;
  final String route;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? cs.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? cs.primary : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
