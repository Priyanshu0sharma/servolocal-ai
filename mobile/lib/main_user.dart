import 'package:flutter/material.dart';
import 'screens/user_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ServoLocalUserApp());
}

class ServoLocalUserApp extends StatelessWidget {
  const ServoLocalUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SERVOLOCAL AI — User App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF064E3B),
          primary: const Color(0xFF064E3B),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const ServoLocal18StepUserApp(),
    );
  }
}
