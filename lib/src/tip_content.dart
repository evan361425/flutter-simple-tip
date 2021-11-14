import 'package:flutter/material.dart';

import 'shapes/tip_shape_border.dart';
import 'tip_position_delegate.dart';

class TipContent extends StatelessWidget {
  // user provide

  final String? title;
  final String? message;
  final Widget? content;
  final BoxConstraints boxConstraints;
  final Decoration? decoration;
  final TextStyle textStyle;
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
    this.content,
    required this.boxConstraints,
    this.decoration,
    required this.textStyle,
    required this.padding,
    required this.margin,
    required this.verticalOffset,
    required this.closerText,
    required this.preferBelow,
    required this.animation,
    required this.hideTip,
    required this.target,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final decoration = this.decoration ??
        ShapeDecoration(
          color: (isDark ? Colors.white : Colors.grey[700]!).withOpacity(0.9),
          shape: TipShapeBorder(arrowArc: 0.1, target: target),
        );

    final content = this.content == null
        ? [
            if (title != null)
              Text(title!, style: textStyle.copyWith(fontSize: 22)),
            Text(message!),
          ]
        : [this.content!];

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
              style: textStyle.copyWith(
                color: isDark ? Colors.black : Colors.white,
              ),
              child: Container(
                decoration: decoration,
                padding: padding,
                margin: margin,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...content,
                    GestureDetector(
                      onTap: hideTip,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                        margin: const EdgeInsets.only(top: 8.0),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          closerText,
                          style: textStyle.copyWith(
                            color: isDark
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
