import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';

enum TripsType { upcoming, past }

class TripsService {
  TripsService._internal();
  static final TripsService instance = TripsService._internal();

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
      final response = await BaseApiService.instance.get(
        Endpoints.getTrips,
        queryParameters: {
          'type': type == TripsType.upcoming ? 'upcoming' : 'past',
        },
        showErrorToast: showErrorToast,
      );

      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> data = response['data'];
        return data.map((json) => TripModel.fromJson(json)).toList();
      } else {
        throw Exception('Invalid or null response data');
      }
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
