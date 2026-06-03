import 'package:flutter/foundation.dart';
import 'package:travel_app_abdelhamid/core/utils/log_helper.dart';
import '../../model/home/trip_model.dart';
import '../../services/trips_service.dart';

class TripBookingProvider extends ChangeNotifier {
  TripModel? _tripDetails;
  TripModel? get tripDetails => _tripDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  PackageDetails? _selectedPackage;
  PackageDetails? get selectedPackage => _selectedPackage;

  String? _bookingId;
  String? get bookingId => _bookingId;

  bool _isBooked = false;
  bool get isBooked => _isBooked;

  void updateAdultCount(int count) {
    if (adultCount != count) {
      adultCount = count;
      notifyListeners();
    }
  }

  void updateSelectedRoomTypeId(String? id) {
    if (selectedRoomTypeId != id) {
      selectedRoomTypeId = id;
      notifyListeners();
    }
  }

  void updateSelectedBedType(String? type) {
    if (selectedBedType != type) {
      selectedBedType = type;
      notifyListeners();
    }
  }

  void updateSelectedChildDetailsId(String? id) {
    if (selectedChildDetailsId != id) {
      selectedChildDetailsId = id;
      notifyListeners();
    }
  }

  void updateSelectedChildCount(int count) {
    if (selectedChildCount != count) {
      selectedChildCount = count;
      notifyListeners();
    }
  }

  // Selected Preference IDs
  String? selectedRoomTypeId;
  String? selectedBedType;
  int adultCount = 1;
  String? selectedChildDetailsId;
  int selectedChildCount = 0;
  int babyCount = 0;

  void updateBabyCount(int count) {
    if (babyCount != count) {
      babyCount = count;
      notifyListeners();
    }
  }

  Future<void> loadTripDetails(String tripId) async {
    _isLoading = true;
    _error = null;
    _isBooked = false;
    notifyListeners();

    try {
      final result = await TripsService.instance.getTripDetails(
        tripId,
        showErrorToast: true,
      );
      _tripDetails = result.trip;
      _isBooked = result.isBooked;
      _bookingId = result.bookingId;
      if (_isBooked && (_bookingId == null || _bookingId!.isEmpty)) {
        await _resolveExistingBookingId();
      }
      if (_tripDetails?.packages?.isNotEmpty ?? false) {
        _selectedPackage = _tripDetails!.packages!.first;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _resolveExistingBookingId() async {
    final tripId = _tripDetails?.id;
    if (tripId == null || tripId.isEmpty) return;

    try {
      final ctx = await TripsService.instance.fetchEnrolledTripContext();
      if (ctx != null && ctx.trip.id == tripId) {
        _bookingId = ctx.bookingId;
      }
    } catch (_) {
      // Room step may still load options by tripId.
    }
  }

  /// When [isBooked] is true, skips `add-package` and only ensures a package is selected.
  Future<bool> proceedToRoomSelection() async {
    if (_tripDetails?.id == null || _selectedPackage?.id == null) {
      _error = 'Trip or Package not selected';
      notifyListeners();
      return false;
    }

    if (_isBooked) {
      if (_bookingId == null || _bookingId!.isEmpty) {
        _isLoading = true;
        notifyListeners();
        try {
          await _resolveExistingBookingId();
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      }
      return true;
    }

    return bookPackage();
  }

  void selectPackage(PackageDetails package) {
    _selectedPackage = package;
    selectedRoomTypeId = null;
    selectedBedType = null;
    adultCount = 1;
    selectedChildDetailsId = null;
    selectedChildCount = 0;
    babyCount = 0;
    notifyListeners();
  }

  double get totalAmount {
    if (_selectedPackage == null) return 0;

    double total = 0;

    // Find selected room and child details to get prices
    final room = _selectedPackage?.roomDetails.firstWhere(
      (r) => r.id == selectedRoomTypeId,
      orElse: () =>
          RoomDetailModel(roomType: '', roomPrice: 0, status: 'inactive'),
    );
    final child = _selectedPackage?.childDetails.firstWhere(
      (c) => c.id == selectedChildDetailsId,
      orElse: () => ChildDetailModel(
        childName: '',
        childPrice: 0,
        ageRange: '',
        bedAllocated: '',
      ),
    );

    total += (room?.roomPrice ?? 0) * adultCount;
    total += (child?.childPrice ?? 0) * selectedChildCount;
    total += 500 * babyCount; // Fixed baby price €500

    return total;
  }

  Future<void> fetchPackageOptions(String tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TripsService.instance.getPackageOptions(tripId);
      if (response['status'] == 1 && response['data'] != null) {
        final data = response['data'];

        // Parse new details
        final List<RoomDetailModel> rooms = (data['roomDetails'] as List)
            .map((r) => RoomDetailModel.fromJson(r))
            .toList();
        final List<ChildDetailModel> children = (data['childDetails'] as List)
            .map((c) => ChildDetailModel.fromJson(c))
            .toList();

        // Update selected package with live details
        if (_selectedPackage != null) {
          _selectedPackage = PackageDetails(
            id: _selectedPackage!.id,
            title: _selectedPackage!.title,
            inclusions: _selectedPackage!.inclusions,
            exclusions: _selectedPackage!.exclusions,
            roomDetails: rooms,
            childDetails: children,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookPackage() async {
    if (_tripDetails?.id == null || _selectedPackage?.id == null) {
      _error = "Trip or Package not selected";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await TripsService.instance.addBookingPackage(
        _tripDetails!.id!,
        _selectedPackage!.id!,
      );

      if (response['status'] == 1 && response['data'] != null) {
        _bookingId = response['data']['_id'];
        LogHelper.instance.info("Booking ID: $_bookingId");
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveRoomPreference() async {
    if (_bookingId == null) {
      _error = "No active booking found";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final room = _selectedPackage?.roomDetails.firstWhere(
        (r) => r.id == selectedRoomTypeId,
        orElse: () =>
            RoomDetailModel(roomType: '', roomPrice: 0, status: 'inactive'),
      );
      final child = _selectedPackage?.childDetails.firstWhere(
        (c) => c.id == selectedChildDetailsId,
        orElse: () => ChildDetailModel(
          childName: '',
          childPrice: 0,
          ageRange: '',
          bedAllocated: '',
        ),
      );

      final data = {
        "bookingId": _bookingId,
        "roomTypeId": selectedRoomTypeId,
        "roomPrice": "€${room?.roomPrice ?? 0}",
        "bedType": selectedBedType?.toLowerCase(),
        "adultCount": adultCount,
        "childDetailsId": selectedChildDetailsId,
        "childCount": selectedChildCount,
        "childPrice": "€${child?.childPrice ?? 0}",
        "babyCount": babyCount,
        "babyPrice": "€${500 * babyCount}",
      };

      final response = await TripsService.instance.saveRoomPreference(data);
      return response['status'] == 1;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
