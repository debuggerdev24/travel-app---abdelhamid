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
    final rawId = json['_id'];
    return TripModel(
      id: rawId?.toString(),
      title: (json['tripName'] ?? json['name'] ?? '').toString(),
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

  /// Nested `trip` from `GET /api/user-payment/my-trip` (`name`, `bannerImage`, dates — may omit `_id`).
  factory TripModel.fromUserPaymentMyTripJson(Map<String, dynamic> json) {
    final rawId = json['_id'] ?? json['tripId'];
    return TripModel(
      id: rawId?.toString(),
      title: (json['tripName'] ?? json['name'] ?? '').toString(),
      location: json['location']?.toString() ?? '',
      image: json['bannerImage']?.toString() ?? '',
      date: _formatDate(json['startDate'], json['endDate']),
      status: json['status']?.toString() ?? 'ongoing',
      description: json['description']?.toString() ?? '',
      packages: null,
    );
  }

  String get imageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http')) return image;

    final baseUrl = AppConstants.imageBaseUrl;
    final normalized = _normalizeUploadPath(image);

    if (normalized.startsWith('/')) {
      return '$baseUrl$normalized';
    }
    return '$baseUrl/uploads/$normalized';
  }

  /// Backend sometimes sends a full Windows path like:
  /// `C:\...\uploads\bannerImage-123.png`
  /// We normalize it to a usable public path/filename.
  static String _normalizeUploadPath(String raw) {
    var v = raw.trim();
    if (v.isEmpty) return v;

    // Convert windows separators to forward slashes.
    v = v.replaceAll('\\', '/');

    // If it already contains `/uploads/`, keep only the public part.
    final idx = v.lastIndexOf('/uploads/');
    if (idx != -1) {
      return v.substring(idx); // starts with /uploads/...
    }

    // Otherwise keep just the filename (covers absolute paths).
    final lastSlash = v.lastIndexOf('/');
    if (lastSlash != -1 && lastSlash < v.length - 1) {
      return v.substring(lastSlash + 1);
    }
    return v;
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

  /// Shown when [fileImage] is null (remote documents).
  final String? networkThumbnailUrl;

  /// Full file URL for View / PDF (optional).
  final String? networkFileUrl;
  final String? subtitle;
  final Map<String, String>? info;
  final String button1;
  final String button2;
  final String icon;

  DocumentModel({
    required this.image,
    required this.title,
    this.fileImage,
    this.networkThumbnailUrl,
    this.networkFileUrl,
    this.subtitle,
    this.info,
    required this.button1,
    required this.button2,
    required this.icon,
  });
}

class TripPaymentDetails {
  final String packageName;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final bool isFullyPaid;

  TripPaymentDetails({
    required this.packageName,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.isFullyPaid,
  });

  /// Prefer [paid] from [GET user-payment/history] when it is higher than [paidAmount]
  /// (e.g. my-trip summary not yet updated after Stripe, but history rows exist).
  TripPaymentDetails withReconciledPaid(double paid) {
    final total = totalAmount;
    if (total <= 0) return this;
    final p = paid.clamp(0.0, total);
    final pend = (total - p).clamp(0.0, total);
    final fully = pend < 0.009;
    return TripPaymentDetails(
      packageName: packageName,
      totalAmount: total,
      paidAmount: p,
      pendingAmount: pend,
      isFullyPaid: fully,
    );
  }

  factory TripPaymentDetails.fromJson(Map<String, dynamic> json) {
    final summary = json['paymentSummary'];
    // Root + nested summary: summary keys win (typical API shape).
    final merged = Map<String, dynamic>.from(json);
    if (summary is Map) {
      merged.addAll(Map<String, dynamic>.from(summary));
    }

    num readNum(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v;
      return double.tryParse(v.toString()) ?? 0;
    }

    double pickAmount(List<String> keys) {
      for (final k in keys) {
        if (!merged.containsKey(k)) continue;
        return readNum(merged[k]).toDouble();
      }
      return 0;
    }

    String pickString(List<String> keys) {
      for (final k in keys) {
        final v = merged[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    bool pickFullyPaid() {
      final v = merged['isFullyPaid'] ?? merged['fullyPaid'];
      if (v == true) return true;
      if (v == false) return false;
      final s = v?.toString().toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
      return false;
    }

    var total = pickAmount(const [
      'totalAmount',
      'total_amount',
      'total',
      'packageTotal',
      'grandTotal',
    ]);
    var paid = pickAmount(const [
      'paidAmount',
      'paid_amount',
      'amountPaid',
      'paid',
    ]);
    var pending = pickAmount(const [
      'pendingAmount',
      'pending_amount',
      'pending',
      'balance',
      'remaining',
      'remainingAmount',
    ]);

    // If only two of three are present, derive the third.
    if (total <= 0 && paid >= 0 && pending >= 0 && (paid > 0 || pending > 0)) {
      total = paid + pending;
    } else if (pending <= 0 && total > 0 && paid >= 0 && paid <= total + 0.01) {
      pending = (total - paid).clamp(0.0, double.infinity);
    } else if (paid <= 0 &&
        total > 0 &&
        pending >= 0 &&
        pending <= total + 0.01) {
      paid = (total - pending).clamp(0.0, double.infinity);
    }

    var isFully = pickFullyPaid();
    if (!isFully && total > 0 && pending < 0.009) {
      isFully = true;
    }

    return TripPaymentDetails(
      packageName: pickString(const [
        'packageName',
        'package_name',
        'packageTitle',
        'title',
      ]),
      totalAmount: total,
      paidAmount: paid,
      pendingAmount: pending,
      isFullyPaid: isFully,
    );
  }
}

/// Result of [TripsService.fetchEnrolledTripContext]: user's latest active/pending booking for the Trips tab.
class EnrolledTripContext {
  final TripModel trip;
  final String bookingId;
  final TripPaymentDetails paymentDetails;

  EnrolledTripContext({
    required this.trip,
    required this.bookingId,
    required this.paymentDetails,
  });
}
