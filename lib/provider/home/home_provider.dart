import 'package:flutter/widgets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';

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

  // Package Details Data
  List<PackageDetails> get packageList => _packageList;

  PackageDetails? _selectedPackage;
  PackageDetails? get selectedPackage => _selectedPackage;

  List<TripModel> get tripList => _pasttripList;
  List<TripModel> get upcomingtripList => _upcomingtripList;
    PaymentMethosEnum selectedMethod = PaymentMethosEnum.googlePay;

  void changeSelectedMethod(PaymentMethosEnum method) {
    selectedMethod = method;
    notifyListeners();
  }

  final List<PackageDetails> _packageList = [
    PackageDetails(
      title: 'Premium Package',
      roomOptions: [
        'Single room - €4,500 per person',
        'Double room - €3,500 per person',
        'Triple room - €2,500 per person',
        'Quadroom - €1,500 per person',
      ],
      childPrices: [
        'Infant (0–2 yrs) No Bed - €500',
        'Child (2–10 yrs) No Bed - €1,250',
        'Child (2–10 yrs) With Bed - rate with a child discount of €150',
        'Child (10–12 yrs) With Bed - rate with a child discount of €125',
      ],
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
      roomOptions: [
        'Single room - €4,500 per person',
        'Double room - €3,500 per person',
        'Triple room - €2,500 per person',
        'Quadroom - €1,500 per person',
      ],
      childPrices: [
        'Infant (0–2 yrs) No Bed - €500',
        'Child (2–10 yrs) No Bed - €1,250',
        'Child (2–10 yrs) With Bed - rate with a child discount of €150',
        'Child (10–12 yrs) With Bed - rate with a child discount of €125',
      ],
      inclusions: [
        'Economy Flights',
        '4★ Hotels (Close to Haram / Masjid Nabawi)',
        'Group Transport (AC Bus)',
        'Dedicated Guide Support',
      ],
      exclusions: [
        'All Meals Not Included (Buffet)',
        'Personal expenses',
      ],
    ),
    PackageDetails(
      title: 'Silver Package',
      roomOptions: [
        'Single room - €4,500 per person',
        'Double room - €3,500 per person',
        'Triple room - €2,500 per person',
        'Quadroom - €1,500 per person',
      ],
      childPrices: [
        'Infant (0–2 yrs) No Bed - €500',
        'Child (2–10 yrs) No Bed - €1,250',
        'Child (2–10 yrs) With Bed - rate with a child discount of €150',
        'Child (10–12 yrs) With Bed - rate with a child discount of €125',
      ],
      inclusions: [
        'Economy Flights',
        '3★ Hotels (Walking distance ~500m)',
        'Group Transport (Shared Bus)',
        'Guide Support via WhatsApp',
      ],
      exclusions: [
        'All Meals Not Included (Buffet)',
        'No personal SIM card',
      ],
    ),
    PackageDetails(
      title: 'Standard / Economy Package',
      roomOptions: [
        'Single room - €4,500 per person',
        'Double room - €3,500 per person',
        'Triple room - €2,500 per person',
        'Quadroom - €1,500 per person',
      ],
      childPrices: [
        'Infant (0–2 yrs) No Bed - €500',
        'Child (2–10 yrs) No Bed - €1,250',
        'Child (2–10 yrs) With Bed - rate with a child discount of €150',
        'Child (10–12 yrs) With Bed - rate with a child discount of €125',
      ],
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
  /// Demo data
  final List<TripModel> _pasttripList = [
    TripModel(
      image: AppAssets.trip1,
      title: "Zenstone Retreat",
      location: "Kyoto, Japan",
      date: "10 May – 20 May 2024",
      status: "Completed",
      description:
          "Welcome to Zenstone Retreat, a serene haven where nature and tranquility meet.",
    ),
    TripModel(
      image: AppAssets.trip2,
      title: "Lotus Walk",
      location: "Lake Como, Italy",
      date: "01 Jun – 11 Jun 2024",
      status: "Completed",
      description:
          "Lotus Walk offers a peaceful journey through scenic lakeside landscapes.",
    ),
  ];

  final List<TripModel> _upcomingtripList = [
    TripModel(
      image: AppAssets.trip3,
      title: "Umrah Trip 2025",
      location: "Makkah, Madinah",
      date: "10 Feb – 20 Feb 2025",
      description:
          "Welcome to Zenstone Retreat, a serene haven where nature and tranquility meet.",
      status: '',
    ),
    TripModel(
      image: AppAssets.trip4,
      title: "Umrah Trip 2025",
      location: "Makkah, Madinah",
      date: "10 Feb – 20 Feb 2025",
      description:
          "Lotus Walk offers a peaceful journey through scenic lakeside landscapes.",
      status: '',
    ),
  ];

    final List<String> roomTypes = [
    "Double",
    "Triple",
    "Quadruple",
  ];

  final List<String> bedTypes = [
    "Join Bed (King Size)",
    "Double Separate",
    "Separate",
  ];

  final List<String> childOptions = [
    "Child (2–10 yrs) No Bed - €1,250",
    "Child (2–10 yrs) With Bed - rate\nwith a child discount of €150",
    "Child (10–12 yrs) With Bed - rate\nwith a child discount of €125",
  ];

  final List<String> numberOfChildren = ["00", "01", "02"];

  final List<String> babyOptions = [
    "Baby (0–2 yrs) No Bed - €500"
  ];

  final List<String> numberOfBaby = ["00", "01", "02"];




 
}
