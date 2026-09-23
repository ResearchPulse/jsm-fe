import 'package:web/web.dart' as web;

import 'sso_session_store.dart';

class WebSsoSessionStore implements SsoSessionStore {
  @override
  String? read(String key) => web.window.sessionStorage.getItem(key);

  @override
  void write(String key, String value) =>
      web.window.sessionStorage.setItem(key, value);

  @override
  void remove(String key) => web.window.sessionStorage.removeItem(key);
}

SsoSessionStore createSsoSessionStore() => WebSsoSessionStore();
