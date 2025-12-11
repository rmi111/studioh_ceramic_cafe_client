part of 'auth_cubit.dart';

class AuthState {
  final User? firebaseUser;
  final UserModel? currentUserModel;
  final bool isLoading;
  final bool isObscure;
  final bool isLogin;
  final bool isRememberMe;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isLoggedIn;
  final String message;
  final String userEmail;
  final String userType;
  final List<UserModel> allUsers;
  final List<UserModel> adminUsers;

  const AuthState({
    this.firebaseUser,
    this.currentUserModel,
    this.isLoading = false,
    this.isObscure = true,
    this.isLogin = true,
    this.isRememberMe = false,
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.isLoggedIn = false, // ✅ NEW
    this.message = '',
    this.userEmail = '', // ✅ NEW
    this.userType = '', // ✅ NEW
    this.allUsers = const [],
    this.adminUsers = const [],
  });

  AuthState copyWith({
    User? firebaseUser,
    UserModel? currentUserModel,
    bool? isLoading,
    bool? isObscure,
    bool? isLogin,
    bool? isRememberMe,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isLoggedIn,
    String? message,
    String? userEmail,
    String? userType,
    List<UserModel>? allUsers,
    List<UserModel>? adminUsers,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      currentUserModel: currentUserModel ?? this.currentUserModel,
      isLoading: isLoading ?? this.isLoading,
      isObscure: isObscure ?? this.isObscure,
      isLogin: isLogin ?? this.isLogin,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      message: message ?? this.message,
      userEmail: userEmail ?? this.userEmail,
      userType: userType ?? this.userType,
      allUsers: allUsers ?? this.allUsers,
      adminUsers: adminUsers ?? this.adminUsers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          firebaseUser == other.firebaseUser &&
          currentUserModel == other.currentUserModel &&
          isLoading == other.isLoading &&
          isObscure == other.isObscure &&
          isLogin == other.isLogin &&
          isRememberMe == other.isRememberMe &&
          isEmailValid == other.isEmailValid &&
          isPasswordValid == other.isPasswordValid &&
          isLoggedIn == other.isLoggedIn &&
          message == other.message &&
          userEmail == other.userEmail &&
          userType == other.userType &&
          allUsers == other.allUsers &&
          adminUsers == other.adminUsers;

  @override
  int get hashCode =>
      firebaseUser.hashCode ^
      currentUserModel.hashCode ^
      isLoading.hashCode ^
      isObscure.hashCode ^
      isLogin.hashCode ^
      isRememberMe.hashCode ^
      isEmailValid.hashCode ^
      isPasswordValid.hashCode ^
      isLoggedIn.hashCode ^
      message.hashCode ^
      userEmail.hashCode ^
      userType.hashCode ^
      allUsers.hashCode ^
      adminUsers.hashCode;
}