import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Target max size for multipart uploads (nginx often limits ~1MB).
const int kUploadMaxBytes = 900 * 1024;

/// Backward-compatible alias.
const int kProfileImageMaxBytes = kUploadMaxBytes;

/// Compresses [sourcePath] to JPEG and returns a path safe to upload.
/// Always runs at least one compression pass; keeps the smallest result under [maxBytes].
Future<String> compressImageForUpload(
  String sourcePath, {
  int maxBytes = kUploadMaxBytes,
}) async {
  final source = File(sourcePath);
  if (!await source.exists()) return sourcePath;

  final originalSize = await source.length();
  if (originalSize <= 0) return sourcePath;

  final dir = await getTemporaryDirectory();
  var quality = 82;
  var maxDim = 1280;
  String? bestPath;
  var bestSize = originalSize;

  for (var attempt = 0; attempt < 6; attempt++) {
    final target =
        '${dir.path}/upload_${DateTime.now().millisecondsSinceEpoch}_$attempt.jpg';
    final out = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      target,
      quality: quality,
      minWidth: maxDim,
      minHeight: maxDim,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (out == null) break;

    final size = await File(out.path).length();
    if (size > 0 && size < bestSize) {
      bestPath = out.path;
      bestSize = size;
    }
    if (size > 0 && size <= maxBytes) {
      return out.path;
    }

    quality = (quality - 12).clamp(35, 95);
    maxDim = (maxDim * 0.8).round().clamp(480, 1920);
  }

  return bestPath ?? sourcePath;
}

/// Returns a [File] ready for multipart upload (compressed when possible).
Future<File> compressImageFileForUpload(
  File file, {
  int maxBytes = kUploadMaxBytes,
}) async {
  final path = await compressImageForUpload(file.path, maxBytes: maxBytes);
  return File(path);
}
