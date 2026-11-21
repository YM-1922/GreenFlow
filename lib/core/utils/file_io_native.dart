/// Platform file I/O helper — native (mobile/desktop) implementation using dart:io.
library;

import 'dart:io';

/// Read a file's content. Returns null if the file doesn't exist or on error.
String? readFileSync(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      return file.readAsStringSync();
    }
  } catch (_) {}
  return null;
}

/// Write content to a file. Silently fails on error.
void writeFileSync(String path, String content) {
  try {
    File(path).writeAsStringSync(content);
  } catch (_) {}
}

/// Delete a file if it exists. Silently fails on error.
void deleteFileSync(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  } catch (_) {}
}
