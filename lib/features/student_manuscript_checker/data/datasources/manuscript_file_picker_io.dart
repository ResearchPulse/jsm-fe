import 'manuscript_file_picker.dart';

/// Fallback file picker for non-web / testing environments.
Future<PickedManuscriptFile?> pickManuscriptFile() async {
  return null;
}
