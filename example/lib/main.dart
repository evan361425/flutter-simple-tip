import 'package:flutter/material.dart';
import 'package:simple_tip/simple_tip.dart';

void main() {
  final observer = RouteObserver<ModalRoute<void>>();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorObservers: [observer],
    home: StartPage(observer: observer),
  ));
}

class StartPage extends StatelessWidget {
  final RouteObserver<ModalRoute<void>> observer;
  const StartPage({Key? key, required this.observer}) : super(key: key);

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
      candidateLength: 3,
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
                message: 'Tip content 1',
                grouper: grouper,
                child: const Card(
                  child: ListTile(title: Text('Ordered tip 1')),
                ),
              ),
              OrderedTip(
                order: 2,
                version: 1,
                id: 't-2',
                message: 'Tip content 2',
                grouper: grouper,
                child: const Card(
                  child: ListTile(title: Text('Ordered tip 2')),
                ),
              ),
              OrderedTip(
                order: 3,
                version: 1,
                id: 't-3',
                message: 'Tip content 3',
                grouper: grouper,
                child: const Card(
                  child: ListTile(title: Text('Ordered tip 3')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
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
              message: 'Simple tip without backdrop (default)',
              onClosed: () => setState(() => isDisable = true),
              isDisabled: isDisable,
              child: const Card(
                child: ListTile(
                  title: Text('Simple tip'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  static bool isDisable = false;

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
            message: 'Simple tip with backdrop',
            onClosed: () => setState(() => isDisable = true),
            isDisabled: isDisable,
            withBackdrop: true,
            child: const Card(
              child: ListTile(
                title: Text('Tip 1'),
              ),
            ),
          ),
          SimpleTip(
            title: 'Some title',
            message: 'Show together if not using OrderedTip',
            onClosed: () => setState(() => isDisable = true),
            isDisabled: isDisable,
            withBackdrop: true,
            child: const Card(
              child: ListTile(
                title: Text('Tip 2'),
              ),
            ),
          ),
          SimpleTip(
            message: 'Click anywhere to close the tips',
            onClosed: () => setState(() => isDisable = true),
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
