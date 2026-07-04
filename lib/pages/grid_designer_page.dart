import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';
import 'package:printing/printing.dart';

import '../models/grid_sheet.dart';
import '../models/grid_workbook.dart';
import '../models/pattern_selection.dart';
import '../models/ph_color_swatch.dart';
import '../services/grid_pdf_exporter.dart';
import '../services/pattern_repeat_service.dart';
import '../services/pixel_image_service.dart';
import '../services/workbook_storage.dart';
import '../widgets/control_panel.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/ph_color_info_dialog.dart';
import '../widgets/pdf_export_dialog.dart';
import '../widgets/pixel_image_import_dialog.dart';
import '../widgets/grid_canvas.dart';
import '../widgets/paper_shell.dart';

class GridDesignerPage extends StatefulWidget {
  const GridDesignerPage({super.key});

  @override
  State<GridDesignerPage> createState() => _GridDesignerPageState();
}

class _GridDesignerPageState extends State<GridDesignerPage> {
  static const int defaultColumns = 84;
  static const int defaultRows = 57;
  static const double cellSize = 18.0;
  static const double pageMargin = 44.0;
  static const double minZoom = 0.5;
  static const double maxZoom = 2.0;
  static const double zoomStep = 0.1;
  static const int maxRepeatSpacing = 12;

  final List<Color> palette = const [
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
    Color(0xFFEAB308),
  ];

  static const List<PhColorSwatch> phPalette = [
    PhColorSwatch(
      pHValue: 2.5,
      color: Color(0xFFB4261D),
      rgb: '180, 38, 29',
      hsv: '3.6°, 0.839, 0.706',
      lab: '41.39, 52.50, 41.81',
      hex: '#B4261D',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำมะขามเปียก 260 ml pH 2.4',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 2.5',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิมเวลา 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 2.4',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50 °C',
        'ล้างไหมในอุณหภูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาดแล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 3,
      color: Color(0xFF9A120F),
      rgb: '154, 18, 15',
      hsv: '1.3°, 0.903, 0.604',
      lab: '33.49, 50.35, 39.33',
      hex: '#9A120F',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำมะขามเปียก 88 ml pH 2.4',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 3',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ ',
        'ต้มไหมในน้ำเดิม เวลา 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 2.5',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50°C',
        'ล้างไหมในน้ำอุณหภูมิ 50°C 1 นาท',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาด แล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 3.5,
      color: Color(0xFFB41320),
      rgb: '180, 19, 32',
      hsv: '355.2°, 0.894, 0.706',
      lab: '39.46, 57.32, 38.84',
      hex: '#B41320',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำมะขามเปียก 35 ml pH 2.4',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 3.5',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิม 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 2.7',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50°C',
        'ล้างไหมในน้ำอุณหูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาด แล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 4,
      color: Color(0xFF90141A),
      rgb: '144, 20, 26',
      hsv: '357.1°, 0.861, 0.565',
      lab: '31.85, 46.78, 31.87',
      hex: '#90141A',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำมะขามเปียก 20 ml pH 2.4',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 4',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิม 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 3.2',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50°C',
        'ล้างไหมในน้ำอุณหูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาด แล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 4.5,
      color: Color(0xFF7B0A12),
      rgb: '123, 10, 18',
      hsv: '355.8°, 0.919, 0.482',
      lab: '25.77, 43.60, 28.19',
      hex: '#7B0A12',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำมะขามเปียก 12 ml pH 2.4',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 4.5',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิมเวลา 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 3.5',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50 °C',
        'ล้างไหมในอุณหภูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาดแล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 5,
      color: Color(0xFF8F2231),
      rgb: '143, 34, 49',
      hsv: '351.7°, 0.762, 0.561',
      lab: '34.63, 42.35, 22.80',
      hex: '#8F2231',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำมะขามเปียก 4 ml pH 2.4',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 5',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิม 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 3.9',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50°C',
        'ล้างไหมในน้ำอุณหูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาด แล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 5.5,
      color: Color(0xFF83242D),
      rgb: '131, 36, 45',
      hsv: '354.3°, 0.725, 0.514',
      lab: '30.47, 39.66, 18.90',
      hex: '#83242D',
      requirements: ['น้ำครั่ง 300 ml', 'สารส้มช่วยติดสี 0.5 g'],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 5.5',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิมเวลา 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 4.4',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50 °C',
        'ล้างไหมในอุณหภูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาดแล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 6,
      color: Color(0xFFBE5955),
      rgb: '190, 89, 85',
      hsv: '2.3°, 0.553, 0.745',
      lab: '51.02, 39.33, 23.49',
      hex: '#BE5955',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำเถ้า 4 ml pH 12',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 6',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิม 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 4.7',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50°C',
        'ล้างไหมในน้ำอุณหูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาด แล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 6.5,
      color: Color(0xFFC06759),
      rgb: '192, 103, 89',
      hsv: '8.2°, 0.536, 0.753',
      lab: '54.08, 33.98, 24.69',
      hex: '#C06759',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำเถ้า 9 ml pH 12',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 6.5',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิมเวลา 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 5.2',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50 °C',
        'ล้างไหมในอุณหภูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาดแล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
    PhColorSwatch(
      pHValue: 7,
      color: Color(0xFFD48064),
      rgb: '212, 128, 100',
      hsv: '15.0°, 0.528, 0.831',
      lab: '62.36, 29.57, 29.58',
      hex: '#D48064',
      requirements: [
        'น้ำครั่ง 300 ml',
        'น้ำเถ้า 15 ml pH 12',
        'สารส้มช่วยติดสี 0.5 g',
      ],
      steps: [
        'แช่ไหมในน้ำเปล่า 500 ml เวลา 10 นาที',
        'ตั้งไฟอุ่นน้ำครั่งให้อุณหภูมิ 50°C',
        'ปรับ pH น้ำครั่งตามส่วนผสม',
        'วัด pH ในหม้อ : pH 7',
        'แช่ไหมในน้ำครั่ง 300 ml ขยี้ บิด ๆ 5 นาที',
        'บิดไหมให้หมาด ๆ',
        'ต้มไหมในน้ำเดิม 30 นาที',
        'หลังต้ม บิดให้หมาด ๆ',
        'วัด pH น้ำหลังต้ม : pH 5.6',
        'ตากไว้ในอาคารโล่ง 1 วัน',
        'ต้มน้ำเปล่า 1 L อุณหภูมิ 50°C',
        'ล้างไหมในน้ำอุณหูมิ 50°C 1 นาที',
        'ล้างในน้ำธรรมดา 500 ml อีก 5 น้ำ',
        'บิดให้หมาด แล้วนำไปตาก 1 วัน จะได้ไหม',
      ],
    ),
  ];

  GridWorkbook workbook = GridWorkbook.initial(
    columns: defaultColumns,
    rows: defaultRows,
  );
  Color? selectedColor = const Color(0xFF0F766E);
  bool eraseMode = false;
  bool patternSelectionMode = false;
  double zoomLevel = 1.0;
  bool exportingPdf = false;
  String? currentFilePath;
  String? currentFileName;
  PatternSelection? patternSelection;
  int horizontalRepeatSpacing = 0;
  int verticalRepeatSpacing = 0;

  final List<GridWorkbook> _undoStack = [];
  final List<GridWorkbook> _redoStack = [];
  bool _historyRecordedForGesture = false;

  @override
  void dispose() {
    super.dispose();
  }

  GridSheet get activeSheet => workbook.activeSheet;

  int get filledCount => activeSheet.cells.fold<int>(
    0,
    (total, row) => total + row.whereType<Color>().length,
  );

  List<Color> get activeSheetColors {
    final colorCounts = <int, ({Color color, int count})>{};
    for (final row in activeSheet.cells) {
      for (final color in row) {
        if (color == null) {
          continue;
        }
        final colorKey = _colorKey(color);
        final existing = colorCounts[colorKey];
        colorCounts[colorKey] = (
          color: color,
          count: existing == null ? 1 : existing.count + 1,
        );
      }
    }

    final colors = colorCounts.values.toList()
      ..sort((a, b) {
        final countCompare = b.count.compareTo(a.count);
        if (countCompare != 0) {
          return countCompare;
        }
        return _colorKey(a.color).compareTo(_colorKey(b.color));
      });
    return [for (final colorCount in colors) colorCount.color];
  }

  int _colorKey(Color color) {
    final alpha = (color.a * 255).round().clamp(0, 255).toInt();
    final red = (color.r * 255).round().clamp(0, 255).toInt();
    final green = (color.g * 255).round().clamp(0, 255).toInt();
    final blue = (color.b * 255).round().clamp(0, 255).toInt();
    return alpha << 24 | red << 16 | green << 8 | blue;
  }

  String get currentFileLabel {
    if (currentFileName != null && currentFileName!.trim().isNotEmpty) {
      return currentFileName!;
    }

    final fromPath = _basenameFromPath(currentFilePath);
    if (fromPath != null) {
      return fromPath;
    }

    if (currentFilePath == null || currentFilePath!.trim().isEmpty) {
      return 'ยังไม่บันทึก';
    }

    return currentFilePath!;
  }

  String? _basenameFromPath(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final segments = path.split(RegExp(r'[\\/]'));
    return segments.isEmpty ? null : segments.last;
  }

  void _applyWorkbook(
    GridWorkbook nextWorkbook, {
    String? filePath,
    String? fileName,
  }) {
    setState(() {
      workbook = nextWorkbook;
      if (filePath != null) {
        currentFilePath = filePath;
      }
      if (fileName != null) {
        currentFileName = fileName;
      }
    });
  }

  void _applyWorkbookChange(
    GridWorkbook nextWorkbook, {
    String? filePath,
    String? fileName,
    bool recordHistory = true,
    bool clearHistory = false,
  }) {
    if (clearHistory) {
      _undoStack.clear();
      _redoStack.clear();
    } else if (recordHistory) {
      _undoStack.add(workbook.copyWith());
      _redoStack.clear();
    }

    setState(() {
      workbook = nextWorkbook;
      if (filePath != null) {
        currentFilePath = filePath;
      }
      if (fileName != null) {
        currentFileName = fileName;
      }
    });
  }

  void _recordGestureHistoryIfNeeded() {
    if (_historyRecordedForGesture) {
      return;
    }

    _undoStack.add(workbook.copyWith());
    _redoStack.clear();
    _historyRecordedForGesture = true;
  }

  void _endGestureHistory() {
    _historyRecordedForGesture = false;
  }

  void _selectColor(Color? color, {bool erase = false}) {
    setState(() {
      selectedColor = color;
      eraseMode = erase;
      patternSelectionMode = false;
    });
  }

  void _togglePatternSelectionMode() {
    setState(() {
      patternSelectionMode = !patternSelectionMode;
    });
  }

  void _clearPatternSelection() {
    setState(() {
      patternSelection = null;
    });
  }

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  void _undo() {
    if (_undoStack.isEmpty) {
      return;
    }

    final previousWorkbook = _undoStack.removeLast();
    _redoStack.add(workbook.copyWith());
    setState(() {
      workbook = previousWorkbook;
      _historyRecordedForGesture = false;
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) {
      return;
    }

    final nextWorkbook = _redoStack.removeLast();
    _undoStack.add(workbook.copyWith());
    setState(() {
      workbook = nextWorkbook;
      _historyRecordedForGesture = false;
    });
  }

  void _setHorizontalRepeatSpacing(int value) {
    final nextValue = value.clamp(0, maxRepeatSpacing);
    if (nextValue == horizontalRepeatSpacing) {
      return;
    }

    setState(() {
      horizontalRepeatSpacing = nextValue;
    });
  }

  void _setVerticalRepeatSpacing(int value) {
    final nextValue = value.clamp(0, maxRepeatSpacing);
    if (nextValue == verticalRepeatSpacing) {
      return;
    }

    setState(() {
      verticalRepeatSpacing = nextValue;
    });
  }

  void _increaseHorizontalRepeatSpacing() =>
      _setHorizontalRepeatSpacing(horizontalRepeatSpacing + 1);

  void _decreaseHorizontalRepeatSpacing() =>
      _setHorizontalRepeatSpacing(horizontalRepeatSpacing - 1);

  void _increaseVerticalRepeatSpacing() =>
      _setVerticalRepeatSpacing(verticalRepeatSpacing + 1);

  void _decreaseVerticalRepeatSpacing() =>
      _setVerticalRepeatSpacing(verticalRepeatSpacing - 1);

  void _clearAll() {
    final nextWorkbook = workbook.copyWith();
    for (final row in nextWorkbook.activeSheet.cells) {
      row.fillRange(0, row.length, null);
    }
    _applyWorkbookChange(nextWorkbook);
  }

  void _setZoom(double value) {
    final clampedZoom = value.clamp(minZoom, maxZoom).toDouble();
    if ((clampedZoom - zoomLevel).abs() < 0.001) {
      return;
    }
    setState(() {
      zoomLevel = clampedZoom;
    });
  }

  void _zoomIn() => _setZoom(zoomLevel + zoomStep);

  void _zoomOut() => _setZoom(zoomLevel - zoomStep);

  void _resetZoom() => _setZoom(1.0);

  void _selectSheet(int index) {
    if (index == workbook.activeSheetIndex) {
      return;
    }

    setState(() {
      workbook = workbook.copyWith(activeSheetIndex: index);
    });
  }

  String _makeUniqueSheetName(String baseName) {
    final trimmedBaseName = baseName.trim();
    final existingNames = workbook.sheets.map((sheet) => sheet.name).toSet();
    if (!existingNames.contains(trimmedBaseName)) {
      return trimmedBaseName;
    }

    var suffix = 2;
    while (existingNames.contains('$trimmedBaseName $suffix')) {
      suffix++;
    }
    return '$trimmedBaseName $suffix';
  }

  String _nextSheetName() {
    final existingNames = workbook.sheets.map((sheet) => sheet.name).toSet();
    var suffix = 1;
    while (existingNames.contains('Sheet $suffix')) {
      suffix++;
    }
    return 'Sheet $suffix';
  }

  void _addSheet() {
    final sheetName = _nextSheetName();
    final nextWorkbook = workbook.addSheet(
      GridSheet.blank(
        name: sheetName,
        rows: workbook.rows,
        columns: workbook.columns,
      ),
    );
    _applyWorkbookChange(nextWorkbook);
  }

  Future<void> _renameActiveSheet() async {
    final controller = TextEditingController(text: activeSheet.name);
    final nextName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('เปลี่ยนชื่อชีต'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'ชื่อชีต',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('บันทึก'),
            ),
          ],
        );
      },
    );

    final trimmedName = nextName?.trim();
    if (trimmedName == null || trimmedName.isEmpty) {
      return;
    }

    final uniqueName = _makeUniqueSheetName(trimmedName);
    _applyWorkbookChange(
      workbook.renameSheet(workbook.activeSheetIndex, uniqueName),
    );
  }

  Future<void> _deleteActiveSheet() async {
    if (workbook.sheets.length == 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ต้องมีอย่างน้อย 1 ชีต')));
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ลบชีต'),
          content: Text('ต้องการลบ ${activeSheet.name} หรือไม่'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final nextIndex = workbook.activeSheetIndex == workbook.sheets.length - 1
        ? workbook.activeSheetIndex - 1
        : workbook.activeSheetIndex;
    _applyWorkbookChange(workbook.removeSheet(workbook.activeSheetIndex));
    setState(() {
      workbook = workbook.copyWith(
        activeSheetIndex: nextIndex.clamp(0, workbook.sheets.length - 2),
      );
    });
  }

  Future<void> _openFile() async {
    try {
      final loaded = await WorkbookStorage.loadFromPickedFile();
      if (loaded == null) {
        return;
      }

      _applyWorkbookChange(
        loaded.workbook,
        filePath: loaded.path,
        fileName: loaded.name,
        recordHistory: false,
        clearHistory: true,
      );
      setState(() {
        currentFileName = loaded.name;
        patternSelection = null;
        patternSelectionMode = false;
        _historyRecordedForGesture = false;
      });
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เปิดไฟล์ $currentFileLabel แล้ว')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เปิดไฟล์ไม่สำเร็จ: $error')));
    }
  }

  Future<void> _pickCustomColor() async {
    final pickedColor = await showDialog<Color?>(
      context: context,
      builder: (dialogContext) {
        return ColorPickerDialog(
          initialColor: selectedColor ?? const Color(0xFF0F766E),
        );
      },
    );

    if (pickedColor == null) {
      return;
    }

    _selectColor(pickedColor);
  }

  void _pickPhColor(PhColorSwatch swatch) {
    _selectColor(swatch.color);
  }

  Future<void> _openPhColorHelp() async {
    final initialIndex = phPalette.indexWhere(
      (swatch) => selectedColor == swatch.color,
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return PhColorHelpDialog(
          swatches: phPalette,
          initialIndex: initialIndex < 0 ? 0 : initialIndex,
        );
      },
    );
  }

  Future<void> _importPixelImage() async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Images',
            extensions: ['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp'],
          ),
        ],
      );
      if (file == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      final importSettings = await showDialog<PixelImageImportSettings>(
        context: context,
        builder: (dialogContext) {
          return PixelImageImportDialog(
            maxColumns: workbook.columns,
            maxRows: workbook.rows,
          );
        },
      );
      if (importSettings == null) {
        return;
      }

      final targetColumns = importSettings.mode == PixelImageImportMode.full
          ? workbook.columns
          : importSettings.columns;
      final targetRows = importSettings.mode == PixelImageImportMode.full
          ? workbook.rows
          : importSettings.rows;

      final imageBytes = await file.readAsBytes();
      final importedCells = await PixelImageService.buildPixelGrid(
        imageBytes: imageBytes,
        columns: targetColumns,
        rows: targetRows,
        maxColors: importSettings.maxColors,
      );
      final nextSheet = GridSheet.blank(
        name: activeSheet.name,
        rows: workbook.rows,
        columns: workbook.columns,
      );
      for (
        var row = 0;
        row < importedCells.length && row < workbook.rows;
        row++
      ) {
        final importedRow = importedCells[row];
        for (
          var column = 0;
          column < importedRow.length && column < workbook.columns;
          column++
        ) {
          nextSheet.cells[row][column] = importedRow[column];
        }
      }
      _applyWorkbookChange(
        workbook.replaceSheet(workbook.activeSheetIndex, nextSheet),
      );
      setState(() {
        patternSelection = null;
        patternSelectionMode = false;
        _historyRecordedForGesture = false;
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('นำเข้ารูปภาพ ${file.name} แล้ว')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('นำเข้ารูปภาพไม่สำเร็จ: $error')));
    }
  }

  Future<void> _saveFile({bool saveAs = false}) async {
    try {
      final saved = await WorkbookStorage.saveWorkbook(
        workbook: workbook,
        currentPath: saveAs ? null : currentFilePath,
        suggestedFileName:
            currentFileName ?? WorkbookStorage.defaultFileName(DateTime.now()),
      );

      _applyWorkbook(workbook, filePath: saved.path, fileName: saved.name);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกไฟล์ ${saved.name} แล้ว')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกไฟล์ไม่สำเร็จ: $error')));
    }
  }

  Future<void> _exportPdf() async {
    if (exportingPdf) {
      return;
    }

    final exportSettings = await showDialog<PdfExportSettings>(
      context: context,
      builder: (dialogContext) {
        return PdfExportDialog(
          sheetNames: workbook.sheets.map((sheet) => sheet.name).toList(),
          initialSheetIndex: workbook.activeSheetIndex,
        );
      },
    );
    if (exportSettings == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    final sheetsToExport = switch (exportSettings.mode) {
      PdfExportMode.currentSheet => <GridSheet>[
        workbook.sheets[workbook.activeSheetIndex],
      ],
      PdfExportMode.chooseSheet =>
        exportSettings.sheetIndices
            .map((index) => workbook.sheets[index])
            .toList(),
      PdfExportMode.allSheets => workbook.sheets,
    };

    setState(() {
      exportingPdf = true;
    });

    try {
      final bytes = await GridPdfExporter.build(
        sheets: sheetsToExport,
        columns: workbook.columns,
        rows: workbook.rows,
      );
      final fileName = exportSettings.mode == PdfExportMode.allSheets
          ? 'thai_silk_all_sheets.pdf'
          : 'thai_silk_grid.pdf';
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ส่งออก PDF ไม่สำเร็จ: $error')));
    } finally {
      if (mounted) {
        setState(() {
          exportingPdf = false;
        });
      }
    }
  }

  ({int row, int column})? _cellFromLocalPosition(Offset localPosition) {
    final int column = (localPosition.dx / cellSize).floor();
    final int row = (localPosition.dy / cellSize).floor();

    if (column < 0 ||
        column >= workbook.columns ||
        row < 0 ||
        row >= workbook.rows) {
      return null;
    }

    return (row: row, column: column);
  }

  void _paintCellFromLocalPosition(
    Offset localPosition, {
    bool recordHistory = true,
  }) {
    final cell = _cellFromLocalPosition(localPosition);
    if (cell == null) {
      return;
    }

    final row = cell.row;
    final column = cell.column;
    final Color? paintColor = eraseMode ? null : selectedColor;
    if (activeSheet.cells[row][column] == paintColor) {
      return;
    }

    if (recordHistory) {
      _recordGestureHistoryIfNeeded();
    }

    setState(() {
      activeSheet.cells[row][column] = paintColor;
    });
  }

  void _startPatternSelection(Offset localPosition) {
    final cell = _cellFromLocalPosition(localPosition);
    if (cell == null) {
      return;
    }

    setState(() {
      patternSelection = PatternSelection(
        startRow: cell.row,
        startColumn: cell.column,
        endRow: cell.row,
        endColumn: cell.column,
      );
    });
  }

  void _updatePatternSelection(Offset localPosition) {
    final currentSelection = patternSelection;
    if (currentSelection == null) {
      _startPatternSelection(localPosition);
      return;
    }

    final cell = _cellFromLocalPosition(localPosition);
    if (cell == null) {
      return;
    }

    setState(() {
      patternSelection = PatternSelection(
        startRow: currentSelection.startRow,
        startColumn: currentSelection.startColumn,
        endRow: cell.row,
        endColumn: cell.column,
      );
    });
  }

  void _repeatPattern(PatternRepeatDirection direction) {
    final selection = patternSelection;
    if (selection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกบล็อคแพทเทิร์นก่อน')),
      );
      return;
    }

    final nextCells = PatternRepeatService.repeat(
      cells: activeSheet.cells,
      selection: selection,
      direction: direction,
      horizontalSpacing: horizontalRepeatSpacing,
      verticalSpacing: verticalRepeatSpacing,
    );

    final nextSheet = activeSheet.copyWith(cells: nextCells);
    _applyWorkbookChange(
      workbook.replaceSheet(workbook.activeSheetIndex, nextSheet),
    );
  }

  Widget _buildSheetTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.grid_view_rounded, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (
                      var index = 0;
                      index < workbook.sheets.length;
                      index++
                    ) ...[
                      _SheetTab(
                        title: workbook.sheets[index].name,
                        selected: index == workbook.activeSheetIndex,
                        onTap: () => _selectSheet(index),
                      ),
                      const SizedBox(width: 8),
                    ],
                    OutlinedButton.icon(
                      onPressed: _addSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('เพิ่มชีต'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<_SheetMenuAction>(
              tooltip: 'จัดการชีต',
              onSelected: (action) {
                switch (action) {
                  case _SheetMenuAction.rename:
                    _renameActiveSheet();
                    break;
                  case _SheetMenuAction.delete:
                    _deleteActiveSheet();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: _SheetMenuAction.rename,
                  child: Text('เปลี่ยนชื่อชีต'),
                ),
                if (workbook.sheets.length > 1)
                  const PopupMenuItem(
                    value: _SheetMenuAction.delete,
                    child: Text('ลบชีตนี้'),
                  ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.more_horiz),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gridSize = Size(
      workbook.columns * cellSize,
      workbook.rows * cellSize,
    );
    final canvasBaseSize = Size(
      gridSize.width + pageMargin * 2,
      gridSize.height + pageMargin * 2,
    );

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
            const _UndoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            const _UndoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
            const _RedoIntent(),
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): const _RedoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            const _RedoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              _undo();
              return null;
            },
          ),
          _RedoIntent: CallbackAction<_RedoIntent>(
            onInvoke: (_) {
              _redo();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool wideLayout = constraints.maxWidth >= 1024;

                  final canvas = GridCanvas(
                    baseSize: canvasBaseSize,
                    cells: activeSheet.cells,
                    selection: patternSelection,
                    cellSize: cellSize,
                    pageMargin: pageMargin,
                    zoomLevel: zoomLevel,
                    minZoom: minZoom,
                    maxZoom: maxZoom,
                    onZoomChanged: (nextZoom) {
                      setState(() {
                        zoomLevel = nextZoom;
                      });
                    },
                    onTapDown: patternSelectionMode
                        ? _startPatternSelection
                        : _paintCellFromLocalPosition,
                    onInteractionEnd: _endGestureHistory,
                    onDragStart: patternSelectionMode
                        ? _startPatternSelection
                        : _paintCellFromLocalPosition,
                    onDragUpdate: patternSelectionMode
                        ? _updatePatternSelection
                        : (localPosition) => _paintCellFromLocalPosition(
                            localPosition,
                            recordHistory: false,
                          ),
                  );

                  final controls = ControlsPanel(
                    theme: theme,
                    palette: palette,
                    sheetColors: activeSheetColors,
                    phPalette: phPalette,
                    selectedColor: selectedColor,
                    eraseMode: eraseMode,
                    filledCount: filledCount,
                    sheetCount: workbook.sheets.length,
                    activeSheetName: activeSheet.name,
                    currentFileLabel: currentFileLabel,
                    onPickColor: (color) => _selectColor(color),
                    onPickPhColor: _pickPhColor,
                    onOpenPhHelp: _openPhColorHelp,
                    onPickCustomColor: _pickCustomColor,
                    onPickEraser: () => _selectColor(null, erase: true),
                    onClearAll: _clearAll,
                    onExportPdf: _exportPdf,
                    onOpenFile: _openFile,
                    onImportPixelImage: _importPixelImage,
                    onSaveFile: () => _saveFile(),
                    onSaveFileAs: () => _saveFile(saveAs: true),
                    onUndo: _undo,
                    onRedo: _redo,
                    canUndo: canUndo,
                    canRedo: canRedo,
                    patternSelectionMode: patternSelectionMode,
                    patternSelection: patternSelection,
                    onTogglePatternSelectionMode: _togglePatternSelectionMode,
                    onClearPatternSelection: _clearPatternSelection,
                    onRepeatPatternHorizontal: () =>
                        _repeatPattern(PatternRepeatDirection.horizontal),
                    onRepeatPatternVertical: () =>
                        _repeatPattern(PatternRepeatDirection.vertical),
                    onRepeatPatternDiagonalDownRight: () => _repeatPattern(
                      PatternRepeatDirection.diagonalDownRight,
                    ),
                    onRepeatPatternDiagonalUpRight: () =>
                        _repeatPattern(PatternRepeatDirection.diagonalUpRight),
                    onRepeatPatternTile: () =>
                        _repeatPattern(PatternRepeatDirection.tile),
                    horizontalRepeatSpacing: horizontalRepeatSpacing,
                    verticalRepeatSpacing: verticalRepeatSpacing,
                    onHorizontalRepeatSpacingIncrease:
                        _increaseHorizontalRepeatSpacing,
                    onHorizontalRepeatSpacingDecrease:
                        _decreaseHorizontalRepeatSpacing,
                    onHorizontalRepeatSpacingChanged:
                        _setHorizontalRepeatSpacing,
                    onVerticalRepeatSpacingIncrease:
                        _increaseVerticalRepeatSpacing,
                    onVerticalRepeatSpacingDecrease:
                        _decreaseVerticalRepeatSpacing,
                    onVerticalRepeatSpacingChanged: _setVerticalRepeatSpacing,
                    columns: workbook.columns,
                    rows: workbook.rows,
                    zoomLevel: zoomLevel,
                    isExportingPdf: exportingPdf,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                    onResetZoom: _resetZoom,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.colorScheme.brightness == Brightness.dark
                            ? const [Color(0xFF101816), Color(0xFF17231F)]
                            : const [Color(0xFFFAE5E6), Color(0xFFF8EFF0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildSheetTabs(context),
                          const SizedBox(height: 20),
                          Expanded(
                            child: wideLayout
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: PaperShell(child: canvas),
                                      ),
                                      const SizedBox(width: 20),
                                      SizedBox(width: 340, child: controls),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: SingleChildScrollView(
                                          child: controls,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        flex: 5,
                                        child: PaperShell(child: canvas),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTab extends StatelessWidget {
  const _SheetTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = selected
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            title,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

enum _SheetMenuAction { rename, delete }

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}
