/// Platform file I/O helper — exports the correct implementation based on platform.
library;

export 'file_io_native.dart' if (dart.library.html) 'file_io_web.dart';
