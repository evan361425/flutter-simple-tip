import 'package:flutter/material.dart';

import 'simple_tip.dart';
import 'tip_grouper.dart';
import 'state_manager/state_manager.dart';

/// Tips show in order.
///
/// Make [SimpleTip] more flexable.
///
/// Example:
/// ```
/// Widget build(context) {
///   final key = GlobalKey<TipGrouperState>();
///   return OrderedTip(
///     id: 'id1',
///     grouper: key,
///     order: 1,
///     message: 'Tip for profile',
///     child: TextButton(
///       onPressed: navigateToProfile,
///       child: Text('Profile'),
///     ),
///   );
/// }
/// ```
class OrderedTip extends StatefulWidget {
  /// ID of this tip.
  ///
  /// It should be unique in the same group
  final String id;

  /// State of grouper that contains many [OrderedTip]
  ///
  /// If one screen have multiple groups, it is possible to
  /// show many tips in one screen.
  final GlobalKey<TipGrouperState>? grouper;

  /// Title of [SimpleTip]
  ///
  /// See details in [SimpleTip.title]
  final String? title;

  /// Message of [SimpleTip]
  ///
  /// See details in [SimpleTip.message]
  final String? message;

  /// Content of [SimpleTip]
  ///
  /// See details in [SimpleTip.contentBuilder]
  final Widget? content;

  /// The version it should be.
  ///
  /// [SimpleTip.isDisabled] will be `false` if version is not equal
  /// to given version from [getVersion]
  ///
  /// Implement:
  /// ```
  /// if (TipOrdered.getVersion(groupId, id) != version) {
  ///   enabledTip = id;
  ///   break; // break the loop
  /// }
  /// ```
  ///
  /// Default set to `0`.
  final int version;

  /// The order to show the tip, lower order higher priority.
  ///
  /// Implement:
  /// ```
  /// tipList.sort((a, b) => a.order.compareTo(b.order))
  /// ```
  ///
  /// Default set to `0`.
  final int order;

  /// Tip's content constraints
  ///
  /// More detail on [SimpleTip.boxConstraints]
  final BoxConstraints boxConstraints;

  /// Tip's container decoration
  ///
  /// More detail on [SimpleTip.decoration]
  final Decoration? decoration;

  /// Tip's text default style
  ///
  /// More detail on [SimpleTip.textStyle]
  final TextStyle textStyle;

  /// The amount of space by which to inset the tip's content.
  ///
  /// More detail on [SimpleTip.padding]
  final EdgeInsets padding;

  /// The empty space that surrounds the tip.
  ///
  /// More detail on [SimpleTip.margin]
  final EdgeInsets margin;

  /// The vertical gap between the widget and the displayed tip.
  ///
  /// More detail on [SimpleTip.verticalOffset]
  final double verticalOffset;

  /// Text of button to close tip.
  ///
  /// More detail on [SimpleTip.closerText]
  final String closerText;

  /// The length of time that a tip will wait for showing.
  ///
  /// More detail on [SimpleTip.waitDuration]
  final Duration waitDuration;

  /// Whether the tip's [message] should be excluded from the semantics
  /// tree.
  ///
  /// More detail on [SimpleTip.excludeFromSemantics]
  final bool excludeFromSemantics;

  /// Whether the tips defaults to being displayed below the widget.
  ///
  /// More detail on [SimpleTip.preferBelow]
  final bool preferBelow;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  const OrderedTip({
    Key? key,
    required this.id,
    this.grouper,
    this.title,
    this.message,
    this.content,
    this.version = 0,
    this.order = 0,
    this.boxConstraints = const BoxConstraints(minHeight: 24.0),
    this.decoration,
    this.textStyle = const TextStyle(),
    this.padding = const EdgeInsets.all(8.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
    this.verticalOffset = 24.0,
    this.closerText = 'OK',
    this.waitDuration = const Duration(milliseconds: 300),
    this.excludeFromSemantics = false,
    this.preferBelow = true,
    required this.child,
  }) : super(key: key);

  @override
  OrderedTipState createState() => OrderedTipState();
}

class OrderedTipState extends State<OrderedTip> with TipItem {
  bool retired = false;

  bool isEnabled = false;

  @override
  String get id => widget.id;

  int get order => widget.order;

  @override
  int get version => widget.version;

  @override
  Widget build(BuildContext context) {
    if (widget.grouper == null) return widget.child;

    return SimpleTip(
      title: widget.title,
      message: widget.message,
      content: widget.content,
      boxConstraints: widget.boxConstraints,
      decoration: widget.decoration,
      textStyle: widget.textStyle,
      padding: widget.padding,
      margin: widget.margin,
      verticalOffset: widget.verticalOffset,
      closerText: widget.closerText,
      waitDuration: widget.waitDuration,
      excludeFromSemantics: widget.excludeFromSemantics,
      preferBelow: widget.preferBelow,
      isDisabled: !isEnabled,
      onClosed: () {
        retired = true;
        final grouper = widget.grouper!.currentState;

        grouper?.widget.stateManager.tipRead(grouper.widget.id, this);
        grouper?.raiseElection();
      },
      child: widget.child,
    );
  }

  void disable() {
    if (mounted) {
      setState(() {
        retired = true;
        isEnabled = false;
      });
    }
  }

  Future<void> enable() async {
    if (mounted) {
      setState(() {
        isEnabled = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.grouper?.currentState?.nominate(this);
  }
}
