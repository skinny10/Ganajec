import 'package:flutter/material.dart';

class AlertaCriticaBanner extends StatelessWidget {
  final int totalCriticos;
  final String descripcion;
  final VoidCallback onTap;

  const AlertaCriticaBanner({
    super.key,
    required this.totalCriticos,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFBA1A1A), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalCriticos casos cr\u00edticos requieren atenci\u00f3n',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFFBA1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBA1A1A), size: 20),
          ],
        ),
      ),
    );
  }
}
