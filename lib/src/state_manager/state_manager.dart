import '../ordered_tip.dart';

/// Manage state for [OrderedTip]
///
/// It helps your APP remember wheather user had read the tip.
abstract class StateManager {
  /// Get [OrderedTip.version] from your filesystem, eg: SharedPreferences, hive
  ///
  /// Default using in-memory records version.
  /// **You should setup your getter method!**
  bool shouldShow(String groupId, OrderedTipItem item);

  /// Set [OrderedTip.version] after user manually close it
  ///
  /// Default using in-memory records version.
  /// You should setup your setter method!
  Future<void> tipRead(String groupId, OrderedTipItem item);
}
