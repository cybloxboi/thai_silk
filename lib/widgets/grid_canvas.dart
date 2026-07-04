import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../models/pattern_selection.dart';
import 'grid_painter.dart';

class GridCanvas extends StatefulWidget {
  const GridCanvas({
    super.key,
    required this.baseSize,
    required this.cells,
    required this.horizontalController,
    required this.verticalController,
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
  final ScrollController horizontalController;
  final ScrollController verticalController;
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
  double? _scaleStartZoom;

  ScrollPosition? _primaryPosition(ScrollController controller) {
    if (!controller.hasClients) {
      return null;
    }

    for (final position in controller.positions.toList().reversed) {
      if (position.hasContentDimensions) {
        return position;
      }
    }

    return null;
  }

  void _applyZoom(double nextZoom, Offset focalPoint) {
    final clampedZoom = nextZoom
        .clamp(widget.minZoom, widget.maxZoom)
        .toDouble();
    if ((clampedZoom - widget.zoomLevel).abs() < 0.001) {
      return;
    }

    final currentZoom = widget.zoomLevel;
    final currentHorizontalOffset = widget.horizontalController.hasClients
        ? widget.horizontalController.offset
        : 0.0;
    final currentVerticalOffset = widget.verticalController.hasClients
        ? widget.verticalController.offset
        : 0.0;
    final zoomRatio = clampedZoom / currentZoom;

    final targetHorizontalOffset =
        (currentHorizontalOffset + focalPoint.dx) * zoomRatio - focalPoint.dx;
    final targetVerticalOffset =
        (currentVerticalOffset + focalPoint.dy) * zoomRatio - focalPoint.dy;

    widget.onZoomChanged(clampedZoom);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _jumpTo(widget.horizontalController, targetHorizontalOffset);
      _jumpTo(widget.verticalController, targetVerticalOffset);
    });
  }

  void _jumpTo(ScrollController controller, double targetOffset) {
    final position = _primaryPosition(controller);
    if (position == null) {
      return;
    }

    final clampedOffset = targetOffset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    controller.jumpTo(clampedOffset);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _scaleStartZoom = widget.zoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) {
      return;
    }

    final startingZoom = _scaleStartZoom ?? widget.zoomLevel;
    _applyZoom(startingZoom * details.scale, details.localFocalPoint);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    final bool zoomModifierPressed =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!zoomModifierPressed) {
      return;
    }

    final zoomDelta = math.exp(-event.scrollDelta.dy / 250.0);
    _applyZoom(widget.zoomLevel * zoomDelta, event.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final childSize = Size(
      widget.baseSize.width * widget.zoomLevel,
      widget.baseSize.height * widget.zoomLevel,
    );

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        child: SingleChildScrollView(
          controller: widget.horizontalController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: widget.verticalController,
            scrollDirection: Axis.vertical,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => widget.onTapDown(
                (details.localPosition / widget.zoomLevel) -
                    Offset(widget.pageMargin, widget.pageMargin),
              ),
              onTapUp: (_) => widget.onInteractionEnd(),
              onTapCancel: widget.onInteractionEnd,
              onPanStart: (details) => widget.onDragStart(
                (details.localPosition / widget.zoomLevel) -
                    Offset(widget.pageMargin, widget.pageMargin),
              ),
              onPanUpdate: (details) => widget.onDragUpdate(
                (details.localPosition / widget.zoomLevel) -
                    Offset(widget.pageMargin, widget.pageMargin),
              ),
              onPanEnd: (_) => widget.onInteractionEnd(),
              child: CustomPaint(
                size: childSize,
                painter: GridPainter(
                  cells: widget.cells,
                  cellSize: widget.cellSize,
                  pageMargin: widget.pageMargin,
                  zoomLevel: widget.zoomLevel,
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
        ),
      ),
    );
  }
}
