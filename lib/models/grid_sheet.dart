import 'package:flutter/material.dart';

class GridSheet {
  GridSheet({required this.name, required this.cells});

  factory GridSheet.blank({
    required String name,
    required int rows,
    required int columns,
  }) {
    return GridSheet(
      name: name,
      cells: List.generate(rows, (_) => List<Color?>.filled(columns, null)),
    );
  }

  factory GridSheet.fromJson(
    Map<String, dynamic> json, {
    required int rows,
    required int columns,
  }) {
    final rawCells = json['cells'];
    final parsedCells = List.generate(rows, (row) {
      final rawRow = rawCells is List && row < rawCells.length
          ? rawCells[row]
          : null;
      return List.generate(columns, (column) {
        final rawValue = rawRow is List && column < rawRow.length
            ? rawRow[column]
            : null;
        if (rawValue is! String || rawValue.isEmpty) {
          return null;
        }
        return _decodeColor(rawValue);
      });
    });

    return GridSheet(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String).trim()
          : 'Sheet',
      cells: parsedCells,
    );
  }

  final String name;
  final List<List<Color?>> cells;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'cells': cells
          .map(
            (row) => row
                .map((color) => color == null ? null : _encodeColor(color))
                .toList(),
          )
          .toList(),
    };
  }

  GridSheet copyWith({String? name, List<List<Color?>>? cells}) {
    return GridSheet(
      name: name ?? this.name,
      cells: cells ?? _cloneCells(this.cells),
    );
  }

  static List<List<Color?>> _cloneCells(List<List<Color?>> cells) {
    return cells.map((row) => List<Color?>.from(row)).toList();
  }

  static String _encodeColor(Color color) {
    return color.toARGB32().toRadixString(16).padLeft(8, '0');
  }

  static Color _decodeColor(String value) {
    final normalized = value.startsWith('#') ? value.substring(1) : value;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) {
      return const Color(0x00000000);
    }

    if (normalized.length <= 6) {
      return Color(0xFF000000 | parsed);
    }

    return Color(parsed);
  }
}
