import 'package:flutter/material.dart';

import '../theme/app_style.dart';
import 'premium.dart';

class AppHeader extends StatelessWidget {
  final String lang;
  final bool isMuted;
  final bool configOpen;
  final int time;
  final int points;
  final bool timeWarning;
  final VoidCallback onToggleLang;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleConfig;
  final VoidCallback? onPremiumTap;

  const AppHeader({
    super.key,
    required this.lang,
    required this.isMuted,
    required this.configOpen,
    required this.time,
    required this.points,
    required this.timeWarning,
    required this.onToggleLang,
    required this.onToggleMute,
    required this.onToggleConfig,
    this.onPremiumTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeColor = timeWarning ? Colors.redAccent : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PremiumActionButton(lang: lang, onTap: onPremiumTap),
              const SizedBox(height: 4),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onToggleConfig,
                child: AnimatedRotation(
                  turns: configOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Image.asset(
                    'assets/config.png',
                    width: 30,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF7EC8E3),
                      size: 28,
                    ),
                  ),
                ),
              ),
              if (configOpen) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppStyle.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppStyle.panelBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onToggleLang,
                        child: Image.asset(
                          lang.toUpperCase() == 'EN'
                              ? 'assets/ES.png'
                              : 'assets/EN.png',
                          width: 28,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            lang,
                            style: AppStyle.pixel(size: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onToggleMute,
                        child: Image.asset(
                          isMuted ? 'assets/mic-Off.png' : 'assets/mic-On.png',
                          width: 22,
                          height: 22,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _HudLine(
                label: lang.toUpperCase() == 'ES' ? 'TIEMPO' : 'TIME',
                value: '$time',
                valueColor: timeColor,
              ),
              const SizedBox(height: 8),
              _HudLine(
                label: lang.toUpperCase() == 'ES' ? 'PUNTOS' : 'SCORE',
                value: '$points',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HudLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _HudLine({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label:', style: AppStyle.pixel(size: 8, color: Colors.white)),
        const SizedBox(width: 8),
        Text(value, style: AppStyle.pixel(size: 8, color: valueColor)),
      ],
    );
  }
}
