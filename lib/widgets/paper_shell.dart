import 'package:flutter/material.dart';

class PaperShell extends StatelessWidget {
  const PaperShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : const Color(0xFFFAE5E6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: isDark ? 18 : 30,
            offset: const Offset(0, 18),
            color: isDark
                ? Colors.black.withValues(alpha: 0.34)
                : const Color(0x22000000),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerLow : Colors.white,
              border: Border.all(
                color: isDark
                    ? colorScheme.outlineVariant
                    : const Color(0xFFFDA1A5),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
