import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/user_flight_provider.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';

/// Refetches everything that depends on the current trip (hotels, flights, itinerary,
/// documents bundle, essentials, booking/package details).
Future<void> refreshAllTripScopedData(BuildContext context, String tripId) async {
  if (tripId.isEmpty) return;

  final trip = context.read<TripProvider>();
  final flight = context.read<FlightProvider>();
  final myTrip = context.read<MyTripProvider>();
  final booking = context.read<TripBookingProvider>();

  flight.clearFlightCache();
  myTrip.clearTripDocumentsCache();

  await Future.wait([
    trip.fetchHotelVoucherDetails(tripId, force: true),
    trip.fetchTodayItinerary(tripId, force: true),
    flight.fetchMyFlights(tripId, force: true),
    myTrip.fetchTripDocuments(tripId, force: true),
    myTrip.refreshEssentialsTab(),
    booking.loadTripDetails(tripId),
  ]);
}
