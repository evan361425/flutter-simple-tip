import 'package:flutter/material.dart';

import 'simple_tip.dart';
import 'tip_content.dart';

class OrderedTip extends StatefulWidget {
  static final groups = <String, _RadioGroup>{};

  static final _inMemoryRecords = <String, int>{};

  /// Get [version] of tip from your filesystem, eg: SharedPreferences, hive
  ///
  /// Default using in-memory records version.
  /// **You should setup your getter method!**
  static int Function(String groupId, String id) getVersion =
      (groupId, id) => _inMemoryRecords['$groupId.$id'] ?? 0;

  /// Set [version] of tip after user manually close it
  ///
  /// Default using in-memory records version.
  /// You should setup your setter method!
  static Future<void> Function(String groupId, String id, int version)
      setVersion = (groupId, id, version) async =>
          _inMemoryRecords['$groupId.$id'] = version;

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
    required this.child,
    this.order = 0,
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
  OrderedTipState createState() => OrderedTipState();
}

class OrderedTipState extends State<OrderedTip> {
  _RadioGroup get group => widget.group;

  bool get isDisabled => widget.group.isNotLeader(widget.id);

  @override
  Widget build(BuildContext context) {
    return SimpleTip(
      title: widget.title,
      message: widget.message,
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

  List<_RadioGroupCandidate> sortedCandidates = <_RadioGroupCandidate>[];

  final candidates = <String, _RadioGroupCandidate>{};

  final String groupId;

  _RadioGroup(this.groupId);

  bool get isNotReady => sortedCandidates.length != candidates.length;

  void addCandidate({
    required String id,
    required int version,
    required int order,
  }) {
    if (candidates[id] == null) {
      candidates[id] = _RadioGroupCandidate(
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
    startElection();
    candidates.values.forEach((candidate) {
      candidate.builder();
    });
  }

  void retire(String id) async {
    await OrderedTip.setVersion(groupId, id, candidates[id]!.version);
    // there is no tip enabled, now we can research
    Future.delayed(Duration(seconds: 0), () => reset());
  }

  void setup() {
    sortedCandidates = candidates.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void setupBuilder(String id, VoidCallback builder) {
    if (candidates[id] != null) {
      candidates[id]!.builder = builder;
    }
  }

  void startElection() {
    if (isNotReady) setup();

    leader = null;
    for (final candidate in sortedCandidates) {
      if (OrderedTip.getVersion(groupId, candidate.id) != candidate.version) {
        leader = candidate.id;
        break;
      }
    }
  }
}

class _RadioGroupCandidate {
  final String id;
  final int order;
  final int version;
  late VoidCallback builder;

  _RadioGroupCandidate({
    required this.id,
    required this.version,
    required this.order,
  });
}
