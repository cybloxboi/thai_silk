import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:thai_silk/pages/grid_designer_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  runApp(const ThaiSilkApp());
}

class ThaiSilkApp extends StatelessWidget {
  const ThaiSilkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thai Silk',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const GridDesignerPage(),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF992C2F),
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF101816)
        : const Color(0xFFCAB7AA),
    canvasColor: colorScheme.surface,
    dividerColor: colorScheme.outlineVariant,
  );
}
