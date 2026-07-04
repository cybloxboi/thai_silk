import 'package:flutter/material.dart';

import '../models/pattern_selection.dart';
import 'grid_painter.dart';

class GridCanvas extends StatefulWidget {
  const GridCanvas({
    super.key,
    required this.baseSize,
    required this.cells,
    this.selection,
    required this.cellSize,
    required this.pageMargin,
    required this.zoomLevel,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomChanged,
    required this.onTapDown,
    required this.onInteractionEnd,
    required this.onDragStart,
    required this.onDragUpdate,
  });

  final Size baseSize;
  final List<List<Color?>> cells;
  final PatternSelection? selection;
  final double cellSize;
  final double pageMargin;
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<Offset> onTapDown;
  final VoidCallback onInteractionEnd;
  final ValueChanged<Offset> onDragStart;
  final ValueChanged<Offset> onDragUpdate;

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

class _GridCanvasState extends State<GridCanvas> {
  late final TransformationController _transformationController;
  bool _syncingTransformation = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_handleTransformationChanged);
    _syncTransformationToZoom(widget.zoomLevel);
  }

  @override
  void didUpdateWidget(covariant GridCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.zoomLevel - widget.zoomLevel).abs() >= 0.001) {
      _syncTransformationToZoom(widget.zoomLevel);
    }
  }

  void _syncTransformationToZoom(double nextZoom) {
    final clampedZoom = nextZoom
        .clamp(widget.minZoom, widget.maxZoom)
        .toDouble();
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if ((clampedZoom - currentScale).abs() < 0.001) {
      return;
    }

    final currentTranslation = _transformationController.value.getTranslation();
    _syncingTransformation = true;
    try {
      _transformationController.value = Matrix4.identity()
        ..setEntry(0, 0, clampedZoom)
        ..setEntry(1, 1, clampedZoom)
        ..setEntry(2, 2, 1)
        ..setTranslationRaw(currentTranslation.x, currentTranslation.y, 0);
    } finally {
      _syncingTransformation = false;
    }
  }

  void _handleTransformationChanged() {
    if (_syncingTransformation || !mounted) {
      return;
    }

    final nextZoom = _transformationController.value.getMaxScaleOnAxis();
    final clampedZoom = nextZoom
        .clamp(widget.minZoom, widget.maxZoom)
        .toDouble();
    if ((clampedZoom - widget.zoomLevel).abs() < 0.001) {
      return;
    }

    widget.onZoomChanged(clampedZoom);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_handleTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  Offset _gridLocalPosition(Offset localPosition) {
    return localPosition - Offset(widget.pageMargin, widget.pageMargin);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: widget.minZoom,
      maxScale: widget.maxZoom,
      panEnabled: true,
      scaleEnabled: true,
      constrained: false,
      alignment: Alignment.topLeft,
      boundaryMargin: const EdgeInsets.all(0),
      onInteractionEnd: (_) => widget.onInteractionEnd(),
      child: SizedBox(
        width: widget.baseSize.width,
        height: widget.baseSize.height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) =>
              widget.onTapDown(_gridLocalPosition(details.localPosition)),
          onTapUp: (_) => widget.onInteractionEnd(),
          onTapCancel: widget.onInteractionEnd,
          onPanStart: (details) =>
              widget.onDragStart(_gridLocalPosition(details.localPosition)),
          onPanUpdate: (details) =>
              widget.onDragUpdate(_gridLocalPosition(details.localPosition)),
          onPanEnd: (_) => widget.onInteractionEnd(),
          child: CustomPaint(
            size: widget.baseSize,
            painter: GridPainter(
              cells: widget.cells,
              cellSize: widget.cellSize,
              pageMargin: widget.pageMargin,
              zoomLevel: 1.0,
              selection: widget.selection,
              backgroundColor: isDark
                  ? colorScheme.surfaceContainerHighest
                  : const Color(0xFFFCFBF7),
              paperColor: isDark
                  ? colorScheme.surfaceContainerLowest
                  : Colors.white,
              labelColor: colorScheme.onSurfaceVariant,
              guideColor: isDark
                  ? colorScheme.outlineVariant.withValues(alpha: 0.64)
                  : const Color(0xFFE4DDD1),
              borderColor: isDark
                  ? colorScheme.outline
                  : const Color(0xFFB8AB95),
              selectionColor: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
