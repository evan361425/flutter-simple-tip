import 'package:flutter/material.dart';

import 'simple_tip.dart';
import 'state_manager/in_memory_state_manager.dart';
import 'state_manager/state_manager.dart';
import 'tip_content.dart';

/// Tips show in order.
///
/// Make [SimpleTip] more flexable.
///
/// Example:
/// ```
/// Widget build(context) {
///   return OrderedTip(
///     groupId: 'group1',
///     id: 'id1',
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
  /// Groups of all ordered tip.
  ///
  /// Expose this for public is only make developer easier controll
  /// their resources, you **SHOULD NOT** depends this.
  ///
  /// It may set to `private` in future.
  static final groups = <String, _RadioGroup>{};

  /// Manage the versions state.
  ///
  /// You should extends [StateManager] for your own state
  /// manager, eg: shared_preferences or Hive.
  ///
  /// See details in https://pub.dev/packages/simple_tip
  static StateManager stateManager = InMemoryStateManager();

  /// ID of this tip.
  ///
  /// It should be unique in the same group
  final String id;

  /// ID of the group that contains many [OrderedTip]
  ///
  /// It should be unique between each groups.
  ///
  /// If one screen have multiple groups, it is possible to
  /// show many tips in one screen.
  final String groupId;

  /// Title of [SimpleTip]
  ///
  /// See details in [SimpleTip.title]
  final String? title;

  /// Message of [SimpleTip]
  ///
  /// See details in [SimpleTip.message]
  final String? message;

  /// Content builder for [SimpleTip]
  ///
  /// See details in [SimpleTip.contentBuilder]
  final ContentBuilder? contentBuilder;

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
  final BoxConstraints? boxConstraints;

  /// Tip's container decoration
  ///
  /// More detail on [SimpleTip.decoration]
  final Decoration? decoration;

  /// Tip's text default style
  ///
  /// More detail on [SimpleTip.textStyle]
  final TextStyle? textStyle;

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

  OrderedTip({
    Key? key,
    required this.id,
    required this.groupId,
    this.title,
    this.message,
    this.contentBuilder,
    this.version = 0,
    this.order = 0,
    this.boxConstraints,
    this.decoration,
    this.textStyle,
    this.padding = const EdgeInsets.all(8.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0),
    this.verticalOffset = 24.0,
    this.closerText = 'OK',
    this.waitDuration = Duration.zero,
    this.excludeFromSemantics = false,
    this.preferBelow = true,
    required this.child,
  }) : super(key: key) {
    group.addCandidate(id: id, version: version, order: order);
  }

  _RadioGroup get group {
    var group = groups[groupId];
    if (group == null) {
      group = _RadioGroup(groupId);
      groups[groupId] = group;
    }

    return group;
  }

  @override
  _OrderedTipState createState() => _OrderedTipState();
}

/// Item pass to [StateManager]
class OrderedTipItem {
  /// ID for each tip.
  final String id;

  /// Showing order.
  final int order;

  /// Version of this tip.
  ///
  /// It is useful when you need to controll different user using different
  /// tip.
  final int version;

  late VoidCallback _builder;

  OrderedTipItem({
    required this.id,
    required this.version,
    required this.order,
  });
}

class _OrderedTipState extends State<OrderedTip> {
  _RadioGroup get group => widget.group;

  bool get isDisabled => widget.group.isNotLeader(widget.id);

  @override
  Widget build(BuildContext context) {
    return SimpleTip(
      title: widget.title,
      message: widget.message,
      contentBuilder: widget.contentBuilder,
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
      isDisabled: isDisabled,
      onClosed: () => widget.group.retire(widget.id),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.group.removeCandidate(widget.id);
  }

  @override
  void initState() {
    super.initState();

    final g = group;
    g.setupBuilder(widget.id, () => setState(() {}));
    if (g.isNotReady) {
      g.startElection();
    }
  }
}

class _RadioGroup {
  String? leader;

  List<OrderedTipItem> sortedCandidates = <OrderedTipItem>[];

  final candidates = <String, OrderedTipItem>{};

  final String groupId;

  _RadioGroup(this.groupId);

  bool get isNotReady => sortedCandidates.length != candidates.length;

  void addCandidate({
    required String id,
    required int version,
    required int order,
  }) {
    if (candidates[id] == null) {
      candidates[id] = OrderedTipItem(
        id: id,
        order: order,
        version: version,
      );
    }
  }

  /// Disable all if current is not set
  bool isNotLeader(String id) {
    return leader == null ? true : leader != id;
  }

  void removeCandidate(String id) {
    candidates.remove(id);
    if (candidates.isEmpty) {
      OrderedTip.groups.remove(groupId);
    }
  }

  void reset() {
    final oldLeader = leader;
    startElection();
    if (oldLeader != leader) {
      candidates[oldLeader]?._builder();
      candidates[leader]?._builder();
    }
  }

  void retire(String id) async {
    await OrderedTip.stateManager.tipRead(groupId, candidates[id]!);
    // there is no tip enabled, now we can research
    reset();
  }

  void setup() {
    sortedCandidates = candidates.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void setupBuilder(String id, VoidCallback builder) {
    if (candidates[id] != null) {
      candidates[id]!._builder = builder;
    }
  }

  void startElection() {
    if (isNotReady) setup();

    leader = null;
    for (final candidate in sortedCandidates) {
      if (OrderedTip.stateManager.shouldShow(groupId, candidate)) {
        leader = candidate.id;
        break;
      }
    }
  }
}
