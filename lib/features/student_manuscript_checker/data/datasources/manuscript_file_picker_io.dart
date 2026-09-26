import 'dart:io';
import 'manuscript_file_picker.dart';

/// Native file picker for Windows and IO platforms without requiring native plugin symlinks.
Future<PickedManuscriptFile?> pickManuscriptFile() async {
  if (Platform.isWindows) {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-STA',
        '-Command',
        r'''
        Add-Type -AssemblyName System.Windows.Forms
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Filter = "Tài liệu học thuật (*.pdf;*.txt;*.docx;*.xml)|*.pdf;*.txt;*.docx;*.xml|Tất cả tệp (*.*)|*.*"
        $dialog.Title = "Chọn bản thảo nghiên cứu (Manuscript)"
        $res = $dialog.ShowDialog()
        if ($res -eq [System.Windows.Forms.DialogResult]::OK) {
          [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
          Write-Output $dialog.FileName
        }
        ''',
      ]);
      final path = result.stdout.toString().trim();
      if (path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final name = file.uri.pathSegments.isNotEmpty
              ? file.uri.pathSegments.last
              : path.split(RegExp(r'[\\/]')).last;
          return PickedManuscriptFile(name: name, bytes: bytes);
        }
      }
    } catch (_) {
      return null;
    }
  }
  return null;
}
