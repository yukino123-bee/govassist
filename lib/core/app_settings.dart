import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static final ValueNotifier<bool> pushNotifications = ValueNotifier(true);
  static final ValueNotifier<bool> emailNotifications = ValueNotifier(false);
  static final ValueNotifier<bool> darkMode = ValueNotifier(false);
  static final ValueNotifier<bool> biometricLogin = ValueNotifier(true);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    pushNotifications.value = prefs.getBool('push_notifications') ?? true;
    emailNotifications.value = prefs.getBool('email_notifications') ?? false;
    darkMode.value = prefs.getBool('dark_mode') ?? false;
    biometricLogin.value = prefs.getBool('biometric_login') ?? true;
  }

  static Future<void> setPushNotifications(bool value) async {
    pushNotifications.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', value);
  }

  static Future<void> setEmailNotifications(bool value) async {
    emailNotifications.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications', value);
  }

  static Future<void> setDarkMode(bool value) async {
    darkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  static Future<void> setBiometricLogin(bool value) async {
    biometricLogin.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_login', value);
  }
}
