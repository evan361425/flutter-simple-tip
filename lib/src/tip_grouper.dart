import 'package:flutter/material.dart';

import 'ordered_tip.dart';
import 'state_manager/in_memory_state_manager.dart';
import 'state_manager/state_manager.dart';

class TipGrouper extends StatefulWidget {
  static StateManager defaultStateManager = InMemoryStateManager();

  final Widget child;

  final String id;

  final StateManager stateManager;

  final RouteObserver? routeObserver;

  final int candidateLenght;

  TipGrouper({
    Key? key,
    required this.id,
    required this.candidateLenght,
    StateManager? stateManager,
    this.routeObserver,
    required this.child,
  })  : stateManager = stateManager ?? defaultStateManager,
        super(key: key);

  @override
  TipGrouperState createState() => TipGrouperState();
}

class TipGrouperState extends State<TipGrouper> with RouteAware {
  final candidates = <String, OrderedTipState>{};

  OrderedTipState? enabledTip;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }

  @override
  void didChangeDependencies() {
    final route = ModalRoute.of(context);
    if (route != null) {
      widget.routeObserver?.subscribe(this, route);
    }

    super.didChangeDependencies();
  }

  @override
  void didPop() {
    enabledTip?.disable();
    super.didPop();
  }

  @override
  void didPopNext() {
    raiseElection();
    super.didPopNext();
  }

  @override
  void didPushNext() {
    enabledTip?.disable();
    super.didPushNext();
  }

  @override
  void dispose() {
    enabledTip?.disable();
    super.dispose();
  }

  void nominate(OrderedTipState candidate) {
    final oldLength = candidates.length;
    candidates[candidate.id] = candidate;
    if (oldLength + 1 == widget.candidateLenght) {
      Future<void>.delayed(Duration.zero).then((_) => raiseElection());
    }
  }

  void raiseElection() {
    if (enabledTip?.retired == false) return;

    final newEnabledTip = _getElectionWinner();

    if (newEnabledTip?.id != enabledTip?.id) {
      enabledTip?.disable();
      newEnabledTip?.enable();
      enabledTip = newEnabledTip;
    }
  }

  OrderedTipState? _getElectionWinner() {
    try {
      final items = candidates.values.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      return items.firstWhere(
          (item) => widget.stateManager.shouldShow(widget.id, item));
    } on StateError {
      return null;
    }
  }
}
