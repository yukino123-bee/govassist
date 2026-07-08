import 'package:flutter/material.dart';

import '../../core/app_settings.dart';

import '../../core/translations.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings'.tr()),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Notifications'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AppSettings.pushNotifications,
            builder: (context, pushNotif, _) {
              return SwitchListTile(
                title: Text('Push Notifications'.tr()),
                subtitle: Text('Receive alerts on your device'.tr()),
                value: pushNotif,
                onChanged: (val) => AppSettings.setPushNotifications(val),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AppSettings.emailNotifications,
            builder: (context, emailNotif, _) {
              return SwitchListTile(
                title: Text('Email Notifications'.tr()),
                subtitle: Text('Receive updates via email'.tr()),
                value: emailNotif,
                onChanged: (val) => AppSettings.setEmailNotifications(val),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Preferences'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AppSettings.darkMode,
            builder: (context, isDark, _) {
              return SwitchListTile(
                title: Text('Dark Mode'.tr()),
                subtitle: Text('Switch to dark theme'.tr()),
                value: isDark,
                onChanged: (val) => AppSettings.setDarkMode(val),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Security'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: AppSettings.biometricLogin,
            builder: (context, useBiometric, _) {
              return SwitchListTile(
                title: Text('Biometric Login'.tr()),
                subtitle: Text('Use fingerprint or Face ID to login'.tr()),
                value: useBiometric,
                onChanged: (val) => AppSettings.setBiometricLogin(val),
              );
            },
          ),
        ],
      ),
    );
  }
}
