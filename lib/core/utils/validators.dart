import '../constants/app_constants.dart';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorNameRequired;
    }
    if (value.trim().length < 2) {
      return AppConstants.errorNameMinLength;
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorMobileRequired;
    }
    final trimmed = value.trim();
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return AppConstants.errorMobileDigitsOnly;
    }
    if (trimmed.length != 10) {
      return AppConstants.errorMobileTenDigits;
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return AppConstants.errorInvalidEmail;
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorEnterUsername;
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEnterPassword;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return AppConstants.errorPasswordUppercase;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return AppConstants.errorPasswordNumber;
    }
    if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value)) {
      return AppConstants.errorPasswordSpecialChar;
    }
    return null;
  }
}
