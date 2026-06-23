import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/grid_sheet.dart';
import '../models/grid_workbook.dart';
import '../services/grid_pdf_exporter.dart';
import '../services/workbook_storage.dart';
import '../widgets/control_panel.dart';
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

  final List<Color> palette = const [
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
    Color(0xFFEAB308),
  ];

  GridWorkbook workbook = GridWorkbook.initial(
    columns: defaultColumns,
    rows: defaultRows,
  );
  Color? selectedColor = const Color(0xFF0F766E);
  bool eraseMode = false;
  double zoomLevel = 1.0;
  bool exportingPdf = false;
  String? currentFilePath;

  GridSheet get activeSheet => workbook.activeSheet;

  int get filledCount => activeSheet.cells.fold<int>(
    0,
    (total, row) => total + row.whereType<Color>().length,
  );

  String get currentFileLabel {
    if (currentFilePath == null || currentFilePath!.trim().isEmpty) {
      return 'ยังไม่บันทึก';
    }

    return currentFilePath!.split(Platform.pathSeparator).last;
  }

  void _applyWorkbook(GridWorkbook nextWorkbook, {String? filePath}) {
    setState(() {
      workbook = nextWorkbook;
      if (filePath != null) {
        currentFilePath = filePath;
      }
    });
  }

  void _selectColor(Color? color, {bool erase = false}) {
    setState(() {
      selectedColor = color;
      eraseMode = erase;
    });
  }

  void _clearAll() {
    setState(() {
      for (final row in activeSheet.cells) {
        row.fillRange(0, row.length, null);
      }
    });
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
    final existingNames = workbook.sheets.map((sheet) => sheet.name).toSet();
    if (!existingNames.contains(baseName)) {
      return baseName;
    }

    var suffix = 2;
    while (existingNames.contains('$baseName $suffix')) {
      suffix++;
    }
    return '$baseName $suffix';
  }

  void _addSheet() {
    final sheetName = _makeUniqueSheetName('Sheet');
    final nextWorkbook = workbook.addSheet(
      GridSheet.blank(
        name: sheetName,
        rows: workbook.rows,
        columns: workbook.columns,
      ),
    );
    _applyWorkbook(nextWorkbook);
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
    _applyWorkbook(workbook.renameSheet(workbook.activeSheetIndex, uniqueName));
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
          content: Text('ต้องการลบ "${activeSheet.name}" ใช่ไหม'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton.tonal(
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

    _applyWorkbook(workbook.removeSheet(workbook.activeSheetIndex));
  }

  Future<void> _openFile() async {
    try {
      final loaded = await WorkbookStorage.loadFromPickedFile();
      if (loaded == null) {
        return;
      }

      _applyWorkbook(loaded.workbook, filePath: loaded.path);
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

  Future<void> _saveFile({bool saveAs = false}) async {
    try {
      final path = saveAs
          ? await WorkbookStorage.writeToSelectedPath(
              workbook: workbook,
              currentPath: null,
            )
          : await WorkbookStorage.writeToSelectedPath(
              workbook: workbook,
              currentPath: currentFilePath,
            );

      _applyWorkbook(workbook, filePath: path);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'บันทึกไฟล์ ${path.split(Platform.pathSeparator).last} แล้ว',
          ),
        ),
      );
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

    setState(() {
      exportingPdf = true;
    });

    try {
      final bytes = await GridPdfExporter.build(
        cells: activeSheet.cells,
        columns: workbook.columns,
        rows: workbook.rows,
      );
      await Printing.sharePdf(bytes: bytes, filename: 'thai_silk_grid.pdf');
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

  void _paintCellFromLocalPosition(Offset localPosition) {
    final int column = localPosition.dx ~/ cellSize;
    final int row = localPosition.dy ~/ cellSize;

    if (column < 0 ||
        column >= workbook.columns ||
        row < 0 ||
        row >= workbook.rows) {
      return;
    }

    final Color? paintColor = eraseMode ? null : selectedColor;
    if (activeSheet.cells[row][column] == paintColor) {
      return;
    }

    setState(() {
      activeSheet.cells[row][column] = paintColor;
    });
  }

  Widget _buildSheetTabs(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF9F5EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: Color(0xFF0F766E)),
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

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool wideLayout = constraints.maxWidth >= 1024;

            final canvas = GridCanvas(
              baseSize: canvasBaseSize,
              cells: activeSheet.cells,
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
              onTapDown: _paintCellFromLocalPosition,
              onDragUpdate: _paintCellFromLocalPosition,
            );

            final controls = ControlsPanel(
              theme: theme,
              palette: palette,
              selectedColor: selectedColor,
              eraseMode: eraseMode,
              filledCount: filledCount,
              sheetCount: workbook.sheets.length,
              activeSheetName: activeSheet.name,
              currentFileLabel: currentFileLabel,
              onPickColor: (color) => _selectColor(color),
              onPickEraser: () => _selectColor(null, erase: true),
              onClearAll: _clearAll,
              onExportPdf: _exportPdf,
              onOpenFile: _openFile,
              onSaveFile: () => _saveFile(),
              onSaveFileAs: () => _saveFile(saveAs: true),
              onAddSheet: _addSheet,
              columns: workbook.columns,
              rows: workbook.rows,
              zoomLevel: zoomLevel,
              isExportingPdf: exportingPdf,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onResetZoom: _resetZoom,
            );

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF4EFE6), Color(0xFFE7F0EC)],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: PaperShell(child: canvas)),
                                const SizedBox(width: 20),
                                SizedBox(width: 340, child: controls),
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(child: controls),
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
    final backgroundColor = selected
        ? const Color(0xFF0F766E)
        : const Color(0xFFF1ECE3);
    final foregroundColor = selected ? Colors.white : const Color(0xFF16302D);

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
