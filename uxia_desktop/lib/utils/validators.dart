import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Servicio de validaciones
class Validators {
  static bool isValidEmail(String email) {
    final regex = RegExp(AppConstants.emailPattern);
    return regex.hasMatch(email);
  }

  static bool isValidUrl(String url) {
    final regex = RegExp(AppConstants.urlPattern);
    return regex.hasMatch(url);
  }

  static bool hasScheme(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static String addScheme(String url) {
    return hasScheme(url) ? url : 'http://$url';
  }

  static bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  static bool isValidPhone(String phone) {
    // Al menos 7 dígitos
    final onlyDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return onlyDigits.length >= 7;
  }

  static bool isEmpty(String value) => value.trim().isEmpty;

  static String? validateLoginFields({
    required String url,
    required String user,
    required String password,
  }) {
    if (isEmpty(url) || isEmpty(user) || isEmpty(password)) {
      return AppConstants.msgEmptyFields;
    }
    
    final urlToCheck = addScheme(url);
    if (!isValidUrl(urlToCheck)) {
      if (kDebugMode) print('URL validation failed: $urlToCheck');
      return AppConstants.msgInvalidUrl;
    }
    
    if (user.contains('@') && !isValidEmail(user)) {
      return AppConstants.msgInvalidEmail;
    }
    
    return null;
  }
}
