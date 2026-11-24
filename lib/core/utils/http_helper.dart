/// Cross-platform HTTP helper library with conditional export.
library;

export 'http_helper_native.dart' if (dart.library.html) 'http_helper_web.dart';
