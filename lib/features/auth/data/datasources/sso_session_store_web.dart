import 'package:web/web.dart' as web;

import 'sso_session_store.dart';

class WebSsoSessionStore implements SsoSessionStore {
  @override
  String? read(String key) {
    if (key == SsoSessionKeys.pendingRequest) {
      return web.window.sessionStorage.getItem(key);
    }
    return web.window.localStorage.getItem(key) ??
        web.window.sessionStorage.getItem(key);
  }

  @override
  void write(String key, String value) {
    if (key == SsoSessionKeys.pendingRequest) {
      web.window.sessionStorage.setItem(key, value);
    } else {
      web.window.localStorage.setItem(key, value);
      web.window.sessionStorage.setItem(key, value);
    }
  }

  @override
  void remove(String key) {
    web.window.sessionStorage.removeItem(key);
    web.window.localStorage.removeItem(key);
  }
}

SsoSessionStore createSsoSessionStore() => WebSsoSessionStore();
