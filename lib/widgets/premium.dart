import 'package:flutter/material.dart';

import '../config/premiumManager.dart';
import '../services/in_purchase_service.dart';

class PremiumActionButton extends StatelessWidget {
  final String lang;
  final VoidCallback? onTap;

  const PremiumActionButton({super.key, required this.lang, this.onTap});

  Future<void> _handleAction(BuildContext context, bool isPremium) async {
    if (onTap != null) {
      onTap!();
      return;
    }

    if (isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang == 'ES' ? 'Eres premium' : 'You are premium'),
          backgroundColor: const Color(0xFFA3E635),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    final result = await PremiumPurchaseService.instance.buyPremium();
    if (!context.mounted) return;

    final message = switch (result) {
      PremiumBuyResult.started || PremiumBuyResult.alreadyOwned => null,
      PremiumBuyResult.unavailable => lang == 'ES'
          ? 'Google Play no esta disponible en este dispositivo.'
          : 'Google Play is not available on this device.',
      PremiumBuyResult.productMissing => lang == 'ES'
          ? 'No se encontro el producto premium en Google Play.'
          : 'Premium product was not found in Google Play.',
      PremiumBuyResult.failed => lang == 'ES'
          ? 'No se pudo abrir la compra de Google Play.'
          : 'Google Play purchase could not be opened.',
    };
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ConfigApp.isPremiumNotifier,
      builder: (context, isPremium, _) {
        final String imagePath =
            isPremium ? 'assets/premium.png' : 'assets/ads.png';

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _handleAction(context, isPremium),
          child: Image.asset(
            imagePath,
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) => Icon(
              isPremium ? Icons.workspace_premium : Icons.campaign,
              color: Colors.amber,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}
