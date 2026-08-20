import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:studioh_ceramic_cafe_client/cubit/voucher_cubit/voucher_state.dart';
import 'package:studioh_ceramic_cafe_client/model/voucher.dart';
import 'package:studioh_ceramic_cafe_client/services/api_service.dart';
import 'package:studioh_ceramic_cafe_client/services/revenuecat_service.dart';

class VoucherCubit extends Cubit<VoucherState> {
  final String? userId;
  final String? userEmail;

  VoucherCubit({this.userId, this.userEmail}) : super(const VoucherState()) {
    loadEligibleVouchers();
  }

  @override
  Future<void> close() {
    return super.close();
  }

  /// Load all vouchers from API (server handles eligibility filtering)
  Future<void> loadEligibleVouchers() async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await ApiService.listVouchers(perPage: 100);
      final data = response.data;

      var vouchersData = data['data'] ?? data;
      // Handle Laravel paginator where the actual list is inside another 'data' key
      if (vouchersData is Map && vouchersData.containsKey('data')) {
        vouchersData = vouchersData['data'];
      }

      List<Voucher> allVouchers = [];

      if (vouchersData is List) {
        allVouchers = vouchersData
            .map((v) => Voucher.fromJson(v as Map<String, dynamic>))
            .toList();
      }

      // Categorize vouchers
      final categorized = _categorize(allVouchers);

      emit(state.copyWith(
        allVouchers: allVouchers,
        activeVouchers: categorized['active'],
        usedVouchers: categorized['used'],
        expiredVouchers: categorized['expired'],
        isLoading: false,
      ));
    } catch (e) {
      print('Error loading vouchers: $e');

      // Handle 403 — not a subscriber
      String errorMsg = '';
      try {
        final dioError = e as dynamic;
        if (dioError.response?.statusCode == 403) {
          errorMsg = 'Subscribe to access vouchers';
        }
      } catch (_) {}

      emit(state.copyWith(
        allVouchers: [],
        isLoading: false,
        errorMessage: errorMsg,
      ));
    }
  }

  /// Refresh vouchers
  Future<void> refresh() async {
    await loadEligibleVouchers();
  }

  Voucher? getByCode(String code) {
    try {
      return state.allVouchers.firstWhere((v) => v.code == code);
    } catch (_) {
      return null;
    }
  }

  List<Voucher> searchBy(String query) {
    final q = query.toLowerCase();
    return state.allVouchers.where((v) {
      return v.code.toLowerCase().contains(q) ||
          v.type.toLowerCase().contains(q) ||
          v.description.toLowerCase().contains(q) ||
          v.value.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> fetchAvailableProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        final products = offerings.current!.availablePackages
            .map((package) => package.storeProduct)
            .toList();
        emit(state.copyWith(availableProducts: products));
      } else {
        emit(state.copyWith(availableProducts: []));
      }
    } catch (e) {
      print('Error fetching products: $e');
      emit(state.copyWith(availableProducts: []));
    }
  }

  Map<String, List<Voucher>> _categorize(List<Voucher> vouchers) {
    final active = <Voucher>[];
    final used = <Voucher>[];
    final expired = <Voucher>[];

    for (final v in vouchers) {
      if (v.isRedeemed) {
        used.add(v);
      } else if (v.isExpired) {
        expired.add(v);
      } else if (v.isActive && !v.isExpired && !v.isRedeemed) {
        active.add(v);
      } else {
        expired.add(v);
      }
    }

    return {'active': active, 'used': used, 'expired': expired};
  }
}
