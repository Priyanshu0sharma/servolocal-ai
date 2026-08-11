import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 'user' or 'technician'
  String _selectedRole = 'user';
  // 'phone' or 'email'
  String _authMethod = 'phone';

  final TextEditingController _phoneController = TextEditingController(text: "98765 12345");
  final TextEditingController _otpController = TextEditingController(text: "1234");
  final TextEditingController _emailController = TextEditingController(text: "user@test.com");
  final TextEditingController _passwordController = TextEditingController(text: "123456");

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(String role) {
    setState(() {
      _selectedRole = role;
      if (role == 'technician') {
        _phoneController.text = "98765 43210";
        _emailController.text = "tech@test.com";
      } else {
        _phoneController.text = "98765 12345";
        _emailController.text = "user@test.com";
      }
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool success = false;
      if (_authMethod == 'phone') {
        final phone = _phoneController.text.replaceAll(' ', '').trim();
        final formattedPhone = phone.startsWith('+91') ? phone : "+91 $phone";
        success = await AuthService.instance.loginWithPhone(
          phone: formattedPhone,
          otp: _otpController.text.trim(),
          role: _selectedRole,
        );
      } else {
        success = await AuthService.instance.loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole,
        );
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _selectedRole == 'technician' ? AppTheme.brown : AppTheme.darkGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text("Welcome, ${AuthService.instance.currentUser?.name ?? 'User'}!"),
                ],
              ),
            ),
          );
          widget.onLoginSuccess();
        }
      } else {
        setState(() {
          _errorMessage = "Login failed. Please check credentials or try Instant Demo.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred during sign in.";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _quickDemoLogin(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedRole = role;
    });
    try {
      await AuthService.instance.quickDemoLogin(role);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: role == 'technician' ? AppTheme.brown : AppTheme.darkGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Text("Logged in: ${role == 'technician' ? 'Rahul Kumar (Staff)' : 'Priyanshu (Customer)'}"),
              ],
            ),
          ),
        );
        widget.onLoginSuccess();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showLanguageDialog() {
    final lang = LanguageService.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate_rounded, color: AppTheme.darkGreen, size: 24),
                const SizedBox(width: 10),
                Text(
                  lang.tr('change_language'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.darkGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              title: "English",
              subtitle: "Clean English UI",
              selected: lang.currentLanguage == AppLanguage.english,
              onTap: () {
                lang.setLanguage(AppLanguage.english);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _buildLanguageOption(
              title: "हिंदी (Hindi)",
              subtitle: "शुद्ध हिंदी इंटरफ़ेस",
              selected: lang.currentLanguage == AppLanguage.hindi,
              onTap: () {
                lang.setLanguage(AppLanguage.hindi);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _buildLanguageOption(
              title: "Hinglish",
              subtitle: "Conversational Hindi + English",
              selected: lang.currentLanguage == AppLanguage.hinglish,
              onTap: () {
                lang.setLanguage(AppLanguage.hinglish);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.creme : AppTheme.softBeige,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.brown : Colors.black.withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGreen)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppTheme.brown, size: 20)
            else
              const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showServerSettingsDialog() {
    final controller = TextEditingController(text: AppConfig.host);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.dns_rounded, color: AppTheme.darkGreen, size: 22),
            SizedBox(width: 8),
            Text("Backend Server IP", style: TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your laptop's local Wi-Fi / Hotspot IP (e.g. 192.168.1.10) to connect backend on physical device:",
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "10.0.2.2 or 192.168.x.x",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppTheme.softBeige,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              AppConfig.setHost(controller.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Backend configured: ${AppConfig.apiBaseUrl}")),
              );
            },
            child: const Text("Save & Connect", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final lang = LanguageService.instance;
        final isStaff = _selectedRole == 'technician';

        return Scaffold(
          backgroundColor: AppTheme.softBeige,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ================= TOP HERO BRANDING =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.darkGreen, Color(0xFF0D2218)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Top Bar with Live Indicator & Language Switcher & Settings
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                children: [
                                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF4ADE80)),
                                  SizedBox(width: 6),
                                  Text("AETHERION AI", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // Language Switcher Button
                                InkWell(
                                  onTap: _showLanguageDialog,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.translate, color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          lang.languageName.split(' ').first,
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                                  tooltip: "Backend Server Config",
                                  onPressed: _showServerSettingsDialog,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // App Logo Badge
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE0A96D), AppTheme.brown],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text("⚡", style: TextStyle(fontSize: 30)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "AETHERION",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang.tr('login_sub'),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= TWO MAIN ROLE PORTAL CARDS (USER vs STAFF) =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.tr('select_portal'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            // 1. USER / CUSTOMER PORTAL CARD
                            Expanded(
                              child: InkWell(
                                onTap: () => _onRoleChanged('user'),
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: !isStaff ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: !isStaff ? AppTheme.darkGreen : Colors.black.withValues(alpha: 0.08),
                                      width: !isStaff ? 2.2 : 1,
                                    ),
                                    boxShadow: !isStaff
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.darkGreen.withValues(alpha: 0.12),
                                              blurRadius: 14,
                                              offset: const Offset(0, 6),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: !isStaff ? AppTheme.darkGreen : AppTheme.softBeige,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: !isStaff ? Colors.white : AppTheme.darkGreen,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        lang.tr('user_customer'),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.darkGreen,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: !isStaff ? AppTheme.darkGreen.withValues(alpha: 0.1) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          !isStaff ? "✓ ${lang.tr('active_portal')}" : lang.tr('tap_to_switch'),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: !isStaff ? AppTheme.darkGreen : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // 2. STAFF / TECHNICIAN PORTAL CARD
                            Expanded(
                              child: InkWell(
                                onTap: () => _onRoleChanged('technician'),
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isStaff ? Colors.white : Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isStaff ? AppTheme.brown : Colors.black.withValues(alpha: 0.08),
                                      width: isStaff ? 2.2 : 1,
                                    ),
                                    boxShadow: isStaff
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.brown.withValues(alpha: 0.15),
                                              blurRadius: 14,
                                              offset: const Offset(0, 6),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isStaff ? AppTheme.brown : AppTheme.softBeige,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.engineering_rounded,
                                          color: isStaff ? Colors.white : AppTheme.brown,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        lang.tr('staff_tech'),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.brown,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isStaff ? AppTheme.brown.withValues(alpha: 0.1) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          isStaff ? "✓ ${lang.tr('active_portal')}" : lang.tr('tap_to_switch'),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isStaff ? AppTheme.brown : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ================= LOGIN FORM CARD =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: (isStaff ? AppTheme.brown : AppTheme.darkGreen).withValues(alpha: 0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header & Method Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isStaff ? Icons.badge_outlined : Icons.account_circle_outlined,
                                    color: isStaff ? AppTheme.brown : AppTheme.darkGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isStaff ? lang.tr('staff_login_title') : lang.tr('user_login_title'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: isStaff ? AppTheme.brown : AppTheme.darkGreen,
                                    ),
                                  ),
                                ],
                              ),
                              // Phone / Email Toggle
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.softBeige,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    _buildMethodPill(
                                      label: "OTP",
                                      icon: Icons.phone_android,
                                      selected: _authMethod == 'phone',
                                      themeColor: isStaff ? AppTheme.brown : AppTheme.darkGreen,
                                      onTap: () => setState(() => _authMethod = 'phone'),
                                    ),
                                    _buildMethodPill(
                                      label: "Email",
                                      icon: Icons.email_outlined,
                                      selected: _authMethod == 'email',
                                      themeColor: isStaff ? AppTheme.brown : AppTheme.darkGreen,
                                      onTap: () => setState(() => _authMethod = 'email'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),

                          // --- Phone + OTP Fields ---
                          if (_authMethod == 'phone') ...[
                            Text(lang.tr('phone_number'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.softBeige,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text("🇮🇳 +91", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGreen)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                      decoration: const InputDecoration(
                                        hintText: "Enter 10-digit number",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(lang.tr('otp_code'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                                InkWell(
                                  onTap: () {
                                    setState(() => _otpController.text = "1234");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Demo OTP '1234' auto-filled!"), duration: Duration(seconds: 1)),
                                    );
                                  },
                                  child: Text(
                                    lang.tr('auto_fill_otp'),
                                    style: TextStyle(fontSize: 11, color: isStaff ? AppTheme.brown : AppTheme.darkGreen, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                letterSpacing: 10,
                                fontWeight: FontWeight.w900,
                                color: isStaff ? AppTheme.brown : AppTheme.darkGreen,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: AppTheme.softBeige,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: isStaff ? AppTheme.brown : AppTheme.darkGreen, width: 1.5),
                                ),
                              ),
                            ),
                          ] else ...[
                            // --- Email + Password Fields ---
                            Text(lang.tr('email_address'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined, color: isStaff ? AppTheme.brown : AppTheme.darkGreen, size: 20),
                                filled: true,
                                fillColor: AppTheme.softBeige,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            Text(lang.tr('password'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline, color: isStaff ? AppTheme.brown : AppTheme.darkGreen, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: AppTheme.softBeige,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Sign In Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isStaff ? AppTheme.brown : AppTheme.darkGreen,
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isStaff ? lang.tr('login_btn_staff') : lang.tr('login_btn_user'),
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ================= 1-TAP INSTANT ACCESS DEMO ACCOUNTS =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.bolt, color: Colors.amber, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              lang.tr('direct_access'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // User Card
                        _buildDemoAccountCard(
                          name: "Priyanshu Sharma",
                          roleLabel: lang.tr('user_customer'),
                          subtitle: "👤 Customer App • AI Diagnosis • Repairs",
                          avatarUrl: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
                          badgeColor: AppTheme.darkGreen,
                          enterLabel: lang.tr('enter'),
                          onTap: () => _quickDemoLogin('user'),
                        ),
                        const SizedBox(height: 10),

                        // Staff Card
                        _buildDemoAccountCard(
                          name: "Rahul Kumar",
                          roleLabel: lang.tr('staff_tech'),
                          subtitle: "🛠️ Staff Hub • Voice Status • Earnings",
                          avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
                          badgeColor: AppTheme.brown,
                          enterLabel: lang.tr('enter'),
                          onTap: () => _quickDemoLogin('technician'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMethodPill({
    required String label,
    required IconData icon,
    required bool selected,
    required Color themeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? themeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoAccountCard({
    required String name,
    required String roleLabel,
    required String subtitle,
    required String avatarUrl,
    required Color badgeColor,
    required String enterLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: badgeColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          roleLabel,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(enterLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
