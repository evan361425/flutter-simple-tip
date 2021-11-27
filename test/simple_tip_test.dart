import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_tip/simple_tip.dart';

void main() {
  group('SimpleTip', () {
    test('Must give content or message', () {
      expect(
        () => SimpleTip(onClosed: () {}, child: const Text('text')),
        throwsAssertionError,
      );
    });

    testWidgets('Should show custom content', (tester) async {
      await tester.pumpWidget(MaterialApp(
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: SimpleTip(
            content: const Text('content'),
            message: 'message',
            onClosed: () {},
            child: const Text('text'),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('message'), findsNothing);
      expect(find.text('content'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('content'), findsNothing);
    });
  });
}
