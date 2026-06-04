import 'package:flutter/material.dart';

import 'color_chip.dart';
import 'info_tile.dart';

class ControlsPanel extends StatelessWidget {
  const ControlsPanel({
    super.key,
    required this.theme,
    required this.palette,
    required this.selectedColor,
    required this.eraseMode,
    required this.filledCount,
    required this.onPickColor,
    required this.onPickEraser,
    required this.onClearAll,
    required this.columns,
    required this.rows,
    required this.zoomLevel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  final ThemeData theme;
  final List<Color> palette;
  final Color? selectedColor;
  final bool eraseMode;
  final int filledCount;
  final int columns;
  final int rows;
  final double zoomLevel;
  final ValueChanged<Color> onPickColor;
  final VoidCallback onPickEraser;
  final VoidCallback onClearAll;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    final totalCells = columns * rows;

    return Card(
      elevation: 0,
      color: const Color(0xFFF9F5EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Thai Silk',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF16302D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ตาราง 84 x 57 ช่อง, ช่องละ 1 x 1 cm',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5D625D),
              ),
            ),
            const SizedBox(height: 16),
            InfoTile(
              label: 'ช่องที่ลงสีแล้ว',
              value: '$filledCount / $totalCells',
            ),
            const SizedBox(height: 14),
            Text(
              'สี',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in palette)
                  ColorChip(
                    color: color,
                    selected: !eraseMode && selectedColor == color,
                    onTap: () => onPickColor(color),
                  ),
                ColorChip(
                  color: Colors.white,
                  selected: eraseMode,
                  onTap: onPickEraser,
                  isEraser: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'ซูมกระดาษ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: onZoomOut,
                  icon: const Icon(Icons.remove),
                  tooltip: 'ย่อ',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3EF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${(zoomLevel * 100).round()}%',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: onZoomIn,
                  icon: const Icon(Icons.add),
                  tooltip: 'ขยาย',
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onResetZoom,
                child: const Text('รีเซ็ตซูม'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onClearAll,
              icon: const Icon(Icons.delete_outline),
              label: const Text('ล้างทั้งตาราง'),
            ),
            const SizedBox(height: 12),
            Text(
              'แตะช่องบนตารางเพื่อใส่สี และเลือกยางลบเพื่อลบสีในแต่ละช่อง',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5D625D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
