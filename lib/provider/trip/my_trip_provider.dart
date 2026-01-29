import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';

/// ===============================
///  USER DOCUMENT MODEL
/// ===============================
class UserDocument {
  final String type;
  final String name;
  final File image;

  var filePath;

  UserDocument({
    required this.type,
    required this.name,
    required this.image,
  });
}

class MyTripProvider extends ChangeNotifier {
  bool hidePaymentMethods = false;
  int bottomTabIndex = 0;

  /// Selected Document Type
  List<String> seelcteddocumetype = [];

  /// Uploaded User Documents

  /// Set selected document type
  void selcteddocumetype(List<String> selected) {
    seelcteddocumetype = selected;
    notifyListeners();
  }
List<Map<String, dynamic>> uploadedDocs = [];


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

void addDocument(String type, File file, String name) {
  uploadedDocs.add({
    "type": type,  
    "name": name,   // User entered document name
    "file": file,
    "time": DateTime.now(),
  });
  notifyListeners();
}


  

  /// ===============================
  /// PAYMENT SECTION
  /// ===============================
  PaymentMethosEnum selectedMethod = PaymentMethosEnum.googlePay;

  void changeSelectedMethod(PaymentMethosEnum method) {
    selectedMethod = method;
    notifyListeners();
  }

  bool isSelected(PaymentMethosEnum method) {
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
  Map<String, List<String>> packingData = {
    "Clothing": [
      "Ihram set (2 pcs)",
      "Comfortable walking shoes",
      "Light cotton clothes",
      "Umbrella / Cap",
    ],
    "Toiletries": [
      "Unscented soap",
      "Toothbrush & paste",
      "Towel",
      "Sanitizer",
    ],
    "Gadgets": [
      "Power bank",
      "Universal travel adapter",
      "Mobile with charger",
    ],
    "Documents": [
      "Passport copy",
      "Visa copy",
      "Travel insurance",
    ],
  };

  /// Document Types
  final List<String> documenttypes = [
    "Passport",
    "Visa",
    "Flight Ticket",
    "Medical Certificate",
  ];

  /// Category checkbox toggle
  Map<String, bool> categoryChecked = {};

  MyTripProvider() {
    for (var key in packingData.keys) {
      categoryChecked[key] = false;
    }
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

