import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

Future<void> saveBytesToDestinationPlatform({
  required Uint8List bytes,
  required String destination,
  required String fileName,
  String mimeType = 'application/octet-stream',
}) async {
  final file = XFile.fromData(bytes, name: fileName, mimeType: mimeType);
  await file.saveTo(destination);
}
