import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_tip/simple_tip.dart';

void main() {
  test('fulfill test coverage', () {
    const border = TipShapeBorder(target: Offset.zero);

    border.getInnerPath(Rect.zero);

    expect(identical(border.scale(1.0), border), isTrue);
  });
}
