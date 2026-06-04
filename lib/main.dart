import 'package:flutter/material.dart';
import 'package:thai_silk/pages/grid_designer_page.dart';

void main() {
  runApp(const ThaiSilkApp());
}

class ThaiSilkApp extends StatelessWidget {
  const ThaiSilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thai Silk',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4EFE6),
      ),
      home: const GridDesignerPage(),
    );
  }
}
