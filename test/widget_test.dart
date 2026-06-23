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
    expect(find.text('ซูมกระดาษ'), findsOneWidget);
    expect(find.text('รีเซ็ตซูม'), findsOneWidget);
    expect(find.text('ส่งออก PDF'), findsOneWidget);
    expect(find.text('Tile เต็มตาราง'), findsOneWidget);
  });
}
