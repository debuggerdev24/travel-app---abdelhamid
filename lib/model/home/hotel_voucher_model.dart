import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';

class HotelFacility {
  final String? id;
  final String? note;
  final String? iconRaw;

  const HotelFacility({this.id, this.note, this.iconRaw});

  String get displayLabel {
    final n = note?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Facility';
  }

  String? get iconUrl => serverMediaUrl(iconRaw);
}

class HotelVoucherModel {
  final String hotelName;
  final String hotelAddress;
  final String hotelImage;
  final String hotelContact;
  final String hotelEmail;
  final String? locationUrl;
  final List<HotelFacility> facilities;
  final HotelStayInfo stayInfo;
  final List<HotelRoomAllocation> rooms;

  HotelVoucherModel({
    required this.hotelName,
    required this.hotelAddress,
    required this.hotelImage,
    required this.hotelContact,
    required this.hotelEmail,
    required this.locationUrl,
    required this.facilities,
    required this.stayInfo,
    required this.rooms,
  });

  String get facilitiesDisplayText {
    if (facilities.isEmpty) return '';
    return facilities.map((f) => f.displayLabel).join(', ');
  }

  factory HotelVoucherModel.fromJson(Map<String, dynamic> json) {
    return HotelVoucherModel(
      hotelName: (json['hotelName'] ?? '').toString(),
      hotelAddress: (json['hotelAddress'] ?? '').toString(),
      hotelImage: (json['hotelImage'] ?? '').toString(),
      hotelContact: (json['hotelContact'] ?? '').toString(),
      hotelEmail: (json['hotelEmail'] ?? '').toString(),
      locationUrl: json['locationUrl']?.toString(),
      facilities: _parseFacilities(json['facilities']),
      stayInfo: HotelStayInfo.fromJson(
        (json['stayInfo'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      rooms:
          (json['rooms'] as List?)
              ?.map(
                (e) => HotelRoomAllocation.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
    );
  }

  static List<HotelFacility> _parseFacilities(dynamic raw) {
    if (raw is! List) return const [];
    final out = <HotelFacility>[];
    for (final e in raw) {
      if (e is Map) {
        final map = Map<String, dynamic>.from(e);
        out.add(
          HotelFacility(
            id: map['_id']?.toString(),
            note: map['note']?.toString(),
            iconRaw: map['icon']?.toString(),
          ),
        );
      } else {
        final s = e.toString().trim();
        if (s.isNotEmpty && !s.startsWith('{')) {
          out.add(HotelFacility(note: s));
        }
      }
    }
    return out;
  }
}

class HotelStayInfo {
  final String? checkIn;
  final String? checkOut;
  final String nights;

  HotelStayInfo({
    required this.checkIn,
    required this.checkOut,
    required this.nights,
  });

  factory HotelStayInfo.fromJson(Map<String, dynamic> json) {
    return HotelStayInfo(
      checkIn: json['checkIn']?.toString(),
      checkOut: json['checkOut']?.toString(),
      nights: (json['nights'] ?? '0').toString(),
    );
  }
}

class HotelRoomAllocation {
  final String id;
  final String bookingRef;
  final String roomNumber;
  final String roomType;
  final List<String> guests;
  final String occupancy;

  HotelRoomAllocation({
    required this.id,
    required this.bookingRef,
    required this.roomNumber,
    required this.roomType,
    required this.guests,
    required this.occupancy,
  });

  factory HotelRoomAllocation.fromJson(Map<String, dynamic> json) {
    return HotelRoomAllocation(
      id: (json['_id'] ?? '').toString(),
      bookingRef: (json['bookingRef'] ?? '').toString(),
      roomNumber: (json['roomNumber'] ?? '').toString(),
      roomType: (json['roomType'] ?? '').toString(),
      guests: (json['guests'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      occupancy: (json['occupancy'] ?? '').toString(),
    );
  }
}
