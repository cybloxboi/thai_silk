import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_silk/widgets/pdf_export_dialog.dart';

void main() {
  testWidgets('exports selected sheets with checkboxes', (tester) async {
    PdfExportSettings? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result = await showDialog<PdfExportSettings>(
                    context: context,
                    builder: (dialogContext) {
                      return const PdfExportDialog(
                        sheetNames: ['Sheet 1', 'Sheet 2', 'Sheet 3'],
                        initialSheetIndex: 0,
                      );
                    },
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('เลือกชีตเอง'));
    await tester.pumpAndSettle();

    expect(find.byType(CheckboxListTile), findsNWidgets(3));

    await tester.ensureVisible(find.text('Sheet 2'));
    await tester.tap(find.text('Sheet 2'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'ส่งออก'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mode, PdfExportMode.chooseSheet);
    expect(result!.sheetIndices, [0, 1]);
  });
}
