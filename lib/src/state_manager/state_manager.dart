/// Manage state for [TipItem]
///
/// It helps your APP remember wheather user had read the tip.
abstract class StateManager {
  /// Get [TipItem.version] from your filesystem, eg: SharedPreferences, hive
  ///
  /// Default using in-memory records version.
  /// **You should setup your getter method!**
  bool shouldShow(String groupId, TipItem item);

  /// Set [TipItem.version] after user manually close it
  ///
  /// Default using in-memory records version.
  /// You should setup your setter method!
  Future<void> tipRead(String groupId, TipItem item);
}

mixin TipItem {
  /// ID for each tip.
  String get id;

  /// Version of this tip.
  ///
  /// It is useful when you need to controll different user using different
  /// tip.
  int get version;
}
