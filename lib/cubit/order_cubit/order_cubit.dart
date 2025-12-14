import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';

import '../../model/orders.dart';
import '../../utils/constant/firebase_collection_name.dart';
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
 fetchOrders();
  }

  StreamSubscription? _ordersSubscription;
  final ImagePicker _imagePicker = ImagePicker();

  void _initializeListeners() {
    // Listen to auth state changes to reload orders when user logs in
    authCubit.stream.listen((authState) {
      if (authState.currentUserModel != null) {
        fetchOrders(isAdmin: false);
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

  /// Listen to orders collection for real-time updates
  void listenToOrders({bool isAdmin = false}) {
    final currentUser = authCubit.state.firebaseUser;
    if (currentUser == null) return;

    Query query = FirebaseFirestore.instance
        .collection(FirebaseCollectionName.ORDERS)
        .orderBy('orderDate', descending: true);

    if (!isAdmin) {
      query = query.where('customer', isEqualTo: currentUser.uid);
    }

    _ordersSubscription?.cancel();

    _ordersSubscription = query.snapshots().listen(
      (snapshot) {
        final List<OrderModel> fetchedOrders = snapshot.docs
            .map(
              (doc) => OrderModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList();

        _categorizeOrders(fetchedOrders);
      },
      onError: (error) {
        print(" Error listening to orders: $error");
      },
    );
  }

  /// Categorize orders by status
  void _categorizeOrders(List<OrderModel> fetchedOrders) {
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

  /// Generate unique order reference number
  Future<String> generateOrderRefNumber() async {
    try {
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.ORDERS)
          .orderBy('orderDate', descending: true)
          .get();

      if (ordersSnapshot.docs.isEmpty) {
        return 'cc0001';
      }

      int maxNumber = 0;
      for (var doc in ordersSnapshot.docs) {
        final ref = doc.data()['refNumber'] as String?;
        if (ref != null && ref.startsWith('cc')) {
          final numberPart = ref.substring(2);
          final num = int.tryParse(numberPart);
          if (num != null && num > maxNumber) {
            maxNumber = num;
          }
        }
      }

      final nextNumber = maxNumber + 1;
      return 'cc${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      print('Error generating ref number: $e');
      return 'cc0001';
    }
  }

  /// Add new order with user details
  Future<void> addOrder({
    required String refNumber,
    required String email,
    required String phone,
    String name = '',
    String description = '',
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      // Check if user exists
      final userSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.USERS)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Create user if doesn't exist
      if (userSnapshot.docs.isEmpty) {
        final docRef = FirebaseFirestore.instance
            .collection(FirebaseCollectionName.USERS)
            .doc();
        final customUid = docRef.id;
        await docRef.set({
          'uid': customUid,
          'email': email,
          'phoneNumber': phone,
          'userType': "customer",
          'imageUrl':
              "https://t4.ftcdn.net/jpg/03/64/21/11/240_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg",
          'name': name,
          'enrolledByClient': false,
        });
      }

      // Create order
      final orderDate = DateTime.now().millisecondsSinceEpoch;
      final docRef = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.ORDERS)
          .add({
            'refNumber': refNumber,
            'users': [
              {'email': email, 'phoneNumber': phone, 'name': name},
            ],
            'description': description,
            'orderDate': orderDate,
            'imgUrl': [],
            'status': 'ready_for_glaze',
          });

      // Clear inputs
      clearAllControllers();
      emit(state.copyWith(isLoading: false));

      // Refresh orders
      await fetchOrders(isAdmin: true);
    } catch (e) {
      print('Error adding order: $e');
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// Pick images from gallery or camera
  Future<void> pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage();
        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          final newImages = pickedFiles
              .map((xfile) => File(xfile.path))
              .toList();
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

  /// Update order with images
  Future<void> updateOrderImage({
    required String orderId,
    required List<String> previousImageUrls,
    String status = 'ready_for_glaze',
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      List<String> imageUrls = [];

      for (var img in state.capturedImages) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('order_images')
            .child(
              '${DateTime.now().millisecondsSinceEpoch}_${orderId}_${img.path.split('/').last}',
            );

        final uploadTask = await storageRef.putFile(img);
        if (uploadTask.state == TaskState.success) {
          final imageUrl = await storageRef.getDownloadURL();
          imageUrls.add(imageUrl);
        } else {
          emit(state.copyWith(isLoading: false));
          throw Exception('Image upload failed');
        }
      }

      final List<String> allUrls = [...previousImageUrls, ...imageUrls];

      // Update Firestore
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.ORDERS)
          .doc(orderId)
          .update({'imgUrl': allUrls, 'status': status});

      clearAllControllers();
      emit(state.copyWith(isLoading: false));

      await fetchOrders(isAdmin: true);
    } catch (e) {
      print('Error updating order images: $e');
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// Update order user list
  Future<void> updateOrderUserList({required OrderModel order}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final currentUser = authCubit.state.currentUserModel;

      if (currentUser == null) {
        emit(state.copyWith(isLoading: false));
        throw Exception('No logged-in user');
      }

      final userExists = order.users.any(
        (user) => user.email == currentUser.email,
      );

      if (userExists) {
        emit(state.copyWith(isLoading: false));
        throw Exception('User already part of this order');
      }

      // Update user list
      final updatedUserList = [
        ...order.users.map(
          (user) => {
            'email': user.email,
            'name': user.name,
            'phoneNumber': user.phoneNumber,
          },
        ),
        {
          'email': currentUser.email,
          'name': currentUser.name,
          'phoneNumber': currentUser.phoneNumber,
        },
      ];

      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.ORDERS)
          .doc(order.id)
          .update({'users': updatedUserList});

      clearAllControllers();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print('Error updating order user list: $e');
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// Fetch orders with real-time updates
  Future<void> fetchOrders({bool isAdmin = false}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final currentUser = authCubit.state.currentUserModel;
      if (currentUser == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      _ordersSubscription?.cancel();

      Query query = FirebaseFirestore.instance
          .collection(FirebaseCollectionName.ORDERS)
          .orderBy('orderDate', descending: true);

      _ordersSubscription = query.snapshots().listen(
        (snapshot) {
          List<OrderModel> fetchedOrders = snapshot.docs
              .map(
                (doc) => OrderModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          print("Total Orders Fetched: ${fetchedOrders.length}");

          // Filter for non-admin users
          if (!isAdmin) {
            final userEmail = currentUser.email;
            print("🔍 Filtering for user email: $userEmail");

            fetchedOrders = fetchedOrders
                .where(
                  (order) => order.users.any((user) => user.email == userEmail),
                )
                .toList();

            print(" Filtered Orders: ${fetchedOrders.length}");
          }
print("Fetched Orders: ${fetchedOrders.map((o) => o.refNumber).toList()}");
          _categorizeOrders(fetchedOrders);
          emit(state.copyWith(isLoading: false));
        },
        onError: (error) {
          print(" Error listening to orders: $error");
          emit(state.copyWith(isLoading: false));
        },
      );

      print(" Orders listener set up successfully. Length ${state.orders.length}");
    } catch (e) {
      print(" Error setting up orders listener: $e");
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Add or update user to existing order
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

      final userExists = order.users.any((user) => user.email == userEmail);

      if (userExists) {
        emit(state.copyWith(isLoading: false));
        AppSnackbar.showError(context, "You are already part of this order.");
        throw Exception('User already part of this order');
      }

      // Add user if doesn't exist in users collection
      final userSnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.USERS)
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        final docRef = FirebaseFirestore.instance
            .collection(FirebaseCollectionName.USERS)
            .doc();
        final customUid = docRef.id;
        await docRef.set({
          'uid': customUid,
          'email': userEmail,
          'phoneNumber': userPhone,
          'userType': "customer",
          'imageUrl':
              "https://t4.ftcdn.net/jpg/03/64/21/11/240_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg",
          'name': name,
          'enrolledByClient': false,
        });
      }

      // Update order user list
      final updatedUserList = [
        ...order.users.map(
          (user) => {
            'email': user.email,
            'name': user.name,
            'phoneNumber': user.phoneNumber,
          },
        ),
        {'email': userEmail, 'name': userName ?? '', 'phoneNumber': userPhone},
      ];

      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.ORDERS)
          .doc(order.id)
          .update({'users': updatedUserList});

      clearAllControllers();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      print('Error adding user to order: $e');
      emit(state.copyWith(isLoading: false));
      rethrow;
    }
  }

  /// Get order by reference number
  OrderModel? getOrderByRef(String refNumber) {
    try {
      return state.orders.firstWhere((order) => order.refNumber == refNumber);
    } catch (e) {
      return null;
    }
  }

  /// Filter orders by user email
  void fetchOrdersByUser(String userEmail) {
    final userOrders = state.orders
        .where((order) => order.users.any((user) => user.email == userEmail))
        .toList();
    print("User Orders Fetched: ${userOrders.length}");
    emit(state.copyWith(orders: userOrders));
  }

  /// Select tab
  void selectTab(int tabIndex) {
    print("Selecteding tab : ${tabIndex}");
    emit(state.copyWith(selectedTab: tabIndex));
  }

  /// Clear all controllers
  void clearAllControllers() {
    emit(state.copyWith(capturedImages: []));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
