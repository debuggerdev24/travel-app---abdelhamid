class EmergencyContactsData {
  final EmergencyMedical? medical;
  final EmergencyPolice? police;
  final EmergencyGroupLeader? groupLeader;

  EmergencyContactsData({
    this.medical,
    this.police,
    this.groupLeader,
  });

  factory EmergencyContactsData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic v) =>
        v is Map ? Map<String, dynamic>.from(v) : null;

    return EmergencyContactsData(
      medical: asMap(json['medical']) != null
          ? EmergencyMedical.fromJson(asMap(json['medical'])!)
          : null,
      police: asMap(json['police']) != null
          ? EmergencyPolice.fromJson(asMap(json['police'])!)
          : null,
      groupLeader: asMap(json['groupLeader']) != null
          ? EmergencyGroupLeader.fromJson(asMap(json['groupLeader'])!)
          : null,
    );
  }
}

class EmergencyMedical {
  final String? contactType;
  final String? hospitalNumber;
  final String? ambulanceCode;

  EmergencyMedical({
    this.contactType,
    this.hospitalNumber,
    this.ambulanceCode,
  });

  factory EmergencyMedical.fromJson(Map<String, dynamic> json) {
    return EmergencyMedical(
      contactType: json['contactType']?.toString(),
      hospitalNumber: json['hospitalNumber']?.toString(),
      ambulanceCode: json['ambulanceCode']?.toString(),
    );
  }
}

class EmergencyPolice {
  final String? contactType;
  final String? policeHelpline;

  EmergencyPolice({this.contactType, this.policeHelpline});

  factory EmergencyPolice.fromJson(Map<String, dynamic> json) {
    // Backend schema uses `PoliceHelpline` (capital P).
    final helpline = json['PoliceHelpline'] ?? json['policeHelpline'];
    return EmergencyPolice(
      contactType: json['contactType']?.toString(),
      policeHelpline: helpline?.toString(),
    );
  }
}

class EmergencyGroupLeader {
  final String? contactType;
  final String? leaderName;
  final String? leaderNumber;
  final String? whatsappNumber;

  EmergencyGroupLeader({
    this.contactType,
    this.leaderName,
    this.leaderNumber,
    this.whatsappNumber,
  });

  factory EmergencyGroupLeader.fromJson(Map<String, dynamic> json) {
    return EmergencyGroupLeader(
      contactType: json['contactType']?.toString(),
      leaderName: json['leaderName']?.toString(),
      leaderNumber: json['leaderNumber']?.toString(),
      whatsappNumber: json['whatsappNumber']?.toString(),
    );
  }
}
