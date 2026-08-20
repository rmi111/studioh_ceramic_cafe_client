import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studioh_ceramic_cafe_client/services/api_service.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';

import '../../model/orders.dart';
import '../auth_cubit/auth_cubit.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final AuthCubit authCubit;

  OrderCubit({required this.authCubit})
      : super(
          const OrderState(
            orders: [],
            activeOrders: [],
            preparedOrders: [],
            unCollectedOrders: [],
            collectedOrders: [],
            capturedImages: [],
            isLoading: false,
            selectedTab: 0,
          ),
        ) {
    _initializeListeners();
    fetchOrders();
  }

  final ImagePicker _imagePicker = ImagePicker();

  void _initializeListeners() {
    // Listen to auth state changes to reload orders when user logs in
    authCubit.stream.listen((authState) {
      if (authState.currentUserModel != null) {
        fetchOrders();
      } else {
        // Clear orders when user logs out
        emit(
          state.copyWith(
            orders: [],
            activeOrders: [],
            preparedOrders: [],
            unCollectedOrders: [],
            collectedOrders: [],
          ),
        );
      }
    });
  }

  /// Categorize orders by status
  void _categorizeOrders(List<OrderModel> fetchedOrders) {
    // Sort orders by most recently added first
    fetchedOrders.sort((a, b) {
      final aDate = int.tryParse(a.orderDate) ?? 0;
      final bDate = int.tryParse(b.orderDate) ?? 0;
      return bDate.compareTo(aDate);
    });

    final List<OrderModel> active = [];
    final List<OrderModel> prepared = [];
    final List<OrderModel> unCollected = [];
    final List<OrderModel> collected = [];

    for (var order in fetchedOrders) {
      switch (order.status) {
        case 'collected':
          collected.add(order);
          break;
        case 'uncollected':
          unCollected.add(order);
          break;
        case 'prepared':
          prepared.add(order);
          break;
        default:
          active.add(order);
      }
    }

    emit(
      state.copyWith(
        orders: fetchedOrders,
        activeOrders: active,
        preparedOrders: prepared,
        unCollectedOrders: unCollected,
        collectedOrders: collected,
      ),
    );
  }

  /// Fetch orders from API (customer's own orders)
  Future<void> fetchOrders({bool isAdmin = false}) async {
    final currentUser = authCubit.state.currentUserModel;
    if (currentUser == null) return;

    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.myOrders(perPage: 100);
      final data = response.data;

      // Parse orders from API response
      var ordersData = data['data'] ?? data;
      // Handle Laravel paginator where the actual list is inside another 'data' key
      if (ordersData is Map && ordersData.containsKey('data')) {
        ordersData = ordersData['data'];
      }

      List<OrderModel> fetchedOrders = [];

      if (ordersData is List) {
        fetchedOrders = ordersData
            .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
            .toList();
      }

      print("✅ Fetched ${fetchedOrders.length} orders from API");
      _categorizeOrders(fetchedOrders);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print("❌ Error fetching orders: $e");
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Generate unique order reference number from API
  Future<String> generateOrderRefNumber() async {
    try {
      final response = await ApiService.generateRef();
      final data = response.data;
      final innerData = data['data'] ?? data;
      return innerData['ref_number'] ?? 'cc0001';
    } catch (e) {
      print('Error generating ref number: $e');
      return 'cc0001';
    }
  }

  /// Add new order via API
  Future<void> addOrder({
    required String refNumber,
    required String email,
    required String phone,
    String name = '',
    String description = '',
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      await ApiService.createOrder(
        refNumber: refNumber,
        email: email,
        phoneNumber: phone,
        name: name,
        description: description,
      );

      clearAllControllers();
      emit(state.copyWith(isLoading: false));

      // Refresh orders
      await fetchOrders();
    } catch (e) {
      print('Error adding order: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Pick images from gallery or camera
  Future<void> pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage();
        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          final newImages =
              pickedFiles.map((xfile) => File(xfile.path)).toList();
          final updatedImages = [...state.capturedImages, ...newImages];
          emit(state.copyWith(capturedImages: updatedImages));
          print('Images picked: ${updatedImages.length}');
        }
      } else {
        final pickedFile = await _imagePicker.pickImage(source: source);
        if (pickedFile != null) {
          final updatedImages = [
            ...state.capturedImages,
            File(pickedFile.path),
          ];
          emit(state.copyWith(capturedImages: updatedImages));
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  /// Remove all captured images
  void removeAllImages() {
    emit(state.copyWith(capturedImages: []));
  }

  /// Add user to existing order via API
  Future<void> addOrUpdateUserToOrder({
    required BuildContext context,
    required OrderModel order,
    String? email,
    String? name,
    String? phoneNumber,
    bool navigateToTracking = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final currentUser = authCubit.state.currentUserModel;
      final userEmail = email ?? currentUser?.email;
      final userName = name ?? currentUser?.name;
      final userPhone = phoneNumber ?? currentUser?.phoneNumber;

      if (userEmail == null || userPhone == null) {
        emit(state.copyWith(isLoading: false));
        throw Exception('Missing user information');
      }

      // Check if already part of this order
      final userExists = order.users.any((user) => user.email == userEmail);
      if (userExists) {
        emit(state.copyWith(isLoading: false));
        AppSnackbar.showError(context, "You are already part of this order.");
        return;
      }

      await ApiService.addParticipant(
        order.refNumber,
        email: userEmail,
        name: userName,
        phoneNumber: userPhone,
      );

      clearAllControllers();
      emit(state.copyWith(isLoading: false));

      // Refresh orders
      await fetchOrders();
    } catch (e) {
      print('Error adding user to order: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Get order by reference number (from local state)
  Future<OrderModel?> getOrderByRef(String refNumber) {
    try {
      return Future.value(
          state.orders.firstWhere((order) => order.refNumber == refNumber));
    } catch (e) {
      return Future.value(null);
    }
  }

  /// Filter orders by user email (local)
  void fetchOrdersByUser(String userEmail) {
    final userOrders = state.orders
        .where(
            (order) => order.users.any((user) => user.email == userEmail))
        .toList();
    print("User Orders Fetched: ${userOrders.length}");
    emit(state.copyWith(orders: userOrders));
  }

  /// Select tab
  void selectTab(int tabIndex) {
    print("Selecting tab: $tabIndex");
    emit(state.copyWith(selectedTab: tabIndex));
  }

  /// Clear all controllers
  void clearAllControllers() {
    emit(state.copyWith(capturedImages: []));
  }
}
