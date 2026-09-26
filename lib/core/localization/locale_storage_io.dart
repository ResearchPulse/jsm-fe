import 'dart:io';
import 'locale_storage.dart';

class IoLocaleStorage implements LocaleStorage {
  String? _cached;

  File? _getConfigFile() {
    try {
      final appData = Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'] ??
          Platform.environment['HOME'] ??
          Directory.current.path;
      final dir = Directory('$appData/jsm_fe');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return File('${dir.path}/locale_setting.txt');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> loadLocale() async {
    if (_cached != null) return _cached;
    try {
      final file = _getConfigFile();
      if (file != null && await file.exists()) {
        final content = (await file.readAsString()).trim();
        if (content == 'en' || content == 'vi') {
          _cached = content;
          return content;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> saveLocale(String languageCode) async {
    _cached = languageCode;
    try {
      final file = _getConfigFile();
      if (file != null) {
        await file.writeAsString(languageCode);
      }
    } catch (_) {}
  }
}

LocaleStorage createLocaleStorage() => IoLocaleStorage();
