import 'package:flutter/widgets.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/core/utils/payment_flow_log.dart';
import 'package:trael_app_abdelhamid/model/home/hotel_voucher_model.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/model/home/user_itinerary_model.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';

class TripProvider extends ChangeNotifier {
  /// Last trip the user chose on Home (lists / trip-details navigation).
  TripModel? selectedTrip;

  /// Trip resolved from `GET /api/user-payment/my-trip` (user’s enrolled booking).
  /// The Trips tab uses [tripForTripsTab], not [selectedTrip], so Home selection does not override enrollment.
  TripModel? _enrolledTrip;
  TripModel? get enrolledTrip => _enrolledTrip;

  /// What the Trips tab should display: enrolled trip when present, otherwise Home selection.
  TripModel? get tripForTripsTab => _enrolledTrip ?? selectedTrip;

  // -------------------------------
  // Hotel voucher (current enrolled trip hotel details)
  // -------------------------------
  List<HotelVoucherModel> _hotelVouchers = [];
  List<HotelVoucherModel> get hotelVouchers => _hotelVouchers;

  bool _isHotelVoucherLoading = false;
  bool get isHotelVoucherLoading => _isHotelVoucherLoading;

  String? _hotelVoucherError;
  String? get hotelVoucherError => _hotelVoucherError;
  bool _hasFetchedHotelVouchers = false;
  bool get hasFetchedHotelVouchers => _hasFetchedHotelVouchers;

  Future<void> fetchHotelVoucherDetails(
    String tripId, {
    bool force = false,
  }) async {
    if (_isHotelVoucherLoading) return;
    // If we already tried once (even if empty), don't keep calling.
    if (!force && _hasFetchedHotelVouchers) return;

    _isHotelVoucherLoading = true;
    _hotelVoucherError = null;
    notifyListeners();

    try {
      _hotelVouchers = await TripsService.instance.getHotelVoucherDetails(
        tripId,
        showErrorToast: false,
      );
      _hasFetchedHotelVouchers = true;
    } catch (e) {
      _hotelVoucherError = e.toString();
      _hotelVouchers = [];
      _hasFetchedHotelVouchers = true;
    } finally {
      _isHotelVoucherLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------
  // Itinerary (today / relevant day)
  // -------------------------------
  UserItineraryResponseModel? _todayItinerary;
  UserItineraryResponseModel? get todayItinerary => _todayItinerary;

  bool _isItineraryLoading = false;
  bool get isItineraryLoading => _isItineraryLoading;

  String? _itineraryError;
  String? get itineraryError => _itineraryError;
  bool _hasFetchedItinerary = false;
  bool get hasFetchedItinerary => _hasFetchedItinerary;

  Future<void> fetchTodayItinerary(String tripId, {bool force = false}) async {
    if (_isItineraryLoading) return;
    if (!force && _hasFetchedItinerary) return;

    _isItineraryLoading = true;
    _itineraryError = null;
    notifyListeners();

    try {
      _todayItinerary = await TripsService.instance.getTodayItinerary(
        tripId,
        showErrorToast: false,
      );
    } catch (e) {
      _itineraryError = e.toString();
      _todayItinerary = null;
    } finally {
      _hasFetchedItinerary = true;
      _isItineraryLoading = false;
      notifyListeners();
    }
  }

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
  List<TripModel> get upcomingTripList => _upcomingtripList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Ensures `selectedTrip` is set using the first upcoming trip.
  /// Does not override an existing selection (e.g. after [loadEnrolledTripForTripsTab]).
  Future<void> ensureSelectedTripFromUpcoming() async {
    if (selectedTrip != null) return;

    if (upcomingTripList.isEmpty && !_isLoading) {
      await fetchTrips();
    }

    if (selectedTrip != null) return;

    if (upcomingTripList.isNotEmpty) {
      selectTrip(upcomingTripList.first);
    }
  }

  /// Booking id from the user’s **most recent successful Stripe payment** (checkout or Trips tab).
  /// Used for `GET /user-payment/my-trip?bookingId=` when no explicit id is passed.
  String? _latestPaymentBookingId;

  /// Call after a payment succeeds so [loadEnrolledTripForTripsTab] without args uses this id.
  void rememberLatestPaymentBookingId(String? bookingId) {
    if (bookingId == null || bookingId.isEmpty) return;
    _latestPaymentBookingId = bookingId;
    PaymentFlowLog.log('TripProvider: latest payment booking id', {
      'bookingId': bookingId,
    });
  }

  /// Bumped after a successful payment so [TripPaymentSection] can re-fetch payment history
  /// even when [enrolledBookingId] is unchanged.
  int _paymentHistoryRefreshToken = 0;
  int get paymentHistoryRefreshToken => _paymentHistoryRefreshToken;

  void notifyPaymentHistoryRefresh() {
    _paymentHistoryRefreshToken++;
    notifyListeners();
  }

  /// Latest active/pending booking from `GET /api/user-payment/my-trip` + full trip details.
  /// Updates [_enrolledTrip] and payment fields only — does not change [selectedTrip] (Home).
  ///
  /// [bookingId] overrides; otherwise uses [rememberLatestPaymentBookingId], then last my-trip id.
  Future<void> loadEnrolledTripForTripsTab({String? bookingId}) async {
    _isEnrolledTripLoading = true;
    _isPaymentLoading = true;
    notifyListeners();
    try {
      final String? effectiveId;
      if (bookingId != null && bookingId.isNotEmpty) {
        effectiveId = bookingId;
      } else if (_latestPaymentBookingId != null &&
          _latestPaymentBookingId!.isNotEmpty) {
        effectiveId = _latestPaymentBookingId;
      } else {
        effectiveId = _enrolledBookingId;
      }
      PaymentFlowLog.log('loadEnrolledTripForTripsTab: my-trip query', {
        'effectiveBookingId': effectiveId ?? '(none)',
      });
      final ctx = await TripsService.instance.fetchEnrolledTripContext(
        bookingId: effectiveId,
      );
      if (ctx != null) {
        _enrolledTrip = ctx.trip;
        _paymentDetails = ctx.paymentDetails;
        _enrolledBookingId = ctx.bookingId;
        PaymentFlowLog.log('loadEnrolledTripForTripsTab: state updated', {
          'bookingId': _enrolledBookingId,
          'pendingAmount': _paymentDetails?.pendingAmount,
          'paidAmount': _paymentDetails?.paidAmount,
          'isFullyPaid': _paymentDetails?.isFullyPaid,
        });
      } else {
        _enrolledTrip = null;
        _paymentDetails = null;
        _enrolledBookingId = null;
        PaymentFlowLog.log(
          'loadEnrolledTripForTripsTab: no enrolled context (null)',
        );
      }
    } catch (_) {
      // Keep prior enrolled state on errors; BaseApiService may toast.
    } finally {
      _isEnrolledTripLoading = false;
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  bool _isEnrolledTripLoading = false;
  bool get isEnrolledTripLoading => _isEnrolledTripLoading;

  /// Booking id from [loadEnrolledTripForTripsTab], when applicable.
  String? _enrolledBookingId;
  String? get enrolledBookingId => _enrolledBookingId;

  /// Loads home lists from `GET /api/user/trips/list?type=upcoming` and `?type=past`.
  /// [showGlobalLoading] false for pull-to-refresh (keeps list visible; only the indicator shows).
  Future<void> fetchTrips({bool showGlobalLoading = true}) async {
    if (showGlobalLoading) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final results = await Future.wait([
        TripsService.instance.getUpcomingTrips(showErrorToast: true),
        TripsService.instance.getPastTrips(showErrorToast: true),
      ]);
      _upcomingtripList = results[0];
      _pasttripList = results[1];

      // Auto-pick the first upcoming trip once trips are loaded.
      // Do not override a user-selected trip.
      if (selectedTrip == null && _upcomingtripList.isNotEmpty) {
        selectTrip(_upcomingtripList.first);
      }
    } catch (e) {
      // Errors are handled by BaseApiService and logged
    } finally {
      if (showGlobalLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  PaymentMethodEnum selectedMethod = PaymentMethodEnum.creditCard;

  void changeSelectedMethod(PaymentMethodEnum method) {
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

  // void selectTrip(TripModel trip) {
  //   selectedTrip = trip;
  //   notifyListeners();
  // }

  TripPaymentDetails? _paymentDetails;
  TripPaymentDetails? get paymentDetails => _paymentDetails;

  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  Future<void> fetchPaymentDetails(String tripId) async {
    _isPaymentLoading = true;
    notifyListeners();
    try {
      // Optional: per-trip payment API when not using enrollment summary.
    } catch (e) {
      // handled by BaseApiService
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  void selectTrip(TripModel trip) {
    selectedTrip = trip;
    notifyListeners();
    if (trip.id != null) {
      fetchPaymentDetails(trip.id!);
    }
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
