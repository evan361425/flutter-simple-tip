import 'package:flutter/material.dart';

import 'shapes/tip_shape_border.dart';
import 'tip_position_delegate.dart';

typedef ContentBuilder = Widget Function(
    BuildContext context, VoidCallback closer);

class TipContent extends StatelessWidget {
  // user provide

  final String? title;
  final String? message;
  final ContentBuilder? contentBuilder;
  final BoxConstraints? boxConstraints;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double verticalOffset;
  final String closerText;
  final bool preferBelow;

  // package provide

  final Animation<double> animation;
  final VoidCallback hideTip;
  final Offset target;

  const TipContent({
    Key? key,
    this.title,
    this.message,
    this.contentBuilder,
    this.boxConstraints,
    this.decoration,
    this.textStyle,
    required this.padding,
    required this.margin,
    required this.verticalOffset,
    required this.closerText,
    required this.preferBelow,
    required this.animation,
    required this.hideTip,
    required this.target,
  })  : assert(message != null || contentBuilder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final boxConstraints =
        this.boxConstraints ?? BoxConstraints(minHeight: 24.0);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final decoration = this.decoration ??
        ShapeDecoration(
          color: (isDark ? Colors.white : Colors.grey[700]!).withOpacity(0.9),
          shape: TipShapeBorder(arrowArc: 0.1, target: target),
        );
    final textStyle = this.textStyle ??
        theme.textTheme.bodyText1!.copyWith(
          color: isDark ? Colors.black : Colors.white,
        );

    final child = contentBuilder != null
        ? contentBuilder!(context, hideTip)
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(title!, style: textStyle.copyWith(fontSize: 22)),
              Text(message!),
              GestureDetector(
                onTap: hideTip,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: theme.buttonColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    closerText,
                    style: textStyle.copyWith(
                      color: theme.buttonTheme.colorScheme!.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          );

    return Positioned.fill(
      child: FadeTransition(
        opacity: animation,
        child: CustomSingleChildLayout(
          delegate: TipPositionDelegate(
            target: target,
            verticalOffset: verticalOffset,
            preferBelow: preferBelow,
          ),
          child: ConstrainedBox(
            constraints: boxConstraints,
            child: DefaultTextStyle(
              style: textStyle,
              child: Container(
                decoration: decoration,
                padding: padding,
                margin: margin,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
