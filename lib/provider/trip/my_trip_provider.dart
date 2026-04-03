import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/model/essential/packing_list_model.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/model/trip/trip_documents_bundle_model.dart';
import 'package:trael_app_abdelhamid/services/essential_service.dart';
import 'package:trael_app_abdelhamid/services/trips_service.dart';

/// ===============================
///  USER DOCUMENT MODEL
/// ===============================
class UserDocument {
  final String type;
  final String name;
  final File image;

  File? filePath;

  UserDocument({required this.type, required this.name, required this.image});
}

class MyTripProvider extends ChangeNotifier {
  bool hidePaymentMethods = false;
  int bottomTabIndex = 0;

  // TripPaymentDetails? _paymentDetails;
  // TripPaymentDetails? get paymentDetails => _paymentDetails;

  // bool _isPaymentLoading = false;
  // bool get isPaymentLoading => _isPaymentLoading;

  /// Selected Document Type
  List<String> selectedDocumentType = [];

  /// Uploaded User Documents

  /// Set selected document type
  ///
  ///
  // Future<void> fetchPaymentDetails(String tripId) async {
  //   _isPaymentLoading = true;
  //   _paymentDetails = null;
  //   notifyListeners();
  //   try {
  //     _paymentDetails = await TripsService.instance.getPaymentDetails(tripId);
  //   } catch (e) {
  //     // handled by BaseApiService
  //   } finally {
  //     _isPaymentLoading = false;
  //     notifyListeners();
  //   }
  // }

  void selectDocumentType(List<String> selected) {
    selectedDocumentType = selected;
    notifyListeners();
  }

  /// Legacy local-only rows (not persisted). New uploads use the API + [tripDocumentsBundle].
  List<Map<String, dynamic>> uploadedDocs = [];

  TripDocumentsBundle? _tripDocumentsBundle;
  TripDocumentsBundle? get tripDocumentsBundle => _tripDocumentsBundle;

  bool _isTripDocumentsLoading = false;
  bool get isTripDocumentsLoading => _isTripDocumentsLoading;

  String? _tripDocumentsError;
  String? get tripDocumentsError => _tripDocumentsError;

  bool _hasFetchedTripDocuments = false;
  String? _tripDocumentsTripId;

  /// Loads `GET /trip-documents` bundle (member docs + trip hotel / insurance / checklist).
  Future<void> fetchTripDocuments(String tripId, {bool force = false}) async {
    if (_isTripDocumentsLoading) return;
    if (!force &&
        _hasFetchedTripDocuments &&
        _tripDocumentsTripId == tripId) {
      return;
    }

    _isTripDocumentsLoading = true;
    _tripDocumentsError = null;
    notifyListeners();

    try {
      _tripDocumentsBundle = await TripsService.instance.getTripDocuments(
        tripId,
        showErrorToast: false,
      );
      _hasFetchedTripDocuments = true;
      _tripDocumentsTripId = tripId;
    } catch (e) {
      _tripDocumentsBundle = null;
      _tripDocumentsError = userFacingApiError(e);
      _hasFetchedTripDocuments = true;
      _tripDocumentsTripId = null;
    } finally {
      _isTripDocumentsLoading = false;
      notifyListeners();
    }
  }

  /// Called when the user opens the **Documents** tab (refresh vouchers + documents list).
  Future<void> refreshDocumentsTab(String tripId) async {
    await fetchTripDocuments(tripId, force: true);
  }

  /// Clears the documents bundle so the previous trip is not shown while reloading.
  void clearTripDocumentsCache() {
    _tripDocumentsBundle = null;
    _tripDocumentsError = null;
    _hasFetchedTripDocuments = false;
    _tripDocumentsTripId = null;
    notifyListeners();
  }

  /// Add User Document
  Map<String, List<Map<String, dynamic>>> groupDocs(List docs) {
    final Map<String, List<Map<String, dynamic>>> map = {};

    for (var doc in docs) {
      final type = doc["name"]; // Passport / Visa / Medical / etc.
      if (!map.containsKey(type)) {
        map[type] = [];
      }
      map[type]!.add(doc);
    }
    return map;
  }

  bool _isUploadingDocument = false;
  bool get isUploadingDocument => _isUploadingDocument;

  /// Maps UI labels to backend `documentType` values.
  static String? documentTypeUiToApi(String ui) {
    switch (ui) {
      case 'Passport':
        return 'passport';
      case 'Visa':
        return 'visa';
      case 'Medical Certificate':
        return 'medical certificate';
      default:
        return null;
    }
  }

  /// Uploads via `POST /documents/add-document`. On success refreshes [tripDocumentsBundle].
  /// Returns `null` on success, or an error message.
  Future<String?> uploadUserDocument({
    required String tripId,
    required String uiDocumentType,
    required File file,
    required String documentName,
    String? memberId,
  }) async {
    final apiType = documentTypeUiToApi(uiDocumentType);
    if (apiType == null) {
      return 'This document type cannot be uploaded from the app.';
    }
    final name = documentName.trim();
    if (name.isEmpty) {
      return 'Please enter a document name.';
    }

    _isUploadingDocument = true;
    notifyListeners();
    try {
      await TripsService.instance.addUserDocument(
        tripId: tripId,
        documentType: apiType,
        documentName: name,
        photoFile: file,
        memberId: memberId,
        showErrorToast: false,
      );
      await fetchTripDocuments(tripId, force: true);
      selectDocumentType([]);
      return null;
    } catch (e) {
      return userFacingApiError(e);
    } finally {
      _isUploadingDocument = false;
      notifyListeners();
    }
  }

  /// ===============================
  /// PAYMENT SECTION
  /// ===============================
  PaymentMethodEnum selectedMethod = PaymentMethodEnum.googlePay;

  void changeSelectedMethod(PaymentMethodEnum method) {
    selectedMethod = method;
    notifyListeners();
  }

  bool isSelected(PaymentMethodEnum method) {
    return selectedMethod == method;
  }

  /// ===============================
  /// BOTTOM NAV
  /// ===============================
  void changeBottomTabIndex(int index) {
    bottomTabIndex = index;
    notifyListeners();
  }

  /// ===============================
  /// PAYMENTS LIST
  /// ===============================
  List<PaymentModel> payments = [
    PaymentModel(id: "#TRX001", amount: "250,000", date: "02 Jan 2024"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "22 Dec 2024"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "31 May 2023"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "02 Jan 2024"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "22 Dec 2024"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "31 May 2023"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "02 Jan 2024"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "22 Dec 2024"),
    PaymentModel(id: "#TRX001", amount: "250,000", date: "31 May 2023"),
  ];

  void addPayment(PaymentModel payment) {
    payments.add(payment);
    notifyListeners();
  }

  /// ===============================
  /// PACKING LIST
  /// ===============================
  List<PackingCategory> _packingCategories = [];
  List<PackingCategory> get packingCategories => _packingCategories;

  bool _isPackingLoading = false;
  bool get isPackingLoading => _isPackingLoading;

  String? _packingError;
  String? get packingError => _packingError;

  bool _hasFetchedPackingList = false;
  bool get hasFetchedPackingList => _hasFetchedPackingList;

  /// Refetch essentials-backed data whenever the user opens the **Essentials** tab
  /// on the trip screen (so list + packing list stay up to date).
  Future<void> refreshEssentialsTab() async {
    await fetchPackingList(force: true);
  }

  Future<void> fetchPackingList({bool force = false}) async {
    if (_isPackingLoading) return;
    if (!force && _hasFetchedPackingList) return;

    _isPackingLoading = true;
    _packingError = null;
    notifyListeners();

    try {
      final res = await EssentialService.instance.getPackingList(
        showErrorToast: false,
      );
      _packingCategories = res.categories;

      // Ensure checkbox state exists for each category (local only).
      for (final cat in _packingCategories) {
        final key = cat.title;
        categoryChecked[key] = categoryChecked[key] ?? false;
      }

      _hasFetchedPackingList = true;
    } catch (e) {
      _packingError = e.toString();
      _packingCategories = [];
      _hasFetchedPackingList = true;
    } finally {
      _isPackingLoading = false;
      notifyListeners();
    }
  }

  /// Document types accepted by backend `add-document` (passport / visa / medical certificate).
  final List<String> documentTypes = [
    "Passport",
    "Visa",
    "Medical Certificate",
  ];

  /// Category checkbox toggle
  Map<String, bool> categoryChecked = {};

  MyTripProvider() {
    // checkbox state is local; initialize lazily when packing list is fetched
  }

  void toggleCategory(String key) {
    categoryChecked[key] = !(categoryChecked[key] ?? false);
    notifyListeners();
  }

  void setHidePaymentMethods(bool value) {
    hidePaymentMethods = value;
    notifyListeners();
  }
}
