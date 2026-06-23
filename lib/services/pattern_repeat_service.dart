import 'package:flutter/material.dart';

import '../models/pattern_selection.dart';

enum PatternRepeatDirection {
  horizontal,
  vertical,
  diagonalDownRight,
  diagonalUpRight,
  tile,
}

class PatternRepeatService {
  static List<List<Color?>> repeat({
    required List<List<Color?>> cells,
    required PatternSelection selection,
    required PatternRepeatDirection direction,
    int horizontalSpacing = 0,
    int verticalSpacing = 0,
  }) {
    if (cells.isEmpty || cells.first.isEmpty) {
      return cells;
    }

    final normalizedSelection = selection.normalized();
    final nextCells = _cloneCells(cells);
    final block = _extractBlock(cells, normalizedSelection);
    final repeatHorizontalSpacing = horizontalSpacing < 0
        ? 0
        : horizontalSpacing;
    final repeatVerticalSpacing = verticalSpacing < 0 ? 0 : verticalSpacing;
    final horizontalStep = normalizedSelection.width + repeatHorizontalSpacing;
    final verticalStep = normalizedSelection.height + repeatVerticalSpacing;

    switch (direction) {
      case PatternRepeatDirection.horizontal:
        _repeatHorizontally(
          nextCells: nextCells,
          block: block,
          selection: normalizedSelection,
          horizontalStep: horizontalStep,
        );
        break;
      case PatternRepeatDirection.vertical:
        _repeatVertically(
          nextCells: nextCells,
          block: block,
          selection: normalizedSelection,
          verticalStep: verticalStep,
        );
        break;
      case PatternRepeatDirection.diagonalDownRight:
        _repeatDiagonally(
          nextCells: nextCells,
          block: block,
          selection: normalizedSelection,
          verticalStep: verticalStep,
          horizontalStep: horizontalStep,
          rowDirection: 1,
        );
        break;
      case PatternRepeatDirection.diagonalUpRight:
        _repeatDiagonally(
          nextCells: nextCells,
          block: block,
          selection: normalizedSelection,
          verticalStep: verticalStep,
          horizontalStep: horizontalStep,
          rowDirection: -1,
        );
        break;
      case PatternRepeatDirection.tile:
        _tileAcrossGrid(
          nextCells: nextCells,
          block: block,
          horizontalStep: horizontalStep,
          verticalStep: verticalStep,
        );
        break;
    }

    return nextCells;
  }

  static void _repeatHorizontally({
    required List<List<Color?>> nextCells,
    required List<List<Color?>> block,
    required PatternSelection selection,
    required int horizontalStep,
  }) {
    for (var rowOffset = 0; rowOffset < block.length; rowOffset++) {
      final targetRow = selection.startRow + rowOffset;
      if (targetRow < 0 || targetRow >= nextCells.length) {
        continue;
      }

      for (
        var targetColumn = selection.startColumn;
        targetColumn < nextCells.first.length;
        targetColumn += horizontalStep
      ) {
        for (
          var columnOffset = 0;
          columnOffset < block[rowOffset].length;
          columnOffset++
        ) {
          final sourceColumn = targetColumn + columnOffset;
          if (sourceColumn < 0 || sourceColumn >= nextCells.first.length) {
            continue;
          }

          nextCells[targetRow][sourceColumn] = block[rowOffset][columnOffset];
        }
      }
    }
  }

  static void _repeatVertically({
    required List<List<Color?>> nextCells,
    required List<List<Color?>> block,
    required PatternSelection selection,
    required int verticalStep,
  }) {
    for (
      var columnOffset = 0;
      columnOffset < block.first.length;
      columnOffset++
    ) {
      final targetColumn = selection.startColumn + columnOffset;
      if (targetColumn < 0 || targetColumn >= nextCells.first.length) {
        continue;
      }

      for (
        var targetRow = selection.startRow;
        targetRow < nextCells.length;
        targetRow += verticalStep
      ) {
        for (var rowOffset = 0; rowOffset < block.length; rowOffset++) {
          final sourceRow = targetRow + rowOffset;
          if (sourceRow < 0 || sourceRow >= nextCells.length) {
            continue;
          }

          nextCells[sourceRow][targetColumn] = block[rowOffset][columnOffset];
        }
      }
    }
  }

  static void _repeatDiagonally({
    required List<List<Color?>> nextCells,
    required List<List<Color?>> block,
    required PatternSelection selection,
    required int verticalStep,
    required int horizontalStep,
    required int rowDirection,
  }) {
    for (
      var targetRow = selection.startRow, targetColumn = selection.startColumn;
      targetColumn < nextCells.first.length &&
          targetRow >= 0 &&
          targetRow < nextCells.length;
      targetRow += verticalStep * rowDirection, targetColumn += horizontalStep
    ) {
      _stampBlock(
        nextCells: nextCells,
        block: block,
        row: targetRow,
        column: targetColumn,
      );
    }
  }

  static void _tileAcrossGrid({
    required List<List<Color?>> nextCells,
    required List<List<Color?>> block,
    required int horizontalStep,
    required int verticalStep,
  }) {
    for (var row = 0; row < nextCells.length; row += verticalStep) {
      for (
        var column = 0;
        column < nextCells.first.length;
        column += horizontalStep
      ) {
        _stampBlock(
          nextCells: nextCells,
          block: block,
          row: row,
          column: column,
        );
      }
    }
  }

  static List<List<Color?>> _extractBlock(
    List<List<Color?>> cells,
    PatternSelection selection,
  ) {
    return List.generate(selection.height, (rowOffset) {
      final sourceRow = selection.startRow + rowOffset;
      return List.generate(selection.width, (columnOffset) {
        final sourceColumn = selection.startColumn + columnOffset;
        return cells[sourceRow][sourceColumn];
      });
    });
  }

  static void _stampBlock({
    required List<List<Color?>> nextCells,
    required List<List<Color?>> block,
    required int row,
    required int column,
  }) {
    for (var rowOffset = 0; rowOffset < block.length; rowOffset++) {
      final targetRow = row + rowOffset;
      if (targetRow < 0 || targetRow >= nextCells.length) {
        continue;
      }

      for (
        var columnOffset = 0;
        columnOffset < block[rowOffset].length;
        columnOffset++
      ) {
        final targetColumn = column + columnOffset;
        if (targetColumn < 0 || targetColumn >= nextCells[targetRow].length) {
          continue;
        }

        nextCells[targetRow][targetColumn] = block[rowOffset][columnOffset];
      }
    }
  }

  static List<List<Color?>> _cloneCells(List<List<Color?>> cells) {
    return cells.map((row) => List<Color?>.from(row)).toList();
  }
}
