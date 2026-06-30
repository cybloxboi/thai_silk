import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_silk/models/grid_sheet.dart';
import 'package:thai_silk/services/grid_pdf_exporter.dart';

void main() {
  test('builds a PDF for multiple sheets', () async {
    final sheetOne = GridSheet.blank(name: 'Sheet 1', rows: 3, columns: 3);
    final sheetTwo = GridSheet.blank(name: 'Sheet 2', rows: 3, columns: 3);
    sheetOne.cells[0][0] = const Color(0xFFFF0000);
    sheetTwo.cells[1][1] = const Color(0xFF0000FF);

    final bytes = await GridPdfExporter.build(
      sheets: [sheetOne, sheetTwo],
      columns: 3,
      rows: 3,
    );

    expect(bytes, isNotEmpty);
  });
}
