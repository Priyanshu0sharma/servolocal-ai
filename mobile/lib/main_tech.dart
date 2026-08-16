import 'package:flutter/material.dart';
import 'theme.dart';
import 'models/models.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'screens/technician_app_screen.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();
  await LanguageService.instance.init();
  runApp(const ServoLocalTechnicianApp());
}

class ServoLocalTechnicianApp extends StatelessWidget {
  const ServoLocalTechnicianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AuthService.instance, LanguageService.instance]),
      builder: (context, _) {
        final auth = AuthService.instance;
        return MaterialApp(
          title: 'ServoLocal Partner — Technician Service App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFD97706),
              primary: const Color(0xFFD97706),
              secondary: const Color(0xFF0F172A),
              surface: const Color(0xFFFDFBF7),
            ),
            scaffoldBackgroundColor: const Color(0xFFFDFBF7),
            fontFamily: 'Plus Jakarta Sans',
          ),
          home: !auth.isLoggedIn || !auth.isTechnician
              ? const DedicatedTechnicianLoginScreen()
              : const TechnicianDashboardScreen(),
        );
      },
    );
  }
}

class DedicatedTechnicianLoginScreen extends StatefulWidget {
  const DedicatedTechnicianLoginScreen({super.key});

  @override
  State<DedicatedTechnicianLoginScreen> createState() => _DedicatedTechnicianLoginScreenState();
}

class _DedicatedTechnicianLoginScreenState extends State<DedicatedTechnicianLoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: "98765 43210");
  final TextEditingController _otpController = TextEditingController(text: "1234");
  bool _isLoading = false;

  Future<void> _handleTechLogin() async {
    setState(() => _isLoading = true);
    final phone = _phoneController.text.replaceAll(' ', '').trim();
    final formattedPhone = phone.startsWith('+91') ? phone : "+91 $phone";
    await AuthService.instance.loginWithPhone(
      phone: formattedPhone,
      otp: _otpController.text.trim(),
      role: 'technician',
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber.withOpacity(0.6), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.amber, blurRadius: 20, offset: Offset(0, 6))],
                  ),
                  child: const Center(
                    child: Text("👨‍🔧", style: TextStyle(fontSize: 42)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "ServoLocal Partner",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Service Technician Partner Operations App",
                  style: TextStyle(color: Color(0xFFFBBF24), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDFBF7),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.build_circle_rounded, color: Color(0xFFD97706), size: 24),
                          SizedBox(width: 8),
                          Text("Partner Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text("Enter registered technician mobile to go online & accept emergency repair requests.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Registered Technician Mobile",
                          hintText: "98765 43210",
                          prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFD97706)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Enter 4-Digit OTP",
                          hintText: "1234",
                          prefixIcon: const Icon(Icons.verified_user, color: Color(0xFFD97706)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                          ),
                          onPressed: _isLoading ? null : _handleTechLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("LOGIN AS TECHNICIAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
