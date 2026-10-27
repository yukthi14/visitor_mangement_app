import '../constants/app_constants.dart';

class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Visitor name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(trimmed)) {
      return 'Mobile number must be exactly 10 digits';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
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
