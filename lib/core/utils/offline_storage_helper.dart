import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app_abdelhamid/model/home/trip_model.dart';
import 'package:travel_app_abdelhamid/model/home/user_itinerary_model.dart';
import 'package:travel_app_abdelhamid/model/trip/trip_documents_bundle_model.dart';

class OfflineStorageHelper {
  static const String _savedTripsKey = 'offline_saved_trips';
  static const String _offlineItineraryPrefix = 'offline_itinerary_';
  static const String _offlineDocumentsPrefix = 'offline_documents_';

  /// Saves a trip to the offline list
  static Future<void> saveTripForOffline(TripModel trip) async {
    final prefs = await SharedPreferences.getInstance();
    List<TripModel> savedTrips = await getSavedOfflineTrips();
    
    // Check if trip already exists, update it if so
    int existingIndex = savedTrips.indexWhere((t) => t.id == trip.id);
    if (existingIndex != -1) {
      savedTrips[existingIndex] = trip;
    } else {
      savedTrips.add(trip);
    }
    
    List<String> jsonList = savedTrips.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_savedTripsKey, jsonList);
  }

  /// Gets the list of saved trips
  static Future<List<TripModel>> getSavedOfflineTrips() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_savedTripsKey);
    if (jsonList == null || jsonList.isEmpty) return [];
    
    return jsonList.map((jsonStr) {
      final map = jsonDecode(jsonStr);
      return TripModel.fromJson(Map<String, dynamic>.from(map));
    }).toList();
  }

  /// Removes a trip from the offline list
  static Future<void> removeOfflineTrip(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    List<TripModel> savedTrips = await getSavedOfflineTrips();
    savedTrips.removeWhere((t) => t.id == tripId);
    
    List<String> jsonList = savedTrips.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList(_savedTripsKey, jsonList);
    
    // Also remove associated data
    await prefs.remove('$_offlineItineraryPrefix$tripId');
    await prefs.remove('$_offlineDocumentsPrefix$tripId');
  }

  /// Saves an offline itinerary
  static Future<void> saveOfflineItinerary(String tripId, UserItineraryResponseModel itinerary) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonStr = jsonEncode(itinerary.toJson());
    await prefs.setString('$_offlineItineraryPrefix$tripId', jsonStr);
  }

  /// Gets an offline itinerary
  static Future<UserItineraryResponseModel?> getOfflineItinerary(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString('$_offlineItineraryPrefix$tripId');
    if (jsonStr == null) return null;
    
    final map = jsonDecode(jsonStr);
    return UserItineraryResponseModel.fromJson(Map<String, dynamic>.from(map));
  }

  /// Saves offline documents
  static Future<void> saveOfflineDocuments(String tripId, TripDocumentsBundle documents) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonStr = jsonEncode(documents.toJson());
    await prefs.setString('$_offlineDocumentsPrefix$tripId', jsonStr);
  }

  /// Gets offline documents
  static Future<TripDocumentsBundle?> getOfflineDocuments(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString('$_offlineDocumentsPrefix$tripId');
    if (jsonStr == null) return null;
    
    final map = jsonDecode(jsonStr);
    return TripDocumentsBundle.fromJson(Map<String, dynamic>.from(map));
  }
}
