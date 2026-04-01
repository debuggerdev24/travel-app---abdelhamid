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

  Future<void> fetchMyFlights(String tripId) async {
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