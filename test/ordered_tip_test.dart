import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_tip/simple_tip.dart';

void main() {
  testWidgets('should show in order', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              OrderedTip(
                groupId: 'group1',
                id: 'id1',
                version: 1,
                order: 1,
                message: 'Tip1',
                child: Text('Top Left Widget'),
              ),
              Spacer(),
              OrderedTip(
                groupId: 'group1',
                id: 'id2',
                version: 1,
                order: 2,
                message: 'Tip2',
                child: Text('Top Right Widget'),
              ),
            ]),
            OrderedTip(
              groupId: 'group2',
              id: 'id1',
              version: 1,
              message: 'Tip3',
              child: Text('Bottom Widget'),
            ),
          ],
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Tip1'), findsOneWidget);
    expect(find.text('Tip3'), findsOneWidget);
    expect(find.text('Tip2'), findsNothing);

    await tester.tapAt(Offset.zero);
    // close animation
    await tester.pumpAndSettle();
    // open animation
    await tester.pumpAndSettle();

    expect(find.text('Tip1'), findsNothing);
    expect(find.text('Tip3'), findsNothing);
    expect(find.text('Tip2'), findsOneWidget);

    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text('Tip1'), findsNothing);
    expect(find.text('Tip2'), findsNothing);
    expect(find.text('Tip3'), findsNothing);
  });
}
