import 'package:flutter/material.dart';

import 'simple_tip.dart';
import 'tip_grouper.dart';
import 'state_manager/state_manager.dart';

class OrderedTip extends StatefulWidget {
  final String id;

  final GlobalKey<TipGrouperState> grouper;

  final int order;

  final int version;

  final Widget child;

  const OrderedTip({
    Key? key,
    required this.id,
    required this.grouper,
    required this.order,
    required this.version,
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
    return SimpleTip(
      message: id,
      isDisabled: !isEnabled,
      onClosed: () {
        retired = true;
        widget.grouper.currentState?.raiseElection();
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
    final grouper = widget.grouper.currentState?.widget;
    if (grouper != null) {
      await grouper.stateManager.tipRead(grouper.id, this);
    }
    if (mounted) {
      setState(() {
        isEnabled = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.grouper.currentState?.nominate(this);
  }
}
