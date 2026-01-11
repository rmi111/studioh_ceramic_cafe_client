import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionStatus { initial, loading, loaded, purchasing, purchased, error }

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final Offerings? offerings;
  final bool isPremium;
  final String? errorMessage;
  final Package? selectedPackage;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.offerings,
    this.isPremium = false,
    this.errorMessage,
    this.selectedPackage,
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    Offerings? offerings,
    bool? isPremium,
    String? errorMessage,
    Package? selectedPackage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      offerings: offerings ?? this.offerings,
      isPremium: isPremium ?? this.isPremium,
      errorMessage: errorMessage,
      selectedPackage: selectedPackage ?? this.selectedPackage,
    );
  }

  /// Get packages from default offering
  List<Package> get packages {
    return offerings?.current?.availablePackages ?? [];
  }

  @override
  List<Object?> get props => [status, offerings, isPremium, errorMessage, selectedPackage];
}
