import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/core/utils/date_format_helper.dart';
import 'package:travel_app_abdelhamid/model/home/family_details_model.dart';
import 'package:travel_app_abdelhamid/model/person_details_model.dart';
import 'package:travel_app_abdelhamid/model/profile/user_profile_model.dart';

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

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  final bool _isFamilyLoading = false;
  bool get isFamilyLoading => _isFamilyLoading;

  // Local storage for unsaved data
  Map<String, dynamic>? _localPersonDetailsData;
  Map<String, dynamic>? _localFamilyDetailsData;
  bool _hasUnsavedPersonData = false;
  bool _hasUnsavedFamilyData = false;

  Map<String, dynamic>? get localPersonDetailsData => _localPersonDetailsData;
  Map<String, dynamic>? get localFamilyDetailsData => _localFamilyDetailsData;
  bool get hasUnsavedPersonData => _hasUnsavedPersonData;
  bool get hasUnsavedFamilyData => _hasUnsavedFamilyData;

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
    // Store person details locally instead of calling API immediately
    try {
      _localPersonDetailsData = {
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
      _hasUnsavedPersonData = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Save Family Member Details ──────────────────────────────────────────────
  Future<bool> saveFamilyDetails(String bookingId) async {
    // Store family details locally instead of calling API immediately
    try {
      final familyData = FamilyMemberModel(
        firstName: familyFirstNameController.text.trim(),
        surname: familySurnameController.text.trim(),
        phoneNumber: familyPhoneNumberController.text.trim(),
        relationship: familyRelationshipController.text.trim(),
      );

      _localFamilyDetailsData = familyData.toJson();
      _hasUnsavedFamilyData = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearFamilyControllers() {
    familyFirstNameController.clear();
    familySurnameController.clear();
    familyPhoneNumberController.clear();
    familyRelationshipController.clear();
  }

  // ─── Clear Local Data ─────────────────────────────────────────────────────────
  void clearLocalData() {
    _localPersonDetailsData = null;
    _localFamilyDetailsData = null;
    _hasUnsavedPersonData = false;
    _hasUnsavedFamilyData = false;
    notifyListeners();
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
