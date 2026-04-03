/// Row from `GET /api/location/get-locations` (grouped by country in `data`).
class OfficeLocation {
  final String? id;
  final String name;
  final String country;
  final String address;
  final String contact;
  final String workingHours;
  final String email;

  OfficeLocation({
    this.id,
    required this.name,
    required this.country,
    required this.address,
    required this.contact,
    required this.workingHours,
    required this.email,
  });

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      id: json['_id']?.toString(),
      name: (json['name'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      contact: (json['contact'] ?? '').toString(),
      workingHours: (json['workingHours'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}
