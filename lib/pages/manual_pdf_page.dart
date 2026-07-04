import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ManualPdfPage extends StatelessWidget {
  const ManualPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('คู่มือการใช้งาน')),
      body: Container(
        color: Colors.purple.shade50,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 700,
          child: SfPdfViewer.asset(
            'assets/manual/manual.pdf',
            pageLayoutMode: PdfPageLayoutMode.continuous,
          ),
        ),
      ),
    );
  }
}
