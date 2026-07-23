import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import '../../viewmodels/perfil_viewmodel.dart';
import '../../viewmodels/veterinario_viewmodel.dart';
import '../../viewmodels/mis_ganaderos_viewmodel.dart';
import '../../widgets/rancho_modal.dart';
import 'perfil_components.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<PerfilViewModel>().cargarPerfil();
      final vm = context.read<PerfilViewModel>();
      if (mounted && !vm.tieneRancho && vm.usuario.role == 'dueno') {
        final joined = await mostrarRanchoModal(context, initialTab: 1);
        if (joined && mounted) vm.cargarPerfil();
      }
    });
  }

  Future<void> _mostrarVetGanadero(BuildContext context) async {
    List<VeterinarioInfo> vets = [];
    String? errorMsg;

    try {
      final res = await ApiClient.instance
          .get(ApiConstants.veterinariosGanadero);
      final data = res.data as Map<String, dynamic>;
      final lista = data['veterinarios'] as List? ?? [];
      vets = lista
          .map((e) => VeterinarioInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      errorMsg = 'No disponible';
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _VetGanaderoSheet(vets: vets, error: errorMsg),
    );
  }

  void _mostrarLogoutModal(BuildContext context) {
    final vm = context.read<PerfilViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: Consumer<PerfilViewModel>(
          builder: (ctx, vm, _) => PerfilLogoutModal(
            nombreUsuario: vm.usuario.name,
            email: vm.usuario.email,
            isLoading: vm.isLoggingOut,
            onConfirm: () async {
              final ok = await vm.cerrarSesion();
              if (!context.mounted) return;
              Navigator.of(ctx).pop();
              if (ok) {
                context.go(AppRoutes.login);
              } else {
                final cs = Theme.of(context).colorScheme;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.error ?? 'Error al cerrar sesión'),
                    backgroundColor: cs.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            onCancel: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PerfilViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF0E6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.home),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: Color(0xFF3d2b1f), size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Mi perfil',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3d2b1f),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.editarPerfil).then((_) {
              if (mounted) context.read<PerfilViewModel>().cargarPerfil();
            }),
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF3d2b1f), width: 1.5),
              ),
              child: Text(
                '✏️ Editar',
                style: tt.labelSmall?.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3d2b1f),
                ),
              ),
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                PerfilHeroCard(
                  iniciales: vm.iniciales,
                  nombre: vm.usuario.name,
                  email: vm.usuario.email,
                  plan: vm.plan,
                  onEditarPerfil: () => context.push(AppRoutes.editarPerfil).then((_) {
                    if (mounted) context.read<PerfilViewModel>().cargarPerfil();
                  }),
                ),
                PerfilRanchoCard(
                  nombre: vm.rancho.nombre,
                  municipio: vm.rancho.municipio,
                  estado: vm.rancho.estado,
                  duenoNombre: vm.rancho.duenoNombre,
                  totalBovinos: vm.totalBovinos,
                  ganaderosBtnLabel: 'Ver ganaderos del rancho',
                  isDueno: vm.usuario.role == 'dueno',
                  onUnirseRancho: (!vm.tieneRancho && vm.usuario.role != 'dueno')
                      ? () async {
                          final ok = await mostrarRanchoModal(context);
                          if (ok && context.mounted) {
                            context.read<PerfilViewModel>().cargarPerfil();
                          }
                        }
                      : null,
                  onCrearRancho: (!vm.tieneRancho && vm.usuario.role == 'dueno')
                      ? () async {
                          final ok = await mostrarRanchoModal(context, initialTab: 1);
                          if (ok && context.mounted) {
                            context.read<PerfilViewModel>().cargarPerfil();
                          }
                        }
                      : null,
                  onMisGanaderos: (vm.tieneRancho && vm.usuario.role == 'dueno')
                      ? () => context.push(AppRoutes.misGanaderos)
                      : null,
                  onVerColegas: (vm.tieneRancho && vm.usuario.role != 'dueno')
                      ? () => context.push(AppRoutes.colegas)
                      : null,
                ),

                // ── Cuenta ────────────────────────────────────────────────────
                PerfilSection(
                  label: 'Cuenta',
                  children: [
                    PerfilSettingRow(
                      icon: SettingIcon(emoji: '👤', bg: cs.surfaceContainerLow),
                      name: 'Nombre completo',
                      desc: vm.usuario.name,
                      showChevron: false,
                      accentColor: const Color(0xFF185FA5),
                    ),
                    PerfilSettingRow(
                      icon: SettingIcon(emoji: '✉️', bg: cs.surfaceContainerLow),
                      name: 'Correo electrónico',
                      desc: vm.usuario.email,
                      showChevron: false,
                      accentColor: const Color(0xFF3B6D11),
                    ),
                    PerfilSettingRow(
                      icon: SettingIcon(emoji: '🔑', bg: cs.surfaceContainerLow),
                      name: 'Cambiar contraseña',
                      desc: 'Toca para actualizar tu contraseña',
                      accentColor: const Color(0xFFD85A30),
                      onTap: () => context.push(AppRoutes.cambiarContrasena),
                    ),
                  ],
                ),

                // ── Mi rancho ─────────────────────────────────────────────────
                PerfilSection(
                  label: 'Mi rancho',
                  children: [
                    PerfilSettingRow(
                      icon: SettingIcon(emoji: '🏡', bg: cs.primaryContainer),
                      name: 'Nombre del rancho',
                      desc: vm.rancho.nombre,
                      showChevron: vm.usuario.role == 'dueno',
                      accentColor: const Color(0xFF5C3820),
                      onTap: vm.usuario.role == 'dueno'
                          ? () {
                              final r = vm.rancho;
                              context.push(
                                AppRoutes.editarRancho,
                                extra: RanchoInfo(
                                  id: r.id,
                                  nombre: r.nombre,
                                  municipio: r.municipio,
                                  estado: r.estado,
                                  codigoInvitacion: '',
                                ),
                              ).then((_) {
                                if (mounted) {
                                  context.read<PerfilViewModel>().cargarPerfil();
                                }
                              });
                            }
                          : null,
                    ),
                    PerfilSettingRow(
                      icon: SettingIcon(emoji: '📍', bg: cs.primaryContainer),
                      name: 'Municipio y estado',
                      desc: '${vm.rancho.municipio}, ${vm.rancho.estado}',
                      showChevron: vm.usuario.role == 'dueno',
                      accentColor: const Color(0xFF5C3820),
                      onTap: vm.usuario.role == 'dueno'
                          ? () {
                              final r = vm.rancho;
                              context.push(
                                AppRoutes.editarRancho,
                                extra: RanchoInfo(
                                  id: r.id,
                                  nombre: r.nombre,
                                  municipio: r.municipio,
                                  estado: r.estado,
                                  codigoInvitacion: '',
                                ),
                              ).then((_) {
                                if (mounted) {
                                  context.read<PerfilViewModel>().cargarPerfil();
                                }
                              });
                            }
                          : null,
                    ),
                  ],
                ),

                // ── Veterinario ───────────────────────────────────────────────
                PerfilSection(
                  label: 'Veterinario',
                  children: [
                    PerfilSettingRow(
                      icon: SettingIcon(emoji: '🩺', bg: cs.tertiaryContainer),
                      name: 'Veterinarios del rancho',
                      desc: vm.usuario.role == 'dueno'
                          ? 'Agregar, editar o eliminar veterinarios'
                          : 'Ver teléfono del veterinario',
                      trailingValue: vm.usuario.role == 'dueno'
                          ? 'Gestionar'
                          : 'Ver',
                      accentColor: const Color(0xFF1A6B5A),
                      onTap: vm.usuario.role == 'dueno'
                          ? () => context.push(AppRoutes.veterinarios)
                          : () => _mostrarVetGanadero(context),
                    ),
                  ],
                ),

                // ── Suscripción (solo dueño) ──────────────────────────────────
                if (vm.usuario.role == 'dueno')
                  PerfilSection(
                    label: 'Suscripción',
                    children: [
                      PerfilSettingRow(
                        icon: SettingIcon(emoji: '💳', bg: cs.secondaryContainer),
                        name: 'Mi plan',
                        desc: '${vm.plan} · Activo',
                        trailingValue: 'Ver planes',
                        accentColor: const Color(0xFF5C3820),
                        onTap: () => context.push(AppRoutes.miPlan),
                      ),
                    ],
                  ),

                // ── Sesión ────────────────────────────────────────────────────
                PerfilSection(
                  label: 'Sesión',
                  children: [
                    PerfilSettingRow(
                      icon: SettingIcon(emoji: '🚪', bg: cs.errorContainer),
                      name: 'Cerrar sesión',
                      desc: '${vm.usuario.name} · ${vm.usuario.email}',
                      isDanger: true,
                      accentColor: cs.error,
                      onTap: () => _mostrarLogoutModal(context),
                    ),
                  ],
                ),

                const PerfilVersionText(),
              ],
            ),
    );
  }
}

class _LastRow extends StatelessWidget {
  final Widget child;
  const _LastRow({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(),
      child: child,
    );
  }
}

// ── Bottom sheet read-only para ganadero ─────────────────────────────────────

class _VetGanaderoSheet extends StatelessWidget {
  final List<VeterinarioInfo> vets;
  final String? error;

  const _VetGanaderoSheet({required this.vets, this.error});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
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
          Row(
            children: [
              const Text('🩺', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Veterinario del rancho',
                style: tt.titleMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (error != null)
            Text(
              error!,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            )
          else if (vets.isEmpty)
            Text(
              'El dueño del rancho aún no ha registrado un veterinario.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            )
          else
            ...vets.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.nombre,
                          style: tt.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        if (v.lugar.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            v.lugar,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: cs.tertiaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_outlined,
                                  color: cs.tertiary, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                v.telefono,
                                style: tt.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: cs.tertiary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (v.ubicacion.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: cs.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  v.ubicacion,
                                  style: tt.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
