import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PixelImageImportMode { full, custom }

class PixelImageImportSettings {
  const PixelImageImportSettings({
    required this.mode,
    required this.columns,
    required this.rows,
    required this.maxColors,
  });

  final PixelImageImportMode mode;
  final int columns;
  final int rows;
  final int maxColors;
}

class PixelImageImportDialog extends StatefulWidget {
  const PixelImageImportDialog({
    super.key,
    required this.maxColumns,
    required this.maxRows,
  });

  final int maxColumns;
  final int maxRows;

  @override
  State<PixelImageImportDialog> createState() => _PixelImageImportDialogState();
}

class _PixelImageImportDialogState extends State<PixelImageImportDialog> {
  late PixelImageImportMode _mode;
  late final TextEditingController _columnsController;
  late final TextEditingController _rowsController;
  late final TextEditingController _maxColorsController;

  @override
  void initState() {
    super.initState();
    _mode = PixelImageImportMode.full;
    _columnsController = TextEditingController(
      text: _defaultSize(widget.maxColumns),
    );
    _rowsController = TextEditingController(text: _defaultSize(widget.maxRows));
    _maxColorsController = TextEditingController(text: '16');
  }

  String _defaultSize(int maxSize) {
    if (maxSize <= 0) {
      return '1';
    }

    return (maxSize < 24 ? maxSize : 24).toString();
  }

  @override
  void dispose() {
    _columnsController.dispose();
    _rowsController.dispose();
    _maxColorsController.dispose();
    super.dispose();
  }

  int _parseSize(String value, int fallback, int maxSize) {
    final parsed = int.tryParse(value);
    final nextValue = parsed ?? fallback;
    return nextValue.clamp(1, maxSize).toInt();
  }

  void _confirm() {
    final settings = PixelImageImportSettings(
      mode: _mode,
      columns: _parseSize(_columnsController.text, 1, widget.maxColumns),
      rows: _parseSize(_rowsController.text, 1, widget.maxRows),
      maxColors: _parseSize(_maxColorsController.text, 16, 256),
    );
    Navigator.of(context).pop(settings);
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = _mode == PixelImageImportMode.custom;

    return AlertDialog(
      title: const Text('นำเข้ารูปภาพ'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เลือกรูปแบบการแปลงภาพเป็นพิกเซล',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                title: 'เต็มตาราง',
                subtitle: 'ใช้ขนาด ${widget.maxColumns} x ${widget.maxRows}',
                selected: _mode == PixelImageImportMode.full,
                onTap: () => setState(() => _mode = PixelImageImportMode.full),
              ),
              const SizedBox(height: 10),
              _buildOptionCard(
                title: 'กำหนดขนาด',
                subtitle: 'กำหนดความกว้างและความสูงเอง',
                selected: _mode == PixelImageImportMode.custom,
                onTap: () =>
                    setState(() => _mode = PixelImageImportMode.custom),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: isCustom ? 1 : 0.45,
                child: IgnorePointer(
                  ignoring: !isCustom,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _columnsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'กว้าง',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _rowsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'สูง',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _maxColorsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'จำนวนสี',
                  helperText: 'รวมเฉดสีใกล้เคียงให้เหลือ 1-256 สี',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final backgroundColor = selected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
        : theme.colorScheme.surfaceContainerHighest;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.circle_outlined,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
