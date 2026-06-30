import 'dart:typed_data';

import 'file_saver_io.dart' if (dart.library.html) 'file_saver_web.dart';

Future<void> saveBytesToDestination({
  required Uint8List bytes,
  required String destination,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) {
  return saveBytesToDestinationPlatform(
    bytes: bytes,
    destination: destination,
    fileName: fileName,
    mimeType: mimeType,
  );
}
