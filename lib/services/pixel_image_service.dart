import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class PixelImageService {
  static Future<List<List<Color?>>> buildPixelGrid({
    required Uint8List imageBytes,
    required int columns,
    required int rows,
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
      return List.generate(rows, (row) {
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
    } finally {
      image.dispose();
      codec.dispose();
    }
  }

  static List<List<Color?>> _blankGrid(int rows, int columns) {
    return List.generate(rows, (_) => List<Color?>.filled(columns, null));
  }
}
