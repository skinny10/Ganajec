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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AlertasViewModel>().cargar());
  }

  void _handleAccion(BuildContext context, Alerta alerta) {
    context.read<AlertasViewModel>().marcarLeida(alerta.id);

    switch (alerta.accion) {
      case AlertaAccion.verDetalle:
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<AlertasViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
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
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left,
                color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Notificaciones',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (vm.unreadCount > 0)
            GestureDetector(
              onTap: () =>
                  context.read<AlertasViewModel>().marcarTodasLeidas(),
              child: Container(
                margin: const EdgeInsets.only(right: 18),
                child: Text(
                  'Marcar leídas',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                    decorationColor: cs.outlineVariant,
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.status == AlertasStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar alertas',
                  onRetry: () => context.read<AlertasViewModel>().cargar(),
                )
              : _buildList(context, vm),
    );
  }

  Widget _buildList(BuildContext context, AlertasViewModel vm) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        AlertasSummaryBar(unreadCount: vm.unreadCount),

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
                          context
                              .read<AlertasViewModel>()
                              .marcarLeida(alerta.id);
                        },
                        onAccion: alerta.accion != AlertaAccion.ninguna
                            ? () => _handleAccion(context, alerta)
                            : null,
                      )),
                  const SizedBox(height: 4),
                ],
              ),
            )),

        if (vm.grupos.isEmpty) const _EmptyView(),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'Toca cualquier notificación para marcarla como leída',
              style: tt.labelSmall?.copyWith(
                fontSize: 10.5,
                color: cs.outline,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: cs.error, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          const Text('🔕', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Sin notificaciones',
            style: tt.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aquí aparecerán las alertas de predicciones, anomalías productivas y actualizaciones del sistema.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              fontSize: 12,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
