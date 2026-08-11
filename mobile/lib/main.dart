import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'theme.dart';
import 'models/models.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/language_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();
  await LanguageService.instance.init();
  runApp(const AetherionApp());
}

class AetherionApp extends StatelessWidget {
  const AetherionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AuthService.instance, LanguageService.instance]),
      builder: (context, _) {
        final auth = AuthService.instance;
        return MaterialApp(
          title: 'AETHERION',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: !auth.isLoggedIn
              ? LoginScreen(onLoginSuccess: () {})
              : (auth.isTechnician
                  ? const TechnicianDashboardScreen()
                  : const MainNavigationHub()),
        );
      },
    );
  }
}

// Global Helper to Show Language Switcher Modal Bottom Sheet
void showAppLanguageSelector(BuildContext context) {
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
          _buildLanguageTile(
            ctx: ctx,
            title: "English",
            subtitle: "Clean English UI",
            selected: lang.currentLanguage == AppLanguage.english,
            onTap: () {
              lang.setLanguage(AppLanguage.english);
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 10),
          _buildLanguageTile(
            ctx: ctx,
            title: "हिंदी (Hindi)",
            subtitle: "शुद्ध हिंदी इंटरफ़ेस",
            selected: lang.currentLanguage == AppLanguage.hindi,
            onTap: () {
              lang.setLanguage(AppLanguage.hindi);
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 10),
          _buildLanguageTile(
            ctx: ctx,
            title: "Hinglish",
            subtitle: "Conversational Hindi + English",
            selected: lang.currentLanguage == AppLanguage.hinglish,
            onTap: () {
              lang.setLanguage(AppLanguage.hinglish);
              Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Widget _buildLanguageTile({
  required BuildContext ctx,
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

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final screens = [
      UserHomeScreen(
        onSwitchToTech: () => AuthService.instance.switchRole('technician'),
        onOpenWorkflow: () => setState(() => _currentIndex = 1),
      ),
      const HowAetherionWorksScreen(),
      const UserBookingsScreen(),
      UserProfileScreen(
        onSwitchToTech: () => AuthService.instance.switchRole('technician'),
        onOpenWorkflow: () => setState(() => _currentIndex = 1),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          selectedItemColor: AppTheme.darkGreen,
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: lang.tr('nav_home')),
            BottomNavigationBarItem(icon: const Icon(Icons.account_tree_outlined), label: lang.tr('nav_how_it_works')),
            BottomNavigationBarItem(icon: const Icon(Icons.bookmark_outline), label: lang.tr('nav_bookings')),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: lang.tr('nav_profile')),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// SCREEN 1: USER HOME SCREEN
// =========================================================================
class UserHomeScreen extends StatefulWidget {
  final VoidCallback onSwitchToTech;
  final VoidCallback onOpenWorkflow;
  const UserHomeScreen({super.key, required this.onSwitchToTech, required this.onOpenWorkflow});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  JobModel? _activeJob;

  @override
  void initState() {
    super.initState();
    _loadActiveJob();
  }

  Future<void> _loadActiveJob() async {
    final job = await ApiService.getActiveJob(1);
    if (mounted) {
      setState(() {
        _activeJob = job;
      });
    }
  }

  void _showServerSettingsDialog() {
    final controller = TextEditingController(text: AppConfig.host);
    final lang = LanguageService.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lang.tr('server_ip'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter laptop's local IP (e.g. 192.168.1.10) to connect backend on physical device:", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "e.g. 192.168.1.10",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppTheme.softBeige,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkGreen),
            onPressed: () {
              AppConfig.setHost(controller.text.trim());
              Navigator.pop(ctx);
              _loadActiveJob();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Connected to: ${AppConfig.apiBaseUrl}")),
              );
            },
            child: Text(lang.tr('save_connect'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? 'Priyanshu';

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${lang.tr('greeting_hello')}, $userName 👋", style: const TextStyle(color: AppTheme.darkGreen, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(lang.tr('how_can_help'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
        actions: [
          // Language Switcher in App Bar
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.creme,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.brown.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate, color: AppTheme.brown, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    lang.languageCode.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.brown),
                  ),
                ],
              ),
            ),
            tooltip: lang.tr('change_language'),
            onPressed: () => showAppLanguageSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.wifi_tethering, color: AppTheme.darkGreen),
            tooltip: "Server IP Config",
            onPressed: _showServerSettingsDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadActiveJob,
        color: AppTheme.darkGreen,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Report a Problem Card (Main Action)
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AIDiagnosisScreen()));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBF4EB), Color(0xFFF3E7D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.brown.withValues(alpha: 0.25)),
                  boxShadow: [
                    BoxShadow(color: AppTheme.brown.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFE0A96D), AppTheme.brown]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppTheme.brown.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Center(
                        child: Text("📷", style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang.tr('report_problem'), style: const TextStyle(color: AppTheme.darkGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(lang.tr('report_problem_sub'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.2)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.brown),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Interactive "HOW AETHERION WORKS" Feature Banner
            InkWell(
              onTap: widget.onOpenWorkflow,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppTheme.darkGreen.withValues(alpha: 0.2), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text("⚙️", style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(lang.tr('how_aetherion_works_card'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFE0A96D), borderRadius: BorderRadius.circular(6)),
                                child: const Text("8 STEPS", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF1B4332))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(lang.tr('how_aetherion_works_sub'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Active Service Card
            if (_activeJob != null && !['COMPLETED', 'PAID', 'CANCELLED'].contains(_activeJob!.status)) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(color: AppTheme.darkGreen.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(lang.tr('active_service'), style: const TextStyle(color: AppTheme.darkGreen, fontSize: 15, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(
                                _activeJob!.status.replaceAll('_', ' '),
                                style: const TextStyle(color: AppTheme.darkGreen, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(_activeJob!.technicianAvatar ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_activeJob!.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                              const SizedBox(height: 2),
                              Text("Technician: ${_activeJob!.technicianName ?? 'Rahul Kumar'}", style: const TextStyle(color: AppTheme.mutedGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                              Text("${_activeJob!.technicianDistance ?? 2.4} km away", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => LiveTrackingScreen(job: _activeJob!)));
                        },
                        icon: const Icon(Icons.navigation_outlined, size: 16, color: Colors.white),
                        label: Text(lang.tr('track_live'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Recent Services Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.tr('recent_services'), style: const TextStyle(color: AppTheme.darkGreen, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(lang.tr('view_all'), style: const TextStyle(color: AppTheme.brown, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            _buildHistoryItem("❄️", "AC Repair", lang.tr('completed'), "₹1,450", "12 May 2024"),
            const SizedBox(height: 10),
            _buildHistoryItem("⚡", "Motor Repair", lang.tr('completed'), "₹900", "05 May 2024"),

            const SizedBox(height: 24),
            // Switch to Technician Portal Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.brown.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.tr('are_you_technician'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkGreen)),
                      Text(lang.tr('switch_to_tech'), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brown,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: widget.onSwitchToTech,
                    child: Text(lang.tr('tech_view_btn'), style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String icon, String title, String status, String price, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.creme,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(status, style: const TextStyle(color: AppTheme.mutedGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.w800, fontSize: 14)),
              const SizedBox(height: 2),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// SCREEN 2: HOW AETHERION WORKS (Exact 8-step flow, 1-line diagram & USP)
// =========================================================================
class HowAetherionWorksScreen extends StatelessWidget {
  const HowAetherionWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    final steps = [
      {
        'num': '1',
        'icon': '📷',
        'title': lang.tr('step_1_title'),
        'desc': lang.tr('step_1_desc'),
        'tag': 'App Capture & Location',
      },
      {
        'num': '2',
        'icon': '🤖',
        'title': lang.tr('step_2_title'),
        'desc': lang.tr('step_2_desc'),
        'tag': 'Neural Vision & Cost Engine',
      },
      {
        'num': '3',
        'icon': '📍',
        'title': lang.tr('step_3_title'),
        'desc': lang.tr('step_3_desc'),
        'tag': 'Geo-Proximity Algorithm',
      },
      {
        'num': '4',
        'icon': '📲',
        'title': lang.tr('step_4_title'),
        'desc': lang.tr('step_4_desc'),
        'tag': 'Real-Time Dispatch Feed',
      },
      {
        'num': '5',
        'icon': '🛵',
        'title': lang.tr('step_5_title'),
        'desc': lang.tr('step_5_desc'),
        'tag': 'Live Status & Route GPS',
      },
      {
        'num': '6',
        'icon': '🔧',
        'title': lang.tr('step_6_title'),
        'desc': lang.tr('step_6_desc'),
        'tag': 'Arrived → Inspection → Repair',
      },
      {
        'num': '7',
        'icon': '📸',
        'title': lang.tr('step_7_title'),
        'desc': lang.tr('step_7_desc'),
        'tag': 'Before/After Verified Proof',
      },
      {
        'num': '8',
        'icon': '💳',
        'title': lang.tr('step_8_title'),
        'desc': lang.tr('step_8_desc'),
        'tag': 'Instant UPI & Star Rating',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        title: Text(lang.tr('nav_how_it_works'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.darkGreen)),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: AppTheme.brown),
            tooltip: lang.tr('change_language'),
            onPressed: () => showAppLanguageSelector(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.darkGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.darkGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("⚡", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    lang.tr('how_works_title'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.darkGreen,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            lang.tr('how_works_subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),

          // ================= ONE-LINE FLOW DIAGRAM CARD =================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.darkGreen, Color(0xFF0F2B1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppTheme.darkGreen.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded, color: Color(0xFFE0A96D), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      lang.tr('one_line_flow_title'),
                      style: const TextStyle(
                        color: Color(0xFFE0A96D),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    lang.tr('one_line_flow_content'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ================= MAIN USP QUOTE CARD =================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.brown.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(color: AppTheme.brown.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.brown,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lang.tr('main_usp_title'),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text("💡", style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lang.tr('main_usp_quote'),
                  style: const TextStyle(
                    color: AppTheme.darkGreen,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ================= 8 DETAILED WORKFLOW STEPS =================
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final s = entry.value;
            final isLast = idx == steps.length - 1;

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Number Badge
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.darkGreen, AppTheme.mutedGreen]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(s['icon']!, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    s['title']!,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.darkGreen),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s['desc']!,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.softBeige,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.brown.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                "⚡ ${s['tag']}",
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.brown),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward_rounded, color: AppTheme.brown, size: 20),
                      ],
                    ),
                  ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // Primary Button to test AI Diagnosis
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AIDiagnosisScreen()));
              },
              icon: const Icon(Icons.bolt, color: Colors.amber),
              label: Text(
                lang.tr('run_ai_btn'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// =========================================================================
// SCREEN 3: AI DIAGNOSIS SCREEN (With Photo/Video Upload & Sample Presets)
// =========================================================================
class AIDiagnosisScreen extends StatefulWidget {
  const AIDiagnosisScreen({super.key});

  @override
  State<AIDiagnosisScreen> createState() => _AIDiagnosisScreenState();
}

class _AIDiagnosisScreenState extends State<AIDiagnosisScreen> {
  final TextEditingController _descController = TextEditingController(
    text: "AC cooling nahi kar raha aur outdoor unit se unusual sound aa rahi hai.",
  );
  XFile? _selectedMedia;
  String? _sampleImageUrl;
  DiagnosisResult? _diagnosis;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedMedia = picked;
          _sampleImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error selecting image: $e")),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _selectedMedia = picked;
          _sampleImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error selecting video: $e")),
        );
      }
    }
  }

  void _selectSamplePreset(String desc, String imageUrl) {
    setState(() {
      _descController.text = desc;
      _sampleImageUrl = imageUrl;
      _selectedMedia = null;
    });
  }

  Future<void> _runDiagnosis() async {
    setState(() => _isLoading = true);
    final res = await ApiService.runDiagnosis(
      _descController.text,
      imagePath: _selectedMedia?.path,
    );
    setState(() {
      _diagnosis = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        title: Text(lang.tr('ai_diagnosis_title'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: AppTheme.brown),
            tooltip: lang.tr('change_language'),
            onPressed: () => showAppLanguageSelector(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Problem Input Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.tr('describe_problem'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.darkGreen.withValues(alpha: 0.2))),
                    filled: true,
                    fillColor: AppTheme.softBeige,
                    hintText: lang.tr('describe_hint'),
                  ),
                ),
                const SizedBox(height: 14),

                // ================= PHOTO & VIDEO UPLOAD SECTION =================
                Text(lang.tr('upload_media_title'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen, fontSize: 13)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.darkGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 18, color: AppTheme.darkGreen),
                        label: Text(lang.tr('take_photo'), style: const TextStyle(color: AppTheme.darkGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.brown),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.photo_library_rounded, size: 18, color: AppTheme.brown),
                        label: Text(lang.tr('choose_gallery'), style: const TextStyle(color: AppTheme.brown, fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.videocam_outlined, size: 18, color: AppTheme.textSecondary),
                    label: Text(lang.tr('record_video'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                    onPressed: _pickVideo,
                  ),
                ),

                // Selected Image Thumbnail Preview
                if (_selectedMedia != null || _sampleImageUrl != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.creme,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.brown.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _selectedMedia != null
                              ? Image.file(File(_selectedMedia!.path), width: 54, height: 54, fit: BoxFit.cover)
                              : Image.network(_sampleImageUrl!, width: 54, height: 54, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.tr('media_attached'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.darkGreen)),
                              Text(
                                _selectedMedia != null ? _selectedMedia!.name : "Sample appliance diagnostic photo",
                                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                          onPressed: () => setState(() {
                            _selectedMedia = null;
                            _sampleImageUrl = null;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Preset Appliance Samples
                Text(lang.tr('sample_photos'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _presetChip(
                      "❄️ AC Outdoor Unit",
                      "AC cooling nahi kar raha aur outdoor unit se unusual sound aa rahi hai.",
                      "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400",
                    ),
                    _presetChip(
                      "🧊 Fridge Defrost Coils",
                      "Refrigerator defrost nahi ho raha, baraf jam gayi hai aur cooling kam hai.",
                      "https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=400",
                    ),
                    _presetChip(
                      "🧺 Washing Machine Belt",
                      "Washing machine drum spin nahi kar raha aur aawaz aa rahi hai.",
                      "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=400",
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Run AI Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _runDiagnosis,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              const SizedBox(width: 10),
                              Text(lang.tr('analyzing_ai'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : Text(lang.tr('run_ai_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),

          if (_diagnosis != null) ...[
            const SizedBox(height: 16),
            // Detected Issue Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.tr('detected_issue'), style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text("${_diagnosis!.icon} ${_diagnosis!.detectedIssue}", style: const TextStyle(color: AppTheme.darkGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang.tr('confidence'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      Text("${_diagnosis!.confidence}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _diagnosis!.confidence / 100,
                    backgroundColor: Colors.grey[200],
                    color: AppTheme.brown,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang.tr('severity'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(_diagnosis!.severity, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Possible Causes
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.tr('possible_causes'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ..._diagnosis!.possibleCauses.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ", style: TextStyle(color: AppTheme.brown, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(c, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3))),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Required Parts
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.tr('required_parts'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _diagnosis!.requiredParts.map((p) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.creme,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.brown.withValues(alpha: 0.2)),
                      ),
                      child: Text(p, style: const TextStyle(color: AppTheme.brown, fontSize: 11, fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Estimated Cost Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.creme,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.brown.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.tr('estimated_cost'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text("₹${_diagnosis!.rangeMin.toInt()} – ₹${_diagnosis!.rangeMax.toInt()}", style: const TextStyle(color: AppTheme.darkGreen, fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(lang.tr('no_hidden_charges'), style: const TextStyle(color: AppTheme.mutedGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TechMatchingScreen(diagnosis: _diagnosis!, description: _descController.text)));
                },
                child: Text(lang.tr('find_technician_btn'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _presetChip(String label, String fullDesc, String imgUrl) {
    return ActionChip(
      backgroundColor: AppTheme.creme,
      label: Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.brown, fontWeight: FontWeight.bold)),
      onPressed: () => _selectSamplePreset(fullDesc, imgUrl),
    );
  }
}

// =========================================================================
// SCREEN 4: TECHNICIANS NEARBY
// =========================================================================
class TechMatchingScreen extends StatefulWidget {
  final DiagnosisResult diagnosis;
  final String description;
  const TechMatchingScreen({super.key, required this.diagnosis, required this.description});

  @override
  State<TechMatchingScreen> createState() => _TechMatchingScreenState();
}

class _TechMatchingScreenState extends State<TechMatchingScreen> {
  List<TechnicianModel> _technicians = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTechnicians();
  }

  Future<void> _fetchTechnicians() async {
    final list = await ApiService.getNearbyTechnicians(widget.diagnosis.category);
    setState(() {
      _technicians = list;
      _isLoading = false;
    });
  }

  Future<void> _selectTechnician(TechnicianModel tech) async {
    final job = await ApiService.createJob(
      userId: 1,
      technicianId: tech.id,
      diag: widget.diagnosis,
      description: widget.description,
    );
    if (job != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LiveTrackingScreen(job: job)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        title: Text(lang.tr('tech_nearby_title'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.darkGreen))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _technicians.length,
              itemBuilder: (context, idx) {
                final t = _technicians[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(t.avatar.isNotEmpty ? t.avatar : "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text("⭐ ", style: TextStyle(fontSize: 11)),
                                Text("${t.rating}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                                Text(" (${t.reviewsCount})", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            Text("📍 ${t.distanceKm} ${lang.tr('km_away')}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(t.speciality, style: const TextStyle(color: AppTheme.mutedGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                            Text("₹${t.visitCharge.toInt()} ${lang.tr('visit_charge')}", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brown,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          elevation: 0,
                        ),
                        onPressed: () => _selectTechnician(t),
                        child: Text(lang.tr('select_tech_btn'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// =========================================================================
// SCREEN 5: LIVE TRACKING
// =========================================================================
class LiveTrackingScreen extends StatefulWidget {
  final JobModel job;
  const LiveTrackingScreen({super.key, required this.job});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  late JobModel _job;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        title: Text(lang.tr('live_tracking_title'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Tech Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 22, backgroundImage: NetworkImage(_job.technicianAvatar ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150")),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_job.technicianName ?? "Rahul Kumar", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(_job.status.replaceAll('_', ' '), style: const TextStyle(color: AppTheme.mutedGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                Text("${_job.technicianDistance ?? 2.4} ${lang.tr('km_away')}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mock Map Box with animated route
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE8ECE9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.darkGreen.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("🗺️", style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 4),
                      Text(lang.tr('mock_gps'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen, fontSize: 13)),
                      const Text("Route: 2.4 km • Vaishali Nagar", style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 30,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppTheme.brown, shape: BoxShape.circle),
                    child: const Text("🛵", style: TextStyle(fontSize: 16)),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppTheme.darkGreen, shape: BoxShape.circle),
                    child: const Text("🏠", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Timeline Tracker
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
            child: Column(
              children: [
                _buildStep(lang.tr('status_accepted'), "10:15 AM", true),
                _buildStep(lang.tr('status_on_the_way'), "10:18 AM", _job.status != 'ACCEPTED'),
                _buildStep(lang.tr('status_arrived'), "10:25 AM", ['ARRIVED', 'REPAIRING', 'COMPLETED', 'PAID'].contains(_job.status)),
                _buildStep(lang.tr('status_repairing'), "-", ['REPAIRING', 'COMPLETED', 'PAID'].contains(_job.status)),
                _buildStep(lang.tr('status_completed'), "-", ['COMPLETED', 'PAID'].contains(_job.status)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Proceed to Payment & Proof Button
          if (['COMPLETED', 'PAID', 'REPAIRING'].contains(_job.status))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentProofScreen(job: _job)));
                  },
                  child: Text(lang.tr('view_proof_pay'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brown,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () {},
              child: Text(lang.tr('call_tech'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String name, String time, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked, color: isDone ? AppTheme.darkGreen : Colors.grey[300], size: 20),
              const SizedBox(width: 12),
              Text(name, style: TextStyle(fontWeight: isDone ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
            ],
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}

// =========================================================================
// SCREEN 6: PAYMENT & PROOF SCREEN
// =========================================================================
class PaymentProofScreen extends StatefulWidget {
  final JobModel job;
  const PaymentProofScreen({super.key, required this.job});

  @override
  State<PaymentProofScreen> createState() => _PaymentProofScreenState();
}

class _PaymentProofScreenState extends State<PaymentProofScreen> {
  String _selectedMethod = 'UPI';
  bool _isProcessing = false;

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    final res = await ApiService.processPayment(widget.job.id, _selectedMethod, widget.job.finalAmount);
    setState(() => _isProcessing = false);

    if (res != null && res['success'] == true && mounted) {
      _showFeedbackModal(res['transaction_id'] ?? "TXN-DEMO-48291");
    }
  }

  void _showFeedbackModal(String txnId) {
    double selectedRating = 5;
    final commentController = TextEditingController(text: "Fast and transparent service.");
    final lang = LanguageService.instance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("✅", style: TextStyle(fontSize: 42)),
              const SizedBox(height: 6),
              Text(lang.tr('pay_success'), style: const TextStyle(color: AppTheme.darkGreen, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("${lang.tr('txn_id')}: $txnId", style: const TextStyle(color: AppTheme.brown, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 10),

              Text(lang.tr('rate_experience'), style: const TextStyle(color: AppTheme.darkGreen, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (idx) {
                  return IconButton(
                    icon: Icon(idx < selectedRating ? Icons.star : Icons.star_border, color: const Color(0xFFD97706), size: 32),
                    onPressed: () => setModalState(() => selectedRating = idx + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: lang.tr('leave_feedback'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppTheme.softBeige,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brown,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await ApiService.submitFeedback(widget.job.id, selectedRating, commentController.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(lang.tr('submit_feedback'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        title: Text(lang.tr('payment_proof_title'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Bill Breakdown
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.tr('repair_summary'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                _buildBillRow(lang.tr('labour'), "₹${widget.job.labourCost.toInt()}"),
                _buildBillRow(lang.tr('parts'), "₹${widget.job.partsCost.toInt()}"),
                _buildBillRow(lang.tr('service_charge'), "₹${widget.job.serviceCharge.toInt()}"),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang.tr('total_amount'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.w800, fontSize: 15)),
                    Text("₹${widget.job.finalAmount.toInt()}", style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.w900, fontSize: 17)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Digital Repair Proof
          Text(lang.tr('repair_proof'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildProofCard(lang.tr('before'), widget.job.beforeImage ?? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400")),
              const SizedBox(width: 12),
              Expanded(child: _buildProofCard(lang.tr('after'), widget.job.afterImage ?? "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400")),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Method Selector
          Text(lang.tr('payment_method'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildPaymentOption("UPI", "📱 UPI")),
              const SizedBox(width: 8),
              Expanded(child: _buildPaymentOption("CARD", "💳 Card")),
              const SizedBox(width: 8),
              Expanded(child: _buildPaymentOption("CASH", "💵 Cash")),
            ],
          ),
          const SizedBox(height: 24),

          // Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _isProcessing ? null : _handlePayment,
              child: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("${lang.tr('pay_now')} ₹${widget.job.finalAmount.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProofCard(String title, String imgUrl) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.06))),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imgUrl, height: 90, width: double.infinity, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, String label) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightCream : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.brown : Colors.black.withValues(alpha: 0.08), width: isSelected ? 1.5 : 1),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: isSelected ? AppTheme.brown : AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}

// =========================================================================
// SCREEN 7: TECHNICIAN DASHBOARD
// =========================================================================
class TechnicianDashboardScreen extends StatefulWidget {
  final VoidCallback? onSwitchToUser;
  const TechnicianDashboardScreen({super.key, this.onSwitchToUser});

  @override
  State<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  bool _isOnline = true;

  void _confirmLogout() {
    final lang = LanguageService.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lang.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
        content: const Text("Are you sure you want to sign out from Technician mode?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(ctx);
              AuthService.instance.logout();
            },
            child: Text(lang.tr('logout'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final user = AuthService.instance.currentUser;
    final techName = user?.name ?? "Rahul Kumar";
    final techAvatar = user?.avatar ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150";

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(techAvatar)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(techName, style: const TextStyle(color: AppTheme.darkGreen, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  Text(lang.tr('staff_tech'), style: const TextStyle(color: AppTheme.brown, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: AppTheme.brown),
            tooltip: lang.tr('change_language'),
            onPressed: () => showAppLanguageSelector(context),
          ),
          Row(
            children: [
              Text(_isOnline ? "ONLINE" : "OFFLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _isOnline ? Colors.green : Colors.grey)),
              Switch(
                value: _isOnline,
                activeTrackColor: Colors.green.withValues(alpha: 0.5),
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() => _isOnline = val),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                tooltip: lang.tr('logout'),
                onPressed: _confirmLogout,
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 2x2 Stats
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildTechStat(lang.tr('todays_jobs'), "4"),
              _buildTechStat(lang.tr('pending'), "2"),
              _buildTechStat(lang.tr('today_earnings'), "₹2,850"),
              _buildTechStat(lang.tr('rating'), "⭐ 4.8"),
            ],
          ),
          const SizedBox(height: 16),

          // Voice Status Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(lang.tr('voice_status_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(lang.tr('voice_status_sub'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 10),
                const CircleAvatar(radius: 24, backgroundColor: AppTheme.brown, child: Text("🎙", style: TextStyle(fontSize: 20))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active Job Execution Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang.tr('active_job_execution'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
                    const Chip(label: Text("ON THE WAY", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: AppTheme.mutedGreen),
                  ],
                ),
                const SizedBox(height: 6),
                const Text("Customer: Priyanshu • AC Cooling Issue", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brown),
                      onPressed: () {
                        ApiService.updateJobStatus(6, 'ARRIVED', 1);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status updated to: ARRIVED")));
                      },
                      child: Text(lang.tr('status_arrived_btn'), style: const TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkGreen),
                      onPressed: () {
                        ApiService.updateJobStatus(6, 'REPAIRING', 1);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status updated to: REPAIRING")));
                      },
                      child: Text(lang.tr('status_repairing_btn'), style: const TextStyle(fontSize: 11, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Switch back to User
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.swap_horiz, color: Colors.white),
            onPressed: () {
              if (widget.onSwitchToUser != null) {
                widget.onSwitchToUser!();
              } else {
                AuthService.instance.switchRole('user');
              }
            },
            label: Text(lang.tr('switch_to_user_view'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),

          // Sign out Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _confirmLogout,
            label: Text(lang.tr('sign_out'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppTheme.darkGreen, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

// Bookings Tab
class UserBookingsScreen extends StatelessWidget {
  const UserBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    return Scaffold(
      appBar: AppBar(title: Text(lang.tr('nav_bookings'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: AppTheme.creme, borderRadius: BorderRadius.circular(20)),
              child: const Center(child: Text("📋", style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 16),
            const Text("No Active Bookings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
            const SizedBox(height: 6),
            const Text("Your confirmed service requests will appear here.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// User Profile Screen
class UserProfileScreen extends StatelessWidget {
  final VoidCallback onSwitchToTech;
  final VoidCallback onOpenWorkflow;
  const UserProfileScreen({super.key, required this.onSwitchToTech, required this.onOpenWorkflow});

  void _confirmLogout(BuildContext context) {
    final lang = LanguageService.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lang.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
        content: const Text("Are you sure you want to sign out from your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(ctx);
              AuthService.instance.logout();
            },
            child: Text(lang.tr('logout'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showServerSettingsDialog(BuildContext context) {
    final controller = TextEditingController(text: AppConfig.host);
    final lang = LanguageService.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lang.tr('server_ip'), style: const TextStyle(color: AppTheme.darkGreen, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter laptop's local IP (e.g. 192.168.1.10):", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkGreen),
            onPressed: () {
              AppConfig.setHost(controller.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Connected to: ${AppConfig.apiBaseUrl}")),
              );
            },
            child: Text(lang.tr('save_connect'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService.instance;
    final user = AuthService.instance.currentUser;
    final userName = user?.name ?? "Priyanshu";
    final userPhone = user?.phone ?? "+91 98765 12345";
    final userEmail = user?.email ?? "user@test.com";
    final userAddress = user?.address ?? "Jaipur, Rajasthan";
    final userAvatar = user?.avatar ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200";

    return Scaffold(
      backgroundColor: AppTheme.softBeige,
      appBar: AppBar(
        title: Text(lang.tr('profile_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: AppTheme.brown),
            tooltip: lang.tr('change_language'),
            onPressed: () => showAppLanguageSelector(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: lang.tr('logout'),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkGreen.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundImage: NetworkImage(userAvatar),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.darkGreen),
                ),
                const SizedBox(height: 4),
                Text(
                  "$userPhone • $userEmail",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    lang.tr('customer_account'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.darkGreen),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.brown),
                    const SizedBox(width: 4),
                    Text(userAddress, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Items
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                // How It Works Item
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.darkGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.account_tree_outlined, color: AppTheme.darkGreen, size: 20),
                  ),
                  title: Text(lang.tr('how_it_works_menu'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(lang.tr('how_it_works_menu_sub'), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: onOpenWorkflow,
                ),
                const Divider(height: 1, indent: 60),

                // Language Switcher Item
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.brown.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.translate_rounded, color: AppTheme.brown, size: 20),
                  ),
                  title: Text(lang.tr('language_settings'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text("${lang.tr('language')}: ${lang.languageName}", style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => showAppLanguageSelector(context),
                ),
                const Divider(height: 1, indent: 60),

                // Switch to Tech Item
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.brown.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.engineering_outlined, color: AppTheme.brown, size: 20),
                  ),
                  title: Text(lang.tr('switch_to_tech_view'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(lang.tr('switch_to_tech_sub'), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: onSwitchToTech,
                ),
                const Divider(height: 1, indent: 60),

                // Backend Server Config
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.darkGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.dns_outlined, color: AppTheme.darkGreen, size: 20),
                  ),
                  title: Text(lang.tr('backend_server_config'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text("Current: ${AppConfig.apiBaseUrl}", style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => _showServerSettingsDialog(context),
                ),
                const Divider(height: 1, indent: 60),

                // Sign Out
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                  ),
                  title: Text(lang.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                  subtitle: Text(lang.tr('sign_out_sub'), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
