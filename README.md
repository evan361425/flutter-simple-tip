# Simple Tip

[![codecov](https://codecov.io/gh/evan361425/flutter-simple-tip/branch/master/graph/badge.svg?token=2Lx6Ozhzjw)](https://codecov.io/gh/evan361425/flutter-simple-tip)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/29d3892a0deb4ea79a6def655f5adae1)](https://www.codacy.com/gh/evan361425/flutter-simple-tip/dashboard?utm_source=github.com&utm_medium=referral&utm_content=evan361425/flutter-simple-tip&utm_campaign=Badge_Grade)
[![Pub Version](https://img.shields.io/pub/v/simple_tip)](https://pub.dev/packages/simple_tip)

A widget for showing tips to it's child that automatically setup position.

> This package is separated from my project [POS-System](https://github.com/evan361425/flutter-pos-system).

| All in One                                                                             | Ordered                                                                                        |
| -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| ![](https://github.com/evan361425/flutter-simple-tip/blob/master/images/tip-short.gif) | ![](https://github.com/evan361425/flutter-simple-tip/blob/master/images/tip_ordered-short.gif) |

## How to use

### All in one screen

Wrap your widget with [`SimpleTip`](#simpletip), and give some tips!

```dart
Widget build(context) {
  return SimpleTip(
    message: 'This is my tip!',
    child: Text('Hello world'),
  );
}
```

### In order

Wrap your widget with [`OrderedTip`](#orderedtip) and give `groupId` and `id` for each tip.

```dart
Widget build(context) {
  return Column(children: [
    OrderedTip(
      groupId: 'group1',
      id: 'tip1',
      order: 1,
      message: 'First tip',
      child: Text('Hello world'),
    ),
    OrderedTip(
      groupId: 'group1',
      id: 'tip2',
      order: 2,
      message: 'Second tip',
      child: Text('Hello world again!'),
    )
  ]);
}
```

> You must setup [`stateManager`](#state-manager), otherwise it only works in-memory.
> Which means when you restart your app, tips will show up again!

## Configuration

Two main widget you can use, [`SimpleTip`](#simpletip) and [`OrderedTip`](#orderedtip).

> You can follow Dart provided [API document](https://pub.dev/documentation/simple_tip/latest/simple_tip/simple_tip-library.html)

### SimpleTip

- `title`, `String?`, `null`

  - The title to display in the tip.

- `message`, `String?`, `null`

  - The message to display in the tip. **MUST** set if `contentBuilder` not set.
  - This value will also use for semantics.

- `contentBuilder`, `Widget Function(BuildContext, VoidCallback)?`, `null`
  - Builder for building tip's content.
  - This will "win" when `message` and `contentBuilder` both set.
  - Example:

```dart
final contentBuilder = (BuilderContext context, VoidCallback closer) {
  return Material(
    child: TextButton(
      onPressed: closer,
      child: Text('tap to close tip'),
    ),
  );
};
```

- `boxConstraints`, `BoxConstraints?`, `BoxConstraints(minHeight: 24.0)`

  - Tip's content constraints

- `decoration`, `Decoration?`, see below
  - Tip's container decoration
  - Default:

```dart
ShapeDecoration(
  color: (isDark ? Colors.white : Colors.grey[700]!).withOpacity(0.9),
  shape: TipShapeBorder(arrowArc: 0.1, target: target),
)
```

- `textStyle`, `TextStyle?`, see below
  - Tip's text default style
  - Default:

```dart
Theme.of(context).textTheme.bodyText1!.copyWith(
  color: isDark ? Colors.black : Colors.white,
)
```

- `onClosed`, `VoidCallback?`, `null`
  - A callback after the start of closing tip.
  - This will be needed if you handle tip by filesystem, eg: SharedPreferences, hive
  - Example:

```dart
final isDisabled = instance.read('myTip') == 1;
final onClosed = () {
  instance.write('myTip', 1);
}
```

- `padding`, `EdgeInsets`, `EdgeInsets.all(8.0)`

  - The amount of space by which to inset the tip's content.

- `margin`, `EdgeInsets`, `EdgeInsets.symmetric(horizontal: 16.0)`

  - The empty space that surrounds the tip.
  - Defines the tip's outer `Container.margin`. By default, a long tip will span the width of its window. If long enough, a tip might also span the window's height. This property allows one to define how much space the tip must be inset from the edges of their display window.

- `verticalOffset`, `double`, `24.0`

  - The vertical gap between the widget and the displayed tip.
  - When `preferBelow` is set to true and tips have sufficient space to display themselves, this property defines how much vertical space tips will position themselves under their corresponding widgets. Otherwise, tips will position themselves above their corresponding widgets with the given offset.

- `closerText`, `String`, `OK`

  - Text of button to close tip.

- `waitDuration`, `Duration`, `Duration.zero`

  - The length of time that a tip will wait for showing.
  - Defaults to 0 milliseconds (tips are shown immediately after created).

- `excludeFromSemantics`, `bool`, `false`

  - Whether the tip's `SimpleTip.message` should be excluded from the semantics tree.
  - A tip will add a `Semantics` label that is set to `SimpleTip.message`. Set this property to true if the app is going to provide its own custom semantics label.

- `isDisabled`, `bool`, `false`

  - Disable tip.
  - Wrap `SimpleTip` with `StatefulWidget` and dynamically set this value.

- `preferBelow`, `bool`, `true`

  - Whether the tips defaults to being displayed below the widget.
  - Defaults to true. If there is insufficient space to display the tip in the preferred direction, the tip will be displayed in the opposite direction.

- `child`, `Widget`, **required**
  - The widget below this widget in the tree.

### OrderedTip

> **IMPORTANT** you should set up static property `stateManager` to "remember" that user had read this tip.

- `id`, `String`, **required**

  - ID of this tip.
  - It should be unique in the same group

- `groupId`, `String`, **required**

  - ID of the group that contains many `OrderedTip`
  - It should be unique between each groups.
  - If one screen have multiple groups, it should show many tips in one screen.

- `version`, `int`, `0`
  - The version it should be.
  - `SimpleTip.isDisabled` will be `false` if version is not equal to given version from `static getVersion`.
  - Implement detail:

```dart
if (TipOrdered.getVersion(groupId, id) != version) {
  enabledTip = id;
  break; // break the loop
}
```

- `order`, `int`, `0`
  - The order to show the tip, lower order higher priority.
  - Implement:

```dart
tipList.sort((a, b) => a.order.compareTo(b.order))
```

- `title`, `String?`, same as `SimpleTip.title`
- `message`, `String?`, same as `SimpleTip.message`
- `contentBuilder`, `Widget Function(BuildContext, VoidCallback)?`, same as `SimpleTip.contentBuilder`

#### State Manager

There are two method you need to override:

- `shouldShow`, `int Function(String groupId, OrderedTipItem item)`, see below
  - Get `OrderedTip.version` from your filesystem, eg: SharedPreferences, hive
  - Default using in-memory data to get version:

```dart
bool shouldShow(String groupId, OrderedTipItem item) {
  final lastVersion = _records['$groupId.${item.id}'];
  return lastVersion == null ? true : lastVersion < item.version;
}
```

- `tipRead`, `Future<void> Function(String groupId, OrderedTipItem item)`, see below
  - Set `OrderedTip.version` after user manually close it
  - Default using in-memory data to record version:

```dart
Future<void> tipRead(String groupId, OrderedTipItem item) async {
  _records['$groupId.${item.id}'] = item.version;
}
```

Example of using [shared_preferences](https://pub.dev/packages/shared_preferences):

```dart
void initialize() async {
  final service = await SharedPreferences.getInstance();
  OrderedTip.stateManager = PrefStateManager(service);
}

class PrefStateManager extends StateManager {
  final SharedPreferences pref;

  const PrefStateManager(this.pref);

  @override
  bool shouldShow(String groupId, OrderedTipItem item) {
    final lastVersion = pref.getInt('$groupId.${item.id}');
    return lastVersion == null ? true : lastVersion < item.version;
  }

  @override
  Future<void> tipRead(String groupId, OrderedTipItem item) {
    return pref.setInt('$groupId.${item.id}', item.version);
  }
}
```

Example of using [Hive](https://pub.dev/packages/hive)

```dart
void initialize() async {
  final box = Hive.box('myBox');
  OrderedTip.stateManager = HiveStateManager(box);
}

class HiveStateManager extends StateManager {
  final Box box;

  const HiveStateManager(this.box);

  @override
  bool shouldShow(String groupId, OrderedTipItem item) {
    final lastVersion = box.get('$groupId.${item.id}');
    return lastVersion == null ? true : lastVersion < item.version;
  }

  @override
  Future<void> tipRead(String groupId, OrderedTipItem item) {
    return box.put('$groupId.${item.id}', version);
  }
}
```

## How it works

Main idea is inspired from [`Tooltip`](https://api.flutter.dev/flutter/material/Tooltip-class.html), which using [`overlayState.insert`](https://api.flutter.dev/flutter/widgets/OverlayState/insert.html) to show tips.

`SimpleTip` build tips and _backdrop_ on the `Overlay`, and detect click on backdrop to close it. Multiple tips should build single backdrop and close all tips once it been clicked.

You can also close it by

- User tap `closeButton`
- `dispose` or `deactivate` has been fired

## LICENSE

See in [LICENSE](LICENSE)
