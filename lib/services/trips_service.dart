import 'dart:io';

import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
import 'package:trael_app_abdelhamid/model/home/hotel_voucher_model.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/model/home/user_itinerary_model.dart';
import 'package:trael_app_abdelhamid/model/trip/trip_documents_bundle_model.dart';
import 'package:trael_app_abdelhamid/model/user_flight_model.dart';

enum TripsType { upcoming, past }

class TripsService {
  TripsService._internal();
  static final TripsService instance = TripsService._internal();

  /// Backend: `GET /api/user/trips/list?type=upcoming` → `data` is a JSON array.
  Future<List<TripModel>> getUpcomingTrips({
    bool showErrorToast = false,
  }) async {
    try {
      return await _getTrips(
        TripsType.upcoming,
        showErrorToast: showErrorToast,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Backend: `GET /api/user/trips/list?type=past` → `data` is a JSON array.
  Future<List<TripModel>> getPastTrips({bool showErrorToast = false}) async {
    try {
      return await _getTrips(TripsType.past, showErrorToast: showErrorToast);
    } catch (e) {
      rethrow;
    }
  }

  Future<TripModel> getTripDetails(
    String id, {
    bool showErrorToast = true,
  }) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.getTripDetails,
        queryParameters: {'tripId': id},
        showErrorToast: showErrorToast,
      );

      if (response['data'] != null) {
        return TripModel.fromJson(response['data']);
      } else {
        throw Exception('Trip details not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TripModel>> _getTrips(
    TripsType type, {
    bool showErrorToast = false,
  }) async {
    try {
      final typeStr = type == TripsType.upcoming ? 'upcoming' : 'past';
      final response = await BaseApiService.instance.get(
        Endpoints.getTrips,
        queryParameters: {'type': typeStr},
        showErrorToast: showErrorToast,
      );

      final data = response['data'];
      // Backend: with ?type=upcoming|past, `data` is a plain array of trips.
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => TripModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      // Without `type`, `data` is { upcoming: [...], past: [...] }.
      if (data is Map) {
        final key = type == TripsType.upcoming ? 'upcoming' : 'past';
        final list = data[key] as List<dynamic>? ?? [];
        return list
            .whereType<Map>()
            .map((e) => TripModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> savePersonDetail(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.savePersonDetail,
        body: body,
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addBookingPackage(
    String tripId,
    String packageId,
  ) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.addBookingPackage,
        queryParameters: {'tripId': tripId},
        body: {'packageId': packageId},
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPackageOptions(String tripId) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.getPackageOptions,
        queryParameters: {'tripId': tripId},
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveFamilyDetails({
    required String bookingId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.saveFamilyDetails,
        queryParameters: {'bookingId': bookingId},
        body: body,
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<FlightDetailsModel> getMyFlights(String tripId) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.myFlights,
        queryParameters: {'tripId': tripId},
        showErrorToast: true,
      );

      if (response['data'] != null) {
        return FlightDetailsModel.fromJson(response['data']);
      } else {
        throw Exception('Flight details not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HotelVoucherModel>> getHotelVoucherDetails(
    String tripId, {
    bool showErrorToast = false,
  }) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.hotelVoucherDetails,
        queryParameters: {'tripId': tripId},
        showErrorToast: showErrorToast,
      );

      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => HotelVoucherModel.fromJson(e.cast<String, dynamic>()))
            .toList();
      }

      return [];
    } on ApiException catch (e) {
      // Backend uses 404 when there are no allocations yet.
      // Treat it as an empty state, not an error.
      if (e.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Trip d ocuments bundle: `memberDocuments` + `tripDocuments` (hotel, insurance, checklist).
  /// Backend: `GET /api/user/trip-documents?tripId=`.
  Future<TripDocumentsBundle> getTripDocuments(
    String tripId, {
    bool showErrorToast = false,
  }) async {
    final response = await BaseApiService.instance.get(
      Endpoints.tripDocuments,
      queryParameters: {'tripId': tripId},
      showErrorToast: showErrorToast,
    );

    if (response is! Map) {
      throw Exception('Invalid trip documents response');
    }
    final root = Map<String, dynamic>.from(response);
    final data = root['data'];
    if (data is! Map) {
      throw Exception('Trip documents payload missing');
    }
    return TripDocumentsBundle.fromJson(Map<String, dynamic>.from(data));
  }

  /// `POST /documents/add-document?tripId=` — multipart field `photo` + body fields.
  /// [documentType] must be `passport`, `visa`, or `medical certificate` (backend).
  Future<Map<String, dynamic>> addUserDocument({
    required String tripId,
    required String documentType,
    required String documentName,
    required File photoFile,
    String? memberId,
    bool showErrorToast = true,
  }) async {
    final fields = <String, String>{
      'documentType': documentType,
      'documentName': documentName,
      if (memberId != null && memberId.isNotEmpty) 'memberId': memberId,
    };
    final response = await BaseApiService.instance.postMultipart(
      Endpoints.addUserDocument,
      fields: fields,
      fileFieldName: 'photo',
      filePath: photoFile.path,
      queryParameters: {'tripId': tripId},
      showErrorToast: showErrorToast,
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    throw Exception('Invalid add-document response');
  }

  Future<UserItineraryResponseModel> getTodayItinerary(
    String tripId, {
    bool showErrorToast = false,
  }) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.todayItinerary,
        queryParameters: {'tripId': tripId},
        showErrorToast: showErrorToast,
      );

      final data = response['data'];
      if (data is Map) {
        return UserItineraryResponseModel.fromJson(
          data.cast<String, dynamic>(),
        );
      }

      throw Exception('Itinerary not found');
    } on ApiException catch (e) {
      // Backend uses 404 when there is no itinerary for the day.
      // Treat it as an empty state.
      if (e.statusCode == 404) {
        return UserItineraryResponseModel.empty();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  //   Future<TripPaymentDetails> getPaymentDetails(
  //   String tripId, {
  //   bool showErrorToast = true,
  // }) async {
  //   try {
  //     final response = await BaseApiService.instance.get(
  //       Endpoints.getPaymentDetails, // add this in endpoints.dart manually
  //       queryParameters: {'tripId': tripId},
  //       showErrorToast: showErrorToast,
  //     );

  //     if (response['data'] != null) {
  //       return TripPaymentDetails.fromJson(response['data']);
  //     } else {
  //       throw Exception('Payment details not found');
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }  
  // }

  Future<Map<String, dynamic>> saveRoomPreference(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.saveRoomPreference,
        body: data,
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
