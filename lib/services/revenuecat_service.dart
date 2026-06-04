import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Service for RevenueCat subscription management
class RevenueCatService {
  static const String _iosApiKey = 'appl_fTbRCxqjIfcJrTJKlJeUlViBxLU';
  static const String _androidApiKey = 'goog_YDMnAreJRGFVlTgqUhnrArbkmmF';

  static const String entitlementId = 'premium';

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
  }

  /// Initialize with user ID for attribution
  static Future<void> initializeWithUser(String userId) async {
    final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration config = PurchasesConfiguration(apiKey)
      ..appUserID = userId;
    await Purchases.configure(config);
  }

  /// Login user to RevenueCat
  static Future<void> login(String userId) async {
    await Purchases.logIn(userId);
  }

  /// Logout user from RevenueCat
  static Future<void> logout() async {
    await Purchases.logOut();
  }

  /// Get available offerings (subscription products)
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      print('Error getting offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  static Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return result.customerInfo.entitlements.all[entitlementId]?.isActive ??
          false;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  /// Check if user has premium entitlement
  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  /// Get customer info
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('Error getting customer info: $e');
      return null;
    }
  }

  /// Restore purchases
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }

  /// Listen to customer info updates
  static void addCustomerInfoListener(void Function(CustomerInfo) listener) {
    Purchases.addCustomerInfoUpdateListener(listener);
  }
}
