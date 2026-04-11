class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.surName,
    required this.email,
    required this.phoneNumber,
    required this.age,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.passportNumber,
    required this.languages,
    required this.profileImageRaw,
    this.travellerCode = '',
    this.isVerified = false,
    this.address = '',
    this.houseNumber = '',
    this.placeOfBirth = '',
    this.placeOfResidence = '',
    this.postalCode = '',
  });

  final String firstName;
  final String surName;
  final String email;
  final String phoneNumber;
  final int? age;
  /// ISO string or display string as returned by backend.
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String passportNumber;
  final List<String> languages;
  /// Can be URL/path/filename depending on backend.
  final String profileImageRaw;

  /// `GET /booking/get-user-details` → `travellerCode` (display only; backend may ignore on PATCH).
  final String travellerCode;
  final bool isVerified;
  final String address;
  final String houseNumber;
  final String placeOfBirth;
  final String placeOfResidence;
  final String postalCode;

  String get fullName {
    final f = firstName.trim();
    final l = surName.trim();
    if (f.isEmpty && l.isEmpty) return '';
    if (f.isEmpty) return l;
    if (l.isEmpty) return f;
    return '$f $l';
  }

  String get primaryLanguage => languages.isEmpty ? '' : languages.first;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<String> parseLanguages(dynamic v) {
      if (v == null) return const [];
      if (v is List) {
        return v
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList();
      }
      final s = v.toString();
      if (s.contains(',')) {
        return s
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (s.trim().isEmpty) return const [];
      return [s.trim()];
    }

    final first = (json['firstName'] ?? '').toString().trim();
    final sur = (json['surName'] ?? json['surname'] ?? '').toString().trim();
    final full = (json['fullName'] ?? json['name'] ?? '').toString().trim();
    String derivedFirst = first;
    String derivedSur = sur;
    if (derivedFirst.isEmpty && derivedSur.isEmpty && full.isNotEmpty) {
      final parts = full.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.isNotEmpty) {
        derivedFirst = parts.first;
        derivedSur = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    }

    int? parseAge(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    bool parseVerified(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    return UserProfile(
      firstName: derivedFirst,
      surName: derivedSur,
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['contact'] ?? '').toString(),
      age: parseAge(json['age']),
      dateOfBirth: (json['dateOfBirth'] ?? json['dob'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      nationality: (json['nationality'] ?? '').toString(),
      passportNumber:
          (json['passportNumber'] ?? json['passportNo'] ?? '').toString(),
      // Your API uses `language: "english"`; support both `language` and `languages`.
      languages: parseLanguages(json['languages'] ?? json['language']),
      profileImageRaw: (json['profileImage'] ?? json['profilePicture'] ?? '').toString(),
      travellerCode: (json['travellerCode'] ?? '').toString(),
      isVerified: parseVerified(json['isVerified']),
      address: (json['address'] ?? '').toString(),
      houseNumber: (json['houseNumber'] ?? '').toString(),
      placeOfBirth: (json['placeOfBirth'] ?? '').toString(),
      placeOfResidence: (json['placeOfResidence'] ?? '').toString(),
      postalCode: (json['postalCode'] ?? '').toString(),
    );
  }

  UserProfile copyWith({
    String? firstName,
    String? surName,
    String? email,
    String? phoneNumber,
    int? age,
    String? dateOfBirth,
    String? gender,
    String? nationality,
    String? passportNumber,
    List<String>? languages,
    String? profileImageRaw,
    String? travellerCode,
    bool? isVerified,
    String? address,
    String? houseNumber,
    String? placeOfBirth,
    String? placeOfResidence,
    String? postalCode,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      surName: surName ?? this.surName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      passportNumber: passportNumber ?? this.passportNumber,
      languages: languages ?? this.languages,
      profileImageRaw: profileImageRaw ?? this.profileImageRaw,
      travellerCode: travellerCode ?? this.travellerCode,
      isVerified: isVerified ?? this.isVerified,
      address: address ?? this.address,
      houseNumber: houseNumber ?? this.houseNumber,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      placeOfResidence: placeOfResidence ?? this.placeOfResidence,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}

