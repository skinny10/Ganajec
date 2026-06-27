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
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kGreenLight = Color(0xFFE8F5EF);
  static const _kRedLight = Color(0xFFFDEDEC);
  static const _kCream = Color(0xFFF5F3EE);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<PerfilViewModel>().cargarPerfil();
      // Modal automático si el ganadero no tiene rancho
      if (mounted && !context.read<PerfilViewModel>().tieneRancho) {
        final joined = await mostrarRanchoModal(context);
        if (joined && mounted) {
          // Recarga el perfil para mostrar el rancho nuevo
          context.read<PerfilViewModel>().cargarPerfil();
        }
      }
    });
  }

  /// Bottom sheet read-only para ganadero: muestra teléfono del vet.
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.error ?? 'Error al cerrar sesión'),
                    backgroundColor: const Color(0xFFC0392B),
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
    final notif = vm.notificaciones;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: _kTextPrimary,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.editarPerfil).then((_) {
              // Recarga perfil tras editar (el nombre puede haber cambiado)
              if (mounted) context.read<PerfilViewModel>().cargarPerfil();
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
              child: Text(
                'Editar',
                style: TextStyle(
                  fontSize: 12,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: _kBorder,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              children: [
                // ── Hero ─────────────────────────────────────────────────────
                PerfilHeroCard(
                  iniciales: vm.iniciales,
                  nombre: vm.usuario.name,
                  email: vm.usuario.email,
                  plan: vm.plan,
                  onEditarPerfil: () => context
                      .push(AppRoutes.editarPerfil)
                      .then((_) {
                    if (mounted) context.read<PerfilViewModel>().cargarPerfil();
                  }),
                ),

                // ── Rancho ───────────────────────────────────────────────────
                PerfilRanchoCard(
                  nombre: vm.rancho.nombre,
                  municipio: vm.rancho.municipio,
                  estado: vm.rancho.estado,
                  duenoNombre: vm.rancho.duenoNombre,
                  totalBovinos: vm.totalBovinos,
                  ganaderosBtnLabel: 'Ver ganaderos del rancho',
                  onUnirseRancho: !vm.tieneRancho
                      ? () async {
                          final ok = await mostrarRanchoModal(context);
                          if (ok && context.mounted) {
                            context.read<PerfilViewModel>().cargarPerfil();
                          }
                        }
                      : null,
                  // Dueño → mis ganaderos | Ganadero → colegas del rancho
                  onMisGanaderos: (vm.tieneRancho && vm.usuario.role == 'dueno')
                      ? () => context.push(AppRoutes.misGanaderos)
                      : null,
                  onVerColegas: (vm.tieneRancho && vm.usuario.role != 'dueno')
                      ? () => context.push(AppRoutes.colegas)
                      : null,
                ),

                // ── Cuenta ───────────────────────────────────────────────────
                PerfilSection(
                  label: 'Cuenta',
                  children: [
                    PerfilSettingRow(
                      icon: const SettingIcon(emoji: '👤', bg: Color(0xFFF5F3EE)),
                      name: 'Nombre completo',
                      desc: vm.usuario.name,
                      showChevron: false,
                    ),
                    PerfilSettingRow(
                      icon: const SettingIcon(emoji: '✉️', bg: Color(0xFFF5F3EE)),
                      name: 'Correo electrónico',
                      desc: vm.usuario.email,
                      showChevron: false,
                    ),
                    _LastRow(
                      child: PerfilSettingRow(
                        icon: const SettingIcon(emoji: '🔑', bg: Color(0xFFF5F3EE)),
                        name: 'Cambiar contraseña',
                        desc: 'Toca para actualizar tu contraseña',
                        onTap: () => context.push(AppRoutes.cambiarContrasena),
                      ),
                    ),
                  ],
                ),

                // ── Mi rancho ─────────────────────────────────────────────────
                PerfilSection(
                  label: 'Mi rancho',
                  children: [
                    PerfilSettingRow(
                      icon: const SettingIcon(emoji: '🏡', bg: Color(0xFFFEF9E7)),
                      name: 'Nombre del rancho',
                      desc: vm.rancho.nombre,
                      showChevron: vm.usuario.role == 'dueno',
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
                    _LastRow(
                      child: PerfilSettingRow(
                        icon: const SettingIcon(emoji: '📍', bg: Color(0xFFFEF9E7)),
                        name: 'Municipio y estado',
                        desc: '${vm.rancho.municipio}, ${vm.rancho.estado}',
                        showChevron: vm.usuario.role == 'dueno',
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
                    ),
                  ],
                ),

                // ── Veterinario ───────────────────────────────────────────────
                PerfilSection(
                  label: 'Veterinario',
                  children: [
                    _LastRow(
                      child: PerfilSettingRow(
                        icon: const SettingIcon(
                            emoji: '🩺', bg: Color(0xFFE8F5EF)),
                        name: 'Veterinarios del rancho',
                        desc: vm.usuario.role == 'dueno'
                            ? 'Agregar, editar o eliminar veterinarios'
                            : 'Ver teléfono del veterinario',
                        trailingValue: vm.usuario.role == 'dueno'
                            ? 'Gestionar'
                            : 'Ver',
                        onTap: vm.usuario.role == 'dueno'
                            ? () => context.push(AppRoutes.veterinarios)
                            : () => _mostrarVetGanadero(context),
                      ),
                    ),
                  ],
                ),

                // ── Notificaciones ────────────────────────────────────────────
                PerfilSection(
                  label: 'Notificaciones',
                  children: [
                    PerfilToggleRow(
                      icon: const SettingIcon(emoji: '🔔', bg: Color(0xFFE8F5EF)),
                      name: 'Alertas de predicción',
                      desc: 'Cuando se detecta una enfermedad',
                      value: notif.alertasPrediccion,
                      onChanged: (_) => context.read<PerfilViewModel>().toggleAlertasPrediccion(),
                    ),
                    PerfilToggleRow(
                      icon: const SettingIcon(emoji: '📉', bg: Color(0xFFE8F5EF)),
                      name: 'Anomalías productivas',
                      desc: 'Caídas detectadas por Isolation Forest',
                      value: notif.anomaliasProductivas,
                      onChanged: (_) => context.read<PerfilViewModel>().toggleAnomaliasProductivas(),
                    ),
                    PerfilToggleRow(
                      icon: const SettingIcon(emoji: '📊', bg: Color(0xFFF5F3EE)),
                      name: 'Resumen semanal',
                      desc: 'Reporte de producción cada lunes',
                      value: notif.resumenSemanal,
                      onChanged: (_) => context.read<PerfilViewModel>().toggleResumenSemanal(),
                      isLast: true,
                    ),
                  ],
                ),

                // ── Suscripción ───────────────────────────────────────────────
                PerfilSection(
                  label: 'Suscripción',
                  children: [
                    _LastRow(
                      child: PerfilSettingRow(
                        icon: const SettingIcon(emoji: '💳', bg: Color(0xFFEEF2FF)),
                        name: 'Mi plan',
                        desc: '${vm.plan} · Activo',
                        trailingValue: 'Ver planes',
                        onTap: () => context.push(AppRoutes.miPlan),
                      ),
                    ),
                  ],
                ),

                // ── Legal ─────────────────────────────────────────────────────
                PerfilSection(
                  label: 'Legal',
                  children: [
                    _LastRow(
                      child: PerfilSettingRow(
                        icon: const SettingIcon(emoji: '📄', bg: Color(0xFFF5F3EE)),
                        name: 'Política de Privacidad',
                        desc: 'Cómo manejamos tus datos',
                        onTap: () => context.push(AppRoutes.politicaPrivacidad),
                      ),
                    ),
                  ],
                ),

                // ── Sesión ────────────────────────────────────────────────────
                PerfilSection(
                  label: 'Sesión',
                  children: [
                    _LastRow(
                      child: PerfilSettingRow(
                        icon: const SettingIcon(emoji: '🚪', bg: Color(0xFFFDEDEC)),
                        name: 'Cerrar sesión',
                        desc: '${vm.usuario.name} · ${vm.usuario.email}',
                        isDanger: true,
                        onTap: () => _mostrarLogoutModal(context),
                      ),
                    ),
                  ],
                ),

                // ── Versión ───────────────────────────────────────────────────
                const PerfilVersionText(),
              ],
            ),
    );
  }
}

/// Elimina el border-bottom del último elemento de la card
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5DC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Text('🩺', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Veterinario del rancho',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (error != null)
            Text(
              error!,
              style: const TextStyle(color: Color(0xFF888880), fontSize: 14),
            )
          else if (vets.isEmpty)
            const Text(
              'El dueño del rancho aún no ha registrado un veterinario.',
              style: TextStyle(color: Color(0xFF888880), fontSize: 14),
            )
          else
            ...vets.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8E5DC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (v.lugar.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            v.lugar,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF888880)),
                          ),
                        ],
                        const SizedBox(height: 10),
                        // Teléfono destacado
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone_outlined,
                                  color: Color(0xFF2E7D32), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                v.telefono,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
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
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Color(0xFF888880)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  v.ubicacion,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF888880)),
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
