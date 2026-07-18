import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor:         cs.onPrimaryContainer,
          disabledBackgroundColor: cs.onPrimaryContainer.withOpacity(0.4),
          foregroundColor:         cs.onPrimary,
          disabledForegroundColor: cs.onPrimary.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
              )
            : Row(
                mainAxisSize:      MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_outlined, size: 16, color: cs.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: tt.labelLarge?.copyWith(
                      fontSize: 15,
                      color:    cs.onPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
