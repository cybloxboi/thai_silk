import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PixelImageService {
  static Future<List<List<Color?>>> buildPixelGrid({
    required Uint8List imageBytes,
    required int columns,
    required int rows,
    int maxColors = 16,
  }) async {
    if (columns <= 0 || rows <= 0) {
      return const <List<Color?>>[];
    }

    final codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: columns,
      targetHeight: rows,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    try {
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        return _blankGrid(rows, columns);
      }

      final bytes = byteData.buffer.asUint8List();
      final grid = List.generate(rows, (row) {
        return List.generate(columns, (column) {
          final index = (row * columns + column) * 4;
          final red = bytes[index];
          final green = bytes[index + 1];
          final blue = bytes[index + 2];
          final alpha = bytes[index + 3];
          if (alpha == 0) {
            return null;
          }
          return Color.fromARGB(alpha, red, green, blue);
        });
      });
      return _reduceColors(grid, maxColors.clamp(1, 256).toInt());
    } finally {
      image.dispose();
      codec.dispose();
    }
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
