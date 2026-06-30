import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

import '../models/grid_workbook.dart';
import 'file_saver.dart';

class LoadedWorkbook {
  const LoadedWorkbook({required this.workbook, required this.name, this.path});

  final GridWorkbook workbook;
  final String name;
  final String? path;
}

class SavedWorkbook {
  const SavedWorkbook({required this.name, this.path});

  final String name;
  final String? path;
}

class WorkbookStorage {
  static const String fileExtension = 'thsilk';
  static const String fileLabel = 'Thai Silk project';

  static final List<XTypeGroup> _acceptedTypeGroups = [
    XTypeGroup(label: fileLabel, extensions: const [fileExtension]),
  ];

  static Future<LoadedWorkbook?> loadFromPickedFile() async {
    final file = await openFile(acceptedTypeGroups: _acceptedTypeGroups);
    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();
    final payload = jsonDecode(utf8.decode(bytes));
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('ไฟล์โปรเจกต์ไม่ถูกต้อง');
    }

    final filePath = file.path.trim().isEmpty ? null : file.path;
    return LoadedWorkbook(
      workbook: GridWorkbook.fromJson(payload),
      name: file.name.isNotEmpty
          ? file.name
          : _basenameFromPath(filePath) ?? defaultFileName(DateTime.now()),
      path: filePath,
    );
  }

  static Future<String?> pickSavePath({String? suggestedFileName}) async {
    if (kIsWeb) {
      return null;
    }

    return getSaveLocation(
      acceptedTypeGroups: _acceptedTypeGroups,
      suggestedName: suggestedFileName ?? defaultFileName(DateTime.now()),
    ).then((location) => location?.path);
  }

  static Future<SavedWorkbook> saveWorkbook({
    required GridWorkbook workbook,
    String? currentPath,
    String? suggestedFileName,
  }) async {
    final fileName = _ensureExtension(
      suggestedFileName ?? defaultFileName(DateTime.now()),
    );
    final bytes = Uint8List.fromList(
      utf8.encode(jsonEncode(workbook.toJson())),
    );

    if (kIsWeb) {
      await saveBytesToDestination(
        bytes: bytes,
        destination: fileName,
        fileName: fileName,
        mimeType: 'application/json',
      );
      return SavedWorkbook(name: fileName);
    }

    final path = currentPath ?? await pickSavePath(suggestedFileName: fileName);
    if (path == null) {
      throw Exception('ผู้ใช้ยกเลิกการบันทึก');
    }

    final resolvedPath = _ensureExtension(path);
    await saveBytesToDestination(
      bytes: bytes,
      destination: resolvedPath,
      fileName: fileName,
      mimeType: 'application/json',
    );
    return SavedWorkbook(
      path: resolvedPath,
      name: _basenameFromPath(resolvedPath) ?? fileName,
    );
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

  static String? _basenameFromPath(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final segments = path.split(RegExp(r'[\\/]'));
    return segments.isEmpty ? null : segments.last;
  }
}
