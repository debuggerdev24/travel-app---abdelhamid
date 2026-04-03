import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/model/user_flight_model.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';

class FlightProvider extends ChangeNotifier {
  FlightDetailsModel? _flightDetails;
  FlightDetailsModel? get flightDetails => _flightDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Clears cached flights so the UI does not briefly show the previous trip.
  void clearFlightCache() {
    _flightDetails = null;
    _error = null;
    notifyListeners();
  }

  /// When [force] is true, calls the API again even if flights were already loaded
  /// (e.g. user re-opens the Trip **Flights** tab).
  Future<void> fetchMyFlights(String tripId, {bool force = false}) async {
    if (_isLoading) return;
    if (!force && _flightDetails != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔵 [FlightProvider] Fetching flights for tripId: $tripId');
      _flightDetails = await TripsService.instance.getMyFlights(tripId);
      debugPrint('✅ [FlightProvider] Flights fetched: ${_flightDetails?.flights.length} flights');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ [FlightProvider] Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}