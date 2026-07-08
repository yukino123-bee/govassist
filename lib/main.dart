import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth/login_screen.dart';

import 'core/translations.dart';

import 'core/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();
  await AppTranslations.init();
  runApp(const GovAssistApp());
}

class GovAssistApp extends StatelessWidget {
  const GovAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.darkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppTranslations.currentLanguage,
          builder: (context, lang, child) {
            return MaterialApp(
              key: ValueKey(lang),
              title: 'GovAssist',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              home: const LoginScreen(),
            );
          }
        );
      },
    );
  }
}
