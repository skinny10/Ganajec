import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/admin/domain/entities/admin_sistema_estado.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _resumenAC;

  @override
  void initState() {
    super.initState();
    _resumenAC = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.microtask(() {
      if (context.mounted) context.read<AdminDashboardViewModel>().cargar();
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _resumenAC.forward();
      });
    });
  }

  @override
  void dispose() {
    _resumenAC.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get _userName => TokenStorage.userName ?? 'Admin';

  String get _userInitials {
    final parts = _userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'A';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get _saludo {
    final h = DateTime.now().hour;
    if (h < 12) return '¡Buenos días,';
    if (h < 18) return '¡Buenas tardes,';
    return '¡Buenas noches,';
  }

  Future<void> _logout() async {
    await TokenStorage.clear();
    if (context.mounted) context.go(AppRoutes.login);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<AdminDashboardViewModel>().cargar(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context, cs, tt),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vm.estado != null) ...[
                            _StatusCard(totalBovinos: vm.estado!.totalBovinos),
                            const SizedBox(height: 12),
                            _SectionHeader(
                              title: 'Actividad reciente',
                              actionText: 'Ver todas',
                              onAction: () =>
                                  context.push(AppRoutes.adminAuditoria),
                            ),
                            const SizedBox(height: 8),
                            _ActividadReciente(logs: vm.logs),
                            const SizedBox(height: 12),
                            _SectionHeader(
                              title: 'Resumen rápido',
                              actionText: 'Ver todo',
                              onAction: () =>
                                  context.push(AppRoutes.adminAuditoria),
                            ),
                            const SizedBox(height: 8),
                            _ResumenGrid(
                              estado: vm.estado!,
                              totalGanaderos: vm.totalGanaderos,
                              totalDuenos: vm.totalDuenos,
                              totalVeterinarios: vm.totalVeterinarios,
                              animation: _resumenAC,
                            ),
                            const SizedBox(height: 12),
                          ],
                          _SectionHeader(
                            title: 'Accesos rápidos',
                            actionText: null,
                          ),
                          const SizedBox(height: 10),
                          _AccesosRapidosGrid(
                            onUsuarios: () =>
                                context.push(AppRoutes.adminUsuarios),
                            onRanchos: () =>
                                context.push(AppRoutes.adminRanchos),
                            onAuditoria: () =>
                                context.push(AppRoutes.adminAuditoria),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildAdminNav(context, cs, tt),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, ColorScheme cs, TextTheme tt) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      height: topPad + 178,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        image: DecorationImage(
          image: AssetImage('assets/images/fondo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child:
                ColoredBox(color: Color.fromRGBO(255, 255, 255, 0.15)),
          ),
          Positioned(
            left: 20,
            top: topPad + 20,
            right: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_saludo 👋',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_userName!',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 34,
                    color: cs.onSurface,
                    letterSpacing: -0.6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildRoleBadge(cs, tt),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            height: 160,
            child: Image.asset(
              'assets/images/vacaas.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),
          Positioned(
            top: topPad + 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Icon(Icons.logout,
                        color: cs.error, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                _buildAvatar(cs, tt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings_rounded,
            size: 15,
            color: cs.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Administrador',
            style: tt.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme cs, TextTheme tt) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _userInitials,
          style: tt.labelMedium?.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ── Bottom nav ──────────────────────────────────────────────────────────────

  Widget _buildAdminNav(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 6, 12, MediaQuery.of(context).padding.bottom + 6),
      color: Colors.transparent,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: cs.onSurface.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Inicio (activo)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.home, color: cs.primary, size: 20),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Inicio',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Usuarios
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.adminUsuarios),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        color: cs.onSurfaceVariant, size: 23),
                    const SizedBox(height: 3),
                    Text(
                      'Usuarios',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Ranchos
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.adminRanchos),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.landscape_outlined,
                        color: cs.onSurfaceVariant, size: 23),
                    const SizedBox(height: 3),
                    Text(
                      'Ranchos',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Más (logout)
            Expanded(
              child: GestureDetector(
                onTap: _logout,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_outlined,
                        color: cs.onSurfaceVariant, size: 23),
                    const SizedBox(height: 3),
                    Text(
                      'Más',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: tt.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Status card ─────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final int totalBovinos;
  const _StatusCard({required this.totalBovinos});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5FA56D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.eco_rounded, color: Colors.white.withOpacity(0.85), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todo está funcionando correctamente',
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Monitoreando $totalBovinos bovinos en el sistema',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Actividad reciente ─────────────────────────────────────────────────────

class _ActividadReciente extends StatelessWidget {
  final List<AuditLog> logs;
  const _ActividadReciente({required this.logs});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final recent = logs.length > 4 ? logs.sublist(0, 4) : logs;

    if (recent.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          'Sin actividad reciente',
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          for (int i = 0; i < recent.length; i++) ...[
            _AuditLogTile(log: recent[i]),
            if (i < recent.length - 1)
              Divider(height: 1, color: cs.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  final AuditLog log;
  const _AuditLogTile({required this.log});

  String _labelForAction(String accion) {
    final a = accion.toLowerCase();
    if (a.contains('crear') || a.contains('registro')) {
      return 'Elemento creado';
    }
    if (a.contains('editar') || a.contains('actualizar') || a.contains('modificar')) {
      return 'Elemento actualizado';
    }
    if (a.contains('eliminar') || a.contains('borrar') || a.contains('desactivar')) {
      return 'Elemento eliminado';
    }
    if (a.contains('login') || a.contains('sesion')) return 'Sesión iniciada';
    return accion;
  }

  IconData _iconForAction(String accion) {
    final a = accion.toLowerCase();
    if (a.contains('crear') || a.contains('registro')) {
      return Icons.add_circle_outline;
    }
    if (a.contains('editar') || a.contains('actualizar') || a.contains('modificar')) {
      return Icons.edit_outlined;
    }
    if (a.contains('eliminar') || a.contains('borrar') || a.contains('desactivar')) {
      return Icons.delete_outline;
    }
    if (a.contains('login') || a.contains('sesion')) {
      return Icons.login_outlined;
    }
    return Icons.info_outline;
  }

  Color _colorForAction(String accion, ColorScheme cs) {
    final a = accion.toLowerCase();
    if (a.contains('eliminar') || a.contains('borrar') || a.contains('desactivar')) {
      return cs.error;
    }
    if (a.contains('editar') || a.contains('actualizar') || a.contains('modificar')) {
      return const Color(0xFFE8893C);
    }
    if (a.contains('crear') || a.contains('registro')) {
      return const Color(0xFF5FA56D);
    }
    return cs.primary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final icon = _iconForAction(log.accion);
    final color = _colorForAction(log.accion, cs);
    final label = _labelForAction(log.accion);
    final entidad = log.entidadAfectada.split(':').first;
    final elapsed = _timeAgo(log.creadoEn);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.bodySmall?.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  entidad,
                  style: tt.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            elapsed,
            style: tt.bodySmall?.copyWith(
              fontSize: 11,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String iso) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Ahora';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${(diff.inDays / 7).floor()}sem';
    } catch (_) {
      return '';
    }
  }
}

// ─── Animated card wrapper (entry + press) ──────────────────────────────────

class _AnimatedCard extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedCard({
    required this.animation,
    required this.child,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(widget.animation),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─── Resumen rápido — layout especial ───────────────────────────────────────

class _ResumenGrid extends StatefulWidget {
  final SistemaEstado estado;
  final int totalGanaderos;
  final int totalDuenos;
  final int totalVeterinarios;
  final AnimationController animation;

  _ResumenGrid({
    required this.estado,
    required this.totalGanaderos,
    required this.totalDuenos,
    required this.totalVeterinarios,
    required this.animation,
  });

  @override
  State<_ResumenGrid> createState() => _ResumenGridState();
}

class _ResumenGridState extends State<_ResumenGrid> {
  static const _cafe = Color(0xFF8B5E3C);
  static const _totalCards = 6;

  Animation<double> _cardAnimation(int index) {
    final start = index / _totalCards;
    final end = (index + 1) / _totalCards;
    return CurvedAnimation(
      parent: widget.animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        // ── Top row: card grande + grid 2×2 ──
        SizedBox(
          height: 220,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Tarjeta grande bovinos ──
              Expanded(
                flex: 1,
                child: _AnimatedCard(
                  animation: _cardAnimation(0),
                  child: _HoverCard(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          // ── Fondo café ──
                          Positioned.fill(
                            child: Container(color: _cafe),
                          ),
                          // ── Manchas decorativas (círculos dispersos) ──
                          Positioned(
                            right: 12,
                            top: 18,
                            width: 28,
                            height: 28,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 48,
                            top: 40,
                            width: 18,
                            height: 18,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 60,
                            width: 14,
                            height: 14,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 58,
                            bottom: 80,
                            width: 22,
                            height: 22,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 60,
                            top: 12,
                            width: 16,
                            height: 16,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // ── Imagen vaca esquina inferior derecha ──
                          Positioned(
                            right: -6,
                            bottom: -4,
                            child: Opacity(
                              opacity: 0.2,
                              child: Image.asset(
                                'assets/images/vaca.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // ── Contenido ──
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5E6D3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '🐄',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${widget.estado.totalBovinos}',
                                    style: tt.headlineLarge?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bovinos',
                                    style: tt.bodyLarge?.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_downward_rounded,
                                        color: Color(0xFF4CAF50),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '5 esta semana',
                                        style: tt.bodySmall?.copyWith(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ── Grid 2×2 derecho ──
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _AnimatedCard(
                              animation: _cardAnimation(1),
                              child: _HoverCard(
                                child: _ResumenMiniCard(
                                  icon: Icons.people_outline,
                                  color: cs.primary,
                                  valor: '${widget.estado.totalUsuarios}',
                                  label: 'Usuarios',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _AnimatedCard(
                              animation: _cardAnimation(2),
                              child: _HoverCard(
                                child: _ResumenMiniCard(
                                  icon: Icons.home_outlined,
                                  color: const Color(0xFFE53935),
                                  valor: '${widget.estado.totalRanchos}',
                                  label: 'Ranchos',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _AnimatedCard(
                              animation: _cardAnimation(3),
                              child: _HoverCard(
                                child: _ResumenMiniCard(
                                  icon: Icons.agriculture_outlined,
                                  color: const Color(0xFF8B5E3C),
                                  valor: '${widget.totalGanaderos}',
                                  label: 'Ganaderos',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _AnimatedCard(
                              animation: _cardAnimation(4),
                              child: _HoverCard(
                                child: _ResumenMiniCard(
                                  icon: Icons.business_center_outlined,
                                  color: const Color(0xFF00897B),
                                  valor: '${widget.totalDuenos}',
                                  label: 'Dueños',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Veterinarios card (solo si hay) ──
        if (widget.totalVeterinarios > 0)
          _AnimatedCard(
            animation: _cardAnimation(5),
            child: _HoverCard(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Color(0xFF7B1FA2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${widget.totalVeterinarios} Veterinarios Registrados',
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Hover card wrapper ─────────────────────────────────────────────────────

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _ResumenMiniCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String valor;
  final String label;

  const _ResumenMiniCard({
    required this.icon,
    required this.color,
    required this.valor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const Spacer(),
          Text(
            valor,
            style: tt.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          Text(
            label,
            style: tt.bodySmall?.copyWith(
              fontSize: 10,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Accesos rápidos — lista vertical horizontal ────────────────────────────

class _AccesosRapidosGrid extends StatelessWidget {
  final VoidCallback onUsuarios;
  final VoidCallback onRanchos;
  final VoidCallback onAuditoria;

  const _AccesosRapidosGrid({
    required this.onUsuarios,
    required this.onRanchos,
    required this.onAuditoria,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccesoRapidoTile(
          icon: Icons.people_outline,
          iconColor: const Color(0xFF6D4C41),
          iconBg: const Color(0xFFE8D5C0),
          titulo: 'Gestionar usuarios',
          descripcion: 'Administrar cuentas y permisos',
          onTap: onUsuarios,
        ),
        const SizedBox(height: 10),
        _AccesoRapidoTile(
          icon: Icons.home_outlined,
          iconColor: const Color(0xFF757575),
          iconBg: const Color(0xFFE0E0E0),
          titulo: 'Gestionar ranchos',
          descripcion: 'Crear y administrar ranchos',
          onTap: onRanchos,
        ),
        const SizedBox(height: 10),
        _AccesoRapidoTile(
          icon: Icons.shield_outlined,
          iconColor: const Color(0xFF7B1FA2),
          iconBg: const Color(0xFFEDE7F6),
          titulo: 'Ver auditoría',
          descripcion: 'Historial de actividades del sistema',
          onTap: onAuditoria,
        ),
      ],
    );
  }
}

class _AccesoRapidoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _AccesoRapidoTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFDF6EE),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Stack(
          children: [
            // ── Ilustración sutil rancho en esquina derecha ──
            Positioned(
              right: -4,
              bottom: -4,
              child: Icon(
                Icons.landscape_outlined,
                size: 52,
                color: Colors.brown.withOpacity(0.06),
              ),
            ),
            // ── Contenido ──
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: tt.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descripcion,
                        style: tt.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant.withOpacity(0.5),
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
