import 'package:web/web.dart' as web;
import 'locale_storage.dart';

class WebLocaleStorage implements LocaleStorage {
  static const _key = 'jsm_app_locale';

  @override
  Future<String?> loadLocale() async {
    try {
      final val = web.window.localStorage.getItem(_key);
      if (val == 'en' || val == 'vi') {
        return val;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> saveLocale(String languageCode) async {
    try {
      web.window.localStorage.setItem(_key, languageCode);
    } catch (_) {}
  }
}

LocaleStorage createLocaleStorage() => WebLocaleStorage();
