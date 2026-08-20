import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';
import 'package:studioh_ceramic_cafe_client/model/voucher.dart';

class VoucherState extends Equatable {
  final List<Voucher> allVouchers;
  final List<Voucher> activeVouchers;
  final List<Voucher> usedVouchers;
  final List<Voucher> expiredVouchers;
  final Voucher? subscriptionVoucher;
  final List<StoreProduct> availableProducts;
  final bool isLoading;
  final String errorMessage;

  const VoucherState({
    this.allVouchers = const [],
    this.activeVouchers = const [],
    this.usedVouchers = const [],
    this.expiredVouchers = const [],
    this.subscriptionVoucher,
    this.availableProducts = const [],
    this.isLoading = false,
    this.errorMessage = '',
  });

  VoucherState copyWith({
    List<Voucher>? allVouchers,
    List<Voucher>? activeVouchers,
    List<Voucher>? usedVouchers,
    List<Voucher>? expiredVouchers,
    Voucher? subscriptionVoucher,
    List<StoreProduct>? availableProducts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VoucherState(
      allVouchers: allVouchers ?? this.allVouchers,
      activeVouchers: activeVouchers ?? this.activeVouchers,
      usedVouchers: usedVouchers ?? this.usedVouchers,
      expiredVouchers: expiredVouchers ?? this.expiredVouchers,
      subscriptionVoucher: subscriptionVoucher ?? this.subscriptionVoucher,
      availableProducts: availableProducts ?? this.availableProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allVouchers,
        activeVouchers,
        usedVouchers,
        expiredVouchers,
        subscriptionVoucher,
        availableProducts,
        isLoading,
        errorMessage,
      ];
}
