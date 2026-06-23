import 'package:flutter/material.dart';

import '../models/pattern_selection.dart';

class GridPainter extends CustomPainter {
  const GridPainter({
    required this.cells,
    required this.cellSize,
    required this.pageMargin,
    required this.zoomLevel,
    this.selection,
  });

  final List<List<Color?>> cells;
  final double cellSize;
  final double pageMargin;
  final double zoomLevel;
  final PatternSelection? selection;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFFCFBF7);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final scaledCellSize = cellSize * zoomLevel;
    final scaledMargin = pageMargin * zoomLevel;
    final gridWidth = cells.first.length * scaledCellSize;
    final gridHeight = cells.length * scaledCellSize;
    final gridOrigin = Offset(scaledMargin, scaledMargin);

    final paperPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(scaledMargin, scaledMargin, gridWidth, gridHeight),
      paperPaint,
    );

    final labelStyle = TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: 9 * zoomLevel,
      fontWeight: FontWeight.w600,
    );
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (var column = 0; column < cells.first.length; column++) {
      labelPainter.text = TextSpan(text: '${column + 1}', style: labelStyle);
      labelPainter.layout(minWidth: 0, maxWidth: scaledCellSize);
      final labelX =
          scaledMargin +
          column * scaledCellSize +
          (scaledCellSize - labelPainter.width) / 2;
      final labelY = scaledMargin - labelPainter.height - (4 * zoomLevel);
      labelPainter.paint(canvas, Offset(labelX, labelY));
    }

    for (var row = 0; row < cells.length; row++) {
      labelPainter.text = TextSpan(text: '${row + 1}', style: labelStyle);
      labelPainter.layout(
        minWidth: 0,
        maxWidth: scaledMargin - (8 * zoomLevel),
      );
      final labelX = scaledMargin - labelPainter.width - (6 * zoomLevel);
      final labelY =
          scaledMargin +
          row * scaledCellSize +
          (scaledCellSize - labelPainter.height) / 2;
      labelPainter.paint(canvas, Offset(labelX, labelY));
    }

    final rowPaint = Paint()..style = PaintingStyle.fill;
    for (var row = 0; row < cells.length; row++) {
      for (var column = 0; column < cells[row].length; column++) {
        final color = cells[row][column];
        if (color == null) {
          continue;
        }
        rowPaint.color = color;
        canvas.drawRect(
          Rect.fromLTWH(
            gridOrigin.dx + column * scaledCellSize,
            gridOrigin.dy + row * scaledCellSize,
            scaledCellSize,
            scaledCellSize,
          ),
          rowPaint,
        );
      }
    }

    final normalizedSelection = selection?.normalized();
    if (normalizedSelection != null) {
      final selectionRect = Rect.fromLTWH(
        gridOrigin.dx + normalizedSelection.startColumn * scaledCellSize,
        gridOrigin.dy + normalizedSelection.startRow * scaledCellSize,
        normalizedSelection.width * scaledCellSize,
        normalizedSelection.height * scaledCellSize,
      );

      final selectionFillPaint = Paint()
        ..color = const Color(0x330F766E)
        ..style = PaintingStyle.fill;
      canvas.drawRect(selectionRect, selectionFillPaint);

      final selectionBorderPaint = Paint()
        ..color = const Color(0xFF0F766E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 * zoomLevel;
      canvas.drawRect(
        selectionRect.deflate(0.9 * zoomLevel),
        selectionBorderPaint,
      );
    }

    final guidePaint = Paint()
      ..color = const Color(0xFFE4DDD1)
      ..strokeWidth = 0.6 * zoomLevel;
    for (var column = 0; column <= cells.first.length; column++) {
      final x = gridOrigin.dx + column * scaledCellSize;
      canvas.drawLine(
        Offset(x, gridOrigin.dy),
        Offset(x, gridOrigin.dy + gridHeight),
        guidePaint,
      );
    }
    for (var row = 0; row <= cells.length; row++) {
      final y = gridOrigin.dy + row * scaledCellSize;
      canvas.drawLine(
        Offset(gridOrigin.dx, y),
        Offset(gridOrigin.dx + gridWidth, y),
        guidePaint,
      );
    }

    final borderPaint = Paint()
      ..color = const Color(0xFFB8AB95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4 * zoomLevel;
    canvas.drawRect(
      Rect.fromLTWH(scaledMargin, scaledMargin, gridWidth, gridHeight),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return true;
  }
}
