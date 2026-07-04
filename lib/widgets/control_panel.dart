import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pattern_selection.dart';
import '../models/ph_color_swatch.dart';
import '../pages/manual_pdf_page.dart';
import 'color_chip.dart';
import 'info_tile.dart';

enum _ControlSection { files, colors, zoom, pattern }

class ControlsPanel extends StatefulWidget {
  const ControlsPanel({
    super.key,
    required this.theme,
    required this.palette,
    required this.sheetColors,
    required this.selectedColor,
    required this.eraseMode,
    required this.filledCount,
    required this.sheetCount,
    required this.activeSheetName,
    required this.currentFileLabel,
    required this.onPickColor,
    required this.phPalette,
    required this.onPickPhColor,
    required this.onOpenPhHelp,
    required this.onPickCustomColor,
    required this.onPickEraser,
    required this.onClearAll,
    required this.onExportPdf,
    required this.onOpenFile,
    required this.onImportPixelImage,
    required this.onSaveFile,
    required this.onSaveFileAs,
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
  final List<Color> sheetColors;
  final List<PhColorSwatch> phPalette;
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
  final ValueChanged<PhColorSwatch> onPickPhColor;
  final VoidCallback onOpenPhHelp;
  final VoidCallback onPickCustomColor;
  final VoidCallback onPickEraser;
  final VoidCallback onClearAll;
  final VoidCallback onExportPdf;
  final VoidCallback onOpenFile;
  final VoidCallback onImportPixelImage;
  final VoidCallback onSaveFile;
  final VoidCallback onSaveFileAs;
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

class _ControlsPanelState extends State<ControlsPanel>
    with TickerProviderStateMixin {
  late final TextEditingController _horizontalSpacingController;
  late final TextEditingController _verticalSpacingController;
  _ControlSection _selectedSection = _ControlSection.files;

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

  String _colorHex(Color color) {
    final red = (color.r * 255).round().clamp(0, 255).toInt();
    final green = (color.g * 255).round().clamp(0, 255).toInt();
    final blue = (color.b * 255).round().clamp(0, 255).toInt();
    return '#'
            '${red.toRadixString(16).padLeft(2, '0')}'
            '${green.toRadixString(16).padLeft(2, '0')}'
            '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  String _sectionLabel(_ControlSection section) {
    return switch (section) {
      _ControlSection.files => 'ไฟล์และชีต',
      _ControlSection.colors => 'สี',
      _ControlSection.zoom => 'ซูม',
      _ControlSection.pattern => 'แพทเทิร์น',
    };
  }

  IconData _sectionIcon(_ControlSection section) {
    return switch (section) {
      _ControlSection.files => Icons.folder_copy_outlined,
      _ControlSection.colors => Icons.palette_outlined,
      _ControlSection.zoom => Icons.zoom_out_map_outlined,
      _ControlSection.pattern => Icons.grid_on_outlined,
    };
  }

  Widget _buildSectionSelector(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final section in _ControlSection.values)
          ChoiceChip(
            selected: _selectedSection == section,
            showCheckmark: false,
            onSelected: (_) {
              setState(() {
                _selectedSection = section;
              });
            },
            label: Text(_sectionLabel(section)),
            avatar: Icon(
              _sectionIcon(section),
              size: 18,
              color: _selectedSection == section
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildFileSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
            FilledButton.tonalIcon(
              onPressed: widget.onImportPixelImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('นำเข้ารูปภาพ'),
            ),
            FilledButton.icon(
              onPressed: widget.onSaveFile,
              icon: const Icon(Icons.save_outlined),
              label: const Text('บันทึก'),
            ),
            if (!kIsWeb)
              OutlinedButton.icon(
                onPressed: widget.onSaveFileAs,
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('บันทึกเป็น'),
              ),
            FilledButton.icon(
              onPressed: widget.isExportingPdf ? null : widget.onExportPdf,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                widget.isExportingPdf ? 'กำลังสร้าง PDF...' : 'ส่งออก PDF',
              ),
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
      ],
    );
  }

  Widget _buildColorSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'พาเลตสี',
          style: widget.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'แตะช่องบนตารางเพื่อใส่สี และเลือกยางลบเพื่อลบสีในแต่ละช่อง',
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        _buildSheetColorMenu(colorScheme),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: widget.onPickCustomColor,
              icon: const Icon(Icons.color_lens_outlined),
              label: const Text('เลือกสี'),
            ),
            ColorChip(
              color: widget.selectedColor ?? Colors.white,
              selected: !widget.eraseMode,
              onTap: widget.onPickCustomColor,
            ),
            ColorChip(
              color: Colors.white,
              selected: widget.eraseMode,
              onTap: widget.onPickEraser,
              isEraser: true,
              showSelectionCheck: false,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final color in widget.palette)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorChip(
                    color: color,
                    selected:
                        !widget.eraseMode && widget.selectedColor == color,
                    onTap: () => widget.onPickColor(color),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'สีจากครั่ง',
              style: widget.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              key: const Key('ph_help_button'),
              onPressed: widget.onOpenPhHelp,
              icon: const Icon(Icons.help_outline),
              label: const Text('คำแนะนำการย้อมสี'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final swatch in widget.phPalette)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorChip(
                    key: ValueKey('ph_chip_${swatch.pHValue}'),
                    color: swatch.color,
                    selected:
                        !widget.eraseMode &&
                        widget.selectedColor == swatch.color,
                    onTap: () => widget.onPickPhColor(swatch),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'pH ${swatch.pHValue}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: widget.onClearAll,
          icon: const Icon(Icons.delete_outline),
          label: const Text('ล้างทั้งตาราง'),
        ),
      ],
    );
  }

  Widget _buildZoomSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  color: colorScheme.surfaceContainerHighest,
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
      ],
    );
  }

  Widget _buildPatternSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'แพทเทิร์น',
          style: widget.theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'เลือกบล็อกเพื่อทำซ้ำ',
          style: widget.theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
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
                widget.patternSelectionMode ? 'กำลังเลือกบล็อค' : 'เลือกบล็อค',
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
          'ตั้งค่าระยะห่างตามแนว',
          style: widget.theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
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
              label: const Text('ทแยงลง'),
            ),
            FilledButton.icon(
              onPressed: widget.patternSelection == null
                  ? null
                  : widget.onRepeatPatternDiagonalUpRight,
              icon: const Icon(Icons.north_east),
              label: const Text('ทแยงขึ้น'),
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
      ],
    );
  }

  Widget _buildSectionContent(ColorScheme colorScheme) {
    return switch (_selectedSection) {
      _ControlSection.files => _buildFileSection(colorScheme),
      _ControlSection.colors => _buildColorSection(colorScheme),
      _ControlSection.zoom => _buildZoomSection(colorScheme),
      _ControlSection.pattern => _buildPatternSection(colorScheme),
    };
  }

  Future<void> _showInfoDialog({
    required String title,
    required List<Widget> children,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showManualDialog() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ManualPdfPage()));
  }

  Future<void> _showCreditsDialog() {
    return _showInfoDialog(
      title: 'เครดิตผู้สร้าง',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thai Silk',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'แอปพลิเคชันสำหรับออกแบบลวดลายผ้าไหมไทย พร้อมเครื่องมือจัดการสี แพทเทิร์น และตารางการออกแบบ',
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'ผู้พัฒนา',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.person_outline),
          title: Text('นางสาวเกวลิน มีเพียร'),
        ),
        const ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.person_outline),
          title: Text('นางสาวพาขวัญ บุตสีนนท์'),
        ),
        const ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.person_outline),
          title: Text('นายศุกลณัฏฐ์ ถาวรฟัง'),
        ),
        const SizedBox(height: 8),
        Text('ชั้นมัธยมศึกษาปีที่ 6 โรงเรียนอำนาจเจริญ'),
        const SizedBox(height: 16),
        const Text(
          'เกี่ยวกับแอป',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Thai Silk พัฒนาขึ้นเพื่อช่วยออกแบบลวดลายผ้าไหมไทยได้อย่างสะดวก รองรับการระบายสี การสร้างและทำซ้ำแพทเทิร์น รวมถึงการจัดการไฟล์งานเพื่อเพิ่มประสิทธิภาพในการออกแบบ',
        ),
      ],
    );
  }

  Widget _buildSheetColorMenu(ColorScheme colorScheme) {
    return PopupMenuButton<Color>(
      enabled: widget.sheetColors.isNotEmpty,
      tooltip: 'เลือกสีจากชีตนี้',
      constraints: const BoxConstraints(maxWidth: 260, maxHeight: 360),
      onSelected: widget.onPickColor,
      itemBuilder: (context) {
        return [
          for (final color in widget.sheetColors)
            PopupMenuItem<Color>(
              value: color,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_colorHex(color))),
                  if (!widget.eraseMode && widget.selectedColor == color)
                    Icon(Icons.check, color: colorScheme.primary, size: 18),
                ],
              ),
            ),
        ];
      },
      child: Material(
        color: widget.sheetColors.isEmpty
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.56)
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.palette_outlined,
                size: 18,
                color: widget.sheetColors.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                widget.sheetColors.isEmpty
                    ? 'ยังไม่มีสีในชีต'
                    : 'สีในชีตนี้ (${widget.sheetColors.length})',
                style: widget.theme.textTheme.labelLarge?.copyWith(
                  color: widget.sheetColors.isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_drop_down,
                color: widget.sheetColors.isEmpty
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
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
    final colorScheme = widget.theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
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
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ตาราง ${widget.columns} x ${widget.rows} ช่อง, ช่องละ 1 x 1 cm',
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
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
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _showManualDialog,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('คู่มือ'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _showCreditsDialog,
                    icon: const Icon(Icons.info_outline),
                    label: const Text('เครดิตผู้สร้าง'),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              const Divider(),
              const SizedBox(height: 7),
              Text(
                'เลือกฟังก์ชัน',
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildSectionSelector(colorScheme),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ClipRect(
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_selectedSection),
                  child: _buildSectionContent(colorScheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
