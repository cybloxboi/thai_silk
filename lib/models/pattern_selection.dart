import 'package:flutter/foundation.dart';

@immutable
class PatternSelection {
  const PatternSelection({
    required this.startRow,
    required this.startColumn,
    required this.endRow,
    required this.endColumn,
  });

  final int startRow;
  final int startColumn;
  final int endRow;
  final int endColumn;

  PatternSelection normalized() {
    return PatternSelection(
      startRow: startRow <= endRow ? startRow : endRow,
      startColumn: startColumn <= endColumn ? startColumn : endColumn,
      endRow: startRow <= endRow ? endRow : startRow,
      endColumn: startColumn <= endColumn ? endColumn : startColumn,
    );
  }

  int get width => (endColumn - startColumn).abs() + 1;

  int get height => (endRow - startRow).abs() + 1;

  bool get isValid => width > 0 && height > 0;
}
