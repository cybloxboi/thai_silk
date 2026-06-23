import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import 'grid_painter.dart';

class GridCanvas extends StatefulWidget {
  const GridCanvas({
    super.key,
    required this.baseSize,
    required this.cells,
    required this.cellSize,
    required this.pageMargin,
    required this.zoomLevel,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomChanged,
    required this.onTapDown,
    required this.onDragUpdate,
  });

  final Size baseSize;
  final List<List<Color?>> cells;
  final double cellSize;
  final double pageMargin;
  final double zoomLevel;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<Offset> onTapDown;
  final ValueChanged<Offset> onDragUpdate;

  @override
  State<GridCanvas> createState() => _GridCanvasState();
}

class _GridCanvasState extends State<GridCanvas> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  double? _scaleStartZoom;

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void _applyZoom(double nextZoom, Offset focalPoint) {
    final clampedZoom = nextZoom
        .clamp(widget.minZoom, widget.maxZoom)
        .toDouble();
    if ((clampedZoom - widget.zoomLevel).abs() < 0.001) {
      return;
    }

    final currentZoom = widget.zoomLevel;
    final currentHorizontalOffset = _horizontalController.hasClients
        ? _horizontalController.offset
        : 0.0;
    final currentVerticalOffset = _verticalController.hasClients
        ? _verticalController.offset
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
      _jumpTo(_horizontalController, targetHorizontalOffset);
      _jumpTo(_verticalController, targetVerticalOffset);
    });
  }

  void _jumpTo(ScrollController controller, double targetOffset) {
    if (!controller.hasClients) {
      return;
    }

    final position = controller.position;
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
          controller: _horizontalController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => widget.onTapDown(
                (details.localPosition / widget.zoomLevel) -
                    Offset(widget.pageMargin, widget.pageMargin),
              ),
              onPanStart: (details) => widget.onDragUpdate(
                (details.localPosition / widget.zoomLevel) -
                    Offset(widget.pageMargin, widget.pageMargin),
              ),
              onPanUpdate: (details) => widget.onDragUpdate(
                (details.localPosition / widget.zoomLevel) -
                    Offset(widget.pageMargin, widget.pageMargin),
              ),
              child: CustomPaint(
                size: childSize,
                painter: GridPainter(
                  cells: widget.cells,
                  cellSize: widget.cellSize,
                  pageMargin: widget.pageMargin,
                  zoomLevel: widget.zoomLevel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
