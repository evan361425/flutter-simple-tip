import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_tip/simple_tip.dart';

void main() {
  test('should throw error if message and contentBuilder not set', () {
    expect(() => SimpleTip(child: Text('hi')), throwsAssertionError);
  });

  testWidgets(
    'should show all tip in one screen and close it all in once click',
    (tester) async {
      var isTapped = false;
      var isClosed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                SimpleTip(
                  title: 'example title',
                  message: 'Tip1',
                  child: Text('Top Left Widget'),
                ),
                Spacer(),
                SimpleTip(
                  message: 'Tip2',
                  isDisabled: true,
                  child: Text('Top Right Widget'),
                ),
              ]),
              TextButton(onPressed: () => isTapped = true, child: Text('HI')),
              SimpleTip(
                message: 'Tip3',
                onClosed: () => isClosed = true,
                child: Text('Bottom Widget'),
              ),
            ],
          ),
        ),
      ));
      // faded in, show timer started (and at 0.0)
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.text('Tip1'), findsOneWidget);
      expect(find.text('Tip2'), findsNothing);
      expect(find.text('Tip3'), findsOneWidget);

      await tester.tapAt(tester.getCenter(find.text('HI')));
      await tester.pumpAndSettle();

      expect(find.text('Tip1'), findsNothing);
      expect(find.text('Tip2'), findsNothing);
      expect(find.text('Tip3'), findsNothing);
      expect(isClosed, isTrue);

      await tester.tap(find.text('HI'));

      expect(isTapped, isTrue);
    },
  );

  testWidgets('should close tip after tap closer', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SimpleTip(
          closerText: 'closer',
          message: 'tip',
          child: Text('text'),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('closer'));
    await tester.pumpAndSettle();

    expect(find.text('tip'), findsNothing);
  });

  testWidgets('should able to close custom content', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SimpleTip(
          contentBuilder: (context, closer) => GestureDetector(
            onTap: closer,
            child: Text('closer'),
          ),
          message: 'tip',
          child: Text('text'),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 10));

    await tester.tap(find.text('closer'));
    await tester.pumpAndSettle();

    expect(find.text('tip'), findsNothing);
  });

  testWidgets('should close tip after deactivate', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                Future.delayed(
                  Duration(milliseconds: 10),
                  () => Navigator.of(context).pop(),
                );

                return Scaffold(
                  body: SimpleTip(message: 'tip', child: Text('text')),
                );
              }),
            ),
            child: Text('see tip'),
          ),
        );
      }),
    ));

    await tester.tap(find.text('see tip'));
    await tester.pumpAndSettle();

    expect(find.text('tip'), findsNothing);
  });
}
