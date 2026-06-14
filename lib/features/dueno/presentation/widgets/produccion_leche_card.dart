import 'package:flutter/material.dart';

class ProduccionLecheCard extends StatelessWidget {
  final double litrosHoy;
  final double porcentajeCambio;

  const ProduccionLecheCard({
    super.key,
    required this.litrosHoy,
    required this.porcentajeCambio,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final esPositivo = porcentajeCambio >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.water_drop_outlined,
                  color: Color(0xFF805611)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (esPositivo ? const Color(0xFF4CAF50) : colors.error)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${esPositivo ? '+' : ''}${porcentajeCambio.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        esPositivo ? const Color(0xFF4CAF50) : colors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${litrosHoy.toStringAsFixed(0)} L',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          Text(
            'Producci\u00f3n total hoy',
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          _buildSegmentedBar(),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Normal',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                'Buena',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                'Anomal\u00edas',
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedBar() {
    const total = 200.0;
    final normal = (80 / total).clamp(0.0, 1.0);
    final buena = ((140 - 80) / total).clamp(0.0, 1.0);
    final anomalia = ((total - 140) / total).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            Expanded(
              flex: (normal * 100).toInt().clamp(1, 100),
              child: Container(color: const Color(0xFF4CAF50)),
            ),
            Expanded(
              flex: (buena * 100).toInt().clamp(1, 100),
              child: Container(color: const Color(0xFFF9A825)),
            ),
            Expanded(
              flex: (anomalia * 100).toInt().clamp(1, 100),
              child: Container(color: const Color(0xFFBA1A1A)),
            ),
          ],
        ),
      ),
    );
  }
}
