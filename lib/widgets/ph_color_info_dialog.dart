import 'package:flutter/material.dart';

import '../models/ph_color_swatch.dart';
import 'info_tile.dart';

class PhColorHelpDialog extends StatefulWidget {
  const PhColorHelpDialog({
    super.key,
    required this.swatches,
    required this.initialIndex,
  });

  final List<PhColorSwatch> swatches;
  final int initialIndex;

  @override
  State<PhColorHelpDialog> createState() => _PhColorHelpDialogState();
}

class _PhColorHelpDialogState extends State<PhColorHelpDialog> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, widget.swatches.length - 1);
  }

  PhColorSwatch get _selectedSwatch => widget.swatches[_selectedIndex];

  Widget _buildStepItem(int index, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('คำแนะนำการย้อมสีไหมจากครั่ง'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เลือก pH ด้านล่างเพื่อดูข้อมูล และแตะสีในพาเลตเพื่อเลือกใช้งาน',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0; index < widget.swatches.length; index++)
                    ChoiceChip(
                      label: Text('pH ${widget.swatches[index].pHValue}'),
                      selected: _selectedIndex == index,
                      selectedColor: colorScheme.primaryContainer,
                      onSelected: (_) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 84,
                decoration: BoxDecoration(
                  color: _selectedSwatch.color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x33000000)),
                ),
              ),
              const SizedBox(height: 16),
              InfoTile(label: 'pH', value: '${_selectedSwatch.pHValue}'),
              const SizedBox(height: 10),
              InfoTile(label: 'HEX', value: _selectedSwatch.hex),
              const SizedBox(height: 10),
              InfoTile(label: 'RGB', value: _selectedSwatch.rgb),
              const SizedBox(height: 10),
              InfoTile(label: 'HSV', value: _selectedSwatch.hsv),
              const SizedBox(height: 10),
              InfoTile(label: 'L*a*b*', value: _selectedSwatch.lab),
              const SizedBox(height: 16),
              Text(
                'ส่วนประกอบที่ต้องใช้',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (
                var index = 0;
                index < _selectedSwatch.requirements.length;
                index++
              )
                _buildStepItem(index, _selectedSwatch.requirements[index]),
              const SizedBox(height: 16),
              Text(
                'วิธีทำการย้อมสี',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (var index = 0; index < _selectedSwatch.steps.length; index++)
                _buildStepItem(index, _selectedSwatch.steps[index]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ปิด'),
        ),
      ],
    );
  }
}
