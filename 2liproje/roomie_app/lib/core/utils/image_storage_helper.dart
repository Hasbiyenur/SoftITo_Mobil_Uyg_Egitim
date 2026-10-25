import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageHelper {
  ImageStorageHelper._();

  static const _uuid = Uuid();

  /// Copies a temporary or picked image file to persistent application documents storage.
  /// Returns the permanent local file path or original URI if network/asset.
  static Future<String> saveImagePermanently(String sourcePath) async {
    // If it's a web path, asset, or empty, return as is
    if (sourcePath.isEmpty ||
        sourcePath.startsWith('http') ||
        sourcePath.startsWith('assets/')) {
      return sourcePath;
    }

    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return sourcePath;
      }

      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/roomio_media');
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final extension = sourcePath.contains('.')
          ? sourcePath.split('.').last
          : 'jpg';
      final fileName =
          'roomio_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}.$extension';
      final targetPath = '${mediaDir.path}/$fileName';

      final permanentFile = await sourceFile.copy(targetPath);
      return permanentFile.path;
    } catch (e) {
      debugPrint('Error saving image permanently: $e');
      return sourcePath;
    }
  }
}
