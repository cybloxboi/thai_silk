import 'package:flutter/material.dart';

import '../widgets/grid_canvas.dart';
import '../widgets/control_panel.dart';
import '../widgets/paper_shell.dart';

class GridDesignerPage extends StatefulWidget {
  const GridDesignerPage({super.key});

  @override
  State<GridDesignerPage> createState() => _GridDesignerPageState();
}

class _GridDesignerPageState extends State<GridDesignerPage> {
  static const int columns = 84;
  static const int rows = 57;
  static const double cellSize = 18.0;
  static const double pageMargin = 44.0;
  static const double minZoom = 0.5;
  static const double maxZoom = 2.0;
  static const double zoomStep = 0.1;

  final List<Color> palette = const [
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
    Color(0xFFEAB308),
  ];

  late final List<List<Color?>> cells = List.generate(
    rows,
    (_) => List<Color?>.filled(columns, null),
  );
  late final TransformationController _zoomController;

  Color? selectedColor = const Color(0xFF0F766E);
  bool eraseMode = false;
  double zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _zoomController = TransformationController();
    _zoomController.addListener(_syncZoomLevel);
  }

  @override
  void dispose() {
    _zoomController.removeListener(_syncZoomLevel);
    _zoomController.dispose();
    super.dispose();
  }

  void _syncZoomLevel() {
    final nextZoom = _zoomController.value.getMaxScaleOnAxis();
    if (!mounted || (nextZoom - zoomLevel).abs() < 0.001) {
      return;
    }

    setState(() {
      zoomLevel = nextZoom;
    });
  }

  int get filledCount =>
      cells.fold<int>(0, (total, row) => total + row.whereType<Color>().length);

  void _selectColor(Color? color, {bool erase = false}) {
    setState(() {
      selectedColor = color;
      eraseMode = erase;
    });
  }

  void _clearAll() {
    setState(() {
      for (final row in cells) {
        row.fillRange(0, row.length, null);
      }
    });
  }

  void _setZoom(double value) {
    final clampedZoom = value.clamp(minZoom, maxZoom).toDouble();
    _zoomController.value = Matrix4.identity()
      ..scaleByDouble(clampedZoom, clampedZoom, clampedZoom, 1.0);
  }

  void _zoomIn() => _setZoom(zoomLevel + zoomStep);

  void _zoomOut() => _setZoom(zoomLevel - zoomStep);

  void _resetZoom() => _setZoom(1.0);

  void _paintCellFromLocalPosition(Offset localPosition) {
    final int column = localPosition.dx ~/ cellSize;
    final int row = localPosition.dy ~/ cellSize;

    if (column < 0 || column >= columns || row < 0 || row >= rows) {
      return;
    }

    final Color? paintColor = eraseMode ? null : selectedColor;
    if (cells[row][column] == paintColor) {
      return;
    }

    setState(() {
      cells[row][column] = paintColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gridSize = Size(columns * cellSize, rows * cellSize);
    final canvasSize = Size(
      (gridSize.width + pageMargin * 2) * zoomLevel,
      (gridSize.height + pageMargin * 2) * zoomLevel,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wideLayout = constraints.maxWidth >= 1024;

            final canvas = GridCanvas(
              size: canvasSize,
              cells: cells,
              cellSize: cellSize,
              pageMargin: pageMargin,
              zoomLevel: zoomLevel,
              onTapDown: _paintCellFromLocalPosition,
              onDragUpdate: _paintCellFromLocalPosition,
            );

            final controls = ControlsPanel(
              theme: theme,
              palette: palette,
              selectedColor: selectedColor,
              eraseMode: eraseMode,
              filledCount: filledCount,
              onPickColor: (color) => _selectColor(color),
              onPickEraser: () => _selectColor(null, erase: true),
              onClearAll: _clearAll,
              columns: columns,
              rows: rows,
              zoomLevel: zoomLevel,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onResetZoom: _resetZoom,
            );

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4EFE6), Color(0xFFE7F0EC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: wideLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: PaperShell(child: canvas)),
                          const SizedBox(width: 20),
                          SizedBox(width: 320, child: controls),
                        ],
                      )
                    : Column(
                        children: [
                          controls,
                          const SizedBox(height: 16),
                          Expanded(child: PaperShell(child: canvas)),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
