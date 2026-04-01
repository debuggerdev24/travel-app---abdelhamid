class PersonDetailsModel {
  final String id;
  final String travellerCode;
  final String language;
  final String email;
  final bool isVerified;
  final String phoneNumber;
  final String firstName;
  final String surname;
  final String? dateOfBirth;
  final String placeOfBirth;
  final String nationality;
  final String address;
  final String houseNumber;
  final String postalCode;
  final String placeOfResidence;

  PersonDetailsModel({
    required this.id,
    required this.travellerCode,
    required this.language,
    required this.email,
    required this.isVerified,
    required this.phoneNumber,
    required this.firstName,
    required this.surname,
    this.dateOfBirth,
    required this.placeOfBirth,
    required this.nationality,
    required this.address,
    required this.houseNumber,
    required this.postalCode,
    required this.placeOfResidence,
  });

  factory PersonDetailsModel.fromJson(Map<String, dynamic> json) {
    return PersonDetailsModel(
      id: json['_id'] ?? '',
      travellerCode: json['travellerCode'] ?? '',
      language: json['language'] ?? '',
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
      phoneNumber: json['phoneNumber'] ?? '',
      firstName: json['firstName'] ?? '',
      surname: json['surname'] ?? '',
      dateOfBirth: json['dateOfBirth'],
      placeOfBirth: json['placeOfBirth'] ?? '',
      nationality: json['nationality'] ?? '',
      address: json['address'] ?? '',
      houseNumber: json['houseNumber'] ?? '',
      postalCode: json['postalCode'] ?? '',
      placeOfResidence: json['placeOfResidence'] ?? '',
    );
  }
}