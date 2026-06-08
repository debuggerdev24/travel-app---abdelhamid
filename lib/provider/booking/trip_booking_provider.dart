import 'package:flutter/foundation.dart';
import 'package:travel_app_abdelhamid/core/utils/log_helper.dart';
import 'package:travel_app_abdelhamid/core/network/base_api_service.dart';
import 'package:travel_app_abdelhamid/core/network/endpoints.dart';
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

  bool _isRoomPreferenceSaved = false;
  bool get isRoomPreferenceSaved => _isRoomPreferenceSaved;

  String? _roomPreferenceId;
  String? get roomPreferenceId => _roomPreferenceId;

  Map<String, dynamic>? _savedRoomPreference;
  Map<String, dynamic>? get savedRoomPreference => _savedRoomPreference;

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
    _isRoomPreferenceSaved = false;
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
      // Check if room preference is already saved by checking upcoming bookings
      await _checkRoomPreferenceStatus(tripId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkRoomPreferenceStatus(String tripId) async {
    try {
      final bookings = await TripsService.instance.getUpcomingBookings(
        showErrorToast: false,
      );
      final tripBooking = bookings.firstWhere(
        (booking) => booking.trip.id == tripId,
        orElse: () => bookings.firstWhere(
          (booking) => booking.trip.id == tripId,
          orElse: () => throw Exception('Booking not found'),
        ),
      );
      _roomPreferenceId = tripBooking.roomPreferenceId;
      _isRoomPreferenceSaved =
          tripBooking.roomPreferenceId != null &&
          tripBooking.roomPreferenceId!.isNotEmpty;

      // If room preference is saved, try to fetch the saved data
      if (_isRoomPreferenceSaved) {
        await fetchSavedRoomPreference();
      }

      notifyListeners();
    } catch (e) {
      // If we can't check, assume not saved
      _isRoomPreferenceSaved = false;
      _roomPreferenceId = null;
    }
  }

  Future<void> fetchSavedRoomPreference() async {
    // If we already have saved data locally, use it
    if (_savedRoomPreference != null) {
      LogHelper.instance.info('Using locally stored room preference data');
      _populateFormFromSavedData(_savedRoomPreference!);
      return;
    }

    try {
      // First try the dedicated room preference API with roomPreferenceId
      if (_roomPreferenceId != null) {
        final savedData = await TripsService.instance.getRoomPreference(
          roomPreferenceId: _roomPreferenceId,
        );
        if (savedData != null) {
          _savedRoomPreference = savedData;
          LogHelper.instance.info('Found room preference via roomPreferenceId');
          _populateFormFromSavedData(savedData);
          return;
        }
      }

      // Fallback: try with bookingId
      if (_bookingId != null) {
        final savedData = await TripsService.instance.getRoomPreference(
          bookingId: _bookingId,
        );
        if (savedData != null) {
          _savedRoomPreference = savedData;
          LogHelper.instance.info('Found room preference via bookingId');
          _populateFormFromSavedData(savedData);
          return;
        }
      }

      // Fallback: try to get booking details which might include room preference
      if (_bookingId != null) {
        final response = await BaseApiService.instance.get(
          Endpoints.bookingGetPackageDetails,
          queryParameters: {'bookingId': _bookingId},
          showErrorToast: false,
        );

        if (response['status'] == 1 && response['data'] != null) {
          final data = Map<String, dynamic>.from(response['data'] as Map);
          _savedRoomPreference = data;
          LogHelper.instance.info('Booking details response: ${data.keys}');

          // Check if room preference data exists in the response
          // Try different possible field names
          final roomPreference =
              data['roomPreference'] ??
              data['roomPreferences'] ??
              data['room_details'] ??
              data['roomDetails'];

          if (roomPreference != null && roomPreference is Map) {
            LogHelper.instance.info(
              'Found room preference data: $roomPreference',
            );
            _populateFormFromSavedData(
              Map<String, dynamic>.from(roomPreference),
            );
          } else {
            // Try to populate directly from the booking data if fields exist
            _populateFormFromSavedData(data);
          }
        }
      }
    } catch (e) {
      LogHelper.instance.error('Error fetching saved room preference: $e');
      _savedRoomPreference = null;
      // Fallback to using package options data as defaults
      _populateFormFromPackageOptions();
    }
  }

  void _populateFormFromPackageOptions() {
    if (_selectedPackage == null) return;

    LogHelper.instance.info('Populating form from package options data');

    // Set default room type (first available room)
    if (_selectedPackage!.roomDetails.isNotEmpty) {
      selectedRoomTypeId = _selectedPackage!.roomDetails.first.id;
      LogHelper.instance.info('Default room type: $selectedRoomTypeId');
    }

    // Set default child details (first available child option)
    if (_selectedPackage!.childDetails.isNotEmpty) {
      selectedChildDetailsId = _selectedPackage!.childDetails.first.id;
      LogHelper.instance.info('Default child details: $selectedChildDetailsId');
    }

    // Set default bed type if available
    if (selectedBedType == null) {
      selectedBedType = 'With Bed';
      LogHelper.instance.info('Default bed type: $selectedBedType');
    }

    notifyListeners();
  }

  void _populateFormFromSavedData(Map<String, dynamic> data) {
    LogHelper.instance.info('Populating form from data: $data');

    // Handle different field name formats
    adultCount =
        data['adultCount'] ?? data['adult_count'] ?? data['adult'] ?? 1;
    selectedChildCount = data['childCount'] ?? data['child_count'] ?? 0;
    babyCount = data['babyCount'] ?? data['baby_count'] ?? 0;

    // Handle roomTypeId - might be in roomPreference or need to extract from package
    selectedRoomTypeId =
        data['roomTypeId']?.toString() ??
        data['room_type_id']?.toString() ??
        data['roomTypeId']?.toString();

    // Handle bedType
    selectedBedType =
        data['bedType']?.toString() ?? data['bed_type']?.toString();

    // Handle childDetailsId
    selectedChildDetailsId =
        data['childDetailsId']?.toString() ??
        data['child_details_id']?.toString();

    // If roomPreference is nested in the data, extract from it
    if (data['roomPreference'] != null && data['roomPreference'] is Map) {
      final roomPref = Map<String, dynamic>.from(data['roomPreference'] as Map);
      adultCount = roomPref['adult'] ?? adultCount;
      selectedChildCount = roomPref['childCount'] ?? selectedChildCount;
    }

    // If package is available, try to extract roomTypeId from roomOptions
    if (data['package'] != null && data['package'] is Map) {
      final package = Map<String, dynamic>.from(data['package'] as Map);
      if (package['roomOptions'] != null && package['roomOptions'] is List) {
        final roomOptions = package['roomOptions'] as List;
        if (roomOptions.isNotEmpty && selectedRoomTypeId == null) {
          final firstRoom = roomOptions.first;
          if (firstRoom is Map) {
            selectedRoomTypeId = firstRoom['_id']?.toString();
            LogHelper.instance.info(
              'Extracted roomTypeId from package: $selectedRoomTypeId',
            );
          }
        }
      }

      // Try to extract childDetailsId from childOptions
      if (package['childOptions'] != null && package['childOptions'] is List) {
        final childOptions = package['childOptions'] as List;
        if (childOptions.isNotEmpty && selectedChildDetailsId == null) {
          final firstChild = childOptions.first;
          if (firstChild is Map) {
            selectedChildDetailsId = firstChild['_id']?.toString();
            LogHelper.instance.info(
              'Extracted childDetailsId from package: $selectedChildDetailsId',
            );
          }
        }
      }
    }

    LogHelper.instance.info(
      'Populated fields - roomTypeId: $selectedRoomTypeId, bedType: $selectedBedType, adultCount: $adultCount, childCount: $selectedChildCount, babyCount: $babyCount',
    );
    notifyListeners();
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
      if (response['status'] == 1) {
        _isRoomPreferenceSaved = true;
        // Store the saved data locally
        _savedRoomPreference = data;
      }
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
