import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'manuscript_file_picker.dart';

/// Web file picker using HTMLInputElement.
Future<PickedManuscriptFile?> pickManuscriptFile() async {
  final completer = Completer<PickedManuscriptFile?>();

  final input = web.document.createElement('input') as web.HTMLInputElement;
  input.type = 'file';
  input.accept = '.pdf,.docx,.txt';
  input.style.display = 'none';
  web.document.body?.append(input);

  input.onchange = (web.Event _) {
    final files = input.files;
    if (files == null || files.length == 0) {
      input.remove();
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final file = files.item(0);
    if (file == null) {
      input.remove();
      if (!completer.isCompleted) completer.complete(null);
      return;
    }

    final fileName = file.name;
    final reader = web.FileReader();

    reader.onload = ((web.Event _) {
      input.remove();
      final result = reader.result;
      if (result != null && result.isA<JSArrayBuffer>()) {
        final jsArrayBuffer = result as JSArrayBuffer;
        final bytes = jsArrayBuffer.toDart.asUint8List();
        if (!completer.isCompleted) {
          completer.complete(PickedManuscriptFile(
            name: fileName,
            bytes: bytes,
          ));
        }
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
    }).toJS;

    reader.onerror = ((web.Event _) {
      input.remove();
      if (!completer.isCompleted) completer.complete(null);
    }).toJS;

    reader.readAsArrayBuffer(file);
  }.toJS;

  input.click();

  return completer.future;
}
