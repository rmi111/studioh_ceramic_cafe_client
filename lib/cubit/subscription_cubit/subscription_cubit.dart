import 'package:cloud_firestore/cloud_firestore.dart';
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
    
    // Sync with Firestore if we have a user ID
    if (userId != null) {
      _syncSubscriptionToFirestore(isPremium);
    }
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
        
        // Sync with Firestore
        if (userId != null) {
          await _syncSubscriptionToFirestore(true);
        }
        
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
      
      if (userId != null && isPremium) {
        await _syncSubscriptionToFirestore(true);
      }
      
      return isPremium;
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: 'Restore failed: $e',
      ));
      return false;
    }
  }

  /// Sync subscription status to Firestore
  Future<void> _syncSubscriptionToFirestore(bool isSubscriber) async {
    if (userId == null) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isSubscriber': isSubscriber});
    } catch (e) {
      print('Failed to sync subscription to Firestore: $e');
    }
  }

  /// Check current premium status
  Future<void> checkPremiumStatus() async {
    final isPremium = await RevenueCatService.isPremium();
    emit(state.copyWith(isPremium: isPremium));
  }
}
