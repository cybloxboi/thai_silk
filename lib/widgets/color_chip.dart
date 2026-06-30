import 'package:flutter/material.dart';

class ColorChip extends StatelessWidget {
  const ColorChip({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
    this.isEraser = false,
    this.diameter = 44,
    this.showSelectionCheck = true,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool isEraser;
  final double diameter;
  final bool showSelectionCheck;

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
        width: diameter,
        height: diameter,
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isEraser)
              const Icon(Icons.delete_outline_rounded, color: Color(0xFF374151)),
            if (selected && showSelectionCheck)
              Positioned(
                right: diameter * 0.06,
                top: diameter * 0.06,
                child: Container(
                  width: diameter * 0.32,
                  height: diameter * 0.32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F766E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
