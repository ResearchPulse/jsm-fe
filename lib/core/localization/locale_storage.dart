import 'locale_storage_stub.dart'
    if (dart.library.js_interop) 'locale_storage_web.dart'
    if (dart.library.io) 'locale_storage_io.dart';

abstract class LocaleStorage {
  Future<String?> loadLocale();
  Future<void> saveLocale(String languageCode);

  factory LocaleStorage() => createLocaleStorage();
}
