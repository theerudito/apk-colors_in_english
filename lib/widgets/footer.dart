import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_style.dart';

class AppFooter extends StatelessWidget {
  final String lang;

  const AppFooter({super.key, required this.lang});

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final isEs = lang.toUpperCase() == 'ES';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEs ? 'SIGUENOS' : 'FOLLOW US',
            style: AppStyle.pixel(size: 8, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Colors.pinkAccent,
                  size: 18,
                ),
                onPressed: () => _launchUrl('https://instagram.com/theerudito'),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const FaIcon(
                  FontAwesomeIcons.globe,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => _launchUrl('https://jorgeloor-dev.web.app/'),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const FaIcon(
                  FontAwesomeIcons.github,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => _launchUrl('https://github.com/theerudito'),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const FaIcon(
                  FontAwesomeIcons.linkedin,
                  color: Colors.lightBlueAccent,
                  size: 18,
                ),
                onPressed: () =>
                    _launchUrl('https://www.linkedin.com/in/theerudito'),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.greenAccent,
                  size: 18,
                ),
                onPressed: () => _launchUrl(
                  'https://wa.me/593960806054?text=Hola%20Between%20Bytes%20Software',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  isEs ? 'Hecho con ' : 'Made with ',
                  style: AppStyle.pixel(size: 7, color: Colors.white70),
                ),
              ),
              const Icon(Icons.favorite, color: Colors.red, size: 12),
              Flexible(
                child: Text(
                  ' Between Bytes Software $currentYear',
                  style: AppStyle.pixel(size: 7, color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
