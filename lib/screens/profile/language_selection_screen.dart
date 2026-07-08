import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/translations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguage = 'English';

  final Map<String, String> _languages = {
    'en': 'English',
    'tl': 'Filipino',
    'ceb': 'Cebuano',
  };

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveLanguage(String languageCode) async {
    await AppTranslations.setLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language'.tr()),
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final langCode = _languages.keys.elementAt(index);
          final langName = _languages[langCode]!;
          return RadioListTile<String>(
            title: Text(langName.tr()),
            value: langCode,
            // ignore: deprecated_member_use
            groupValue: _selectedLanguage,
            // ignore: deprecated_member_use
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
              _saveLanguage(value!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${'Language'.tr()} -> ${langName.tr()}')),
              );
            },
          );
        },
      ),
    );
  }
}
