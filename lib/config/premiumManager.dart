import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigApp {
  static const String _premiumKey = 'is_premium';
  static final ValueNotifier<bool> isPremiumNotifier = ValueNotifier<bool>(
    false,
  );

  static bool get isPremium => isPremiumNotifier.value;

  static Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isPremiumNotifier.value = prefs.getBool(_premiumKey) ?? false;
  }

  static Future<void> setPremium(bool value) async {
    isPremiumNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
  }
}
