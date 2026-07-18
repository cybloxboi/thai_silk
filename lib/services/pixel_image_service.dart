import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum PixelImageFitMode { cover, contain }

class PixelImageService {
  static Future<ui.Image> decodeImage(Uint8List imageBytes) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    try {
      final frame = await codec.getNextFrame();
      return frame.image;
    } finally {
      codec.dispose();
    }
  }

  static Future<List<List<Color?>>> buildPixelGrid({
    required Uint8List imageBytes,
    required int columns,
    required int rows,
    int maxColors = 16,
    PixelImageFitMode fitMode = PixelImageFitMode.cover,
  }) async {
    if (columns <= 0 || rows <= 0) {
      return const <List<Color?>>[];
    }

    final image = await decodeImage(imageBytes);
    try {
      return await buildPixelGridFromImage(
        image: image,
        columns: columns,
        rows: rows,
        maxColors: maxColors,
        fitMode: fitMode,
      );
    } finally {
      image.dispose();
    }
  }

  static Future<List<List<Color?>>> buildPixelGridFromImage({
    required ui.Image image,
    required int columns,
    required int rows,
    int maxColors = 16,
    PixelImageFitMode fitMode = PixelImageFitMode.cover,
  }) async {
    if (columns <= 0 || rows <= 0) {
      return const <List<Color?>>[];
    }

    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      return _blankGrid(rows, columns);
    }

    final bytes = byteData.buffer.asUint8List();
    final grid = _sampleImageToGrid(
      bytes: bytes,
      sourceWidth: image.width,
      sourceHeight: image.height,
      columns: columns,
      rows: rows,
      fitMode: fitMode,
    );
    final reduced = _reduceColors(grid, maxColors.clamp(1, 256).toInt());
    return reduced;
  }

  static List<List<Color?>> _sampleImageToGrid({
    required Uint8List bytes,
    required int sourceWidth,
    required int sourceHeight,
    required int columns,
    required int rows,
    required PixelImageFitMode fitMode,
  }) {
    if (sourceWidth <= 0 || sourceHeight <= 0) {
      return _blankGrid(rows, columns);
    }

    final scale = fitMode == PixelImageFitMode.cover
        ? math.max(columns / sourceWidth, rows / sourceHeight)
        : math.min(columns / sourceWidth, rows / sourceHeight);
    final renderedWidth = sourceWidth * scale;
    final renderedHeight = sourceHeight * scale;
    final offsetX = (columns - renderedWidth) / 2;
    final offsetY = (rows - renderedHeight) / 2;

    return List.generate(rows, (row) {
      return List.generate(columns, (column) {
        final centerX = column + 0.5;
        final centerY = row + 0.5;
        if (fitMode == PixelImageFitMode.contain &&
            (centerX < offsetX ||
                centerX > offsetX + renderedWidth ||
                centerY < offsetY ||
                centerY > offsetY + renderedHeight)) {
          return null;
        }

        final sampleX = (centerX - offsetX) / scale;
        final sampleY = (centerY - offsetY) / scale;
        return _sampleColor(
          bytes: bytes,
          sourceWidth: sourceWidth,
          sourceHeight: sourceHeight,
          x: sampleX,
          y: sampleY,
        );
      });
    });
  }

  static Color? _sampleColor({
    required Uint8List bytes,
    required int sourceWidth,
    required int sourceHeight,
    required double x,
    required double y,
  }) {
    final clampedX = x.clamp(0.0, (sourceWidth - 1).toDouble());
    final clampedY = y.clamp(0.0, (sourceHeight - 1).toDouble());

    final left = clampedX.floor();
    final top = clampedY.floor();
    final right = math.min(left + 1, sourceWidth - 1);
    final bottom = math.min(top + 1, sourceHeight - 1);
    final xWeight = clampedX - left;
    final yWeight = clampedY - top;

    final topLeft = _readPixel(bytes, sourceWidth, left, top);
    final topRight = _readPixel(bytes, sourceWidth, right, top);
    final bottomLeft = _readPixel(bytes, sourceWidth, left, bottom);
    final bottomRight = _readPixel(bytes, sourceWidth, right, bottom);

    final topBlend = _blendPixels(topLeft, topRight, xWeight);
    final bottomBlend = _blendPixels(bottomLeft, bottomRight, xWeight);
    final sampled = _blendPixels(topBlend, bottomBlend, yWeight);
    if (sampled.alpha == 0) {
      return null;
    }

    return Color.fromARGB(
      sampled.alpha,
      sampled.red,
      sampled.green,
      sampled.blue,
    );
  }

  static _RgbaPixel _readPixel(Uint8List bytes, int sourceWidth, int x, int y) {
    final index = (y * sourceWidth + x) * 4;
    return _RgbaPixel(
      red: bytes[index],
      green: bytes[index + 1],
      blue: bytes[index + 2],
      alpha: bytes[index + 3],
    );
  }

  static _RgbaPixel _blendPixels(
    _RgbaPixel left,
    _RgbaPixel right,
    double weight,
  ) {
    final alpha = _lerpChannel(left.alpha, right.alpha, weight);
    if (alpha == 0) {
      return const _RgbaPixel(alpha: 0, red: 0, green: 0, blue: 0);
    }

    return _RgbaPixel(
      alpha: alpha,
      red: _blendPremultipliedChannel(
        left.red,
        left.alpha,
        right.red,
        right.alpha,
        weight,
        alpha,
      ),
      green: _blendPremultipliedChannel(
        left.green,
        left.alpha,
        right.green,
        right.alpha,
        weight,
        alpha,
      ),
      blue: _blendPremultipliedChannel(
        left.blue,
        left.alpha,
        right.blue,
        right.alpha,
        weight,
        alpha,
      ),
    );
  }

  static int _lerpChannel(int start, int end, double weight) {
    return (start + (end - start) * weight).round().clamp(0, 255).toInt();
  }

  static int _blendPremultipliedChannel(
    int leftChannel,
    int leftAlpha,
    int rightChannel,
    int rightAlpha,
    double weight,
    int alpha,
  ) {
    final leftPremultiplied = leftChannel * leftAlpha;
    final rightPremultiplied = rightChannel * rightAlpha;
    final blended =
        leftPremultiplied + (rightPremultiplied - leftPremultiplied) * weight;
    return (blended / alpha).round().clamp(0, 255).toInt();
  }

  static List<List<Color?>> _blankGrid(int rows, int columns) {
    return List.generate(rows, (_) => List<Color?>.filled(columns, null));
  }

  static List<List<Color?>> _reduceColors(
    List<List<Color?>> grid,
    int maxColors,
  ) {
    final pixels = <_PalettePixel>[];
    for (final row in grid) {
      for (final color in row) {
        if (color == null) {
          continue;
        }
        pixels.add(_PalettePixel.fromColor(color));
      }
    }

    if (pixels.isEmpty || _countUniqueColors(pixels) <= maxColors) {
      return grid;
    }

    final palette = _buildPalette(pixels, maxColors);
    if (palette.isEmpty) {
      return grid;
    }

    return [
      for (final row in grid)
        [
          for (final color in row)
            color == null
                ? null
                : _nearestPaletteColor(_PalettePixel.fromColor(color), palette),
        ],
    ];
  }

  static int _countUniqueColors(List<_PalettePixel> pixels) {
    final uniqueColors = <int>{};
    for (final pixel in pixels) {
      uniqueColors.add(pixel.argb);
    }
    return uniqueColors.length;
  }

  static List<Color> _buildPalette(List<_PalettePixel> pixels, int maxColors) {
    final buckets = <_ColorBucket>[_ColorBucket(List.of(pixels))];

    while (buckets.length < maxColors) {
      buckets.sort((a, b) => b.range.compareTo(a.range));
      final bucketToSplit = buckets.first;
      if (!bucketToSplit.canSplit) {
        break;
      }

      buckets.removeAt(0);
      final (left, right) = bucketToSplit.split();
      buckets
        ..add(left)
        ..add(right);
    }

    return [
      for (final bucket in buckets)
        if (bucket.pixels.isNotEmpty) bucket.averageColor,
    ];
  }

  static Color _nearestPaletteColor(_PalettePixel pixel, List<Color> palette) {
    var nearestColor = palette.first;
    var nearestDistance = _colorDistance(pixel, nearestColor);

    for (var index = 1; index < palette.length; index++) {
      final color = palette[index];
      final distance = _colorDistance(pixel, color);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestColor = color;
      }
    }

    return nearestColor;
  }

  static int _colorDistance(_PalettePixel pixel, Color color) {
    final alphaDiff = pixel.alpha - _channelValue(color.a);
    final redDiff = pixel.red - _channelValue(color.r);
    final greenDiff = pixel.green - _channelValue(color.g);
    final blueDiff = pixel.blue - _channelValue(color.b);
    return alphaDiff * alphaDiff +
        redDiff * redDiff +
        greenDiff * greenDiff +
        blueDiff * blueDiff;
  }

  static int _channelValue(double value) {
    return (value * 255).round().clamp(0, 255).toInt();
  }
}

class _RgbaPixel {
  const _RgbaPixel({
    required this.alpha,
    required this.red,
    required this.green,
    required this.blue,
  });

  final int alpha;
  final int red;
  final int green;
  final int blue;
}

class _PalettePixel {
  const _PalettePixel({
    required this.alpha,
    required this.red,
    required this.green,
    required this.blue,
  });

  factory _PalettePixel.fromColor(Color color) {
    return _PalettePixel(
      alpha: PixelImageService._channelValue(color.a),
      red: PixelImageService._channelValue(color.r),
      green: PixelImageService._channelValue(color.g),
      blue: PixelImageService._channelValue(color.b),
    );
  }

  final int alpha;
  final int red;
  final int green;
  final int blue;

  int get argb => alpha << 24 | red << 16 | green << 8 | blue;
}

class _ColorBucket {
  _ColorBucket(this.pixels);

  final List<_PalettePixel> pixels;

  bool get canSplit => pixels.length > 1 && range > 0;

  int get alphaRange => _range((pixel) => pixel.alpha);

  int get redRange => _range((pixel) => pixel.red);

  int get greenRange => _range((pixel) => pixel.green);

  int get blueRange => _range((pixel) => pixel.blue);

  int get range => [
    alphaRange,
    redRange,
    greenRange,
    blueRange,
  ].reduce((max, value) => value > max ? value : max);

  Color get averageColor {
    var alphaTotal = 0;
    var redTotal = 0;
    var greenTotal = 0;
    var blueTotal = 0;
    for (final pixel in pixels) {
      alphaTotal += pixel.alpha;
      redTotal += pixel.red;
      greenTotal += pixel.green;
      blueTotal += pixel.blue;
    }

    final count = pixels.length;
    return Color.fromARGB(
      (alphaTotal / count).round(),
      (redTotal / count).round(),
      (greenTotal / count).round(),
      (blueTotal / count).round(),
    );
  }

  (_ColorBucket, _ColorBucket) split() {
    final channel = _widestChannel();
    pixels.sort((a, b) => channel(a).compareTo(channel(b)));
    final middle = pixels.length ~/ 2;
    return (
      _ColorBucket(List.of(pixels.take(middle))),
      _ColorBucket(List.of(pixels.skip(middle))),
    );
  }

  int Function(_PalettePixel pixel) _widestChannel() {
    final ranges = {
      alphaRange: (_PalettePixel pixel) => pixel.alpha,
      redRange: (_PalettePixel pixel) => pixel.red,
      greenRange: (_PalettePixel pixel) => pixel.green,
      blueRange: (_PalettePixel pixel) => pixel.blue,
    };
    return ranges[range]!;
  }

  int _range(int Function(_PalettePixel pixel) valueOf) {
    var minValue = 255;
    var maxValue = 0;
    for (final pixel in pixels) {
      final value = valueOf(pixel);
      if (value < minValue) {
        minValue = value;
      }
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue - minValue;
  }
}
