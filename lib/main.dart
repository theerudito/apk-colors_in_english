import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'config/languageManager.dart';
import 'config/premiumManager.dart';
import 'services/in_purchase_service.dart';
import 'theme/app_style.dart';
import 'widgets/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppStyle.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await ConfigApp.loadPremiumStatus();
  await AppLanguageController.loadLanguage();

  try {
    await PremiumPurchaseService.instance.initialize();
  } catch (e) {
    debugPrint('Error al inicializar In-App Purchase: $e');
  }

  if (!kIsWeb &&
      (Platform.isAndroid || Platform.isIOS) &&
      !ConfigApp.isPremium) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('Error al inicializar Google Mobile Ads: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colors In English',
      theme: ThemeData(
        scaffoldBackgroundColor: AppStyle.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D5AFE),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
