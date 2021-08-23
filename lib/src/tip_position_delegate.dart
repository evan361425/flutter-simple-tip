import 'package:flutter/material.dart';

/// A delegate for computing the layout of a tip to be displayed above or
/// bellow a target specified in the global coordinate system.
class TipPositionDelegate extends SingleChildLayoutDelegate {
  /// The offset of the target the tip is positioned near in the global
  /// coordinate system.
  final Offset target;

  /// The amount of vertical distance between the target and the displayed
  /// tip.
  final double verticalOffset;

  /// Whether the tip is displayed below its widget by default.
  ///
  /// If there is insufficient space to display the tip in the preferred
  /// direction, the tip will be displayed in the opposite direction.
  final bool preferBelow;

  /// Creates a delegate for computing the layout of a tip.
  ///
  /// The arguments must not be null.
  TipPositionDelegate({
    required this.target,
    required this.verticalOffset,
    required this.preferBelow,
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return positionDependentBox(
      size: size,
      childSize: childSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: preferBelow,
    );
  }

  @override
  bool shouldRelayout(TipPositionDelegate oldDelegate) {
    return target != oldDelegate.target ||
        verticalOffset != oldDelegate.verticalOffset ||
        preferBelow != oldDelegate.preferBelow;
  }
}
