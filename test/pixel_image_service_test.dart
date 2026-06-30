import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_silk/services/pixel_image_service.dart';

void main() {
  test('builds a pixel grid from image bytes', () async {
    final imageBytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg==',
    );

    final grid = await PixelImageService.buildPixelGrid(
      imageBytes: imageBytes,
      columns: 2,
      rows: 3,
    );

    expect(grid, hasLength(3));
    expect(grid.every((row) => row.length == 2), isTrue);
    for (final row in grid) {
      for (final color in row) {
        expect(color, const Color(0xFFFF0000));
      }
    }
  });
}
