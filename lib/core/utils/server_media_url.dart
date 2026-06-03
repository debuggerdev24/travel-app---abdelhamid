import 'package:travel_app_abdelhamid/core/constants/app_constants.dart';

/// True when [raw] looks like an uploads path or URL, not a Mongo id / plain name.
bool _looksLikeMediaPath(String raw) {
  final v = raw.trim();
  if (v.isEmpty) return false;
  if (v.startsWith('http://') || v.startsWith('https://')) return true;
  if (v.contains('/uploads/') || v.startsWith('/uploads/')) return true;
  if (v.startsWith('uploads/')) return true;
  return v.contains('.') &&
      RegExp(
        r'\.(jpg|jpeg|png|gif|webp|bmp|svg|pdf|doc|docx)$',
        caseSensitive: false,
      ).hasMatch(v);
}

/// Builds a full URL for files served under `/uploads/` (same rules as [TripModel.imageUrl]).
String? serverMediaUrl(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final trimmed = raw.trim();
  if (!_looksLikeMediaPath(trimmed)) return null;
  if (trimmed.startsWith('http')) return trimmed;

  final baseUrl = AppConstants.imageBaseUrl;
  final normalized = _normalizeUploadPath(trimmed);

  if (normalized.startsWith('/')) {
    return Uri.parse('$baseUrl$normalized').toString();
  }
  return Uri.parse('$baseUrl/uploads/$normalized').toString();
}
/// Resolves a user/group avatar from a string path or nested API object.
String? resolveProfilePictureUrl(dynamic raw) {
  if (raw == null) return null;
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    for (final key in [
      'profilePicture',
      'profileImage',
      'photo',
      'imageUrl',
      'avatar',
      'image',
    ]) {
      final resolved = resolveProfilePictureUrl(map[key]);
      if (resolved != null && resolved.isNotEmpty) return resolved;
    }
    return null;
  }
  final text = raw.toString().trim();
  if (text.isEmpty) return null;
  return serverMediaUrl(text);
}

/// Reads sender avatar fields from a chat message payload.
String? profilePictureFromMessage(
  Map<String, dynamic> message, {
  Map<String, String>? senderAvatars,
}) {
  final senderImage = message['senderImage']?.toString();
  if (senderImage != null && senderImage.isNotEmpty) {
    final resolved = serverMediaUrl(senderImage);
    if (resolved != null && resolved.isNotEmpty) return resolved;
  }

  for (final key in [
    'senderProfilePicture',
    'senderAvatar',
    'senderPhoto',
    'profilePicture',
    'profileImage',
  ]) {
    final resolved = resolveProfilePictureUrl(message[key]);
    if (resolved != null && resolved.isNotEmpty) return resolved;
  }

  if (message['sender'] is Map) {
    final resolved = resolveProfilePictureUrl(message['sender']);
    if (resolved != null && resolved.isNotEmpty) return resolved;
  }
  if (message['user'] is Map) {
    final resolved = resolveProfilePictureUrl(message['user']);
    if (resolved != null && resolved.isNotEmpty) return resolved;
  }
  if (message['userId'] is Map) {
    final resolved = resolveProfilePictureUrl(message['userId']);
    if (resolved != null && resolved.isNotEmpty) return resolved;
  }

  final senderId = message['sender']?.toString();
  if (senderAvatars != null &&
      senderId != null &&
      senderId.isNotEmpty &&
      senderAvatars.containsKey(senderId)) {
    return senderAvatars[senderId];
  }

  return null;
}

/// Collects `sender` → avatar URL from history/socket message lists.
Map<String, String> senderAvatarMapFromMessages(List<dynamic> messages) {
  final map = <String, String>{};
  for (final item in messages) {
    if (item is! Map) continue;
    final m = Map<String, dynamic>.from(item);
    final senderId = m['sender']?.toString();
    if (senderId == null || senderId.isEmpty) continue;
    final url = profilePictureFromMessage(m);
    if (url != null && url.isNotEmpty) {
      map[senderId] = url;
    }
  }
  return map;
}

/// Merges optional `participantImages` / `participantProfilePictures` from history.
Map<String, String> mergeParticipantImages(
  Map<String, String> base,
  Map<String, dynamic> historyPayload,
) {
  final merged = Map<String, String>.from(base);
  for (final key in ['participantImages', 'participantProfilePictures']) {
    final raw = historyPayload[key];
    if (raw is! Map) continue;
    raw.forEach((id, value) {
      final url = resolveProfilePictureUrl(value);
      if (url != null && url.isNotEmpty) {
        merged[id.toString()] = url;
      }
    });
  }
  return merged;
}
String _normalizeUploadPath(String raw) {
  var v = raw.trim();
  if (v.isEmpty) return v;

  v = v.replaceAll('\\', '/');

  final idx = v.lastIndexOf('/uploads/');
  if (idx != -1) {
    return v.substring(idx);
  }

  final lastSlash = v.lastIndexOf('/');
  if (lastSlash != -1 && lastSlash < v.length - 1) {
    return v.substring(lastSlash + 1);
  }
  return v;
}
