import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_silk/widgets/pixel_image_import_dialog.dart';

void main() {
  testWidgets('returns custom pixel import settings', (tester) async {
    PixelImageImportSettings? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result = await showDialog<PixelImageImportSettings>(
                    context: context,
                    builder: (dialogContext) {
                      return const PixelImageImportDialog(
                        maxColumns: 84,
                        maxRows: 57,
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

    expect(find.text('เต็มตาราง'), findsOneWidget);
    expect(find.text('กำหนดขนาด'), findsOneWidget);

    await tester.tap(find.text('กำหนดขนาด'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'กว้าง'), '12');
    await tester.enterText(find.widgetWithText(TextField, 'สูง'), '18');
    await tester.tap(find.text('นำเข้า'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.mode, PixelImageImportMode.custom);
    expect(result!.columns, 12);
    expect(result!.rows, 18);
  });
}
