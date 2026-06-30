import 'dart:math' as math;

import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, required this.initialColor});

  final Color initialColor;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    final hsvColor = HSVColor.fromColor(widget.initialColor);
    _hue = hsvColor.hue;
    _saturation = hsvColor.saturation;
    _value = hsvColor.value;
  }

  Color get _currentColor {
    return HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor();
  }

  void _updateWheelFromPosition(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delta = localPosition - center;
    final radius = size.shortestSide / 2;
    if (radius <= 0) {
      return;
    }
    final distance = delta.distance.clamp(0.0, radius);
    final angle = math.atan2(delta.dy, delta.dx);
    final hue = (angle * 180 / math.pi + 360) % 360;

    setState(() {
      _hue = hue;
      _saturation = distance / radius;
    });
  }

  Widget _buildWheel() {
    const wheelSize = 280.0;
    final size = Size.square(wheelSize);
    final radius = size.shortestSide / 2;
    final center = Offset(radius, radius);
    final angle = _hue * math.pi / 180;
    final handlePosition =
        center +
        Offset(
          math.cos(angle) * _saturation * radius,
          math.sin(angle) * _saturation * radius,
        );

    return SizedBox.square(
      dimension: wheelSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (details) =>
            _updateWheelFromPosition(details.localPosition, size),
        onPanUpdate: (details) =>
            _updateWheelFromPosition(details.localPosition, size),
        child: CustomPaint(
          painter: _ColorWheelPainter(handlePosition: handlePosition),
        ),
      ),
    );
  }

  Widget _buildValueSlider() {
    final sliderColor = HSVColor.fromAHSV(1, _hue, 1, 1).toColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ความสว่าง', style: TextStyle(fontWeight: FontWeight.w700)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withValues(alpha: 0.18),
            thumbColor: sliderColor,
          ),
          child: Slider(
            min: 0,
            max: 1,
            value: _value,
            onChanged: (value) => setState(() => _value = value),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Color Picker'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x33000000)),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _buildWheel()),
              const SizedBox(height: 16),
              _buildValueSlider(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_currentColor),
          child: const Text('เลือกสี'),
        ),
      ],
    );
  }
}

class _ColorWheelPainter extends CustomPainter {
  _ColorWheelPainter({required this.handlePosition});

  final Offset handlePosition;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    final wheelPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Color(0xFFFF0000),
          Color(0xFFFF7F00),
          Color(0xFFFFFF00),
          Color(0xFF00FF00),
          Color(0xFF00FFFF),
          Color(0xFF0000FF),
          Color(0xFFFF00FF),
          Color(0xFFFF0000),
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, wheelPaint);

    final whiteFadePaint = Paint()
      ..shader = RadialGradient(
        colors: const [Colors.white, Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawCircle(center, radius, whiteFadePaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0x33000000);
    canvas.drawCircle(center, radius, ringPaint);

    final handleShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = const Color(0x55000000);
    final handlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white;
    canvas.drawCircle(handlePosition, 10, handleShadowPaint);
    canvas.drawCircle(handlePosition, 10, handlePaint);
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return oldDelegate.handlePosition != handlePosition;
  }
}
