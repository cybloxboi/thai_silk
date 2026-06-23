import 'grid_sheet.dart';

class GridWorkbook {
  GridWorkbook({
    required this.columns,
    required this.rows,
    required this.sheets,
    required this.activeSheetIndex,
  });

  factory GridWorkbook.initial({required int columns, required int rows}) {
    return GridWorkbook(
      columns: columns,
      rows: rows,
      sheets: [GridSheet.blank(name: 'Sheet 1', rows: rows, columns: columns)],
      activeSheetIndex: 0,
    );
  }

  factory GridWorkbook.fromJson(Map<String, dynamic> json) {
    final columns = (json['columns'] as num?)?.toInt() ?? 84;
    final rows = (json['rows'] as num?)?.toInt() ?? 57;
    final rawSheets = json['sheets'];

    final sheets = <GridSheet>[];
    if (rawSheets is List && rawSheets.isNotEmpty) {
      for (final rawSheet in rawSheets) {
        if (rawSheet is Map<String, dynamic>) {
          sheets.add(
            GridSheet.fromJson(rawSheet, rows: rows, columns: columns),
          );
        }
      }
    }

    if (sheets.isEmpty) {
      sheets.add(
        GridSheet.blank(name: 'Sheet 1', rows: rows, columns: columns),
      );
    }

    final activeSheetIndex = (json['activeSheetIndex'] as num?)?.toInt() ?? 0;

    return GridWorkbook(
      columns: columns,
      rows: rows,
      sheets: sheets,
      activeSheetIndex: activeSheetIndex.clamp(0, sheets.length - 1).toInt(),
    );
  }

  final int columns;
  final int rows;
  final List<GridSheet> sheets;
  final int activeSheetIndex;

  GridSheet get activeSheet => sheets[activeSheetIndex];

  GridWorkbook copyWith({
    int? columns,
    int? rows,
    List<GridSheet>? sheets,
    int? activeSheetIndex,
  }) {
    final nextSheets =
        sheets ?? this.sheets.map((sheet) => sheet.copyWith()).toList();
    final nextActiveSheetIndex = (activeSheetIndex ?? this.activeSheetIndex)
        .clamp(0, nextSheets.length - 1)
        .toInt();

    return GridWorkbook(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      sheets: nextSheets,
      activeSheetIndex: nextActiveSheetIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': 1,
      'columns': columns,
      'rows': rows,
      'activeSheetIndex': activeSheetIndex,
      'sheets': sheets.map((sheet) => sheet.toJson()).toList(),
    };
  }

  GridWorkbook addSheet(GridSheet sheet) {
    return copyWith(
      sheets: [...sheets, sheet],
      activeSheetIndex: sheets.length,
    );
  }

  GridWorkbook replaceSheet(int index, GridSheet sheet) {
    final nextSheets = sheets.toList();
    nextSheets[index] = sheet;
    return copyWith(sheets: nextSheets);
  }

  GridWorkbook removeSheet(int index) {
    if (sheets.length == 1) {
      return this;
    }

    final nextSheets = sheets.toList()..removeAt(index);
    final nextActiveSheetIndex = index <= activeSheetIndex
        ? (activeSheetIndex - 1).clamp(0, nextSheets.length - 1).toInt()
        : activeSheetIndex;

    return copyWith(sheets: nextSheets, activeSheetIndex: nextActiveSheetIndex);
  }

  GridWorkbook renameSheet(int index, String name) {
    final nextSheets = sheets.toList();
    nextSheets[index] = nextSheets[index].copyWith(name: name);
    return copyWith(sheets: nextSheets);
  }
}
