import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studioh_ceramic_cafe_client/model/user.dart';
import 'package:studioh_ceramic_cafe_client/services/api_service.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit()
      : super(const AuthState(
          currentUserModel: null,
          isLoading: false,
          message: '',
          allUsers: [],
          adminUsers: [],
          isLoggedIn: false,
        ));

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check login status using stored API token
  Future<void> checkLoginStatus() async {
    print('🔍 Checking login status...');
    emit(state.copyWith(isLoading: true));

    try {
      final hasToken = await ApiService.hasToken();

      if (hasToken) {
        print('✅ Token found. Fetching user data from API...');

        try {
          final response = await ApiService.me();
          final data = response.data;
          final innerData = data['data'] ?? data;
          final userData = innerData['user'] ?? innerData;
          final userModel = UserModel.fromJson(userData);

          // Save to SharedPreferences for quick access
          await saveLoginData(
              userModel.email, userModel.userType, userModel.id.toString());

          emit(state.copyWith(
            currentUserModel: userModel,
            isLoggedIn: true,
            isLoading: false,
            userEmail: userModel.email,
            userType: userModel.userType,
          ));

          print('✅ User is logged in: ${userModel.email}');

          // Register FCM token after successful auth check
          _registerFcmToken();
        } catch (e) {
          print('❌ Token invalid or expired: $e');
          await ApiService.clearToken();
          await clearLoginData();
          emit(state.copyWith(isLoading: false, isLoggedIn: false));
        }
      } else {
        print('❌ No token found. Show login screen.');
        emit(state.copyWith(isLoading: false, isLoggedIn: false));
      }
    } catch (e) {
      print('❌ Error checking login status: $e');
      emit(state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        message: 'Error checking login status: $e',
      ));
    }
  }

  /// Check first login and show welcome dialog
  Future<void> checkFirstLoginAndShowWelcome(
      BuildContext context, int userId) async {
    print('📋 Checking first login for user: $userId');

    try {
      final currentUser = state.currentUserModel;
      if (currentUser == null) return;

      if (!currentUser.enrolledByClient) {
        print('✅ First login detected! Showing welcome...');

        // Show welcome local notification
        try {
          await _flutterLocalNotificationsPlugin.show(
            0,
            'Thanks for downloading the Studioh! App 🎉',
            'Please message us if you need assistance',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'default_channel',
                'General',
                channelDescription: 'General notifications',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(sound: 'default'),
            ),
          );
          print('✅ Welcome notification shown');
        } catch (e) {
          print('❌ Error showing notification: $e');
        }

        // Show welcome dialog
        try {
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Welcome 🎉"),
                  content: const Text(
                    "Thanks for joining our app! We're glad to have you on board.",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Continue"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                );
              },
              barrierDismissible: false,
            );
            print('✅ Welcome dialog shown');
          }
        } catch (e) {
          print('❌ Error showing dialog: $e');
        }

        // Update enrolled flag via API
        try {
          await ApiService.updateUser(
              userId, {'enrolled_by_client': true});
          print('✅ Updated enrolledByClient flag');
        } catch (e) {
          print('❌ Error updating flag: $e');
        }
      } else {
        print('ℹ️ User already enrolled, skipping welcome');
      }
    } catch (e) {
      print('❌ Error checking first login: $e');
    }
  }

  /// Email-only login (no password required for customers)
  Future<void> loginWithEmail(String email) async {
    print('📧 Attempting email login for: $email');
    emit(state.copyWith(isLoading: true, message: ''));

    try {
      final response = await ApiService.loginEmail(email: email);
      final data = response.data;

      // Extract token and user from API response
      final responseData = data['data'] ?? data;
      final token = responseData['token'] ?? responseData['access_token'];
      final userData = responseData['user'] ?? responseData['data'] ?? responseData;

      if (token == null || userData == null) {
        emit(state.copyWith(
          isLoading: false,
          message: '❌ Invalid response from server',
          isLoggedIn: false,
        ));
        return;
      }

      // Save token securely
      await ApiService.saveToken(token);

      // Parse user model
      final userModel = UserModel.fromJson(userData);

      // Save to SharedPreferences
      await saveLoginData(
          email, userModel.userType, userModel.id.toString());

      emit(state.copyWith(
        currentUserModel: userModel,
        isLoggedIn: true,
        isLoading: false,
        message: '✅ Login Successful',
        userEmail: email,
        userType: userModel.userType,
      ));

      // Register FCM token
      _registerFcmToken();

      print('✅ Login successful: $email');
    } on Exception catch (e) {
      print('❌ Error during login: $e');
      String errorMessage = 'Login failed';

      // Try to extract API error message
      try {
        final dioError = e as dynamic;
        if (dioError.response?.data != null) {
          errorMessage = dioError.response.data['message'] ??
              'No account found with this email';
        }
      } catch (_) {}

      emit(state.copyWith(
        isLoading: false,
        message: '❌ $errorMessage',
        currentUserModel: null,
        isLoggedIn: false,
        clearUser: true,
      ));
    }
  }

  /// Register new user via API
  Future<void> onRegistration({
    required BuildContext context,
    required String email,
    required String name,
    required String phone,
    String imageUrl =
        "https://t4.ftcdn.net/jpg/03/64/21/11/240_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg",
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await ApiService.register(
        email: email,
        name: name,
        phoneNumber: phone,
        password: email, // Use email as default password for email-only auth
      );

      final data = response.data;
      final token = data['token'] ?? data['access_token'];
      final userData = data['user'] ?? data['data'];

      if (token != null) {
        await ApiService.saveToken(token);
      }

      final userModel = userData != null
          ? UserModel.fromJson(userData)
          : UserModel(
              email: email,
              name: name,
              phoneNumber: phone,
              imageUrl: imageUrl,
              userType: "customer",
            );

      await saveLoginData(
          email, "customer", userModel.id.toString());

      emit(state.copyWith(
        currentUserModel: userModel,
        isLoading: false,
        userEmail: email,
        userType: "customer",
        isLoggedIn: true,
      ));

      // Register FCM token
      _registerFcmToken();

      print("✅ Registration successful: $email");
    } on Exception catch (e) {
      emit(state.copyWith(isLoading: false));

      String errorMessage = 'Registration failed';
      try {
        final dioError = e as dynamic;
        if (dioError.response?.data != null) {
          errorMessage =
              dioError.response.data['message'] ?? 'User already exists';
        }
      } catch (_) {}

      if (context.mounted) {
        AppSnackbar.showError(context, errorMessage);
      }
      print("❌ Error registering user: $e");
    }
  }

  /// Save login data to SharedPreferences
  Future<void> saveLoginData(
      String email, String userType, String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
      await prefs.setString('uid', uid);
      await prefs.setString('userType', userType);
      print('✅ Login data saved to SharedPreferences');
    } catch (e) {
      print('❌ Error saving login data: $e');
    }
  }

  /// Clear login data from SharedPreferences
  Future<void> clearLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('email');
      await prefs.remove('uid');
      await prefs.remove('userType');
      print('✅ Login data cleared from SharedPreferences');
    } catch (e) {
      print('❌ Error clearing login data: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    print('🚪 Signing out user...');
    emit(state.copyWith(isLoading: true));

    try {
      // Call API logout (invalidates server-side token)
      try {
        await ApiService.logout();
      } catch (_) {
        // Proceed with local cleanup even if API call fails
      }

      // Clear stored token
      await ApiService.clearToken();

      // Clear SharedPreferences
      await clearLoginData();

      emit(const AuthState(
        currentUserModel: null,
        isLoading: false,
        message: 'Successfully logged out',
        allUsers: [],
        adminUsers: [],
        isLoggedIn: false,
      ));

      print('✅ Successfully logged out');
    } catch (e) {
      print('❌ Error during logout: $e');
      emit(state.copyWith(
        isLoading: false,
        message: 'Error during logout: $e',
        isLoggedIn: false,
      ));
    }
  }

  /// Toggle password visibility
  void toggleObscure() {
    emit(state.copyWith(isObscure: !state.isObscure));
  }

  /// Toggle login/signup mode
  void toggleLogin() {
    emit(state.copyWith(isLogin: !state.isLogin));
  }

  /// Toggle remember me
  void toggleRememberMe() {
    emit(state.copyWith(isRememberMe: !state.isRememberMe));
  }

  /// Set email validity
  void setEmailValid(bool value) {
    emit(state.copyWith(isEmailValid: value));
  }

  /// Set password validity
  void setPasswordValid(bool value) {
    emit(state.copyWith(isPasswordValid: value));
  }

  /// Set current user data
  void setCurrentUserData(UserModel user) {
    emit(state.copyWith(currentUserModel: user));
  }

  /// Fetch all users from API
  Future<void> fetchAllUsers() async {
    try {
      print('📋 Fetching all users...');
      final response = await ApiService.listUsers(perPage: 100);
      final data = response.data;

      final usersData = data['data'] ?? data;
      List<UserModel> users = [];

      if (usersData is List) {
        users = usersData
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();
      }

      emit(state.copyWith(allUsers: users));
      print("✅ Fetched ${users.length} users.");
    } catch (e) {
      print("❌ Error fetching users: $e");
      emit(state.copyWith(
        allUsers: [],
        message: "Error fetching users: $e",
      ));
    }
  }

  /// Fetch admin users
  Future<void> fetchAdminUsers() async {
    emit(state.copyWith(isLoading: true));
    try {
      print('🔍 Fetching admin users...');
      final response = await ApiService.listUsers(type: 'admin', perPage: 100);
      final data = response.data;

      final usersData = data['data'] ?? data;
      List<UserModel> admins = [];

      if (usersData is List) {
        admins = usersData
            .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
            .toList();
      }

      emit(state.copyWith(adminUsers: admins, isLoading: false));
      print("✅ Found ${admins.length} admin users.");
    } catch (e) {
      print("❌ Error fetching admin users: $e");
      emit(state.copyWith(
        adminUsers: [],
        message: "Error fetching admins: $e",
        isLoading: false,
      ));
    }
  }

  /// Fetch and set current user from API
  Future<void> fetchAndSetCurrentUser(String uid) async {
    try {
      final response = await ApiService.me();
      final data = response.data;
      final userData = data['data'] ?? data['user'] ?? data;
      final user = UserModel.fromJson(userData);
      emit(state.copyWith(currentUserModel: user));
      print("✅ User fetched and set: ${user.email}");
    } catch (e) {
      print("❌ Error fetching user: $e");
    }
  }

  /// Update user profile via API
  Future<void> updateUserProfileInfo({
    required BuildContext context,
    required String name,
    required String phone,
    File? imageFile,
  }) async {
    emit(state.copyWith(isLoading: true));

    try {
      final currentUser = state.currentUserModel;
      if (currentUser == null) {
        emit(state.copyWith(isLoading: false));
        AppSnackbar.showError(context, 'No user logged in');
        return;
      }

      String? imageUrl = currentUser.imageUrl;

      // Upload image via API if a new image is selected
      if (imageFile != null) {
        print('📤 Uploading profile image...');
        final uploadResponse = await ApiService.uploadImage(
          imageFile,
          folder: 'profile_images',
        );
        final uploadData = uploadResponse.data;
        imageUrl = uploadData['url'] ?? uploadData['data']?['url'] ?? imageUrl;
        print('✅ Image uploaded: $imageUrl');
      }

      // Update user via API
      await ApiService.updateUser(currentUser.id, {
        'name': name,
        'phone_number': phone,
        if (imageUrl != null) 'image_url': imageUrl,
      });

      // Create updated user model
      final updatedUser = UserModel(
        id: currentUser.id,
        uid: currentUser.uid,
        email: currentUser.email,
        name: name,
        phoneNumber: phone,
        imageUrl: imageUrl,
        userType: currentUser.userType,
        isSubscriber: currentUser.isSubscriber,
        enrolledByClient: currentUser.enrolledByClient,
      );

      emit(state.copyWith(
        currentUserModel: updatedUser,
        isLoading: false,
      ));

      print('✅ Profile updated successfully!');
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      print('❌ Error updating profile: $e');
      if (context.mounted) {
        AppSnackbar.showError(context, 'Failed to update profile: $e');
      }
    }
  }

  /// Register FCM token with Laravel backend
  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await ApiService.registerDevice(
          fcmToken: fcmToken,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
        print('✅ FCM token registered');
      }
    } catch (e) {
      print('⚠️ FCM registration failed: $e');
    }
  }
}