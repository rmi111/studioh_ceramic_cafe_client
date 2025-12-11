import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studioh_ceramic_cafe_client/model/user.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/firebase_collection_name.dart';
part 'auth_state.dart';
class AuthCubit extends Cubit<AuthState> {
  AuthCubit()
      : super(const AuthState(
          firebaseUser: null,
          currentUserModel: null,
          isLoading: false,
          message: '',
          allUsers: [],
          adminUsers: [],
          isLoggedIn: false,
        )) {
    _initAuthListener();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void _initAuthListener() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _handleAuthChanged(user);
      } else {
        emit(state.copyWith(
          firebaseUser: null,
          currentUserModel: null,
          isLoggedIn: false,
        ));
      }
    });
  }

  Future<void> _handleAuthChanged(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.USERS)
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final userModel = UserModel.fromMap(doc.data()!, user.uid);
        emit(state.copyWith(
          firebaseUser: user,
          currentUserModel: userModel,
          isLoggedIn: true,
        ));
      }
    } catch (e) {
      print("Firestore fetch failed: $e");
    }
  }

  /// ✅ Check login status from SharedPreferences on app startup
  Future<void> checkLoginStatus() async {
    print('🔍 Checking login status...');
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get saved login data
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final savedEmail = prefs.getString('email');
      final savedUid = prefs.getString('uid');
      final savedUserType = prefs.getString('userType');

      print(' SharedPreferences Data:');
      print('   isLoggedIn: $isLoggedIn');
      print('   email: $savedEmail');
      print('   uid: $savedUid');

      if (isLoggedIn && savedEmail != null && savedUid != null) {
        print('✅ User was previously logged in. Fetching user data...');

        // Fetch user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection(FirebaseCollectionName.USERS)
            .doc(savedUid)
            .get();

        if (userDoc.exists) {
          final userModel = UserModel.fromMap(userDoc.data()!, savedUid);

          print('✅ User data fetched: ${userModel.email}');

          emit(state.copyWith(
            currentUserModel: userModel,
            isLoggedIn: true,
            isLoading: false,
            userEmail: savedEmail,
            userType: savedUserType ?? 'customer',
          ));

          print('User is logged in. Ready for dashboard.');
        } else {
          print(' User document not found in Firestore. Clearing login data.');
          await clearLoginData();
          emit(state.copyWith(isLoading: false, isLoggedIn: false));
        }
      } else {
        print('❌ No previous login found. Show login screen.');
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

  /// ✅ Email login (no Firebase Auth needed)
  Future<void> loginWithEmail(String email) async {
    print(' Attempting email login for: $email');
    emit(state.copyWith(isLoading: true, message: ''));

    try {
      // Check if email exists in Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.USERS)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print('📊 Query result: ${querySnapshot.docs.length} documents found');

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final userData = doc.data();
        
        print('User data found: $userData');

        final uid = userData['uid'] ?? doc.id;
        final userType = userData['userType'] ?? 'customer';
        final name = userData['name'] ?? '';
        final phoneNumber = userData['phoneNumber'] ?? '';
        final imageUrl = userData['imageUrl'] ?? '';

        print('🔍 Extracted data:');
        print('   uid: $uid');
        print('   email: $email');
        print('   name: $name');
        print('   userType: $userType');

        // Create user model
        final userModel = UserModel(
          uid: uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
          imageUrl: imageUrl,
          userType: userType,
        );

        print('✅ UserModel created: ${userModel.email}');

        // Save to SharedPreferences
        await saveLoginData(email, userType, uid);
        print('✅ Saved to SharedPreferences');

        // Update state with new user data
        emit(state.copyWith(
          currentUserModel: userModel,
          firebaseUser: null, // We're not using Firebase Auth
          isLoggedIn: true,
          isLoading: false,
          message: '✅ Login Successful',
          userEmail: email,
          userType: userType,
        ));

        print('✅ State updated - currentUserModel: ${state.currentUserModel?.email}');
        print('✅ Login successful: $email (UID: $uid)');
      } else {
        print('❌ No user found with email: $email');
        emit(state.copyWith(
          isLoading: false,
          message: '❌ No account found with this email',
          currentUserModel: null,
          isLoggedIn: false,
        ));
      }
    } catch (e) {
      print('❌ Error during login: $e');
      print('Stack trace: $e');
      emit(state.copyWith(
        isLoading: false,
        message: '❌ Login failed: $e',
        currentUserModel: null,
        isLoggedIn: false,
      ));
    }
  }

  /// ✅ Save login data to SharedPreferences
  Future<void> saveLoginData(String email, String userType, String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('email', email);
      await prefs.setString('uid', uid);
      await prefs.setString('userType', userType);

      print('✅ Login data saved to SharedPreferences');
      print('   email: $email');
      print('   uid: $uid');
      print('   userType: $userType');
    } catch (e) {
      print('❌ Error saving login data: $e');
      throw Exception('Failed to save login data: $e');
    }
  }

  /// ✅ Clear login data from SharedPreferences
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

  /// ✅ Sign out
  Future<void> signOut() async {
    print('Signing out user...');
    emit(state.copyWith(isLoading: true));

    try {
      // Clear SharedPreferences
      print('Clearing SharedPreferences...');
      await clearLoginData();



      print('✅ Emitting logout state...');
      emit(const AuthState(
        firebaseUser: null,
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

  /// Fetch all users
  Future<void> fetchAllUsers() async {
    try {
      print('Fetching all users...');
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.USERS)
          .get();

      print('📊 Got ${snapshot.docs.length} documents');

      final users = snapshot.docs.map((doc) {
        try {
          return UserModel.fromMap(doc.data(), doc.id);
        } catch (e) {
          print(' Error parsing user ${doc.id}: $e');
          return null;
        }
      }).whereType<UserModel>().toList();

      emit(state.copyWith(allUsers: users));
      print("✅ Fetched ${users.length} users successfully.");
    } catch (e) {
      print("❌ Error fetching users: $e");
      emit(state.copyWith(
        allUsers: [],
        message: "Error fetching users: $e",
      ));
    }
  }

  /// Fetch admin users from all users
 Future<void> fetchAdminUsers() async {
    emit(state.copyWith(isLoading: true));
    try {
      print('🔍 Filtering admin users...');
     await fetchAllUsers();
      final admins = state.allUsers
          .where((user) => user.userType.toLowerCase() == 'admin')
          .toList();

      emit(state.copyWith(adminUsers: admins,isLoading: false));
      print("✅ Found ${admins.length} admin users.");

      for (var admin in admins) {
        print('   - ${admin.email} (${admin.uid})');
      }
    } catch (e) {
      print("❌ Error filtering admin users: $e");
      emit(state.copyWith(
        adminUsers: [],
        message: "Error filtering admins: $e",
      ));
    }
  }

  /// Fetch and set current user
  Future<void> fetchAndSetCurrentUser(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.USERS)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final user = UserModel.fromMap(doc.data()!, uid);
        emit(state.copyWith(currentUserModel: user));
        print("User fetched and set: ${user.email}");
      } else {
        print("No user found for UID: $uid");
      }
    } catch (e) {
      print("❌ Error fetching user: $e");
    }
  }
  Future<void> updateUserProfileInfo({
    required String name,
    required String phone,
    required BuildContext context,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final uid = state.currentUserModel?.uid;
      if (uid == null) {
        throw Exception('No user is currently logged in.');
      }

      print("Phone Number  ${phone}");
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.USERS)
          .doc(uid)
          .update({'name': name, 'phoneNumber': phone});

      await fetchAndSetCurrentUser(uid);
      emit(state.copyWith(isLoading: false));
      Navigator.pop(context);
      print("Profile updated successfully.");
    } catch (e) {
      emit(
        state.copyWith(message: "Error updating profile: $e", isLoading: false),
      );
      print("Error updating profile: $e");
    }
  }
}