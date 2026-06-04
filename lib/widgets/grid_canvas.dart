import 'package:flutter/material.dart';

import 'grid_painter.dart';

class GridCanvas extends StatelessWidget {
  const GridCanvas({
    super.key,
    required this.size,
    required this.cells,
    required this.cellSize,
    required this.pageMargin,
    required this.zoomLevel,
    required this.onTapDown,
    required this.onDragUpdate,
  });

  final Size size;
  final List<List<Color?>> cells;
  final double cellSize;
  final double pageMargin;
  final double zoomLevel;
  final ValueChanged<Offset> onTapDown;
  final ValueChanged<Offset> onDragUpdate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => onTapDown(
            (details.localPosition / zoomLevel) -
                Offset(pageMargin, pageMargin),
          ),
          onPanStart: (details) => onDragUpdate(
            (details.localPosition / zoomLevel) -
                Offset(pageMargin, pageMargin),
          ),
          onPanUpdate: (details) => onDragUpdate(
            (details.localPosition / zoomLevel) -
                Offset(pageMargin, pageMargin),
          ),
          child: CustomPaint(
            size: size,
            painter: GridPainter(
              cells: cells,
              cellSize: cellSize,
              pageMargin: pageMargin,
              zoomLevel: zoomLevel,
            ),
          ),
        ),
      ),
    );
  }
}
