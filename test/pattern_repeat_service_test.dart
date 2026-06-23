import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_silk/models/pattern_selection.dart';
import 'package:thai_silk/services/pattern_repeat_service.dart';

void main() {
  const red = Color(0xFFFF0000);
  const green = Color(0xFF00FF00);
  const blue = Color(0xFF0000FF);
  const yellow = Color(0xFFFFFF00);

  List<List<Color?>> buildGrid(int rows, int columns) {
    return List.generate(rows, (_) => List<Color?>.filled(columns, null));
  }

  test('repeats a block horizontally with spacing', () {
    final cells = buildGrid(6, 6);
    cells[1][0] = red;
    cells[1][1] = green;
    cells[2][0] = blue;
    cells[2][1] = yellow;

    final repeated = PatternRepeatService.repeat(
      cells: cells,
      selection: const PatternSelection(
        startRow: 1,
        startColumn: 0,
        endRow: 2,
        endColumn: 1,
      ),
      direction: PatternRepeatDirection.horizontal,
      horizontalSpacing: 1,
    );

    expect(repeated[1], [red, green, null, red, green, null]);
    expect(repeated[2], [blue, yellow, null, blue, yellow, null]);
    expect(repeated[0], everyElement(isNull));
    expect(repeated[3], everyElement(isNull));
  });

  test('repeats a block vertically', () {
    final cells = buildGrid(6, 6);
    cells[0][2] = red;
    cells[0][3] = green;
    cells[1][2] = blue;
    cells[1][3] = yellow;

    final repeated = PatternRepeatService.repeat(
      cells: cells,
      selection: const PatternSelection(
        startRow: 0,
        startColumn: 2,
        endRow: 1,
        endColumn: 3,
      ),
      direction: PatternRepeatDirection.vertical,
    );

    expect(repeated[0][2], red);
    expect(repeated[0][3], green);
    expect(repeated[2][2], red);
    expect(repeated[2][3], green);
    expect(repeated[4][2], red);
    expect(repeated[4][3], green);
  });

  test('repeats a block diagonally down-right', () {
    final cells = buildGrid(6, 6);
    cells[0][0] = red;
    cells[0][1] = green;
    cells[1][0] = blue;
    cells[1][1] = yellow;

    final repeated = PatternRepeatService.repeat(
      cells: cells,
      selection: const PatternSelection(
        startRow: 0,
        startColumn: 0,
        endRow: 1,
        endColumn: 1,
      ),
      direction: PatternRepeatDirection.diagonalDownRight,
    );

    expect(repeated[0][0], red);
    expect(repeated[0][1], green);
    expect(repeated[1][0], blue);
    expect(repeated[1][1], yellow);
    expect(repeated[2][2], red);
    expect(repeated[2][3], green);
    expect(repeated[3][2], blue);
    expect(repeated[3][3], yellow);
    expect(repeated[4][4], red);
    expect(repeated[5][5], yellow);
  });

  test('repeats a block diagonally up-right', () {
    final cells = buildGrid(6, 6);
    cells[4][0] = red;
    cells[4][1] = green;
    cells[5][0] = blue;
    cells[5][1] = yellow;

    final repeated = PatternRepeatService.repeat(
      cells: cells,
      selection: const PatternSelection(
        startRow: 4,
        startColumn: 0,
        endRow: 5,
        endColumn: 1,
      ),
      direction: PatternRepeatDirection.diagonalUpRight,
    );

    expect(repeated[4][0], red);
    expect(repeated[4][1], green);
    expect(repeated[5][0], blue);
    expect(repeated[5][1], yellow);
    expect(repeated[2][2], red);
    expect(repeated[2][3], green);
    expect(repeated[3][2], blue);
    expect(repeated[3][3], yellow);
  });

  test('tiles a block across the full grid', () {
    final cells = buildGrid(6, 6);
    cells[2][2] = red;
    cells[2][3] = green;
    cells[3][2] = blue;
    cells[3][3] = yellow;

    final repeated = PatternRepeatService.repeat(
      cells: cells,
      selection: const PatternSelection(
        startRow: 2,
        startColumn: 2,
        endRow: 3,
        endColumn: 3,
      ),
      direction: PatternRepeatDirection.tile,
      horizontalSpacing: 1,
      verticalSpacing: 2,
    );

    expect(repeated[0][0], red);
    expect(repeated[0][1], green);
    expect(repeated[1][0], blue);
    expect(repeated[1][1], yellow);
    expect(repeated[0][3], red);
    expect(repeated[2][0], isNull);
    expect(repeated[4][0], red);
    expect(repeated[4][3], red);
  });
}
