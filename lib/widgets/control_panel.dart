import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pattern_selection.dart';
import 'color_chip.dart';
import 'info_tile.dart';

class ControlsPanel extends StatefulWidget {
  const ControlsPanel({
    super.key,
    required this.theme,
    required this.palette,
    required this.selectedColor,
    required this.eraseMode,
    required this.filledCount,
    required this.sheetCount,
    required this.activeSheetName,
    required this.currentFileLabel,
    required this.onPickColor,
    required this.onPickEraser,
    required this.onClearAll,
    required this.onExportPdf,
    required this.onOpenFile,
    required this.onSaveFile,
    required this.onSaveFileAs,
    required this.onAddSheet,
    required this.onUndo,
    required this.onRedo,
    required this.canUndo,
    required this.canRedo,
    required this.patternSelectionMode,
    required this.patternSelection,
    required this.onTogglePatternSelectionMode,
    required this.onClearPatternSelection,
    required this.onRepeatPatternHorizontal,
    required this.onRepeatPatternVertical,
    required this.onRepeatPatternDiagonalDownRight,
    required this.onRepeatPatternDiagonalUpRight,
    required this.onRepeatPatternTile,
    required this.horizontalRepeatSpacing,
    required this.verticalRepeatSpacing,
    required this.onHorizontalRepeatSpacingIncrease,
    required this.onHorizontalRepeatSpacingDecrease,
    required this.onHorizontalRepeatSpacingChanged,
    required this.onVerticalRepeatSpacingIncrease,
    required this.onVerticalRepeatSpacingDecrease,
    required this.onVerticalRepeatSpacingChanged,
    required this.columns,
    required this.rows,
    required this.zoomLevel,
    required this.isExportingPdf,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  final ThemeData theme;
  final List<Color> palette;
  final Color? selectedColor;
  final bool eraseMode;
  final int filledCount;
  final int sheetCount;
  final String activeSheetName;
  final String currentFileLabel;
  final int columns;
  final int rows;
  final double zoomLevel;
  final ValueChanged<Color> onPickColor;
  final VoidCallback onPickEraser;
  final VoidCallback onClearAll;
  final VoidCallback onExportPdf;
  final VoidCallback onOpenFile;
  final VoidCallback onSaveFile;
  final VoidCallback onSaveFileAs;
  final VoidCallback onAddSheet;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool canUndo;
  final bool canRedo;
  final bool patternSelectionMode;
  final PatternSelection? patternSelection;
  final VoidCallback onTogglePatternSelectionMode;
  final VoidCallback onClearPatternSelection;
  final VoidCallback onRepeatPatternHorizontal;
  final VoidCallback onRepeatPatternVertical;
  final VoidCallback onRepeatPatternDiagonalDownRight;
  final VoidCallback onRepeatPatternDiagonalUpRight;
  final VoidCallback onRepeatPatternTile;
  final int horizontalRepeatSpacing;
  final int verticalRepeatSpacing;
  final VoidCallback onHorizontalRepeatSpacingIncrease;
  final VoidCallback onHorizontalRepeatSpacingDecrease;
  final ValueChanged<int> onHorizontalRepeatSpacingChanged;
  final VoidCallback onVerticalRepeatSpacingIncrease;
  final VoidCallback onVerticalRepeatSpacingDecrease;
  final ValueChanged<int> onVerticalRepeatSpacingChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;
  final bool isExportingPdf;

  @override
  State<ControlsPanel> createState() => _ControlsPanelState();
}

class _ControlsPanelState extends State<ControlsPanel> {
  late final TextEditingController _horizontalSpacingController;
  late final TextEditingController _verticalSpacingController;

  @override
  void initState() {
    super.initState();
    _horizontalSpacingController = TextEditingController(
      text: widget.horizontalRepeatSpacing.toString(),
    );
    _verticalSpacingController = TextEditingController(
      text: widget.verticalRepeatSpacing.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ControlsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(
      _horizontalSpacingController,
      widget.horizontalRepeatSpacing,
      oldWidget.horizontalRepeatSpacing,
    );
    _syncController(
      _verticalSpacingController,
      widget.verticalRepeatSpacing,
      oldWidget.verticalRepeatSpacing,
    );
  }

  void _syncController(
    TextEditingController controller,
    int nextValue,
    int previousValue,
  ) {
    if (nextValue == previousValue) {
      return;
    }

    final nextText = nextValue.toString();
    if (controller.text == nextText) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
      composing: TextRange.empty,
    );
  }

  @override
  void dispose() {
    _horizontalSpacingController.dispose();
    _verticalSpacingController.dispose();
    super.dispose();
  }

  int _parseSpacing(String value, int fallback) {
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return fallback;
    }

    return parsed.clamp(0, 12);
  }

  Widget _buildSpacingControl({
    required String label,
    required TextEditingController controller,
    required VoidCallback onIncrease,
    required VoidCallback onDecrease,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: widget.theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onChanged: (value) => onChanged(_parseSpacing(value, 0)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onDecrease,
          icon: const Icon(Icons.remove),
          tooltip: 'ลดระยะห่าง',
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          onPressed: onIncrease,
          icon: const Icon(Icons.add),
          tooltip: 'เพิ่มระยะห่าง',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCells = widget.columns * widget.rows;

    return Card(
      elevation: 0,
      color: const Color(0xFFF9F5EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thai Silk',
                style: widget.theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16302D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ตาราง ${widget.columns} x ${widget.rows} ช่อง, ช่องละ 1 x 1 cm',
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5D625D),
                ),
              ),
              const SizedBox(height: 16),
              InfoTile(label: 'ไฟล์งาน', value: widget.currentFileLabel),
              const SizedBox(height: 10),
              InfoTile(
                label: 'ชีตที่ใช้งาน',
                value: '${widget.activeSheetName} • ${widget.sheetCount} ชีต',
              ),
              const SizedBox(height: 14),
              InfoTile(
                label: 'ช่องที่ลงสีแล้ว',
                value: '${widget.filledCount} / $totalCells',
              ),
              const SizedBox(height: 14),
              Text(
                'ไฟล์และชีต',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: widget.onOpenFile,
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('เปิดไฟล์'),
                  ),
                  FilledButton.icon(
                    onPressed: widget.onSaveFile,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('บันทึก'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onSaveFileAs,
                    icon: const Icon(Icons.save_as_outlined),
                    label: const Text('บันทึกเป็น'),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.onAddSheet,
                    icon: const Icon(Icons.add_box_outlined),
                    label: const Text('เพิ่มชีต'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: widget.canUndo ? widget.onUndo : null,
                    icon: const Icon(Icons.undo),
                    label: const Text('ย้อนกลับ'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: widget.canRedo ? widget.onRedo : null,
                    icon: const Icon(Icons.redo),
                    label: const Text('ทำซ้ำ'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'สี',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final color in widget.palette)
                    ColorChip(
                      color: color,
                      selected:
                          !widget.eraseMode && widget.selectedColor == color,
                      onTap: () => widget.onPickColor(color),
                    ),
                  ColorChip(
                    color: Colors.white,
                    selected: widget.eraseMode,
                    onTap: widget.onPickEraser,
                    isEraser: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'แพทเทิร์น',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: widget.onTogglePatternSelectionMode,
                    icon: Icon(
                      widget.patternSelectionMode
                          ? Icons.highlight_alt_outlined
                          : Icons.select_all,
                    ),
                    label: Text(
                      widget.patternSelectionMode
                          ? 'กำลังเลือกบล็อค'
                          : 'เลือกบล็อค',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: widget.patternSelection == null
                        ? null
                        : widget.onClearPatternSelection,
                    icon: const Icon(Icons.clear),
                    label: const Text('ลบการเลือก'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InfoTile(
                label: 'บล็อคที่เลือก',
                value: widget.patternSelection == null
                    ? 'ยังไม่ได้เลือก'
                    : '${widget.patternSelection!.width} x ${widget.patternSelection!.height} ช่อง',
              ),
              const SizedBox(height: 10),
              Text(
                'ลากบนตารางเพื่อเลือกบล็อค แล้วเลือกทิศทางที่ต้องการ',
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5D625D),
                ),
              ),
              const SizedBox(height: 12),
              _buildSpacingControl(
                label: 'แนวนอน',
                controller: _horizontalSpacingController,
                onIncrease: widget.onHorizontalRepeatSpacingIncrease,
                onDecrease: widget.onHorizontalRepeatSpacingDecrease,
                onChanged: widget.onHorizontalRepeatSpacingChanged,
              ),
              const SizedBox(height: 10),
              _buildSpacingControl(
                label: 'แนวตั้ง',
                controller: _verticalSpacingController,
                onIncrease: widget.onVerticalRepeatSpacingIncrease,
                onDecrease: widget.onVerticalRepeatSpacingDecrease,
                onChanged: widget.onVerticalRepeatSpacingChanged,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: widget.patternSelection == null
                        ? null
                        : widget.onRepeatPatternHorizontal,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('ซ้ำแนวนอน'),
                  ),
                  FilledButton.icon(
                    onPressed: widget.patternSelection == null
                        ? null
                        : widget.onRepeatPatternVertical,
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('ซ้ำแนวตั้ง'),
                  ),
                  FilledButton.icon(
                    onPressed: widget.patternSelection == null
                        ? null
                        : widget.onRepeatPatternDiagonalDownRight,
                    icon: const Icon(Icons.south_east),
                    label: const Text('ทแยง ↘'),
                  ),
                  FilledButton.icon(
                    onPressed: widget.patternSelection == null
                        ? null
                        : widget.onRepeatPatternDiagonalUpRight,
                    icon: const Icon(Icons.north_east),
                    label: const Text('ทแยง ↗'),
                  ),
                  FilledButton.icon(
                    onPressed: widget.patternSelection == null
                        ? null
                        : widget.onRepeatPatternTile,
                    icon: const Icon(Icons.grid_on_outlined),
                    label: const Text('Tile เต็มตาราง'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'ซูมกระดาษ',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: widget.onZoomOut,
                    icon: const Icon(Icons.remove),
                    tooltip: 'ย่อ',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3EF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${(widget.zoomLevel * 100).round()}%',
                        textAlign: TextAlign.center,
                        style: widget.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: widget.onZoomIn,
                    icon: const Icon(Icons.add),
                    tooltip: 'ขยาย',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onResetZoom,
                  child: const Text('รีเซ็ตซูม'),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: widget.isExportingPdf ? null : widget.onExportPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  widget.isExportingPdf ? 'กำลังสร้าง PDF...' : 'ส่งออก PDF',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: widget.onClearAll,
                icon: const Icon(Icons.delete_outline),
                label: const Text('ล้างทั้งตาราง'),
              ),
              const SizedBox(height: 12),
              Text(
                'แตะช่องบนตารางเพื่อใส่สี และเลือกยางลบเพื่อลบสีในแต่ละช่อง',
                style: widget.theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5D625D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
