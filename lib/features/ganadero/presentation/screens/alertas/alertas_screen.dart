import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';
import '../../viewmodels/alertas_viewmodel.dart';
import 'alertas_components.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AlertasViewModel>().cargar());
  }

  void _handleAccion(BuildContext context, Alerta alerta) {
    // Marcar como leída
    context.read<AlertasViewModel>().marcarLeida(alerta.id);

    switch (alerta.accion) {
      case AlertaAccion.verDetalle:
        // Si tuviéramos el Animal cargado navegaríamos con extra:
        // Por ahora va a home (en implementación real buscaríamos el animal)
        context.go(AppRoutes.home);
        break;
      case AlertaAccion.verResultado:
        context.go(AppRoutes.home);
        break;
      case AlertaAccion.ninguna:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AlertasViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.chevron_left,
                color: _kTextPrimary, size: 20),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (vm.unreadCount > 0)
            GestureDetector(
              onTap: () => context.read<AlertasViewModel>().marcarTodasLeidas(),
              child: Container(
                margin: const EdgeInsets.only(right: 18),
                child: const Text(
                  'Marcar leídas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888880),
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFE8E5DC),
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
          : vm.status == AlertasStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar alertas',
                  onRetry: () => context.read<AlertasViewModel>().cargar(),
                )
              : _buildList(vm),
    );
  }

  Widget _buildList(AlertasViewModel vm) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Barra resumen
        AlertasSummaryBar(unreadCount: vm.unreadCount),

        // Grupos
        ...vm.grupos.map((grupo) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlertasDateLabel(titulo: grupo.titulo),
                  ...grupo.alertas.map((alerta) => AlertaCard(
                        key: ValueKey(alerta.id),
                        alerta: alerta,
                        onTap: () {
                          context.read<AlertasViewModel>().marcarLeida(alerta.id);
                        },
                        onAccion: alerta.accion != AlertaAccion.ninguna
                            ? () => _handleAccion(context, alerta)
                            : null,
                      )),
                  const SizedBox(height: 4),
                ],
              ),
            )),

        if (vm.grupos.isEmpty)
          const _EmptyView(),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'Toca cualquier notificación para marcarla como leída',
              style: TextStyle(
                fontSize: 10.5,
                color: _kTextMuted,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFC0392B), size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF888880))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Text('🔕', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Aquí aparecerán las alertas de predicciones, anomalías productivas y actualizaciones del sistema.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888880),
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
