class FamilyMemberModel {
  final String firstName;
  final String surname;
  final String phoneNumber;
  final String relationship;

  FamilyMemberModel({
    required this.firstName,
    required this.surname,
    required this.phoneNumber,
    required this.relationship,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      firstName: json['firstName'] ?? '',
      surname: json['surname'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "surname": surname,
      "phoneNumber": phoneNumber,
      "relationship": relationship,
    };
  }
}