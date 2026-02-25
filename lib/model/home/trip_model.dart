import 'dart:io';

import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';

class TripModel {
  final String? id;
  final String image;
  final String title;
  final String location;
  final String date;
  final String status;
  final String description;
  final List<PackageDetails>? packages;

  TripModel({
    this.id,
    required this.image,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.description,
    this.packages,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['_id'],
      title: json['tripName'] ?? '',
      location: json['location'] ?? '',
      image: json['bannerImage'] ?? '',
      date: _formatDate(json['startDate'], json['endDate']),
      status: json['status'] ?? 'ongoing',
      description: json['description'] ?? '',
      packages: json['packages'] != null
          ? (json['packages'] as List)
                .map((p) => PackageDetails.fromJson(p))
                .toList()
          : null,
    );
  }

  String get imageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    final baseUrl = AppConstants.imageBaseUrl;
    if (image.startsWith('/')) {
      return '$baseUrl$image';
    }
    return '$baseUrl/uploads/$image';
  }

  static String _formatDate(dynamic start, dynamic end) {
    if (start == null || end == null) return '-';
    try {
      final startDate = DateTime.parse(start.toString());
      final endDate = DateTime.parse(end.toString());

      final List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${startDate.day} ${months[startDate.month - 1]} – ${endDate.day} ${months[endDate.month - 1]} ${endDate.year}';
    } catch (e) {
      return '-';
    }
  }
}

class PackageDetails {
  final String? id;
  final String title;
  final List<RoomDetailModel> roomDetails;
  final List<ChildDetailModel> childDetails;
  final List<String> inclusions;
  final List<String> exclusions;

  PackageDetails({
    this.id,
    required this.title,
    required this.roomDetails,
    required this.childDetails,
    required this.inclusions,
    required this.exclusions,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    return PackageDetails(
      id: json['_id'],
      title: json['packageName'] ?? '',
      roomDetails: json['roomDetails'] != null
          ? (json['roomDetails'] as List)
                .map((r) => RoomDetailModel.fromJson(r))
                .toList()
          : [],
      childDetails: json['childDetails'] != null
          ? (json['childDetails'] as List)
                .map((c) => ChildDetailModel.fromJson(c))
                .toList()
          : [],
      inclusions: (json['inclusion'] as List?)?.cast<String>() ?? [],
      exclusions: (json['exclusion'] as List?)?.cast<String>() ?? [],
    );
  }

  // Helper for backward compatibility with UI that uses String lists
  List<String> get roomOptions =>
      roomDetails.map((r) => '${r.roomType} - €${r.roomPrice}').toList();
  List<String> get childPrices =>
      childDetails.map((c) => '${c.childName} - €${c.childPrice}').toList();
}

class RoomDetailModel {
  final String? id;
  final String roomType;
  final double roomPrice;
  final String status;

  RoomDetailModel({
    this.id,
    required this.roomType,
    required this.roomPrice,
    required this.status,
  });

  factory RoomDetailModel.fromJson(Map<String, dynamic> json) {
    return RoomDetailModel(
      id: json['_id'],
      roomType: json['roomType'] ?? '',
      roomPrice: (json['roomPrice'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}

class ChildDetailModel {
  final String? id;
  final String childName;
  final String ageRange;
  final String bedAllocated;
  final double childPrice;

  ChildDetailModel({
    this.id,
    required this.childName,
    required this.ageRange,
    required this.bedAllocated,
    required this.childPrice,
  });

  factory ChildDetailModel.fromJson(Map<String, dynamic> json) {
    return ChildDetailModel(
      id: json['_id'],
      childName: json['childName'] ?? '',
      ageRange: json['ageRange'] ?? '',
      bedAllocated: json['bedAllocated'] ?? '',
      childPrice: (json['childPrice'] ?? 0).toDouble(),
    );
  }
}

class PaymentModel {
  final String id;
  final String amount;
  final String date;

  PaymentModel({required this.id, required this.amount, required this.date});
}

class FlightModel {
  final String title;
  final String flightNumber;
  final String route;
  final String date;
  final String departure;
  final String arrival;
  final String duration;
  final String seat;
  final String baggage;
  final String airlineContact;
  final String deskNo;
  final String email;
  final String status;

  FlightModel({
    required this.title,
    required this.flightNumber,
    required this.route,
    required this.date,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.seat,
    required this.baggage,
    required this.airlineContact,
    required this.deskNo,
    required this.email,
    required this.status,
  });

  /// 🔥 Return all fields in a map to generate buildRow dynamically
  Map<String, String> get infoMap => {
    "Flight": flightNumber,
    "Route": route,
    "Date": date,
    "Departure": departure,
    "Arrival": arrival,
    "Duration": duration,
    "Seat": seat,
    "Baggage": baggage,
    "Airline Contact": airlineContact,
    "Desk No": deskNo,
    "Email": email,
    "Status": status,
  };
}

class HotelModel {
  final String title;
  final String name;
  final String address;
  final String phone;
  final String checkIn;
  final String checkOut;
  final String roomType;
  final String roomNo;
  final String facilities;
  final String status;

  HotelModel({
    required this.title,
    required this.name,
    required this.address,
    required this.phone,
    required this.checkIn,
    required this.checkOut,
    required this.roomType,
    required this.roomNo,
    required this.facilities,
    required this.status,
  });

  Map<String, String> get infoMap => {
    "Name": name,
    "Address": address,
    "Phone": phone,
    "Check-in": checkIn,
    "Check-out": checkOut,
    "Room Type": roomType,
    "Room No": roomNo,
    "Facilities": facilities,
    "Status": status,
  };
}

class UserDocument {
  String? name;
  String? filePath;

  UserDocument({this.name, this.filePath});
}

class DocumentModel {
  final String image;
  final String title;
  final File? fileImage;
  final String? subtitle;
  final Map<String, String>? info;
  final String button1;
  final String button2;
  final String icon;

  DocumentModel({
    required this.image,
    required this.title,
    this.fileImage,
    this.subtitle,
    this.info,
    required this.button1,
    required this.button2,
    required this.icon,
  });
}
