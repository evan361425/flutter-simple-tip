import 'package:flutter/material.dart';
import 'package:simple_tip/simple_tip.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: TipScreen()));
}

class TipScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Tip(
              title: 'example title',
              message: 'This tip will show bellow left',
              child: BlockOfText('Top Left Widget', Colors.amber),
            ),
            Spacer(),
            Tip(
              message: 'This tip will show bellow right',
              child: BlockOfText('Top Right Widget', Colors.indigo),
            ),
          ]),
          ElevatedButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TipOrderedScreen())),
            child: Text('Try Ordered Tips'),
          ),
          Tip(
            message: 'This tip will show above',
            child: BlockOfText('Bottom Widget', Colors.cyan),
          ),
        ],
      ),
    );
  }
}

class TipOrderedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            TipOrdered(
              groupId: 'group1',
              id: 'tip1',
              order: 1,
              version: 1,
              message: 'First very long long long long long tip',
              child: BlockOfText('Top Left Widget', Colors.amber),
            ),
            Spacer(),
            TipOrdered(
              groupId: 'group1',
              id: 'tip3',
              order: 3,
              version: 1,
              message: 'Third tip',
              child: BlockOfText('Top Right Widget', Colors.indigo),
            ),
          ]),
          TipOrdered(
            groupId: 'group1',
            id: 'tip2',
            order: 2,
            version: 1,
            message: 'Second tip',
            child: BlockOfText('Bottom Widget', Colors.cyan),
          ),
        ],
      ),
    );
  }
}

class BlockOfText extends StatelessWidget {
  final String text;

  final Color color;

  const BlockOfText(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      margin: const EdgeInsets.all(4.0),
      padding: const EdgeInsets.all(8.0),
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
