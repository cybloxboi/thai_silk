import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class GridPdfExporter {
  static Future<Uint8List> build({
    required List<List<Color?>> cells,
    required int columns,
    required int rows,
  }) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4.landscape;

    const double pageInset = 20.0;
    const double labelBandLeft = 26.0;
    const double labelBandTop = 18.0;

    final availableWidth = pageFormat.width - (pageInset * 2) - labelBandLeft;
    final availableHeight = pageFormat.height - (pageInset * 2) - labelBandTop;
    final cellSize = math.min(availableWidth / columns, availableHeight / rows);
    final gridWidth = cellSize * columns;
    final gridHeight = cellSize * rows;
    final originX =
        pageInset + labelBandLeft + (availableWidth - gridWidth) / 2;
    final originY =
        pageInset + labelBandTop + (availableHeight - gridHeight) / 2;

    final labelStyle = pw.TextStyle(
      color: PdfColor.fromInt(0xFF4B5563),
      fontSize: 7.5,
      fontWeight: pw.FontWeight.bold,
    );
    final gridLineColor = PdfColor.fromInt(0xFFE4DDD1);
    final borderColor = PdfColor.fromInt(0xFFB8AB95);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          final children = <pw.Widget>[
            pw.Positioned.fill(
              child: pw.Container(color: PdfColor.fromInt(0xFFFFFFFF)),
            ),
          ];

          for (var column = 0; column < columns; column++) {
            children.add(
              pw.Positioned(
                left: originX + column * cellSize,
                top: pageInset,
                child: pw.SizedBox(
                  width: cellSize,
                  height: labelBandTop,
                  child: pw.Center(
                    child: pw.Text('${column + 1}', style: labelStyle),
                  ),
                ),
              ),
            );
          }

          for (var row = 0; row < rows; row++) {
            children.add(
              pw.Positioned(
                left: pageInset,
                top: originY + row * cellSize,
                child: pw.SizedBox(
                  width: labelBandLeft,
                  height: cellSize,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('${row + 1}', style: labelStyle),
                  ),
                ),
              ),
            );
          }

          for (var row = 0; row < rows; row++) {
            for (var column = 0; column < columns; column++) {
              final cellColor = cells[row][column];
              if (cellColor == null) {
                continue;
              }

              children.add(
                pw.Positioned(
                  left: originX + column * cellSize,
                  top: originY + row * cellSize,
                  child: pw.SizedBox(
                    width: cellSize,
                    height: cellSize,
                    child: pw.Container(color: _toPdfColor(cellColor)),
                  ),
                ),
              );
            }
          }

          for (var column = 0; column <= columns; column++) {
            children.add(
              pw.Positioned(
                left: originX + column * cellSize,
                top: originY,
                child: pw.SizedBox(
                  width: 0.6,
                  height: gridHeight,
                  child: pw.Container(color: gridLineColor),
                ),
              ),
            );
          }

          for (var row = 0; row <= rows; row++) {
            children.add(
              pw.Positioned(
                left: originX,
                top: originY + row * cellSize,
                child: pw.SizedBox(
                  width: gridWidth,
                  height: 0.6,
                  child: pw.Container(color: gridLineColor),
                ),
              ),
            );
          }

          children.add(
            pw.Positioned(
              left: originX,
              top: originY,
              child: pw.SizedBox(
                width: gridWidth,
                height: gridHeight,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor, width: 1),
                  ),
                ),
              ),
            ),
          );

          return pw.Stack(children: children);
        },
      ),
    );

    return pdf.save();
  }

  static PdfColor _toPdfColor(Color color) {
    return PdfColor.fromInt(color.toARGB32());
  }
}
