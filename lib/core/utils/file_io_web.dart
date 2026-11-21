/// Platform file I/O helper — web stub (no filesystem access on web).
library;

/// Read a file's content. Always returns null on web.
String? readFileSync(String path) => null;

/// Write content to a file. No-op on web.
void writeFileSync(String path, String content) {}

/// Delete a file. No-op on web.
void deleteFileSync(String path) {}
