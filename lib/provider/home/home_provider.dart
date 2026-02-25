import 'package:flutter/widgets.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';

class TripProvider extends ChangeNotifier {
  TripModel? selectedTrip;

  int rating = 0;
  String reviewText = "";
  bool reviewSubmitted = false;
  // -------------------------------
  List<String> selectedRoomTypes = [];
  List<String> selectedBedTypes = [];
  List<String> selectedChildTypes = [];
  List<String> selectedBabyTypes = [];

  List<String> selectedChildCountList = [];
  List<String> selectedBabyCount = [];

  List<PackageDetails> get packageList => _packageList;

  PackageDetails? _selectedPackage;
  PackageDetails? get selectedPackage => _selectedPackage;

  List<TripModel> _pasttripList = [];
  List<TripModel> _upcomingtripList = [];

  List<TripModel> get tripList => _pasttripList;
  List<TripModel> get upcomingtripList => _upcomingtripList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTrips() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        TripsService.instance.getUpcomingTrips(showErrorToast: true),
        TripsService.instance.getPastTrips(showErrorToast: true),
      ]);
      _upcomingtripList = results[0];
      _pasttripList = results[1];
    } catch (e) {
      // Errors are handled by BaseApiService and logged
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  PaymentMethosEnum selectedMethod = PaymentMethosEnum.googlePay;

  void changeSelectedMethod(PaymentMethosEnum method) {
    selectedMethod = method;
    notifyListeners();
  }

  final List<PackageDetails> _packageList = [
    PackageDetails(
      title: 'Premium Package',
      roomDetails: [],
      childDetails: [],
      inclusions: [
        'Business Class Flights',
        '5★ Hotels (Kaaba View in Makkah, Luxury Hotel in Madinah)',
        'VIP Transport (Private Bus)',
        'Dedicated Guide & Escort',
        'Free SIM Card + Internet Package',
      ],
      exclusions: [
        'All Meals Not Included (Buffet)',
        'Personal shopping',
        'Extra excursions outside package',
      ],
    ),
    PackageDetails(
      title: 'Gold Package',
      roomDetails: [],
      childDetails: [],
      inclusions: [
        'Economy Flights',
        '4★ Hotels (Close to Haram / Masjid Nabawi)',
        'Group Transport (AC Bus)',
        'Dedicated Guide Support',
      ],
      exclusions: ['All Meals Not Included (Buffet)', 'Personal expenses'],
    ),
    PackageDetails(
      title: 'Silver Package',
      roomDetails: [],
      childDetails: [],
      inclusions: [
        'Economy Flights',
        '3★ Hotels (Walking distance ~500m)',
        'Group Transport (Shared Bus)',
        'Guide Support via WhatsApp',
      ],
      exclusions: ['All Meals Not Included (Buffet)', 'No personal SIM card'],
    ),
    PackageDetails(
      title: 'Standard / Economy Package',
      roomDetails: [],
      childDetails: [],
      inclusions: [
        'Basic Economy Flights',
        '2★ Hotels (outside Haram radius, shuttle provided)',
        'Shared Transport (Shuttle Bus)',
      ],
      exclusions: [
        'All Meals Not Included (Buffet)',
        'No escort, only group leader support',
      ],
    ),
  ];

  // Select a package to show in UI
  void selectPackage(PackageDetails package) {
    _selectedPackage = package;
    notifyListeners();
  }

  void selectTrip(TripModel trip) {
    selectedTrip = trip;
    notifyListeners();
  }

  void setRating(int value) {
    rating = value;
    notifyListeners();
  }

  void setReview(String text) {
    reviewText = text;
    notifyListeners();
  }

  void submitReview() {
    reviewSubmitted = true;
    notifyListeners();
  }

  void updateRoomTypes(List<String> rooms) {
    selectedRoomTypes = rooms;
    notifyListeners();
  }

  void updateBedTypes(List<String> beds) {
    selectedBedTypes = beds;
    notifyListeners();
  }

  void updateChildTypes(List<String> childs) {
    selectedChildTypes = childs;
    notifyListeners();
  }

  void updateBabyTypes(List<String> babys) {
    selectedBabyTypes = babys;
    notifyListeners();
  }

  // -------------------------------
  // Update Single Select
  // -------------------------------
  void updateChildCount(List<String> values) {
    selectedChildCountList = values;
    notifyListeners();
  }

  void updateBabyCount(List<String> values) {
    selectedBabyCount = values;
    notifyListeners();
  }
  // -------------------------------
  // Update Single Select
  // -------------------------------
  // ... methods omitted for brevity as they are same ...

  final List<String> roomTypes = ["Double", "Triple", "Quadruple"];

  final List<String> bedTypes = ["Single Bed", "King Size Bed"];

  final List<String> childOptions = [
    "Child (2–10 yrs) No Bed - €1,250",
    "Child (2–10 yrs) With Bed - rate\nwith a child discount of €150",
    "Child (10–12 yrs) With Bed - rate\nwith a child discount of €125",
  ];

  final List<String> numberOfChildren = ["00", "01", "02"];

  final List<String> babyOptions = ["Baby (0–2 yrs) No Bed - €500"];

  final List<String> numberOfBaby = ["00", "01", "02"];
}
