import 'package:in_app_purchase/in_app_purchase.dart';

/// Single in-app purchase: "Buy Me a Coffee" (USD 0.99).
/// Grants the Supporter badge only — no gameplay advantage.
class CoffeeIap {
  static const String productId = 'qavexyukonsolitaireprocoffee';
  static const String priceLabel = '\$0.99';

  final InAppPurchase _iap = InAppPurchase.instance;
  bool available = false;
  bool busy = false;
  ProductDetails? product;
  String? error;

  Future<void> init() async {
    try {
      available = await _iap.isAvailable();
    } catch (_) {
      available = false;
    }
    if (!available) return;
    try {
      final resp = await _iap.queryProductDetails({productId});
      if (resp.productDetails.isNotEmpty) {
        product = resp.productDetails.first;
      } else {
        error = 'Product not found in store.';
      }
      if (resp.error != null) error = resp.error!.message;
    } catch (e) {
      error = e.toString();
    }
  }

  /// Returns true if the purchase flow was launched.
  Future<bool> buy() async {
    if (product == null || busy) return false;
    busy = true;
    try {
      return await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: product!));
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      busy = false;
    }
  }
}
