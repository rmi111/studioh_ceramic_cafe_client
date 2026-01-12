import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:studioh_ceramic_cafe_client/cubit/voucher_cubit/voucher_state.dart';
import 'package:studioh_ceramic_cafe_client/model/voucher.dart';
import 'package:studioh_ceramic_cafe_client/services/revenuecat_service.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/firebase_collection_name.dart';

class VoucherCubit extends Cubit<VoucherState> {
  final String? userId;
  final String? userEmail;

  VoucherCubit({this.userId, this.userEmail}) : super(const VoucherState()) {
    loadEligibleVouchers();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  /// Load all vouchers the current user is eligible for
  Future<void> loadEligibleVouchers() async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<Voucher> allVouchers = [];

      // Check subscription status
      final isSubscriber = await RevenueCatService.isPremium();

      // 1. Subscription Vouchers (new subscriber)
      if (isSubscriber) {
        final newSubVoucher = await _fetchVoucher('VOUCHER_NEW_SUBSCRIBER');
        if (newSubVoucher != null) {
          allVouchers.add(newSubVoucher);
        }

        // Existing subscriber voucher
        final existingSubVoucher = await _fetchVoucher(
          'VOUCHER_EXISTING_SUBSCRIBER',
        );
        if (existingSubVoucher != null) {
          allVouchers.add(existingSubVoucher);
        }
      }

      // 2. Collection Voucher (available to all users who collect orders)
      final collectionVoucher = await _fetchVoucher('VOUCHER_COLLECTION');
      if (collectionVoucher != null) {
        allVouchers.add(collectionVoucher);
      }

      // 3. Specific Vouchers (assigned to this user)
      if (userId != null) {
        final specificVouchers = await _fetchSpecificVouchers(userId!);
        allVouchers.addAll(specificVouchers);
      }

      // 4. OhNo Vouchers (assigned to this user)
      if (userId != null) {
        final ohnoVouchers = await _fetchOhNoVouchers(userId!);
        allVouchers.addAll(ohnoVouchers);
      }

      // Categorize all vouchers
      final categorized = _categorize(allVouchers);

      emit(
        state.copyWith(
          allVouchers: allVouchers,
          activeVouchers: categorized['active'],
          usedVouchers: categorized['used'],
          expiredVouchers: categorized['expired'],
          isLoading: false,
        ),
      );
    } catch (e) {
      print('Error loading vouchers: $e');
      emit(state.copyWith(allVouchers: [], isLoading: false));
    }
  }

  /// Fetch a single voucher document
  Future<Voucher?> _fetchVoucher(String docId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.VOUCHERS)
          .doc(docId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['code'] = docId;
        return Voucher.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching voucher $docId: $e');
      return null;
    }
  }

  /// Fetch vouchers from VOUCHER_SPECIFIC assigned to this user
  Future<List<Voucher>> _fetchSpecificVouchers(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.VOUCHERS)
          .doc('VOUCHER_SPECIFIC')
          .get();

      if (!doc.exists || doc.data() == null) return [];

      final data = doc.data()!;
      if (data['vouchers'] is! List) return [];

      final List<Voucher> userVouchers = [];
      for (var v in data['vouchers']) {
        if (v is Map<String, dynamic> && v['assignedTo'] == userId) {
          userVouchers.add(Voucher.fromMap(v));
        }
      }

      return userVouchers;
    } catch (e) {
      print('Error fetching specific vouchers: $e');
      return [];
    }
  }

  /// Fetch OhNo vouchers assigned to this user
  Future<List<Voucher>> _fetchOhNoVouchers(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.VOUCHERS)
          .doc('VOUCHER_OHNO')
          .get();

      if (!doc.exists || doc.data() == null) return [];

      final data = doc.data()!;
      if (data['vouchers'] is! List) return [];

      final List<Voucher> userVouchers = [];
      for (var v in data['vouchers']) {
        if (v is Map<String, dynamic>) {
          // OhNo vouchers might be assigned to specific users or available to all
          if (v['assignedTo'] == null || v['assignedTo'] == userId) {
            userVouchers.add(Voucher.fromMap(v));
          }
        }
      }

      return userVouchers;
    } catch (e) {
      print('Error fetching ohno vouchers: $e');
      return [];
    }
  }

  /// Refresh vouchers
  Future<void> refresh() async {
    await loadEligibleVouchers();
  }

  /// Listen to voucher changes in real-time
  void listenToVouchers() {
    _sub?.cancel();

    _sub = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.VOUCHERS)
        .snapshots()
        .listen(
          (_) {
            // Reload when any voucher changes
            loadEligibleVouchers();
          },
          onError: (err) {
            print('Voucher listen error: $err');
          },
        );
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
    final now = DateTime.now();

    final active = <Voucher>[];
    final used = <Voucher>[];
    final expired = <Voucher>[];

    for (final v in vouchers) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(v.expiryDate);
      final isExpired = expiry.isBefore(now);
      final isUsed = v.redeemedDate != null;
      final isActiveFlag = v.isActive;

      if (isUsed) {
        used.add(v);
      } else if (isExpired) {
        expired.add(v);
      } else if (isActiveFlag && !isExpired && !isUsed) {
        active.add(v);
      } else {
        expired.add(v);
      }
    }

    return {'active': active, 'used': used, 'expired': expired};
  }
}
