import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/grid_sheet.dart';

class GridPdfExporter {
  static Future<Uint8List> build({
    required List<GridSheet> sheets,
    required int columns,
    required int rows,
  }) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4.landscape;

    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/th_sarabun_new_bold.ttf'),
    );

    const double pageInset = 20.0;
    const double labelBandLeft = 10.0;
    const double labelBandTop = 10.0;
    const double labelGap = 2;

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
      font: boldFont,
      color: PdfColor.fromInt(0xFF4B5563),
      fontSize: 9,
    );
    final gridLineColor = PdfColor.fromInt(0xFFE4DDD1);
    final borderColor = PdfColor.fromInt(0xFFB8AB95);

    for (final sheet in sheets) {
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            final children = <pw.Widget>[
              pw.Positioned.fill(
                child: pw.Container(color: PdfColor.fromInt(0xFFFFFFFF)),
              ),
              pw.Positioned(
                left: pageInset,
                top: 6,
                child: pw.Text(
                  sheet.name,
                  style: pw.TextStyle(
                    font: boldFont,
                    color: PdfColor.fromInt(0xFF111827),
                    fontSize: 14,
                  ),
                ),
              ),
            ];

            for (var column = 0; column < columns; column++) {
              children.add(
                pw.Positioned(
                  left: originX + column * cellSize,
                  top: originY - labelBandTop - labelGap,
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
                  left: originX - labelBandLeft - labelGap,
                  top: originY + row * cellSize,
                  child: pw.SizedBox(
                    width: labelBandLeft,
                    height: cellSize,
                    child: pw.Center(
                      child: pw.Text('${row + 1}', style: labelStyle),
                    ),
                  ),
                ),
              );
            }

            for (var row = 0; row < rows; row++) {
              for (var column = 0; column < columns; column++) {
                final cellColor = sheet.cells[row][column];
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
    }

    return pdf.save();
  }

  static PdfColor _toPdfColor(Color color) {
    return PdfColor.fromInt(color.toARGB32());
  }
}
