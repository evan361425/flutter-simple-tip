import 'package:flutter_test/flutter_test.dart';
import 'package:simple_tip/src/tip_position_delegate.dart';

void main() {
  test('should update old delegate', () {
    final delegate1 = TipPositionDelegate(
      preferBelow: true,
      target: Offset.zero,
      verticalOffset: 0,
    );
    final delegate2 = TipPositionDelegate(
      preferBelow: false,
      target: Offset.zero,
      verticalOffset: 0,
    );

    expect(delegate1.shouldRelayout(delegate2), isTrue);
  });
}
