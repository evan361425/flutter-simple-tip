import 'package:flutter/material.dart';
import 'package:simple_tip/simple_tip.dart';

final observer = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorObservers: [observer],
    home: const StartPage(),
  ));
}

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Page1(
                grouper: GlobalKey<TipGrouperState>(),
                observer: observer,
              ),
            ));
          },
          child: const Text('start'),
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  final GlobalKey<TipGrouperState> grouper;

  final RouteObserver<ModalRoute<void>> observer;

  const Page1({
    Key? key,
    required this.grouper,
    required this.observer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TipGrouper(
      key: grouper,
      id: 'group',
      candidateLenght: 3,
      routeObserver: observer,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Text('pop'),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Page2(),
              )),
              icon: const Text('next'),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OrderedTip(
                order: 1,
                version: 1,
                id: 't-1',
                grouper: grouper,
                child: const Card(child: ListTile(title: Text('Tip 1'))),
              ),
              OrderedTip(
                order: 2,
                version: 1,
                id: 't-2',
                grouper: grouper,
                child: const Card(child: ListTile(title: Text('Tip 2'))),
              ),
              OrderedTip(
                order: 3,
                version: 1,
                id: 't-3',
                grouper: grouper,
                child: const Card(child: ListTile(title: Text('Tip 3'))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  static bool isDisable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Text('pop'),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const Page3(),
            )),
            icon: const Text('next'),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SimpleTip(
              message: 'Simple tip',
              onClosed: () => isDisable = true,
              isDisabled: isDisable,
              child: const Card(
                child: ListTile(
                  title: Text('Tip 1'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  static bool isDisable = false;

  const Page3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Text('pop'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SimpleTip(
            message: 'Simple tip 1',
            onClosed: () => isDisable = true,
            isDisabled: isDisable,
            withBackdrop: true,
            child: const Card(
              child: ListTile(
                title: Text('Tip 1'),
              ),
            ),
          ),
          SimpleTip(
            message: 'Simple tip 2',
            onClosed: () => isDisable = true,
            isDisabled: isDisable,
            withBackdrop: true,
            child: const Card(
              child: ListTile(
                title: Text('Tip 2'),
              ),
            ),
          ),
          SimpleTip(
            message: 'Simple tip 3',
            onClosed: () => isDisable = true,
            isDisabled: isDisable,
            withBackdrop: true,
            child: const Card(
              child: ListTile(
                title: Text('Tip 3'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
