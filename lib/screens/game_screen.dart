import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/languageManager.dart';
import '../db/database_helper.dart';
import '../theme/app_style.dart';
import '../widgets/ads_banner.dart';
import '../widgets/color_options_grid.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';

enum AvatarMood { idle, happy, sad }

class GameBootData {
  final String lang;
  final bool isMuted;
  final int points;
  final GameRound? round;

  const GameBootData({
    required this.lang,
    required this.isMuted,
    required this.points,
    required this.round,
  });
}

class GameScreen extends StatefulWidget {
  final GameBootData? boot;

  const GameScreen({super.key, this.boot});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const _scoreKey = 'score';
  static const _muteKey = 'is_muted';
  static const _roundSeconds = 10;
  static const _roundPoints = 10;

  final AudioPlayer _audioPlayer = AudioPlayer();

  String _lang = 'ES';
  bool _isMuted = false;
  bool _configOpen = false;
  bool _dbOk = false;
  bool _isLocked = false;
  bool _revealAll = false;
  bool _timeWarning = false;

  int _points = 0;
  int _time = 0;
  AvatarMood _avatar = AvatarMood.idle;

  GameColor? _target;
  List<GameColor> _options = [];
  final Set<int> _revealedWrong = {};

  Timer? _timer;

  String get _avatarAsset {
    switch (_avatar) {
      case AvatarMood.happy:
        return 'assets/faceHappy.png';
      case AvatarMood.sad:
        return 'assets/faceSad.png';
      case AvatarMood.idle:
        return 'assets/faceDefault.png';
    }
  }

  @override
  void initState() {
    super.initState();
    final boot = widget.boot;
    if (boot != null) {
      _lang = boot.lang;
      _isMuted = boot.isMuted;
      _points = boot.points;
      _applyRound(boot.round, startTimer: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _target != null) {
          _startTimer();
        }
      });
    } else {
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    await AppLanguageController.loadLanguage();
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _lang =
          AppLanguageController.currentLanguage == AppLanguage.es ? 'ES' : 'EN';
      _isMuted = prefs.getBool(_muteKey) ?? false;
      _points = prefs.getInt(_scoreKey) ?? 0;
    });

    await _loadNextQuestion();
  }

  void _applyRound(GameRound? round, {required bool startTimer}) {
    if (round == null) {
      _dbOk = false;
      _options = [];
      _target = null;
      return;
    }

    _target = round.target;
    _options = round.options;
    _revealedWrong.clear();
    _revealAll = false;
    _avatar = AvatarMood.idle;
    _isLocked = false;
    _dbOk = true;
    _time = _roundSeconds;
    _timeWarning = false;

    if (startTimer) {
      _startTimer();
    }
  }

  Future<void> _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scoreKey, _points);
  }

  Future<void> _toggleLanguage() async {
    _playClick();
    final nextLanguage = _lang == 'ES' ? AppLanguage.en : AppLanguage.es;
    await AppLanguageController.saveLanguage(nextLanguage);
    if (!mounted) return;
    setState(() {
      _lang = nextLanguage == AppLanguage.es ? 'ES' : 'EN';
    });
    await _loadNextQuestion();
  }

  Future<void> _toggleMute() async {
    _playClick();
    final prefs = await SharedPreferences.getInstance();
    final next = !_isMuted;
    await prefs.setBool(_muteKey, next);
    if (!mounted) return;
    setState(() => _isMuted = next);
  }

  void _toggleConfig() {
    _playClick();
    setState(() => _configOpen = !_configOpen);
  }

  Future<void> _playSound(String asset) async {
    if (_isMuted) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Error audio: $e');
    }
  }

  void _playClick() => _playSound('mouse.ogg');

  Future<void> _loadNextQuestion() async {
    _timer?.cancel();

    try {
      final round = await DatabaseHelper.instance.loadRandomRound();
      if (!mounted) return;
      setState(() => _applyRound(round, startTimer: true));
    } catch (e) {
      debugPrint('Error loading colors: $e');
      if (!mounted) return;
      setState(() {
        _dbOk = false;
        _options = [];
        _target = null;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isLocked) return;
      if (_time <= 1) {
        timer.cancel();
        _onRoundEnd();
        return;
      }

      setState(() {
        _time -= 1;
        if (_time == 5) {
          _timeWarning = true;
        }
      });
      if (_time == 5) {
        _playSound('clock.ogg');
      }
    });
  }

  Future<void> _onRoundEnd() async {
    if (_isLocked) return;
    setState(() {
      _isLocked = true;
      _time = 0;
      _revealAll = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      await _loadNextQuestion();
    }
  }

  Future<void> _verifyAnswer(int index) async {
    if (_isLocked || _target == null) return;
    final selected = _options[index];

    if (selected.id == _target!.id) {
      setState(() {
        _isLocked = true;
        _revealAll = true;
        _avatar = AvatarMood.happy;
        _points += _roundPoints;
      });
      await _saveScore();
      await _playSound('correct.mp3');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        await _loadNextQuestion();
      }
      return;
    }

    setState(() {
      _revealedWrong.add(index);
      _avatar = AvatarMood.sad;
      _points = max(0, _points - _roundPoints);
    });
    await _saveScore();
    await _playSound('error.mp3');
  }

  double _nameSize(String name) {
    if (name.length < 7) return 22;
    if (name.length < 12) return 16;
    return 12;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEs = _lang.toUpperCase() == 'ES';
    final targetName = _target?.nameFor(_lang) ?? '';
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppStyle.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 48 : 22,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: isTablet ? 12 : 8),
                          Image.asset(
                            _avatarAsset,
                            width: isTablet ? 140 : 96,
                            height: isTablet ? 140 : 96,
                            filterQuality: FilterQuality.none,
                            errorBuilder: (context, error, stackTrace) => Text(
                              'B)',
                              style: AppStyle.pixel(
                                size: 40,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isEs
                                ? 'BASE DE DATOS: ${_dbOk ? 'OK' : 'ERROR'}'
                                : 'DATABASE: ${_dbOk ? 'OK' : 'ERROR'}',
                            style: AppStyle.pixel(
                              size: 7,
                              color: _dbOk ? Colors.white54 : Colors.redAccent,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            isEs ? 'QUE COLOR ES' : 'WHAT COLOR IS',
                            textAlign: TextAlign.center,
                            style: AppStyle.pixel(size: isTablet ? 16 : 13),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            targetName,
                            textAlign: TextAlign.center,
                            style: AppStyle.pixel(
                              size:
                                  _nameSize(targetName) * (isTablet ? 1.2 : 1),
                            ),
                          ),
                          const Spacer(),
                          ColorOptionsGrid(
                            options: _options,
                            lang: _lang,
                            revealedWrong: _revealedWrong,
                            revealAll: _revealAll,
                            enabled: !_isLocked,
                            onSelected: _verifyAnswer,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    AppHeader(
                      lang: _lang,
                      isMuted: _isMuted,
                      configOpen: _configOpen,
                      time: _time,
                      points: _points,
                      timeWarning: _timeWarning,
                      onToggleLang: _toggleLanguage,
                      onToggleMute: _toggleMute,
                      onToggleConfig: _toggleConfig,
                    ),
                  ],
                ),
              ),
              AdBannerWidget(lang: _lang),
              AppFooter(lang: _lang),
            ],
          ),
        ),
      ),
    );
  }
}
