import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/languageManager.dart';
import '../db/database_helper.dart';
import '../screens/game_screen.dart';
import '../theme/app_style.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openGame();
  }

  Future<void> _openGame() async {
    final preload = _preload();
    await Future.wait<void>([
      preload.then((_) {}),
      Future<void>.delayed(const Duration(milliseconds: 1600)),
    ]);

    final boot = await preload;
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => GameScreen(boot: boot),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Future<GameBootData> _preload() async {
    await AppLanguageController.loadLanguage();
    final prefs = await SharedPreferences.getInstance();
    final round = await DatabaseHelper.instance.loadRandomRound();

    return GameBootData(
      lang: AppLanguageController.currentLanguage == AppLanguage.es
          ? 'ES'
          : 'EN',
      isMuted: prefs.getBool('is_muted') ?? false,
      points: prefs.getInt('score') ?? 0,
      round: round,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppStyle.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenSize.width * 0.75,
                maxHeight: screenSize.height * 0.40,
              ),
              child: Image.asset(
                'assets/splash.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.color_lens,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
