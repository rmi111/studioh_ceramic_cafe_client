import 'package:flutter/material.dart';

import '../../utils/widget/snacke_bar.dart';

/// Centralized form validation utility class
class FormValidator {
  // Private constructor to prevent instantiation
  FormValidator._();

  // Email validation regex
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // Phone validation regex
  static final RegExp _phoneRegex = RegExp(r'^[0-9]+$');

  /// Validates email format
  /// Returns true if valid, false otherwise
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  /// Validates phone number
  /// Returns true if valid (7-15 digits), false otherwise
  static bool isValidPhone(String phone) {
    return phone.length >= 7 &&
        phone.length <= 15 &&
        _phoneRegex.hasMatch(phone);
  }

  /// Validates password strength
  /// Must be at least 8 characters with uppercase, lowercase, number, and special char
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  /// Simple password validation (minimum 6 characters)
  static bool isValidPasswordSimple(String password) {
    return password.length >= 6;
  }

  /// Validates name (not empty and contains only letters and spaces)
  static bool isValidName(String name) {
    return name.isNotEmpty &&
        name.length >= 2 &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  /// Checks if field is not empty
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  // ==================== VALIDATION WITH SNACKBAR ====================

  /// Validates email and shows snackbar if invalid
  /// Returns true if valid
  static bool validateEmail(BuildContext context, String email, {String? customMessage}) {
    if (email.isEmpty) {
      AppSnackbar.show(context, 'Email is required.');
      return false;
    }

    if (!isValidEmail(email)) {
      AppSnackbar.show(context, customMessage ?? 'Please enter a valid email address.');
      return false;
    }

    return true;
  }

  /// Validates phone and shows snackbar if invalid
  /// Returns true if valid
  static bool validatePhone(BuildContext context, String phone, {String? customMessage}) {
    if (phone.isEmpty) {
      AppSnackbar.show(context, 'Phone number is required.');
      return false;
    }

    if (!isValidPhone(phone)) {
      AppSnackbar.show(context, customMessage ?? 'Please enter a valid phone number (7-15 digits).');
      return false;
    }

    return true;
  }

  /// Validates password and shows snackbar if invalid
  /// Returns true if valid
  static bool validatePassword(BuildContext context, String password, {
    bool useStrongValidation = false,
    String? customMessage,
  }) {
    if (password.isEmpty) {
      AppSnackbar.show(context, 'Password is required.');
      return false;
    }

    // if (useStrongValidation) {
    //   if (!isValidPassword(password)) {
    //     AppSnackbar.show(
    //       context,
    //       customMessage ?? 'Password must be at least 8 characters with uppercase, lowercase, number, and special character.',
    //     );
    //     return false;
    //   }
    // } else {
    //   if (!isValidPasswordSimple(password)) {
    //     AppSnackbar.show(context, customMessage ?? 'Password must be at least 6 characters.');
    //     return false;
    //   }
    // }

    return true;
  }

  /// Validates name and shows snackbar if invalid
  /// Returns true if valid
  static bool validateName(BuildContext context, String name, {String? customMessage}) {
    if (name.isEmpty) {
      AppSnackbar.show(context, 'Name is required.');
      return false;
    }

    if (!isValidName(name)) {
      AppSnackbar.show(context, customMessage ?? 'Please enter a valid name (letters only, min 2 characters).');
      return false;
    }

    return true;
  }

  /// Validates required field and shows snackbar if empty
  /// Returns true if valid
  static bool validateRequired(BuildContext context, String value, String fieldName) {
    if (!isNotEmpty(value)) {
      AppSnackbar.show(context, '$fieldName is required.');
      return false;
    }
    return true;
  }

  /// Validates password confirmation match
  /// Returns true if passwords match
  static bool validatePasswordMatch(BuildContext context, String password, String confirmPassword) {
    if (password != confirmPassword) {
      AppSnackbar.show(context, 'Passwords do not match.');
      return false;
    }
    return true;
  }

  // ==================== BULK VALIDATION ====================

  /// Validates registration form (name, email, phone, password)
  /// Returns true if all fields are valid
  static bool validateRegistration(
      BuildContext context, {
        required String name,
        required String email,
        required String phone,
        required String password,
        String? confirmPassword,
        bool useStrongPassword = false,
      }) {
    if (!validateName(context, name)) return false;
    if (!validateEmail(context, email)) return false;
    if (!validatePhone(context, phone)) return false;
    if (!validatePassword(context, password, useStrongValidation: useStrongPassword)) return false;

    if (confirmPassword != null) {
      if (!validatePasswordMatch(context, password, confirmPassword)) return false;
    }

    return true;
  }
  static bool validateUpdateProfile(
      BuildContext context, {
        required String name,
        required String email,
        required String phone,
      }) {
    if (!validateName(context, name)) return false;
    if (!validateEmail(context, email)) return false;
    if (!validatePhone(context, phone)) return false;

    return true;
  }
  /// Validates login form (email, password)
  /// Returns true if all fields are valid
  static bool validateLogin(
      BuildContext context, {
        required String email,
        required String password,
      }) {
    if (!validateEmail(context, email)) return false;
    if (!validateRequired(context, password, 'Password')) return false;

    return true;
  }

  /// Validates phone login form (phone, password)
  /// Returns true if all fields are valid
  static bool validatePhoneLogin(
      BuildContext context, {
        required String phone,
        required String password,
      }) {
    if (!validatePhone(context, phone)) return false;
    if (!validateRequired(context, password, 'Password')) return false;

    return true;
  }


  /// Get email error message without showing snackbar
  /// Returns null if valid
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email is required.';
    if (!isValidEmail(email)) return 'Please enter a valid email address.';
    return null;
  }

  /// Get phone error message without showing snackbar
  /// Returns null if valid
  static String? getPhoneError(String phone) {
    if (phone.isEmpty) return 'Phone number is required.';
    if (!isValidPhone(phone)) return 'Please enter a valid phone number (7-15 digits).';
    return null;
  }

  /// Get password error message without showing snackbar
  /// Returns null if valid
  static String? getPasswordError(String password, {bool useStrongValidation = false}) {
    if (password.isEmpty) return 'Password is required.';

    if (useStrongValidation) {
      if (!isValidPassword(password)) {
        return 'Password must be at least 8 characters with uppercase, lowercase, number, and special character.';
      }
    } else {
      if (!isValidPasswordSimple(password)) {
        return 'Password must be at least 6 characters.';
      }
    }

    return null;
  }

  /// Get name error message without showing snackbar
  /// Returns null if valid
  static String? getNameError(String name) {
    if (name.isEmpty) return 'Name is required.';
    if (!isValidName(name)) return 'Please enter a valid name (letters only, min 2 characters).';
    return null;
  }
}