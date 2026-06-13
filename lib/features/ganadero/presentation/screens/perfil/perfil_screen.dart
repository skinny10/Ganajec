import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../../viewmodels/perfil_viewmodel.dart';
import 'perfil_components.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kGreenLight = Color(0xFFE8F5EF);
  static const _kRedLight = Color(0xFFFDEDEC);
  static const _kCream = Color(0xFFF5F3EE);

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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Editar perfil — próximamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
      body: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 40),
        children: [
          // ── Hero ───────────────────────────────────────────────────────────
          PerfilHeroCard(
            iniciales: vm.iniciales,
            nombre: vm.usuario.name,
            email: vm.usuario.email,
            plan: vm.plan,
          ),

          // ── Rancho ─────────────────────────────────────────────────────────
          PerfilRanchoCard(
            nombre: vm.rancho.nombre,
            municipio: vm.rancho.municipio,
            estado: vm.rancho.estado,
            totalBovinos: vm.totalBovinos,
          ),

          // ── Cuenta ─────────────────────────────────────────────────────────
          PerfilSection(
            label: 'Cuenta',
            children: [
              PerfilSettingRow(
                icon: const SettingIcon(emoji: '👤', bg: Color(0xFFF5F3EE)),
                name: 'Nombre completo',
                desc: vm.usuario.name,
                onTap: () {},
              ),
              PerfilSettingRow(
                icon: const SettingIcon(emoji: '✉️', bg: Color(0xFFF5F3EE)),
                name: 'Correo electrónico',
                desc: vm.usuario.email,
                onTap: () {},
              ),
              _LastRow(
                child: PerfilSettingRow(
                  icon: const SettingIcon(emoji: '🔑', bg: Color(0xFFF5F3EE)),
                  name: 'Cambiar contraseña',
                  desc: 'Última actualización: hace 3 meses',
                  onTap: () {},
                ),
              ),
            ],
          ),

          // ── Mi rancho ──────────────────────────────────────────────────────
          PerfilSection(
            label: 'Mi rancho',
            children: [
              PerfilSettingRow(
                icon: const SettingIcon(emoji: '🏡', bg: Color(0xFFFEF9E7)),
                name: 'Nombre del rancho',
                desc: vm.rancho.nombre,
                onTap: () {},
              ),
              _LastRow(
                child: PerfilSettingRow(
                  icon: const SettingIcon(emoji: '📍', bg: Color(0xFFFEF9E7)),
                  name: 'Municipio y estado',
                  desc: '${vm.rancho.municipio}, ${vm.rancho.estado}',
                  onTap: () {},
                ),
              ),
            ],
          ),

          // ── Notificaciones ─────────────────────────────────────────────────
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

          // ── Suscripción ────────────────────────────────────────────────────
          PerfilSection(
            label: 'Suscripción',
            children: [
              _LastRow(
                child: PerfilSettingRow(
                  icon: const SettingIcon(emoji: '💳', bg: Color(0xFFEEF2FF)),
                  name: 'Mi plan',
                  desc: '${vm.plan} · Activo',
                  trailingValue: 'Ver planes',
                  onTap: () {},
                ),
              ),
            ],
          ),

          // ── Sesión ─────────────────────────────────────────────────────────
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

          // ── Versión ────────────────────────────────────────────────────────
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
