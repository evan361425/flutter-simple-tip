import 'dart:async';

import 'package:flutter/material.dart';

import 'tip_content.dart';

/// A widget for showing tips to it's child and automatically setup position.
///
/// The idea is mainly copy from material [Tooltip].
///
/// Example:
/// ```
/// Widget build(context) {
///   return Tip(
///     message: 'Now it's time to see your profile!',
///     child: TextButton(
///       onPressed: navigateToProfile,
///       child: Text('See profile'),
///     ),
///   );
/// }
/// ```
class SimpleTip extends StatefulWidget {
  /// The title to display in the tip.
  final String? title;

  /// The text to display in the tip.
  ///
  /// This value will also use for semantics.
  final String? message;

  /// Content of tip
  ///
  /// This will "win" when [message] and [content] both set.
  ///
  /// Example:
  /// ```
  /// final content = Text('hi');
  /// ```
  final Widget? content;

  /// Tip's content constraints
  ///
  /// Default:
  /// ```
  /// BoxConstraints(minHeight: 24.0)
  /// ```
  final BoxConstraints boxConstraints;

  /// Tip's container decoration
  ///
  /// Default:
  /// ```
  /// ShapeDecoration(
  ///   color: (isDark ? Colors.white : Colors.grey[700]!).withOpacity(0.9),
  ///   shape: TipShapeBorder(arrowArc: 0.1, target: target),
  /// )
  /// ```
  final Decoration? decoration;

  /// Tip's text default style
  ///
  /// Default:
  /// ```
  /// TextStyle()
  /// ```
  final TextStyle textStyle;

  /// A callback after the start of closing tip.
  ///
  /// This will be needed if you handle tip by filesystem, eg: SharedPreferences, hive
  ///
  /// Example:
  /// ```
  /// final isDisabled = instance.read('mytip') == 1;
  /// final onClosed = () {
  ///   instance.write('mytip', 1);
  /// }
  /// ```
  final VoidCallback onClosed;

  /// The amount of space by which to inset the tip's content.
  ///
  /// Default:
  /// ```
  /// EdgeInsets.all(8.0)
  /// ```
  final EdgeInsets padding;

  /// The empty space that surrounds the tip.
  ///
  /// Defines the tip's outer [Container.margin]. By default, a
  /// long tip will span the width of its window. If long enough,
  /// a tip might also span the window's height. This property allows
  /// one to define how much space the tip must be inset from the edges
  /// of their display window.
  ///
  /// Default:
  /// ```
  /// EdgeInsets.symmetric(horizontal: 16.0)
  /// ```
  final EdgeInsets margin;

  /// The vertical gap between the widget and the displayed tip.
  ///
  /// When [preferBelow] is set to true and tips have sufficient space to
  /// display themselves, this property defines how much vertical space
  /// tips will position themselves under their corresponding widgets.
  /// Otherwise, tips will position themselves above their corresponding
  /// widgets with the given offset.
  ///
  /// Default: `24.0`
  final double verticalOffset;

  /// Text of button to close tip.
  ///
  /// Default: `OK`
  final String closerText;

  /// The length of time that a tip will wait for showing.
  ///
  /// Defaults to 300 milliseconds (same as PageRoute default `transitionDuration`).
  final Duration waitDuration;

  /// Whether the tip's [message] should be excluded from the semantics
  /// tree.
  ///
  /// Defaults to false. A tip will add a [Semantics] label that is set to
  /// [SimpleTip.message]. Set this property to true if the app is going to
  /// provide its own custom semantics label.
  final bool excludeFromSemantics;

  /// Disable tip.
  ///
  /// Wrap [SimpleTip] with `StatefulWidget` and dynamically set this value.
  ///
  /// Default: `false`
  final bool isDisabled;

  /// Whether the tips defaults to being displayed below the widget.
  ///
  /// Defaults to true. If there is insufficient space to display the tip in
  /// the preferred direction, the tip will be displayed in the opposite
  /// direction.
  final bool preferBelow;

  /// Whether use backdrop
  ///
  /// Default: `false`
  final bool withBackdrop;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  const SimpleTip({
    Key? key,
    this.title,
    this.message,
    this.content,
    this.boxConstraints = const BoxConstraints(minHeight: 24.0),
    this.decoration,
    this.textStyle = const TextStyle(),
    required this.onClosed,
    this.padding = const EdgeInsets.all(8.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
    this.verticalOffset = 24.0,
    this.closerText = 'OK',
    this.waitDuration = const Duration(milliseconds: 300),
    this.excludeFromSemantics = false,
    this.isDisabled = false,
    this.preferBelow = true,
    this.withBackdrop = false,
    required this.child,
  })  : assert(message != null || content != null),
        super(key: key);

  @override
  SimpleTipState createState() => SimpleTipState();
}

/// State o [SimpleTip]
class SimpleTipState extends State<SimpleTip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // save in state avoid missing widget when removing tips
  late bool _withBackdrop;
  OverlayEntry? _entry;
  Timer? _showTimer;

  static OverlayEntry? _backdrop;
  static bool _backdropIsBuilt = false;
  static final List<VoidCallback> _backdropCb = <VoidCallback>[];

  @override
  Widget build(BuildContext context) {
    if (widget.isDisabled) {
      _removeEntry();
      return widget.child;
    }
    assert(Overlay.of(context, debugRequiredFor: widget) != null);
    _showTimer ??= Timer(widget.waitDuration, showEntry);

    return Semantics(
      label: widget.excludeFromSemantics ? null : widget.message,
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _removeEntry();
    _removeBackdrop();
    _showTimer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _removeEntry();
    _removeBackdrop();
    _controller.dispose();
    super.dispose();
  }

  /// Gracefully closing tip
  ///
  /// It will trigger [AnimationController.reverse]
  void hideEntry() {
    _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _withBackdrop = widget.withBackdrop;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 75),
      vsync: this,
    )..addStatusListener(_handleStatusChanged);
  }

  /// Shows the tip
  void showEntry() {
    _showTimer?.cancel();
    _showTimer = null;
    _createNewEntry();
    _controller.forward();
  }

  void _createNewEntry() {
    final overlayState = Overlay.of(context)!;

    final box = context.findRenderObject()! as RenderBox;
    final target = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayState.context.findRenderObject(),
    );

    // insert backdrop first
    if (_withBackdrop) {
      if (!_backdropIsBuilt) {
        // We create this widget outside of the overlay entry's builder to prevent
        // updated values from happening to leak into the overlay when the overlay
        // rebuilds.
        final Widget backdropOverlay = SizedBox.expand(
          child: GestureDetector(onTap: () {
            // avoid ConcurrentModificationError: changing iteration during iterate
            for (var cb in _backdropCb) {
              cb();
            }
            _removeBackdrop();
          }),
        );
        _backdrop = OverlayEntry(builder: (_) => backdropOverlay);
        overlayState.insert(_backdrop!);
        _backdropIsBuilt = true;
        _backdropCb.add(hideEntry);
      } else {
        _backdropCb.add(hideEntry);
      }
    }

    final Widget overlay = Directionality(
      textDirection: Directionality.of(context),
      child: TipContent(
        // user provide
        title: widget.title,
        message: widget.message,
        preferBelow: widget.preferBelow,
        boxConstraints: widget.boxConstraints,
        closerText: widget.closerText,
        content: widget.content,
        decoration: widget.decoration,
        textStyle: widget.textStyle,
        margin: widget.margin,
        padding: widget.padding,
        verticalOffset: widget.verticalOffset,
        // package provide
        animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn,
        ),
        target: target,
        hideTip: hideEntry,
      ),
    );
    _entry = OverlayEntry(builder: (BuildContext context) => overlay);
    overlayState.insert(_entry!);
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _removeEntry();
      widget.onClosed();
    }
  }

  void _removeEntry() {
    if (_entry != null) {
      _showTimer?.cancel();
      _showTimer = null;
      _entry!.remove();
      _entry = null;
    }
  }

  void _removeBackdrop() {
    _backdrop?.remove();
    _backdrop = null;
    _backdropIsBuilt = false;
    _backdropCb.clear();
  }
}
