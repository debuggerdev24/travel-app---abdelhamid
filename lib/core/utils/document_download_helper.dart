import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:travel_app_abdelhamid/core/utils/pref_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';

/// Android: system "Save as" picker. iOS: system share sheet (save to Files, etc.).
Future<void> shareDocumentFile({
  required BuildContext context,
  File? localFile,
  String? networkUrl,
  required String label,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);

  try {
    if (localFile != null) {
      if (!localFile.existsSync()) {
        messenger?.showSnackBar(
          const SnackBar(content: Text('File is no longer available.')),
        );
        return;
      }
      final name = _sanitizeFileName(label);
      final ext = _extensionFromPath(localFile.path);
      final fileName = ext != null ? '$name$ext' : name;
      await _saveOrShare(
        messenger: messenger,
        bytes: await _readBytes(localFile),
        fileName: fileName,
        label: label,
      );
      return;
    }

    final url = _resolveDownloadUrl(networkUrl);
    if (url == null) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('No file available to download.')),
      );
      return;
    }

    messenger?.showSnackBar(
      const SnackBar(content: Text('Preparing download…')),
    );

    final downloaded = await _downloadNetworkFile(url, label);
    messenger?.hideCurrentSnackBar();

    await _saveOrShare(
      messenger: messenger,
      bytes: downloaded.bytes,
      fileName: downloaded.fileName,
      label: label,
    );
  } on DioException {
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not download the file. Please try again.'),
      ),
    );
  } catch (e) {
    messenger?.hideCurrentSnackBar();
    debugPrint('shareDocumentFile error: $e');
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not save the file. Please try again.'),
      ),
    );
  }
}

class _DownloadedFile {
  final Uint8List bytes;
  final String fileName;

  _DownloadedFile({required this.bytes, required this.fileName});
}

String? _resolveDownloadUrl(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return serverMediaUrl(trimmed) ??
      (trimmed.startsWith('http://') || trimmed.startsWith('https://')
          ? trimmed
          : null);
}

Future<Uint8List> _readBytes(File file) async {
  return Uint8List.fromList(await file.readAsBytes());
}

Future<_DownloadedFile> _downloadNetworkFile(String url, String label) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ),
  );
  final token = PrefHelper.getAccessToken();
  final headers = <String, dynamic>{};
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }

  final response = await dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes, headers: headers),
  );

  final data = response.data;
  if (data == null || data.isEmpty) {
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Empty file',
    );
  }

  final ext = _extensionFromUrl(url, response.headers.value('content-type'));
  final base = _sanitizeFileName(label);
  final fileName = '$base$ext';

  return _DownloadedFile(bytes: Uint8List.fromList(data), fileName: fileName);
}

Future<void> _saveOrShare({
  required ScaffoldMessengerState? messenger,
  required Uint8List bytes,
  required String fileName,
  required String label,
}) async {
  if (!kIsWeb && Platform.isIOS) {
    final dir = await getTemporaryDirectory();
    final temp = File('${dir.path}/$fileName');
    await temp.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(temp.path, name: fileName)],
      subject: label,
    );
    return;
  }

  if (!kIsWeb && Platform.isAndroid) {
    final savedPath = await FilePicker.saveFile(
      dialogTitle: 'Save file',
      fileName: fileName,
      bytes: bytes,
    );
    if (savedPath == null || savedPath.isEmpty) {
      return;
    }
    messenger?.showSnackBar(
      const SnackBar(content: Text('File saved successfully.')),
    );
    return;
  }

  final dir = await getTemporaryDirectory();
  final temp = File('${dir.path}/$fileName');
  await temp.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles(
    [XFile(temp.path, name: fileName)],
    subject: label,
  );
}

String _sanitizeFileName(String name) {
  var s = name.trim();
  if (s.isEmpty) s = 'document';
  return s.replaceAll(RegExp(r'[<>:"/\\|?*\n\r]'), '_');
}

String? _extensionFromPath(String path) {
  final i = path.lastIndexOf('.');
  if (i <= 0 || i >= path.length - 1) return null;
  return path.substring(i).toLowerCase();
}

String _extensionFromUrl(String url, String? contentType) {
  try {
    final path = Uri.parse(url).path.toLowerCase();
    if (path.endsWith('.pdf')) return '.pdf';
    if (path.endsWith('.png')) return '.png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return '.jpg';
    if (path.endsWith('.webp')) return '.webp';
  } catch (_) {}
  final ct = contentType?.toLowerCase() ?? '';
  if (ct.contains('pdf')) return '.pdf';
  if (ct.contains('png')) return '.png';
  if (ct.contains('jpeg') || ct.contains('jpg')) return '.jpg';
  if (ct.contains('webp')) return '.webp';
  return '.jpg';
}
