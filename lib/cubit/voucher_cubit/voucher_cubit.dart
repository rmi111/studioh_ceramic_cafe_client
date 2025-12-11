import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:studioh_ceramic_cafe_client/cubit/voucher_cubit/voucher_state.dart';
import 'package:studioh_ceramic_cafe_client/model/voucher.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/firebase_collection_name.dart';

class VoucherCubit extends Cubit<VoucherState> {
  VoucherCubit() : super(const VoucherState()) {
    loadAllVouchers();
    listenToVouchers();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  Future<void> loadAllVouchers() async {
    emit(state.copyWith(isLoading: true));
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.VOUCHERS)
          .get();

      List<Voucher> loaded = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final docId = doc.id;

        if (docId == 'VOUCHER_FREE_ITEMS' && data['vouchers'] is List) {
          for (var v in data['vouchers']) {
            loaded.add(Voucher.fromMap(v));
          }
        } else if (docId == 'VOUCHER_SUBSCRIPTION' ||
            docId == 'VOUCHER_CUSTOM_ITEM') {
          loaded.add(Voucher.fromMap({...data, 'code': docId}));
        }
      }

      emit(state.copyWith(allVouchers: loaded, isLoading: false));
    } catch (e) {
      emit(state.copyWith(allVouchers: [], isLoading: false));
    }
  }

  void listenToVouchers() {
    _sub?.cancel();

    _sub = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.VOUCHERS)
        .snapshots()
        .listen(
          (snapshot) {
            final list = snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data.putIfAbsent('code', () => doc.id);
              return Voucher.fromMap(data);
            }).toList();

            final categorized = _categorize(list);

            emit(
              state.copyWith(
                allVouchers: list,
                activeVouchers: categorized['active'],
                usedVouchers: categorized['used'],
                expiredVouchers: categorized['expired'],
                isLoading: false,
              ),
            );
          },
          onError: (err) {
            emit(state.copyWith(isLoading: false));
            print('Voucher listen error: $err');
          },
        );
  }

  Future<void> fetchVouchersOnce() async {
    emit(state.copyWith(isLoading: true));
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.VOUCHERS)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data.putIfAbsent('code', () => doc.id);
        return Voucher.fromMap(data);
      }).toList();

      final categorized = _categorize(list);

      emit(
        state.copyWith(
          allVouchers: list,
          activeVouchers: categorized['active'],
          usedVouchers: categorized['used'],
          expiredVouchers: categorized['expired'],
          isLoading: false,
        ),
      );
    } catch (e) {
      print('fetchVouchersOnce error: $e');
      emit(state.copyWith(isLoading: false));
    }
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

  Future<void> loadSubscriptionVoucher() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.VOUCHERS)
          .doc('special_item')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        emit(state.copyWith(subscriptionVoucher: Voucher.fromMap(data)));
      } else {
        emit(state.copyWith(subscriptionVoucher: null));
      }
    } catch (e) {
      print('Error loading subscription voucher: $e');
      emit(state.copyWith(subscriptionVoucher: null));
    }
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
    final now = DateTime.now();

    final active = <Voucher>[];
    final used = <Voucher>[];
    final expired = <Voucher>[];

    for (final v in vouchers) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(v.expiryDate);
      final isExpired = expiry.isBefore(now);
      final isUsed = v.redeemedDate != null;
      final isActiveFlag = v.isActive;
     print('Voucher ${v.code} - isActive: $isActiveFlag, isUsed: $isUsed, isExpired: $isExpired');
      if (isUsed) {
        used.add(v);
      } else if (isExpired) {
        expired.add(v);
      } else if (isActiveFlag && !isExpired && !isUsed) {
        active.add(v);
      } else {
        print('Voucher ${v.code} did not match any category');
        expired.add(v);
      }
    }
    print('Active ${active.length}');
    print('Used ${used.length}');
    print("Expired ${expired.length}");

    return {'active': active, 'used': used, 'expired': expired};
  }
}
