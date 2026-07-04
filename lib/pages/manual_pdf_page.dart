import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class ManualPdfPage extends StatelessWidget {
  const ManualPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('คู่มือการใช้งาน')),
      body: PdfViewer.asset('assets/manual/manual.pdf'),
    );
  }
}
