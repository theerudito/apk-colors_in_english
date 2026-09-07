import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../config/premiumManager.dart';

enum PremiumBuyResult {
  started,
  alreadyOwned,
  unavailable,
  productMissing,
  failed,
}

class PremiumPurchaseService {
  PremiumPurchaseService._();

  static final PremiumPurchaseService instance = PremiumPurchaseService._();

  static const String _premiumProductId = 'premium_qr_reader';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _product;
  bool _isAvailable = false;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await ConfigApp.loadPremiumStatus();

    _subscription ??= _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => debugPrint('purchaseStream cerrado'),
      onError: (error) => debugPrint('purchaseStream error: $error'),
    );

    _isAvailable = await _inAppPurchase.isAvailable();
    if (!_isAvailable) {
      debugPrint('Google Play In-App Purchase no disponible');
      _isInitialized = true;
      return;
    }

    await _loadProduct();
    _isInitialized = true;
    await checkAndRestorePastPurchases();
  }

  Future<void> _loadProduct() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({_premiumProductId});

    if (response.error != null) {
      debugPrint('Error queryProductDetails: ${response.error}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Productos no encontrados: ${response.notFoundIDs}');
    }

    _product = null;
    for (final product in response.productDetails) {
      if (product.id == _premiumProductId) {
        _product = product;
        break;
      }
    }
  }

  Future<bool> checkAndRestorePastPurchases() async {
    if (!_isAvailable || kIsWeb) return ConfigApp.isPremium;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final InAppPurchaseAndroidPlatformAddition androidAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final QueryPurchaseDetailsResponse response =
            await androidAddition.queryPastPurchases();

        for (final purchase in response.pastPurchases) {
          if (purchase.productID == _premiumProductId &&
              (purchase.status == PurchaseStatus.purchased ||
                  purchase.status == PurchaseStatus.restored)) {
            debugPrint('Compra previa encontrada vía queryPastPurchases');
            await ConfigApp.setPremium(true);
            if (purchase.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchase);
            }
            return true;
          }
        }
      }

      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error comprobando compras pasadas: $e');
    }

    return ConfigApp.isPremium;
  }

  Future<bool> restorePurchases() async {
    return checkAndRestorePastPurchases();
  }

  Future<PremiumBuyResult> buyPremium() async {
    if (kIsWeb) {
      debugPrint('La compra solo está disponible en Android/iOS');
      return PremiumBuyResult.unavailable;
    }

    await initialize();

    if (ConfigApp.isPremium) {
      debugPrint('El usuario ya es premium');
      return PremiumBuyResult.alreadyOwned;
    }

    if (!_isAvailable) {
      debugPrint('In-app purchase no disponible en este dispositivo');
      return PremiumBuyResult.unavailable;
    }

    if (_product == null) {
      await _loadProduct();
    }

    final product = _product;
    if (product == null) {
      debugPrint('Producto premium no encontrado en Google Play');
      return PremiumBuyResult.productMissing;
    }

    final PurchaseParam purchaseParam =
        defaultTargetPlatform == TargetPlatform.android
            ? GooglePlayPurchaseParam(productDetails: product)
            : PurchaseParam(productDetails: product);

    try {
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        debugPrint('La compra premium no se pudo iniciar');
        return PremiumBuyResult.failed;
      }
      return PremiumBuyResult.started;
    } catch (e) {
      debugPrint('Excepción al comprar premium: $e');
      final errString = e.toString().toLowerCase();
      if (errString.contains('already') ||
          errString.contains('item_already_owned')) {
        debugPrint('Detección por excepción: El usuario ya posee el ítem.');
        await ConfigApp.setPremium(true);
        return PremiumBuyResult.alreadyOwned;
      }
      return PremiumBuyResult.failed;
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != _premiumProductId) continue;

      if (purchase.status == PurchaseStatus.pending) {
        debugPrint('Compra premium pendiente');
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        unawaited(ConfigApp.setPremium(true));
        if (purchase.pendingCompletePurchase) {
          unawaited(_inAppPurchase.completePurchase(purchase));
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        final errorMsg = purchase.error?.message.toLowerCase() ?? '';
        final errorCode = purchase.error?.code.toLowerCase() ?? '';
        final isAlreadyOwned = errorMsg.contains('already own') ||
            errorMsg.contains('already_owned') ||
            errorCode == '7' ||
            errorCode.contains('item_already_owned');

        if (isAlreadyOwned) {
          debugPrint(
            'Google Play reporta que el producto ya fue comprado. Activando premium.',
          );
          unawaited(ConfigApp.setPremium(true));
        } else {
          debugPrint('Compra premium fallida: ${purchase.error}');
        }

        if (purchase.pendingCompletePurchase) {
          unawaited(_inAppPurchase.completePurchase(purchase));
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        debugPrint('Compra premium cancelada');
        if (purchase.pendingCompletePurchase) {
          unawaited(_inAppPurchase.completePurchase(purchase));
        }
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
