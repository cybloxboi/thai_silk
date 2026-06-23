import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../models/grid_workbook.dart';

class WorkbookStorage {
  static const String fileExtension = 'thsilk';
  static const String fileLabel = 'Thai Silk project';

  static final List<XTypeGroup> _acceptedTypeGroups = [
    XTypeGroup(
      label: fileLabel,
      extensions: const [fileExtension],
    ),
  ];

  static Future<({GridWorkbook workbook, String? path})?> loadFromPickedFile() async {
    final file = await openFile(acceptedTypeGroups: _acceptedTypeGroups);
    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final payload = jsonDecode(utf8.decode(bytes));
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('ไฟล์โปรเจกต์ไม่ถูกต้อง');
    }

    return (workbook: GridWorkbook.fromJson(payload), path: file.path);
  }

  static Future<String?> pickSavePath({
    String? suggestedFileName,
  }) {
    return getSaveLocation(
      acceptedTypeGroups: _acceptedTypeGroups,
      suggestedName: suggestedFileName ?? 'thai_silk.$fileExtension',
    ).then((location) => location?.path);
  }

  static Future<void> saveToPath({
    required String path,
    required GridWorkbook workbook,
  }) async {
    final file = File(_ensureExtension(path));
    await file.writeAsBytes(utf8.encode(jsonEncode(workbook.toJson())));
  }

  static Future<String> writeToSelectedPath({
    required GridWorkbook workbook,
    String? currentPath,
  }) async {
    final path = currentPath ??
        await pickSavePath(suggestedFileName: 'thai_silk.$fileExtension');
    if (path == null) {
      throw const FileSystemException('ผู้ใช้ยกเลิกการบันทึก');
    }

    final resolvedPath = _ensureExtension(path);
    await saveToPath(path: resolvedPath, workbook: workbook);
    return resolvedPath;
  }

  static String defaultFileName(DateTime now) {
    final stamp = now.toIso8601String().replaceAll(':', '-').split('.').first;
    return 'thai_silk_$stamp.$fileExtension';
  }

  static String _ensureExtension(String path) {
    if (path.toLowerCase().endsWith('.$fileExtension')) {
      return path;
    }

    return '$path.$fileExtension';
  }
}
