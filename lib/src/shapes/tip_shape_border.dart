import 'package:flutter/material.dart';

/// Shape has a pointer for target widget(position)
class TipShapeBorder extends ShapeBorder {
  /// Width of arrow
  ///
  /// Default: `20.0`
  final double arrowWidth;

  /// Height of arrow
  ///
  /// Default: `10.0`
  final double arrowHeight;

  /// Arc of arrow
  ///
  /// Should between `1` and `0`
  ///
  /// Default: `4.0`
  final double arrowArc;

  /// Radius of arrow
  final double radius;

  /// The position of target
  final Offset target;

  const TipShapeBorder({
    required this.target,
    this.radius = 4.0,
    this.arrowWidth = 20.0,
    this.arrowHeight = 10.0,
    this.arrowArc = 0.0,
  }) : assert(arrowArc <= 1.0 && arrowArc >= 0.0);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
      rect.topLeft,
      rect.bottomRight - Offset(0, arrowHeight),
    );

    final isDown = target.dy > rect.top;
    final x = arrowWidth, r = 1 - arrowArc;
    final y = isDown ? arrowHeight : -arrowHeight;

    return Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
      ..moveTo(target.dx + arrowWidth / 2, isDown ? rect.bottom : rect.top)
      ..relativeLineTo(-x / 2 * r, y * r)
      ..relativeQuadraticBezierTo(
          -x / 2 * (1 - r), y * (1 - r), -x * (1 - r), 0)
      ..relativeLineTo(-x / 2 * r, -y * r);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
