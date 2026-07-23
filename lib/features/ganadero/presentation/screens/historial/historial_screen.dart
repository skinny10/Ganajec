import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/share/domain/entities/historial_item.dart';
import '../../viewmodels/historial_viewmodel.dart';
import 'historial_components.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool _generandoPDF = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HistorialViewModel>().cargar());
  }

  void _onCardTap(HistorialItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.enfermedad} · ${item.animalNombre}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ── Generación de PDF ───────────────────────────────────────────────────────
  Future<void> _generarPDF(HistorialViewModel vm) async {
    if (_generandoPDF) return;
    setState(() => _generandoPDF = true);

    try {
      final doc = pw.Document();
      final now = DateTime.now();
      final grupos = vm.grupos;

      String _sevLabel(HistorialSeveridad s) => switch (s) {
            HistorialSeveridad.alta => 'Alta',
            HistorialSeveridad.moderada => 'Moderada',
            HistorialSeveridad.leve => 'Leve',
            HistorialSeveridad.sinEnfermedad => 'Sin enfermedad',
          };

      PdfColor _sevColor(HistorialSeveridad s) => switch (s) {
            HistorialSeveridad.alta => PdfColors.red700,
            HistorialSeveridad.moderada => PdfColors.orange700,
            HistorialSeveridad.leve => PdfColors.green700,
            HistorialSeveridad.sinEnfermedad => PdfColors.grey600,
          };

      PdfColor _sevBg(HistorialSeveridad s) => switch (s) {
            HistorialSeveridad.alta => const PdfColor(1, 0.93, 0.93),
            HistorialSeveridad.moderada => const PdfColor(1, 0.97, 0.90),
            HistorialSeveridad.leve => const PdfColor(0.93, 1, 0.93),
            HistorialSeveridad.sinEnfermedad => const PdfColor(0.96, 0.96, 0.96),
          };

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 48),
          // ── Encabezado fijo en cada página ──────────────────────────────
          header: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GANAJEC AI',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey900,
                        ),
                      ),
                      pw.Text(
                        'Historial de predicciones',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey500),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              // Stats row
              pw.Row(
                children: [
                  _pdfStatBox('Severidad alta', vm.countAlta.toString(),
                      PdfColors.red50, PdfColors.red700),
                  pw.SizedBox(width: 6),
                  _pdfStatBox('Total este mes', vm.countMes.toString(),
                      PdfColors.blue50, PdfColors.blue700),
                  pw.SizedBox(width: 6),
                  _pdfStatBox('Sin enfermedad', vm.countSinEnfermedad.toString(),
                      PdfColors.green50, PdfColors.green700),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 4),
            ],
          ),
          // ── Pie de página ────────────────────────────────────────────────
          footer: (ctx) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey400),
            ),
          ),
          // ── Contenido ────────────────────────────────────────────────────
          build: (_) {
            final widgets = <pw.Widget>[];

            if (grupos.isEmpty) {
              widgets.add(pw.Center(
                child: pw.Text(
                  'No hay predicciones registradas.',
                  style: const pw.TextStyle(color: PdfColors.grey600),
                ),
              ));
              return widgets;
            }

            for (final grupo in grupos) {
              // Título del grupo (Hoy, Ayer, Enero 2026…)
              widgets.add(
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 8, bottom: 4),
                  child: pw.Text(
                    grupo.titulo.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              );

              for (final item in grupo.items) {
                final hora =
                    '${item.fecha.hour.toString().padLeft(2, '0')}:${item.fecha.minute.toString().padLeft(2, '0')}';

                widgets.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 5),
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey200),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // Bloque izquierdo: nombre + animal
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.enfermedad,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey900,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                '${item.animalNombre}  ·  $hora',
                                style: const pw.TextStyle(
                                    fontSize: 9, color: PdfColors.grey600),
                              ),
                            ],
                          ),
                        ),
                        // Bloque derecho: % + severidad
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              '${item.confianzaPct}%',
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: _sevBg(item.severidad),
                                borderRadius: const pw.BorderRadius.all(
                                    pw.Radius.circular(10)),
                              ),
                              child: pw.Text(
                                _sevLabel(item.severidad),
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _sevColor(item.severidad),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return widgets;
          },
        ),
      );

      final bytes = await doc.save();
      final filename =
          'ganajec_historial_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';

      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _generandoPDF = false);
    }
  }

  /// Caja de estadística para el encabezado del PDF
  static pw.Widget _pdfStatBox(
      String label, String value, PdfColor bg, PdfColor fg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold, color: fg)),
          pw.Text(label,
              style: pw.TextStyle(fontSize: 8, color: fg)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<HistorialViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left, color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Historial de predicciones',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // Botón descargar PDF (solo visible cuando hay datos cargados)
          if (!vm.isLoading && vm.status != HistorialStatus.error)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: _generandoPDF ? null : () => _generarPDF(vm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: _generandoPDF
                      ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: cs.onSurface),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.picture_as_pdf_outlined,
                                size: 15, color: cs.onSurface),
                            const SizedBox(width: 5),
                            Text(
                              'PDF',
                              style: tt.labelSmall?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
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
          : vm.status == HistorialStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar el historial',
                  onRetry: () => context.read<HistorialViewModel>().cargar(),
                )
              : _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, HistorialViewModel vm) {
    final grupos = vm.grupos;
    final hasFilters = vm.filtroTipo != HistorialFiltroTipo.todos ||
        vm.animalFiltro != null ||
        vm.busqueda.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              HistorialFilterBar(vm: vm),
              HistorialQuickStats(
                alta: vm.countAlta,
                total: vm.countMes,
                sinEnfermedad: vm.countSinEnfermedad,
              ),
            ],
          ),
        ),

        if (vm.isEmpty)
          SliverToBoxAdapter(
            child: HistorialEmptyState(
              hasFilters: hasFilters,
              onLimpiar: () =>
                  context.read<HistorialViewModel>().limpiarFiltros(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => HistorialDateGroup(
                  grupo: grupos[index],
                  onTap: _onCardTap,
                ),
                childCount: grupos.length,
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
                onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
