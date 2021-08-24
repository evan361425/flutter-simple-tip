import 'state_manager.dart';

class InMemoryStateManager extends StateManager {
  final _records = <String, int>{};

  @override
  int getVersion(String groupId, String id) {
    return _records['$groupId.$id'] ?? 0;
  }

  @override
  Future<void> setVersion(String groupId, String id, int version) async {
    _records['$groupId.$id'] = version;
  }
}
