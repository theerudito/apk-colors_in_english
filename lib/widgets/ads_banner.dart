import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/premiumManager.dart';
import '../helpers/ads_strings.dart';

class AdBannerWidget extends StatefulWidget {
  final String lang;

  const AdBannerWidget({super.key, required this.lang});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool get _shouldShowAds => !ConfigApp.isPremium;

  @override
  void initState() {
    super.initState();
    ConfigApp.isPremiumNotifier.addListener(_onPremiumChanged);
    if (_shouldShowAds) {
      _loadAd();
    }
  }

  void _onPremiumChanged() {
    if (!mounted) return;

    if (!_shouldShowAds) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
    } else if (_bannerAd == null) {
      _loadAd();
    }

    setState(() {});
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdsStrings.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Error al cargar banner: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    ConfigApp.isPremiumNotifier.removeListener(_onPremiumChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAds) return const SizedBox.shrink();

    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      alignment: Alignment.center,
      height: 52,
      margin: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
