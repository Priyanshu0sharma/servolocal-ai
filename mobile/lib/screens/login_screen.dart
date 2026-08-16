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
              backgroundColor: _selectedRole == 'technician' ? Colors.green.shade800 : AppTheme.darkGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text("Welcome back, ${AuthService.instance.currentUser?.name ?? 'User'}!"),
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
            backgroundColor: role == 'technician' ? Colors.green.shade800 : AppTheme.darkGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Text("Instant Logged in as: ${role == 'technician' ? 'Rahul Kumar (Staff)' : 'Priyanshu (Customer)'}"),
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
    final isTech = _selectedRole == 'technician';
    showModalBottomSheet(
      context: context,
      backgroundColor: isTech ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.translate_rounded, color: isTech ? Colors.greenAccent : AppTheme.darkGreen, size: 24),
                const SizedBox(width: 10),
                Text(
                  lang.tr('change_language'),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isTech ? Colors.white : AppTheme.darkGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLanguageOption("English", "Clean English UI", lang.currentLanguage == AppLanguage.english, () {
              lang.setLanguage(AppLanguage.english);
              Navigator.pop(ctx);
            }, isTech),
            const SizedBox(height: 10),
            _buildLanguageOption("हिंदी (Hindi)", "शुद्ध हिंदी इंटरफ़ेस", lang.currentLanguage == AppLanguage.hindi, () {
              lang.setLanguage(AppLanguage.hindi);
              Navigator.pop(ctx);
            }, isTech),
            const SizedBox(height: 10),
            _buildLanguageOption("Hinglish", "Conversational Hindi + English", lang.currentLanguage == AppLanguage.hinglish, () {
              lang.setLanguage(AppLanguage.hinglish);
              Navigator.pop(ctx);
            }, isTech),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String subtitle, bool selected, VoidCallback onTap, bool isTech) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? (isTech ? Colors.green.shade900.withValues(alpha: 0.4) : AppTheme.creme) : (isTech ? const Color(0xFF0F172A) : AppTheme.softBeige),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? (isTech ? Colors.greenAccent : AppTheme.brown) : Colors.black.withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isTech ? Colors.white : AppTheme.darkGreen)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: isTech ? Colors.white70 : AppTheme.textSecondary)),
              ],
            ),
            if (selected)
              Icon(Icons.check_circle, color: isTech ? Colors.greenAccent : AppTheme.brown, size: 20)
            else
              const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _showServerSettingsDialog() {
    final controller = TextEditingController(text: AppConfig.host);
    final isTech = _selectedRole == 'technician';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isTech ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.dns_rounded, color: isTech ? Colors.greenAccent : AppTheme.darkGreen, size: 22),
            const SizedBox(width: 8),
            Text("Backend Server IP", style: TextStyle(color: isTech ? Colors.white : AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter your laptop's local IP (e.g. 192.168.1.10):",
              style: TextStyle(fontSize: 12, color: isTech ? Colors.white70 : AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: TextStyle(color: isTech ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "10.0.2.2 or 192.168.x.x",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: isTech ? const Color(0xFF0F172A) : AppTheme.softBeige,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isTech ? Colors.green.shade700 : AppTheme.darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
    final lang = LanguageService.instance;
    final isTech = _selectedRole == 'technician';

    // Theme tokens based on selected role
    final bgColor = isTech ? const Color(0xFF0B131F) : const Color(0xFFF9F7F2);
    final cardBg = isTech ? const Color(0xFF16202E) : Colors.white;
    final textColor = isTech ? Colors.white : const Color(0xFF1B4332);
    final subTextColor = isTech ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryBtnColor = isTech ? const Color(0xFF22C55E) : const Color(0xFF063726);
    final inputBg = isTech ? const Color(0xFF1E293B) : const Color(0xFFF8FAF9);
    final inputBorder = isTech ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ================= TOP BAR (LANGUAGE & SERVER CONFIG) =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  // Language Switcher Dropdown Badge
                  InkWell(
                    onTap: _showLanguageDialog,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isTech ? Colors.white24 : Colors.black12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.language_rounded, size: 16, color: isTech ? Colors.greenAccent : AppTheme.darkGreen),
                          const SizedBox(width: 6),
                          Text(
                            lang.languageName,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: subTextColor),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.dns_outlined, color: isTech ? Colors.white70 : AppTheme.darkGreen, size: 22),
                    tooltip: "Backend IP",
                    onPressed: _showServerSettingsDialog,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ================= LOGO & BRANDING HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isTech ? Colors.black : const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                      border: Border.all(color: isTech ? Colors.greenAccent : AppTheme.darkGreen, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        isTech ? "⚙️" : "🛡️",
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "SERVOLOCAL ",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 1),
                          ),
                          Text(
                            "AI",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isTech ? Colors.greenAccent : Colors.green.shade700, letterSpacing: 1),
                          ),
                        ],
                      ),
                      Text(
                        "Smart Repair. Instant Help.",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subTextColor),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================= WELCOME TITLE =================
              Text(
                isTech ? "Welcome Back,\nTechnician! 👨‍🔧" : "Welcome Back!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, height: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                isTech
                    ? "Login to accept jobs and help businesses keep running."
                    : "Login to continue and get your machines back to work.",
                style: TextStyle(fontSize: 12, color: subTextColor, height: 1.3),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // ================= ROLE SEGMENTED SWITCHER =================
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isTech ? const Color(0xFF1E293B) : const Color(0xFFEFECE6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _onRoleChanged('user'),
                        borderRadius: BorderRadius.circular(26),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isTech ? const Color(0xFF063726) : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: !isTech ? [const BoxShadow(color: Colors.black26, blurRadius: 6)] : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline_rounded, size: 18, color: !isTech ? Colors.white : subTextColor),
                              const SizedBox(width: 6),
                              Text("User Login", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: !isTech ? Colors.white : subTextColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _onRoleChanged('technician'),
                        borderRadius: BorderRadius.circular(26),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isTech ? const Color(0xFF0F172A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(26),
                            border: isTech ? Border.all(color: Colors.greenAccent, width: 1.5) : null,
                            boxShadow: isTech ? [const BoxShadow(color: Colors.black45, blurRadius: 6)] : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.engineering_outlined, size: 18, color: isTech ? Colors.greenAccent : subTextColor),
                              const SizedBox(width: 6),
                              Text("Technician Login", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isTech ? Colors.greenAccent : subTextColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= FORM INPUTS =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: inputBorder),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isTech ? 0.2 : 0.04), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Column(
                  children: [
                    // MOBILE INPUT
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined, color: subTextColor, size: 20),
                        suffixText: "+91",
                        suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        hintText: "Mobile Number",
                        hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.6), fontSize: 14),
                        filled: true,
                        fillColor: inputBg,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: inputBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryBtnColor, width: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PASSWORD INPUT
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: subTextColor, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: subTextColor, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.6), fontSize: 14),
                        filled: true,
                        fillColor: inputBg,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: inputBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryBtnColor, width: 1.5)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isTech ? Colors.greenAccent : AppTheme.darkGreen),
                        ),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],

                    const SizedBox(height: 14),

                    // MAIN LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBtnColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                        ),
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Login", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                                  SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.white24,
                                    child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // FAST 1-TAP DEMO BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isTech ? Colors.amber : AppTheme.brown, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: const Icon(Icons.bolt, color: Colors.amber, size: 18),
                        label: Text(
                          isTech ? "1-TAP FAST DEMO (STAFF / RAHUL)" : "1-TAP FAST DEMO (USER / PRIYANSHU)",
                          style: TextStyle(color: isTech ? Colors.amber : AppTheme.brown, fontWeight: FontWeight.w900, fontSize: 11),
                        ),
                        onPressed: () => _quickDemoLogin(_selectedRole),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // OR CONTINUE WITH DIVIDER
              Row(
                children: [
                  Expanded(child: Divider(color: subTextColor.withValues(alpha: 0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("or continue with", style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: subTextColor.withValues(alpha: 0.2))),
                ],
              ),

              const SizedBox(height: 16),

              // GOOGLE & EMAIL BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: inputBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: cardBg,
                      ),
                      icon: const Text("G", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                      label: Text("Google", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                      onPressed: () => _quickDemoLogin(_selectedRole),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: inputBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: cardBg,
                      ),
                      icon: Icon(Icons.email_outlined, size: 16, color: textColor),
                      label: Text("Email", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ================= FEATURE TRUST BADGES GRID (BOTTOM) =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isTech ? const Color(0xFF131C28) : const Color(0xFFF1EEE8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: isTech
                      ? [
                          _buildBadge("⚙️", "More Jobs", "Verified requests", isTech),
                          _buildBadge("📍", "Smart Match", "Skill & GPS", isTech),
                          _buildBadge("👛", "Payouts", "Fast earnings", isTech),
                          _buildBadge("📈", "Ratings", "Grow profile", isTech),
                        ]
                      : [
                          _buildBadge("🛡️", "Verified Tech", "Background checked", isTech),
                          _buildBadge("⏱️", "Instant Help", "Nearby dispatch", isTech),
                          _buildBadge("₹", "Transparent", "AI estimated cost", isTech),
                          _buildBadge("📋", "Digital Proof", "Photos & invoice", isTech),
                        ],
                ),
              ),

              const SizedBox(height: 24),

              // FOOTER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isTech ? "New Technician? " : "New here? ", style: TextStyle(fontSize: 13, color: subTextColor)),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      isTech ? "Register Now →" : "Create an Account →",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isTech ? Colors.greenAccent : AppTheme.darkGreen),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String icon, String title, String subtitle, bool isTech) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isTech ? Colors.white : AppTheme.darkGreen), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: TextStyle(fontSize: 8, color: isTech ? Colors.white60 : AppTheme.textSecondary), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
