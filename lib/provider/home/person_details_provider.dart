import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/utils/date_format_helper.dart';
import 'package:travel_app_abdelhamid/model/home/family_details_model.dart';
import 'package:travel_app_abdelhamid/model/person_details_model.dart';
import 'package:travel_app_abdelhamid/model/profile/user_profile_model.dart';
import 'package:travel_app_abdelhamid/services/trips_service.dart';

class PersonDetailsProvider extends ChangeNotifier {
  // ─── Personal Details Controllers ───────────────────────────────────────────
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController placeOfResidenceController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  // ─── Family Member Controllers ───────────────────────────────────────────────
  final TextEditingController familyFirstNameController =
      TextEditingController();
  final TextEditingController familySurnameController = TextEditingController();
  final TextEditingController familyPhoneNumberController =
      TextEditingController();
  final TextEditingController familyRelationshipController =
      TextEditingController();

  // ─── State ───────────────────────────────────────────────────────────────────
  PersonDetailsModel? _personDetails;
  PersonDetailsModel? get personDetails => _personDetails;

  FamilyMemberModel? _familyMember;
  FamilyMemberModel? get familyMember => _familyMember;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFamilyLoading = false;
  bool get isFamilyLoading => _isFamilyLoading;

  /// Prefill main booker fields from user profile (Get User Details API).
  /// Only fills fields that are currently empty, so it won't overwrite typing.
  void prefillFromUserProfile(UserProfile p) {
    if (firstNameController.text.trim().isEmpty &&
        p.firstName.trim().isNotEmpty) {
      firstNameController.text = p.firstName.trim();
    }
    if (surnameController.text.trim().isEmpty && p.surName.trim().isNotEmpty) {
      surnameController.text = p.surName.trim();
    }
    if (dateOfBirthController.text.trim().isEmpty &&
        p.dateOfBirth.trim().isNotEmpty) {
      dateOfBirthController.text = formatDateToYyyyMmDd(p.dateOfBirth);
    }
    if (nationalityController.text.trim().isEmpty &&
        p.nationality.trim().isNotEmpty) {
      nationalityController.text = p.nationality.trim();
    }
    if (phoneNumberController.text.trim().isEmpty &&
        p.phoneNumber.trim().isNotEmpty) {
      phoneNumberController.text = p.phoneNumber.trim();
    }
    if (emailController.text.trim().isEmpty && p.email.trim().isNotEmpty) {
      emailController.text = p.email.trim();
    }
    if (placeOfBirthController.text.trim().isEmpty &&
        p.placeOfBirth.trim().isNotEmpty) {
      placeOfBirthController.text = p.placeOfBirth.trim();
    }
    if (addressController.text.trim().isEmpty && p.address.trim().isNotEmpty) {
      addressController.text = p.address.trim();
    }
    if (houseNumberController.text.trim().isEmpty &&
        p.houseNumber.trim().isNotEmpty) {
      houseNumberController.text = p.houseNumber.trim();
    }
    if (postalCodeController.text.trim().isEmpty &&
        p.postalCode.trim().isNotEmpty) {
      postalCodeController.text = p.postalCode.trim();
    }
    if (placeOfResidenceController.text.trim().isEmpty &&
        p.placeOfResidence.trim().isNotEmpty) {
      placeOfResidenceController.text = p.placeOfResidence.trim();
    }
    notifyListeners();
  }

  // ─── Save Personal Details ───────────────────────────────────────────────────
  Future<bool> savePersonDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        "firstName": firstNameController.text.trim(),
        "surname": surnameController.text.trim(),
        "dateOfBirth": dateOfBirthController.text.trim(),
        "placeOfBirth": placeOfBirthController.text.trim(),
        "nationality": nationalityController.text.trim(),
        "email": emailController.text.trim(),
        "address": addressController.text.trim(),
        "houseNumber": houseNumberController.text.trim(),
        "postalCode": postalCodeController.text.trim(),
        "placeOfResidence": placeOfResidenceController.text.trim(),
        "phoneNumber": phoneNumberController.text.trim(),
      };

      final response = await TripsService.instance.savePersonDetail(body);

      if (response['status'] == 1 && response['data'] != null) {
        _personDetails = PersonDetailsModel.fromJson(response['data']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Save Family Member Details ──────────────────────────────────────────────
  Future<bool> saveFamilyDetails(String bookingId) async {
    _isFamilyLoading = true;
    notifyListeners();

    try {
      final familyData = FamilyMemberModel(
        firstName: familyFirstNameController.text.trim(),
        surname: familySurnameController.text.trim(),
        phoneNumber: familyPhoneNumberController.text.trim(),
        relationship: familyRelationshipController.text.trim(),
      );

      final response = await TripsService.instance.saveFamilyDetails(
        bookingId: bookingId,
        body: familyData.toJson(),
      );

      if (response['status'] == 1) {
        _familyMember = familyData;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isFamilyLoading = false;
      notifyListeners();
    }
  }

  // ─── Fetch and Populate Family Member Details ────────────────────────────────
  Future<void> fetchAndPopulateFamilyDetails(String bookingId) async {
    try {
      debugPrint(
        '🔵 [PersonDetailsProvider] Fetching family member details for bookingId: $bookingId',
      );

      // Try to fetch from upcoming bookings first (like room screen does)
      final familyMemberData = await TripsService.instance
          .getFamilyMemberDetails(bookingId);

      if (familyMemberData != null) {
        debugPrint(
          '🔵 [PersonDetailsProvider] Found family member data: $familyMemberData',
        );

        // Populate controllers only if they are empty
        if (familyFirstNameController.text.trim().isEmpty &&
            familyMemberData['firstName'] != null) {
          familyFirstNameController.text = familyMemberData['firstName']
              .toString()
              .trim();
          debugPrint(
            '✅ [PersonDetailsProvider] Populated firstName: ${familyFirstNameController.text}',
          );
        }
        if (familySurnameController.text.trim().isEmpty &&
            familyMemberData['surname'] != null) {
          familySurnameController.text = familyMemberData['surname']
              .toString()
              .trim();
          debugPrint(
            '✅ [PersonDetailsProvider] Populated surname: ${familySurnameController.text}',
          );
        }
        if (familyPhoneNumberController.text.trim().isEmpty &&
            familyMemberData['phoneNumber'] != null) {
          familyPhoneNumberController.text = familyMemberData['phoneNumber']
              .toString()
              .trim();
          debugPrint(
            '✅ [PersonDetailsProvider] Populated phoneNumber: ${familyPhoneNumberController.text}',
          );
        }
        if (familyRelationshipController.text.trim().isEmpty &&
            familyMemberData['relationship'] != null) {
          familyRelationshipController.text = familyMemberData['relationship']
              .toString()
              .trim();
          debugPrint(
            '✅ [PersonDetailsProvider] Populated relationship: ${familyRelationshipController.text}',
          );
        }

        // Store the fetched family member
        _familyMember = FamilyMemberModel.fromJson(familyMemberData);
        notifyListeners();
      } else {
        debugPrint('❌ [PersonDetailsProvider] No family member data found');
      }
    } catch (e) {
      debugPrint('❌ [PersonDetailsProvider] Error fetching family details: $e');
    }
  }

  // ─── Check if Family Member Data Has Changed ────────────────────────────────
  bool hasFamilyDataChanged() {
    if (_familyMember == null) {
      // No existing data, so this is new data
      debugPrint(
        '🔵 [PersonDetailsProvider] No existing family data - treating as new',
      );
      return true;
    }

    final currentFirstName = familyFirstNameController.text.trim();
    final currentSurname = familySurnameController.text.trim();
    final currentPhoneNumber = familyPhoneNumberController.text.trim();
    final currentRelationship = familyRelationshipController.text.trim();

    final hasChanged =
        currentFirstName != _familyMember!.firstName ||
        currentSurname != _familyMember!.surname ||
        currentPhoneNumber != _familyMember!.phoneNumber ||
        currentRelationship != _familyMember!.relationship;

    debugPrint('🔵 [PersonDetailsProvider] Data changed: $hasChanged');
    debugPrint(
      '🔵 [PersonDetailsProvider] Current: $currentFirstName, $currentSurname, $currentPhoneNumber, $currentRelationship',
    );
    debugPrint(
      '🔵 [PersonDetailsProvider] Existing: ${_familyMember!.firstName}, ${_familyMember!.surname}, ${_familyMember!.phoneNumber}, ${_familyMember!.relationship}',
    );

    return hasChanged;
  }

  // ─── Dispose ─────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    firstNameController.dispose();
    surnameController.dispose();
    dateOfBirthController.dispose();
    placeOfBirthController.dispose();
    nationalityController.dispose();
    emailController.dispose();
    addressController.dispose();
    houseNumberController.dispose();
    postalCodeController.dispose();
    placeOfResidenceController.dispose();
    phoneNumberController.dispose();

    familyFirstNameController.dispose();
    familySurnameController.dispose();
    familyPhoneNumberController.dispose();
    familyRelationshipController.dispose();

    super.dispose();
  }
}
