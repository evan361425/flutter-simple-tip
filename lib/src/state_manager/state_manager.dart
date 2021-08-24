abstract class StateManager {
  /// Get [OrderedTip.version] from your filesystem, eg: SharedPreferences, hive
  ///
  /// Default using in-memory records version.
  /// **You should setup your getter method!**
  int getVersion(String groupId, String id);

  /// Set [OrderedTip.version] after user manually close it
  ///
  /// Default using in-memory records version.
  /// You should setup your setter method!
  Future<void> setVersion(String groupId, String id, int version);
}
