import 'package:flutter/material.dart';

enum PdfExportMode { currentSheet, chooseSheet, allSheets }

class PdfExportSettings {
  const PdfExportSettings({required this.mode, required this.sheetIndices});

  final PdfExportMode mode;
  final List<int> sheetIndices;
}

class PdfExportDialog extends StatefulWidget {
  const PdfExportDialog({
    super.key,
    required this.sheetNames,
    required this.initialSheetIndex,
  });

  final List<String> sheetNames;
  final int initialSheetIndex;

  @override
  State<PdfExportDialog> createState() => _PdfExportDialogState();
}

class _PdfExportDialogState extends State<PdfExportDialog> {
  late PdfExportMode _mode;
  late final Set<int> _selectedSheetIndices;

  @override
  void initState() {
    super.initState();
    _mode = PdfExportMode.currentSheet;
    _selectedSheetIndices = {widget.initialSheetIndex};
  }

  void _confirm() {
    if (_mode != PdfExportMode.chooseSheet) {
      Navigator.of(
        context,
      ).pop(PdfExportSettings(mode: _mode, sheetIndices: const []));
      return;
    }

    if (_selectedSheetIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกอย่างน้อย 1 ชีต')),
      );
      return;
    }

    final selectedIndices = _selectedSheetIndices.toList()..sort();
    Navigator.of(
      context,
    ).pop(PdfExportSettings(mode: _mode, sheetIndices: selectedIndices));
  }

  @override
  Widget build(BuildContext context) {
    final isChooseSheet = _mode == PdfExportMode.chooseSheet;

    return AlertDialog(
      title: const Text('ส่งออก PDF'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เลือกขอบเขตของไฟล์ PDF',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                title: 'ชีตที่เลือกอยู่',
                subtitle: 'ส่งออกเฉพาะชีตปัจจุบัน',
                selected: _mode == PdfExportMode.currentSheet,
                onTap: () => setState(() => _mode = PdfExportMode.currentSheet),
              ),
              const SizedBox(height: 10),
              _buildOptionCard(
                title: 'เลือกชีตเอง',
                subtitle: 'ติ๊กเลือกได้หลายชีต',
                selected: _mode == PdfExportMode.chooseSheet,
                onTap: () => setState(() => _mode = PdfExportMode.chooseSheet),
              ),
              const SizedBox(height: 10),
              _buildOptionCard(
                title: 'ทุกชีตในไฟล์',
                subtitle: 'สร้าง PDF ครบทุกชีตทีละหน้า',
                selected: _mode == PdfExportMode.allSheets,
                onTap: () => setState(() => _mode = PdfExportMode.allSheets),
              ),
              const SizedBox(height: 14),
              if (isChooseSheet) ...[
                Text(
                  'เลือกชีตที่ต้องการส่งออก',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5D625D),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 260,
                  child: Material(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < widget.sheetNames.length;
                            index++
                          ) ...[
                            if (index > 0) const Divider(height: 1),
                            CheckboxListTile(
                              value: _selectedSheetIndices.contains(index),
                              title: Text(widget.sheetNames[index]),
                              secondary: Text('${index + 1}'),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedSheetIndices.add(index);
                                  } else {
                                    _selectedSheetIndices.remove(index);
                                  }
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        FilledButton(onPressed: _confirm, child: const Text('ส่งออก')),
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
        : const Color(0x22000000);
    final backgroundColor = selected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
        : const Color(0xFFF8F8F8);

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
                    : const Color(0xFF6B7280),
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
                        color: const Color(0xFF5D625D),
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
