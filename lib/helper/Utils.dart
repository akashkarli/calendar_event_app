import 'package:flutter/widgets.dart';

class CustomColor {
  static const Color dark_blue = Color(0xFF05008b);
  static const Color dark_cyan = Color(0xFF025ab5);
  static const Color sea_blue = Color(0xFF106db6);
  static const Color neon_green = Color(0xFF51ca98);
}




String? validateTitle(String value) {
  if (value != null) {
    value = value.trim();
    if (value.isEmpty) {
      return 'Title can\'t be empty';
    }
  } else {
    return 'Title can\'t be empty';
  }

  return null;
}

String? validateEmail(String value) {
  if (value != null) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Can\'t add an empty email';
    } else {
      final regex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return null;
        }
      }
    }
  } else {
    return 'Can\'t add an empty email';
  }

  return 'Invalid email';
}