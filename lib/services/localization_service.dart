import 'package:flutter/material.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  LocalizationService._internal();

  String _currentLanguage = 'en'; // 'en' or 'local'

  String get currentLanguage => _currentLanguage;

  void setLanguage(String lang) {
    if (lang == 'en' || lang == 'local') {
      _currentLanguage = lang;
      notifyListeners();
    }
  }

  bool get isEnglish => _currentLanguage == 'en';

  // Helper method to choose string based on current language
  String translate(String englishText, String localText) {
    return isEnglish ? englishText : localText;
  }
}
