import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/revenuecat_service.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final String? userId;
  
  SubscriptionCubit({this.userId}) : super(const SubscriptionState()) {
    _init();
  }

  void _init() {
    // Listen to customer info updates
    RevenueCatService.addCustomerInfoListener(_onCustomerInfoUpdate);
    loadOfferings();
  }

  void _onCustomerInfoUpdate(CustomerInfo info) {
    final isPremium = info.entitlements.all[RevenueCatService.entitlementId]?.isActive ?? false;
    emit(state.copyWith(isPremium: isPremium));
    // Subscription sync is now handled by RevenueCat webhook → Laravel backend
    // No need to write to Firestore directly
  }

  /// Load available subscription offerings
  Future<void> loadOfferings() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    
    try {
      final offerings = await RevenueCatService.getOfferings();
      final isPremium = await RevenueCatService.isPremium();
      
      // Default select yearly package if available
      Package? selectedPackage;
      if (offerings?.current != null) {
        final packages = offerings!.current!.availablePackages;
        selectedPackage = packages.firstWhere(
          (p) => p.packageType == PackageType.annual,
          orElse: () => packages.first,
        );
      }
      
      emit(state.copyWith(
        status: SubscriptionStatus.loaded,
        offerings: offerings,
        isPremium: isPremium,
        selectedPackage: selectedPackage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: 'Failed to load subscriptions: $e',
      ));
    }
  }

  /// Select a package
  void selectPackage(Package package) {
    emit(state.copyWith(selectedPackage: package));
  }

  /// Purchase the selected package
  Future<bool> purchase() async {
    if (state.selectedPackage == null) return false;
    
    emit(state.copyWith(status: SubscriptionStatus.purchasing));
    
    try {
      final success = await RevenueCatService.purchasePackage(state.selectedPackage!);
      
      if (success) {
        emit(state.copyWith(
          status: SubscriptionStatus.purchased,
          isPremium: true,
        ));
        // Webhook handles server-side sync automatically
        return true;
      } else {
        emit(state.copyWith(
          status: SubscriptionStatus.loaded,
          errorMessage: 'Purchase was cancelled',
        ));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: 'Purchase failed: $e',
      ));
      return false;
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    emit(state.copyWith(status: SubscriptionStatus.loading));
    
    try {
      final isPremium = await RevenueCatService.restorePurchases();
      
      emit(state.copyWith(
        status: SubscriptionStatus.loaded,
        isPremium: isPremium,
      ));
      // Webhook handles server-side sync automatically
      return isPremium;
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: 'Restore failed: $e',
      ));
      return false;
    }
  }

  /// Check current premium status
  Future<void> checkPremiumStatus() async {
    final isPremium = await RevenueCatService.isPremium();
    emit(state.copyWith(isPremium: isPremium));
  }
}
