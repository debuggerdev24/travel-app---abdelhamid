import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
 
  List<String> languageOptions = [
    "English",
    "Arabic",
    "Hindi",
    "Gujarati",
    "Spanish",
    "French",
    "Urdu",
  ];

  List<String> selectedLanguages = [];

  void updateSelectedLanguages(List<String> values) {
    selectedLanguages = values;
    notifyListeners();
  }
}
