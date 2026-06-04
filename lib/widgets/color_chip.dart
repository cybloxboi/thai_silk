import 'package:flutter/material.dart';

class ColorChip extends StatelessWidget {
  const ColorChip({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    this.isEraser = false,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool isEraser;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF0F766E)
        : const Color(0xFFD6D0C5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isEraser ? const Color(0xFFF7F2E8) : color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: selected ? 3 : 1.2),
          boxShadow: [
            BoxShadow(
              blurRadius: selected ? 12 : 6,
              offset: const Offset(0, 3),
              color: const Color(0x14000000),
            ),
          ],
        ),
        child: isEraser
            ? const Icon(Icons.delete_outline_rounded, color: Color(0xFF374151))
            : null,
      ),
    );
  }
}
