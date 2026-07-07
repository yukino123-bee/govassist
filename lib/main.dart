import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth/login_screen.dart';

import 'core/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTranslations.init();
  runApp(const GovAssistApp());
}

class GovAssistApp extends StatelessWidget {
  const GovAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTranslations.currentLanguage,
      builder: (context, lang, child) {
        return MaterialApp(
          title: 'GovAssist',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        );
      }
    );
  }
}
