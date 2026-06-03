import 'package:intl/intl.dart';
import 'package:travel_app_abdelhamid/core/utils/media_url.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';

class GroupMemberModel {
  final String memberId;
  final String? userId;
  final String name;
  final String role;
  final String? avatarUrl;

  GroupMemberModel({
    required this.memberId,
    this.userId,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final memberId =
        json['_id']?.toString() ??
        json['memberId']?.toString() ??
        json['id']?.toString() ??
        '';
    final userId =
        json['userId']?.toString() ??
        json['user']?.toString() ??
        (json['user'] is Map
            ? (json['user'] as Map)['_id']?.toString()
            : null);

    var name = json['name']?.toString() ?? '';
    if (name.isEmpty && json['user'] is Map) {
      final u = Map<String, dynamic>.from(json['user'] as Map);
      name =
          u['name']?.toString() ??
          u['fullName']?.toString() ??
          '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
    }

    final roleRaw =
        json['role']?.toString() ??
        json['memberRole']?.toString() ??
        json['type']?.toString() ??
        '';

    final avatarRaw =
        resolveProfilePictureUrl(json) ??
        resolveProfilePictureUrl(json['userId']) ??
        resolveProfilePictureUrl(json['user']);

    return GroupMemberModel(
      memberId: memberId,
      userId: userId,
      name: name.isEmpty ? 'Member' : name,
      role: _formatRole(roleRaw),
      avatarUrl: avatarRaw,
    );
  }

  static String _formatRole(String raw) {
    if (raw.isEmpty) return 'Member';
    switch (raw.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'guide':
        return 'Guide';
      case 'support':
        return 'Support Team';
      default:
        return raw[0].toUpperCase() + raw.substring(1);
    }
  }
}

class SharedMediaItem {
  final String url;
  final bool isImage;

  SharedMediaItem({required this.url, required this.isImage});

  factory SharedMediaItem.fromJson(Map<String, dynamic> json) {
    final url = resolveMediaUrl(
          json['fileUrl']?.toString() ??
              json['url']?.toString() ??
              json['imageUrl']?.toString(),
        ) ??
        '';
    final mime = (json['mimeType'] ?? json['contentType'] ?? '')
        .toString()
        .toLowerCase();
    final name = (json['fileName'] ?? '').toString().toLowerCase();
    final isImage =
        mime.startsWith('image/') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.webp');
    return SharedMediaItem(url: url, isImage: isImage);
  }
}

/// Parsed from `GET /api/chat/profile?chatId=` plus optional members list.
class GroupInfoModel {
  final String chatId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? destination;
  final String? dateRange;
  final String? createdByLabel;
  final String? createdOnLabel;
  final List<SharedMediaItem> sharedMedia;
  final List<GroupMemberModel> members;
  final bool isCurrentUserAdmin;

  GroupInfoModel({
    required this.chatId,
    required this.name,
    this.description,
    this.imageUrl,
    this.destination,
    this.dateRange,
    this.createdByLabel,
    this.createdOnLabel,
    this.sharedMedia = const [],
    this.members = const [],
    this.isCurrentUserAdmin = false,
  });

  GroupMemberModel? memberForUser(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    for (final m in members) {
      if (m.userId == userId) return m;
    }
    return null;
  }

  factory GroupInfoModel.fromProfileJson({
    required String chatId,
    required Map<String, dynamic> json,
    List<GroupMemberModel> members = const [],
    String? currentUserId,
  }) {
    final trip = json['trip'];
    Map<String, dynamic>? tripMap;
    if (trip is Map) tripMap = Map<String, dynamic>.from(trip);

    final destination =
        _firstNonEmpty([
          json['destination']?.toString(),
          json['tripDestination']?.toString(),
          tripMap?['destination']?.toString(),
          tripMap?['name']?.toString(),
          _joinCities(tripMap?['cities'] ?? json['cities']),
        ]) ??
        '';

    final start =
        json['startDate'] ??
        json['tripStartDate'] ??
        tripMap?['startDate'] ??
        tripMap?['tripStartDate'];
    final end =
        json['endDate'] ??
        json['tripEndDate'] ??
        tripMap?['endDate'] ??
        tripMap?['tripEndDate'];

    final inlineMembers = _parseMembersList(
      json['members'] ?? json['groupMembers'] ?? json['participants'],
    );
    final allMembers = members.isNotEmpty ? members : inlineMembers;

    final isAdmin =
        json['isAdmin'] == true ||
        json['canDelete'] == true ||
        _currentUserIsAdmin(allMembers, currentUserId);

    return GroupInfoModel(
      chatId: chatId,
      name: json['name']?.toString() ?? 'Group',
      description: _firstNonEmpty([
        json['description']?.toString(),
        json['about']?.toString(),
      ]),
      imageUrl:
          serverMediaUrl(
            json['imageUrl']?.toString() ??
                json['groupImage']?.toString() ??
                json['image']?.toString() ??
                (json['trip'] is Map
                    ? (json['trip'] as Map)['imageUrl']?.toString()
                    : null) ??
                (json['group'] is Map
                    ? (json['group'] as Map)['imageUrl']?.toString()
                    : null),
          ) ??
          resolveProfilePictureUrl(json['group']),
      destination: destination.isEmpty ? null : destination,
      dateRange: _formatDateRange(start, end),
      createdByLabel: _formatCreatedBy(json['createdBy'] ?? json['creator']),
      createdOnLabel: _formatCreatedOn(json['createdAt']),
      sharedMedia: _parseSharedMedia(json),
      members: allMembers,
      isCurrentUserAdmin: isAdmin,
    );
  }

  static List<GroupMemberModel> _parseMembersList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => GroupMemberModel.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.memberId.isNotEmpty)
        .toList();
  }

  static List<SharedMediaItem> _parseSharedMedia(Map<String, dynamic> json) {
    final raw =
        json['sharedMedia'] ??
        json['sharedFiles'] ??
        json['media'] ??
        json['documents'] ??
        json['files'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => SharedMediaItem.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.url.isNotEmpty)
        .toList();
  }

  static bool _currentUserIsAdmin(
    List<GroupMemberModel> members,
    String? userId,
  ) {
    if (userId == null) return false;
    for (final m in members) {
      if (m.userId == userId && m.role.toLowerCase() == 'admin') return true;
    }
    return false;
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  static String _joinCities(dynamic raw) {
    if (raw is! List || raw.isEmpty) return '';
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).join(', ');
  }

  static String _formatCreatedBy(dynamic raw) {
    if (raw == null) return '';
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      final name =
          m['name']?.toString() ??
          m['fullName']?.toString() ??
          '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim();
      final role = m['role']?.toString() ?? '';
      if (name.isEmpty) return '';
      if (role.isNotEmpty) {
        return '$name (${GroupMemberModel._formatRole(role)})';
      }
      return name;
    }
    return raw.toString();
  }

  static String _formatCreatedOn(dynamic raw) {
    final d = _parseDate(raw);
    if (d == null) return '';
    return DateFormat('dd MMM yyyy').format(d);
  }

  static String? _formatDateRange(dynamic startRaw, dynamic endRaw) {
    final start = _parseDate(startRaw);
    final end = _parseDate(endRaw);
    if (start == null && end == null) return null;
    if (start != null && end != null) {
      if (start.year == end.year && start.month == end.month) {
        return '${start.day} – ${DateFormat('d MMM yyyy').format(end)}';
      }
      return '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
    }
    final d = start ?? end!;
    return DateFormat('d MMM yyyy').format(d);
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is Map) {
      final d = raw[r'$date'] ?? raw['\$date'] ?? raw['date'];
      if (d is String) return DateTime.tryParse(d);
      if (d is int) {
        return DateTime.fromMillisecondsSinceEpoch(d, isUtc: true).toLocal();
      }
    }
    return null;
  }
}
