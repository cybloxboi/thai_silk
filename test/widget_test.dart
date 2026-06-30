import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thai_silk/main.dart';

void main() {
  testWidgets('shows the grid designer UI', (tester) async {
    await tester.pumpWidget(const ThaiSilkApp());

    expect(find.text('Thai Silk'), findsOneWidget);
    expect(find.text('ล้างทั้งตาราง'), findsOneWidget);
    expect(find.text('ย้อนกลับ'), findsOneWidget);
    expect(find.textContaining('84 x 57'), findsWidgets);
    expect(find.text('แนวนอน'), findsOneWidget);
    expect(find.text('แนวตั้ง'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('เลือกสี'), findsOneWidget);
    expect(find.text('นำเข้ารูปภาพ'), findsOneWidget);
    expect(find.text('ซูมกระดาษ'), findsOneWidget);
    expect(find.text('รีเซ็ตซูม'), findsOneWidget);
    expect(find.text('ส่งออก PDF'), findsOneWidget);
    expect(find.text('Tile เต็มตาราง'), findsOneWidget);
  });

  testWidgets('opens and confirms the color picker', (tester) async {
    await tester.pumpWidget(const ThaiSilkApp());

    await tester.ensureVisible(find.byIcon(Icons.color_lens_outlined));
    await tester.tap(find.byIcon(Icons.color_lens_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('เลือกสี'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('selects pH colors and opens help dialog separately', (tester) async {
    await tester.pumpWidget(const ThaiSilkApp());

    final phColor = find.byKey(
      const ValueKey('ph_chip_pH2.5'),
      skipOffstage: false,
    );
    await tester.ensureVisible(phColor);
    await tester.tap(phColor);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey('ph_chip_pH2.5'),
          skipOffstage: false,
        ),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );

    final helpButton = find.byKey(const Key('ph_help_button'));
    await tester.ensureVisible(helpButton);
    await tester.tap(helpButton);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('คำแนะนำการย้อมสีไหมจากครั่ง'),
      ),
      findsOneWidget,
    );
    expect(find.text('อุปกรณ์ที่ต้องใช้'), findsOneWidget);
    expect(find.text('วิธีทำการย้อมสี'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('ปิด'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('adds sheets with numeric names', (tester) async {
    await tester.pumpWidget(const ThaiSilkApp());

    final addSheetButton = find
        .widgetWithText(OutlinedButton, 'เพิ่มชีต')
        .first;
    await tester.ensureVisible(addSheetButton);
    await tester.tap(addSheetButton);
    await tester.pumpAndSettle();

    await tester.tap(addSheetButton);
    await tester.pumpAndSettle();

    expect(find.text('Sheet 1'), findsWidgets);
    expect(find.text('Sheet 2'), findsWidgets);
    expect(find.text('Sheet 3'), findsWidgets);
  });

  testWidgets('opens the export pdf dialog', (tester) async {
    await tester.pumpWidget(const ThaiSilkApp());

    await tester.ensureVisible(find.text('ส่งออก PDF'));
    await tester.tap(find.text('ส่งออก PDF'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('ชีตที่เลือกอยู่'), findsOneWidget);
    expect(find.text('เลือกชีตเอง'), findsOneWidget);
    expect(find.text('ทุกชีตในไฟล์'), findsOneWidget);

    await tester.tap(find.text('เลือกชีตเอง'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(CheckboxListTile),
      ),
      findsWidgets,
    );
    expect(find.text('เลือกชีตที่ต้องการส่งออก'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('ยกเลิก'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
