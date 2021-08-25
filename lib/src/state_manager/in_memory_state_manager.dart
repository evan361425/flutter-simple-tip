import '../ordered_tip.dart';
import 'state_manager.dart';

class InMemoryStateManager extends StateManager {
  final _records = <String, int>{};

  @override
  bool shouldShow(String groupId, OrderedTipItem item) {
    final lastVersion = _records['$groupId.${item.id}'];
    return lastVersion == null ? true : lastVersion < item.version;
  }

  @override
  Future<void> tipRead(String groupId, OrderedTipItem item) async {
    _records['$groupId.${item.id}'] = item.version;
  }
}
