import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/pixel_image_service.dart';

enum PixelImageImportMode { full, custom }

class PixelImageImportSettings {
  const PixelImageImportSettings({
    required this.mode,
    required this.columns,
    required this.rows,
    required this.maxColors,
    required this.fitMode,
  });

  final PixelImageImportMode mode;
  final int columns;
  final int rows;
  final int maxColors;
  final PixelImageFitMode fitMode;
}

class PixelImageImportDialog extends StatefulWidget {
  const PixelImageImportDialog({
    super.key,
    required this.maxColumns,
    required this.maxRows,
    required this.previewImage,
    required this.fileName,
  });

  final int maxColumns;
  final int maxRows;
  final ui.Image previewImage;
  final String fileName;

  @override
  State<PixelImageImportDialog> createState() => _PixelImageImportDialogState();
}

class _PixelImageImportDialogState extends State<PixelImageImportDialog> {
  late PixelImageImportMode _mode;
  late PixelImageFitMode _fitMode;
  late final TextEditingController _columnsController;
  late final TextEditingController _rowsController;
  late final TextEditingController _maxColorsController;

  @override
  void initState() {
    super.initState();
    _mode = PixelImageImportMode.full;
    _fitMode = PixelImageFitMode.cover;
    final defaults = _initialCustomGrid();
    _columnsController = TextEditingController(
      text: defaults.columns.toString(),
    );
    _rowsController = TextEditingController(text: defaults.rows.toString());
    _maxColorsController = TextEditingController(text: '24');
    _columnsController.addListener(_handleSettingsChanged);
    _rowsController.addListener(_handleSettingsChanged);
    _maxColorsController.addListener(_handleSettingsChanged);
  }

  ({int columns, int rows}) _initialCustomGrid() {
    final width = widget.previewImage.width;
    final height = widget.previewImage.height;
    final maxSide = math.max(width, height);
    if (width <= 0 || height <= 0 || maxSide <= 0) {
      return (
        columns: _defaultGridSize(widget.maxColumns),
        rows: _defaultGridSize(widget.maxRows),
      );
    }

    final limit = math.min(24, math.min(widget.maxColumns, widget.maxRows));
    final scale = limit / maxSide;
    return (
      columns: _clampSize((width * scale).round(), widget.maxColumns),
      rows: _clampSize((height * scale).round(), widget.maxRows),
    );
  }

  int _defaultGridSize(int maxSize) {
    if (maxSize <= 0) {
      return 1;
    }

    return math.min(maxSize, 24);
  }

  int _clampSize(int value, int maxSize) {
    return value.clamp(1, math.max(1, maxSize)).toInt();
  }

  int _parseSize(String value, int fallback, int maxSize) {
    final parsed = int.tryParse(value);
    final nextValue = parsed ?? fallback;
    return nextValue.clamp(1, math.max(1, maxSize)).toInt();
  }

  int get _targetColumns {
    if (_mode == PixelImageImportMode.full) {
      return widget.maxColumns;
    }

    return _parseSize(_columnsController.text, 1, widget.maxColumns);
  }

  int get _targetRows {
    if (_mode == PixelImageImportMode.full) {
      return widget.maxRows;
    }

    return _parseSize(_rowsController.text, 1, widget.maxRows);
  }

  int get _maxColors {
    return _parseSize(_maxColorsController.text, 24, 256);
  }

  void _confirm() {
    final settings = PixelImageImportSettings(
      mode: _mode,
      columns: _targetColumns,
      rows: _targetRows,
      maxColors: _maxColors,
      fitMode: _fitMode,
    );
    Navigator.of(context).pop(settings);
  }

  @override
  void dispose() {
    _columnsController.removeListener(_handleSettingsChanged);
    _rowsController.removeListener(_handleSettingsChanged);
    _maxColorsController.removeListener(_handleSettingsChanged);
    _columnsController.dispose();
    _rowsController.dispose();
    _maxColorsController.dispose();
    super.dispose();
  }

  void _handleSettingsChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final previewSizeLabel =
        '${widget.previewImage.width} x ${widget.previewImage.height} px';
    final outputSizeLabel = '$_targetColumns x $_targetRows ช่อง';
    final fitModeLabel = _fitMode == PixelImageFitMode.cover
        ? 'เติมเต็มตาราง'
        : 'รักษาสัดส่วน';
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return AlertDialog(
      title: const Text('นำเข้ารูปภาพ'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: SingleChildScrollView(
          child: _buildDialogBody(
            context,
            isWide: isWide,
            previewSizeLabel: previewSizeLabel,
            outputSizeLabel: outputSizeLabel,
            fitModeLabel: fitModeLabel,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('นำเข้า')),
      ],
    );
  }

  Widget _buildDialogBody(
    BuildContext context, {
    required bool isWide,
    required String previewSizeLabel,
    required String outputSizeLabel,
    required String fitModeLabel,
  }) {
    final preview = _buildPreviewCard(
      context,
      previewSizeLabel: previewSizeLabel,
      outputSizeLabel: outputSizeLabel,
      fitModeLabel: fitModeLabel,
    );
    final settings = _buildSettingsCard(context);

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: preview),
          const SizedBox(width: 20),
          Expanded(child: settings),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [preview, const SizedBox(height: 16), settings],
    );
  }

  Widget _buildPreviewCard(
    BuildContext context, {
    required String previewSizeLabel,
    required String outputSizeLabel,
    required String fitModeLabel,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'พรีวิวต้นฉบับและผลลัพธ์ก่อนนำเข้า',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: _previewAspectRatio(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: widget.previewImage.width.toDouble(),
                        height: widget.previewImage.height.toDouble(),
                        child: RawImage(
                          image: widget.previewImage,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetricChip(context, 'ต้นฉบับ', previewSizeLabel),
                _buildMetricChip(context, 'นำเข้า', outputSizeLabel),
                _buildMetricChip(context, 'ฟิต', fitModeLabel),
                _buildMetricChip(context, 'สี', '$_maxColors'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _mode == PixelImageImportMode.full
                  ? 'โหมดนี้ใช้เต็มพื้นที่ของตารางที่มีอยู่'
                  : 'โหมดนี้กำหนดจำนวนช่องเองได้ แล้วจะพอดีกับรูปที่เลือก',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final theme = Theme.of(context);
    final isCustom = _mode == PixelImageImportMode.custom;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ตัวเลือกนำเข้า',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'เลือกขนาดตารางและวิธีวางภาพให้เหมาะกับงาน',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ขนาดตาราง',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('เต็มตาราง'),
                  selected: _mode == PixelImageImportMode.full,
                  onSelected: (_) =>
                      setState(() => _mode = PixelImageImportMode.full),
                ),
                ChoiceChip(
                  label: const Text('กำหนดเอง'),
                  selected: _mode == PixelImageImportMode.custom,
                  onSelected: (_) =>
                      setState(() => _mode = PixelImageImportMode.custom),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedOpacity(
              opacity: isCustom ? 1 : 0.45,
              duration: const Duration(milliseconds: 160),
              child: IgnorePointer(
                ignoring: !isCustom,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        controller: _columnsController,
                        label: 'กว้าง',
                        hint: '${widget.maxColumns}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberField(
                        controller: _rowsController,
                        label: 'สูง',
                        hint: '${widget.maxRows}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'การวางภาพ',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('เติมเต็มตาราง'),
                  selected: _fitMode == PixelImageFitMode.cover,
                  onSelected: (_) =>
                      setState(() => _fitMode = PixelImageFitMode.cover),
                ),
                ChoiceChip(
                  label: const Text('รักษาสัดส่วน'),
                  selected: _fitMode == PixelImageFitMode.contain,
                  onSelected: (_) =>
                      setState(() => _fitMode = PixelImageFitMode.contain),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _fitMode == PixelImageFitMode.cover
                  ? 'ภาพจะขยายเต็มพื้นที่และอาจถูกครอปบางส่วน'
                  : 'ภาพจะไม่ถูกครอป พื้นที่ว่างจะเป็นช่องโปร่งใส',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'จำนวนสี',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildNumberField(
              controller: _maxColorsController,
              label: 'สีสูงสุด',
              hint: '24',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in [8, 16, 24, 32, 64])
                  ActionChip(
                    label: Text('$preset'),
                    onPressed: () => setState(() {
                      _maxColorsController.text = preset.toString();
                    }),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMetricChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _previewAspectRatio() {
    final width = widget.previewImage.width;
    final height = widget.previewImage.height;
    if (width <= 0 || height <= 0) {
      return 1;
    }

    return width / height;
  }
}
