import 'dart:typed_data';

import 'manuscript_file_picker_stub.dart' as platform;

/// Representation of a picked manuscript file.
class PickedManuscriptFile {
  final String name;
  final Uint8List bytes;

  const PickedManuscriptFile({
    required this.name,
    required this.bytes,
  });
}

/// Seam for picking manuscript files. Tests can override [picker].
class ManuscriptFilePickerSeam {
  static Future<PickedManuscriptFile?> Function() picker =
      platform.pickManuscriptFile;

  static void resetToDefault() {
    picker = platform.pickManuscriptFile;
  }
}
