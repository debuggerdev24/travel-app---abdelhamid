import 'package:travel_app_abdelhamid/model/home/trip_model.dart';

/// Result of `GET /api/user/trips/details`
/// (`data.isBooked` + nested `tripDetails`).
class TripDetailsLoadResult {
  final TripModel trip;
  final bool isBooked;
  final String? bookingId;

  TripDetailsLoadResult({
    required this.trip,
    this.isBooked = false,
    this.bookingId,
  });

  factory TripDetailsLoadResult.fromDetailsResponse(Map<String, dynamic> data) {
    final map = Map<String, dynamic>.from(data);
    final trip = TripModel.fromJson(map);
    if ((trip.id == null || trip.id!.isEmpty) &&
        trip.title.isEmpty &&
        map['tripDetails'] == null) {
      throw Exception('Trip details not found');
    }

    String? bookingId = map['bookingId']?.toString();
    if (bookingId == null || bookingId.isEmpty) {
      final booking = map['booking'];
      if (booking is Map) {
        bookingId = booking['_id']?.toString();
      }
    }

    return TripDetailsLoadResult(
      trip: trip,
      isBooked: _parseBool(map['isBooked']),
      bookingId: (bookingId != null && bookingId.isNotEmpty) ? bookingId : null,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == true || value == 1) return true;
    if (value is String) {
      final v = value.toLowerCase();
      return v == 'true' || v == '1';
    }
    return false;
  }
}
