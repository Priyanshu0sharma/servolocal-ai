import 'package:flutter/material.dart';

class AppConfig {
  // Set this to your laptop's Wi-Fi / Hotspot IP address (e.g. 192.168.1.10)
  static String host = "10.0.2.2"; // Android emulator default; replace with laptop IP for physical phone

  static String get apiBaseUrl => "http://$host:8000";
  static String get wsBaseUrl => "ws://$host:8000";

  static void setHost(String newHost) {
    host = newHost;
  }
}

class AppTheme {
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color brown = Color(0xFF7B4B2A);
  static const Color creme = Color(0xFFF5EEE6);
  static const Color lightCream = Color(0xFFFFF8F1);
  static const Color mutedGreen = Color(0xFF4C6B5D);
  static const Color softBeige = Color(0xFFFBF6EF);

  static const Color textPrimary = Color(0xFF1C2520);
  static const Color textSecondary = Color(0xFF5D6D64);

  static ThemeData get themeData {
    return ThemeData(
      primaryColor: darkGreen,
      scaffoldBackgroundColor: softBeige,
      colorScheme: const ColorScheme.light(
        primary: darkGreen,
        secondary: brown,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkGreen),
        titleTextStyle: TextStyle(
          color: darkGreen,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
