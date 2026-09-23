import 'sso_session_store.dart';

/// In-memory stand-in for non-web platforms. The web build (sessionStorage)
/// is the supported Central SSO target; desktop persistence is out of scope.
class MemorySsoSessionStore implements SsoSessionStore {
  final _map = <String, String>{};

  @override
  String? read(String key) => _map[key];

  @override
  void write(String key, String value) => _map[key] = value;

  @override
  void remove(String key) => _map.remove(key);
}

SsoSessionStore createSsoSessionStore() => MemorySsoSessionStore();
