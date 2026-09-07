import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { es, en }

class AppLanguageController {
  static const String _key = 'app_language';

  static AppLanguage currentLanguage = AppLanguage.en;

  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);

    currentLanguage = switch (saved) {
      'es' => AppLanguage.es,
      'en' || null => AppLanguage.en,
      _ => AppLanguage.en,
    };
  }

  static Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.name);
    currentLanguage = language;
  }

  static String get currentLanguageCode => currentLanguage.name;

  static AppLanguage getLanguageFromCode(String? code) {
    switch (code) {
      case 'es':
        return AppLanguage.es;
      case 'en':
      default:
        return AppLanguage.en;
    }
  }
}
