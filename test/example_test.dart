import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/main.dart';

void main() {
  testWidgets('Example APP', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final observer = RouteObserver<ModalRoute<void>>();

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [observer],
      navigatorKey: navigatorKey,
      home: StartPage(observer: observer),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();

    expect(find.text('Tip content 1'), findsOneWidget);
    expect(find.text('Tip content 2'), findsNothing);
    expect(find.text('Tip content 3'), findsNothing);

    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    expect(find.text('Simple tip without backdrop (default)'), findsOneWidget);
    expect(find.text('Tip content 1'), findsNothing);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('Simple tip without backdrop (default)'), findsNothing);

    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    expect(find.text('Simple tip with backdrop'), findsOneWidget);

    // pop back by nature back button
    navigatorKey.currentState?.pop();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Simple tip with backdrop'), findsNothing);
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    // it will not pop, since there is a backdrop
    await tester.tap(find.text('pop'));
    await tester.pumpAndSettle();

    expect(find.text('Simple tip with backdrop'), findsNothing);
    expect(find.text('Simple tip'), findsNothing);

    await tester.tap(find.text('pop'));
    await tester.pumpAndSettle();

    expect(find.text('Simple tip'), findsOneWidget);

    await tester.tap(find.text('pop'));
    await tester.pumpAndSettle();

    expect(find.text('Tip content 1'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tip content 1'), findsNothing);
    expect(find.text('Tip content 2'), findsOneWidget);

    await tester.tap(find.text('pop'));
    await tester.pumpAndSettle();

    expect(find.text('Tip content 2'), findsNothing);

    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();

    expect(find.text('Tip content 2'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Tip content 2'), findsNothing);
    expect(find.text('Tip content 3'), findsNothing);
  });
}
