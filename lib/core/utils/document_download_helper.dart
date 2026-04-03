import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trael_app_abdelhamid/core/utils/pref_helper.dart';

/// Shares a local file or downloads a remote file then opens the system share sheet
/// so the user can save to Files / Drive / etc.
Future<void> shareDocumentFile({
  required BuildContext context,
  File? localFile,
  String? networkUrl,
  required String label,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);

  if (localFile != null) {
    if (!localFile.existsSync()) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('File is no longer available.')),
      );
      return;
    }
    final name = _sanitizeFileName(label);
    final ext = _extensionFromPath(localFile.path);
    await Share.shareXFiles(
      [
        XFile(
          localFile.path,
          name: ext != null ? '$name$ext' : name,
        ),
      ],
      subject: label,
    );
    return;
  }

  final url = networkUrl?.trim();
  if (url == null || url.isEmpty) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('No file available to download.')),
    );
    return;
  }

  messenger?.showSnackBar(
    const SnackBar(content: Text('Preparing download…')),
  );

  try {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    final token = PrefHelper.getAccessToken();
    final headers = <String, dynamic>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        headers: headers,
      ),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('Empty file');
    }

    final ext = _extensionFromUrl(url, response.headers.value('content-type'));
    final base = _sanitizeFileName(label);
    final fileName = '$base$ext';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    messenger?.hideCurrentSnackBar();
    await Share.shareXFiles(
      [XFile(file.path, name: fileName)],
      subject: label,
    );
  } catch (e) {
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not download the file. Please try again.'),
      ),
    );
  }
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
