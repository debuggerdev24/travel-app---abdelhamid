/// Member from `GET /api/team/get-members`.
class TeamMemberModel {
  final String? id;
  final String name;
  /// Backend enum: `support` | `guide`
  final String role;
  final String description;
  final String? profilePictureRaw;
  final bool? available;

  TeamMemberModel({
    this.id,
    required this.name,
    required this.role,
    required this.description,
    this.profilePictureRaw,
    this.available,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      id: json['_id']?.toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      profilePictureRaw: json['profilePicture']?.toString(),
      available: json['available'] as bool?,
    );
  }

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'support':
        return 'Support';
      case 'guide':
        return 'Guide';
      default:
        if (role.isEmpty) return 'Team';
        return role[0].toUpperCase() + role.substring(1);
    }
  }
}
