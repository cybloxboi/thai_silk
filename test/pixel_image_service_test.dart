import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thai_silk/services/pixel_image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PixelImageService', () {
    test('returns an empty grid for invalid dimensions', () async {
      final grid = await PixelImageService.buildPixelGrid(
        imageBytes: Uint8List(0),
        columns: 0,
        rows: 4,
      );

      expect(grid, isEmpty);
    });

    test('samples the source image into the target grid', () async {
      final imageBytes = await _buildQuadrantImageBytes();

      final grid = await PixelImageService.buildPixelGrid(
        imageBytes: imageBytes,
        columns: 2,
        rows: 2,
        maxColors: 256,
      );

      expect(grid, hasLength(2));
      expect(grid[0], hasLength(2));
      expect(grid[1], hasLength(2));
      expect(grid[0][0], const Color(0xFFFF0000));
      expect(grid[0][1], const Color(0xFF00FF00));
      expect(grid[1][0], const Color(0xFF0000FF));
      expect(grid[1][1], const Color(0xFFFFFFFF));
    });

    test(
      'contain fit mode keeps transparent padding around the image',
      () async {
        final imageBytes = await _buildHalfAndHalfImageBytes();

        final grid = await PixelImageService.buildPixelGrid(
          imageBytes: imageBytes,
          columns: 6,
          rows: 6,
          maxColors: 256,
          fitMode: PixelImageFitMode.contain,
        );

        expect(grid, hasLength(6));
        for (final rowIndex in [0, 5]) {
          for (final cell in grid[rowIndex]) {
            expect(cell, isNull);
          }
        }
        expect(grid[2][1], const Color(0xFFFF0000));
        expect(grid[2][3], const Color(0xFF00FF00));
        expect(grid[2][4], const Color(0xFF00FF00));
        expect(grid[3][1], const Color(0xFFFF0000));
        expect(grid[3][3], const Color(0xFF00FF00));
        expect(grid[3][4], const Color(0xFF00FF00));
      },
    );
  });
}

Future<Uint8List> _buildQuadrantImageBytes() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();

  paint.color = const Color(0xFFFF0000);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 2, 2), paint);

  paint.color = const Color(0xFF00FF00);
  canvas.drawRect(const Rect.fromLTWH(2, 0, 2, 2), paint);

  paint.color = const Color(0xFF0000FF);
  canvas.drawRect(const Rect.fromLTWH(0, 2, 2, 2), paint);

  paint.color = const Color(0xFFFFFFFF);
  canvas.drawRect(const Rect.fromLTWH(2, 2, 2, 2), paint);

  final picture = recorder.endRecording();
  final image = await picture.toImage(4, 4);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  return byteData!.buffer.asUint8List();
}

Future<Uint8List> _buildHalfAndHalfImageBytes() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();

  paint.color = const Color(0xFFFF0000);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 2, 2), paint);

  paint.color = const Color(0xFF00FF00);
  canvas.drawRect(const Rect.fromLTWH(2, 0, 2, 2), paint);

  final picture = recorder.endRecording();
  final image = await picture.toImage(4, 2);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  return byteData!.buffer.asUint8List();
}
