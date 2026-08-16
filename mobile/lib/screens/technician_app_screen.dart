import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';

class TechnicianDashboardScreen extends StatefulWidget {
  final VoidCallback? onSwitchToUser;
  const TechnicianDashboardScreen({super.key, this.onSwitchToUser});

  @override
  State<TechnicianDashboardScreen> createState() => _TechnicianDashboardScreenState();
}

class _TechnicianDashboardScreenState extends State<TechnicianDashboardScreen> {
  int _selectedNavIndex = 0;
  bool _isOnline = true;

  // Active Job Execution State
  bool _hasActiveJob = true;
  String _currentStatus = 'ON THE WAY'; // ACCEPTED, ON THE WAY, ARRIVED, INSPECTING, REPAIRING, COMPLETED
  double _labourCost = 500.0;
  double _partsCost = 800.0;
  double _platformFee = 150.0;
  bool _quoteSent = false;

  // Wallet & Earnings State
  double _availableWallet = 18450.0;
  double _todayEarnings = 2850.0;
  double _thisWeekEarnings = 12400.0;
  double _thisMonthEarnings = 42850.0;
  double _netEarnings = 38600.0;
  int _completedJobsCount = 38;

  // Incoming Request Mock
  bool _showNewRequestBanner = true;

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
                Text(lang.tr('change_language'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("English"),
              subtitle: const Text("Clean English UI"),
              trailing: lang.currentLanguage == AppLanguage.english ? const Icon(Icons.check_circle, color: AppTheme.brown) : null,
              onTap: () {
                lang.setLanguage(AppLanguage.english);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text("हिंदी (Hindi)"),
              subtitle: const Text("शुद्ध हिंदी इंटरफ़ेस"),
              trailing: lang.currentLanguage == AppLanguage.hindi ? const Icon(Icons.check_circle, color: AppTheme.brown) : null,
              onTap: () {
                lang.setLanguage(AppLanguage.hindi);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text("Hinglish"),
              subtitle: const Text("Conversational Hindi + English"),
              trailing: lang.currentLanguage == AppLanguage.hinglish ? const Icon(Icons.check_circle, color: AppTheme.brown) : null,
              onTap: () {
                lang.setLanguage(AppLanguage.hinglish);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    final lang = LanguageService.instance;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(lang.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
        content: const Text("Are you sure you want to sign out from Technician Partner mode?"),
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

  void _showWithdrawDialog() {
    final amountController = TextEditingController(text: "5000");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: AppTheme.brown, size: 24),
            SizedBox(width: 8),
            Text("Withdraw to Bank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.darkGreen)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.softBeige, borderRadius: BorderRadius.circular(14)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Available Balance", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text("₹${_availableWallet.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.darkGreen)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text("Enter Amount (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: "₹ ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text("Linked: SBI (••••4521) • UPI: rahul@okaxis", style: TextStyle(fontSize: 11, color: AppTheme.darkGreen, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final amt = double.tryParse(amountController.text) ?? 0.0;
              if (amt > 0 && amt <= _availableWallet) {
                setState(() {
                  _availableWallet -= amt;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.darkGreen,
                    content: Text("✓ ₹${amt.toStringAsFixed(0)} successfully transferred to SBI ••••4521!"),
                  ),
                );
              }
            },
            child: const Text("WITHDRAW NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInspectionQuoteDialog() {
    final labourCtrl = TextEditingController(text: _labourCost.toStringAsFixed(0));
    final partsCtrl = TextEditingController(text: _partsCost.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: AppTheme.darkGreen, size: 24),
                    SizedBox(width: 8),
                    Text("Machine Inspection & Quote", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.darkGreen)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.softBeige, borderRadius: BorderRadius.circular(14)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AI Diagnosis vs Inspection", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.darkGreen)),
                  SizedBox(height: 4),
                  Text("AI Detected: Compressor Relay & R32 Low Gas Pressure\nActual: Replaced 45uF Capacitor & R32 Top-up required.", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text("Parts Cost (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: partsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: AppTheme.softBeige),
            ),
            const SizedBox(height: 12),
            const Text("Labour Charge (₹)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: labourCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: AppTheme.softBeige),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  setState(() {
                    _partsCost = double.tryParse(partsCtrl.text) ?? 800.0;
                    _labourCost = double.tryParse(labourCtrl.text) ?? 500.0;
                    _quoteSent = true;
                    _currentStatus = 'REPAIRING';
                  });
                  ApiService.updateJobStatus(6, 'REPAIRING', 1);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("✓ Inspection Quote sent to customer! Status: REPAIRING")),
                  );
                },
                child: const Text("SEND FINAL QUOTE TO CUSTOMER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionProofDialog() {
    final notesCtrl = TextEditingController(text: "AC cooling restored perfectly. Replaced 45uF capacitor & topped up R32 gas.");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: AppTheme.darkGreen, size: 24),
                    SizedBox(width: 8),
                    Text("Digital Repair Proof & Handover", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppTheme.darkGreen)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(color: AppTheme.softBeige, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black12)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: AppTheme.brown, size: 28),
                        SizedBox(height: 4),
                        Text("Before Repair Photo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(color: AppTheme.softBeige, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black12)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                        SizedBox(height: 4),
                        Text("After Repair Photo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.darkGreen)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text("Repair Notes", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: AppTheme.softBeige),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brown, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  setState(() {
                    _currentStatus = 'COMPLETED';
                    _hasActiveJob = false;
                    _todayEarnings += (_labourCost + _partsCost);
                    _availableWallet += (_labourCost + _partsCost);
                    _completedJobsCount += 1;
                  });
                  ApiService.updateJobStatus(6, 'COMPLETED', 1);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: AppTheme.darkGreen, content: Text("🎉 Repair Completed! Digital proof uploaded & funds credited.")),
                  );
                },
                child: const Text("SUBMIT PROOF & CLOSE JOB", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String nextStatus) {
    setState(() {
      _currentStatus = nextStatus;
    });
    ApiService.updateJobStatus(6, nextStatus, 1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✓ Job Status updated to: $nextStatus")),
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
                  Row(
                    children: const [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                      SizedBox(width: 2),
                      Text("4.8 • AC & Appliance Specialist", style: TextStyle(color: AppTheme.brown, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Text(_isOnline ? "ONLINE" : "OFFLINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _isOnline ? Colors.green : Colors.grey)),
              Switch(
                value: _isOnline,
                activeTrackColor: Colors.green.withValues(alpha: 0.5),
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() => _isOnline = val),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedNavIndex,
        children: [
          _buildHomeJobsTab(lang),
          _buildEarningsWalletTab(lang),
          _buildHistoryTab(lang),
          _buildProfileSettingsTab(lang),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) => setState(() => _selectedNavIndex = index),
        indicatorColor: AppTheme.brown.withValues(alpha: 0.15),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.handyman_outlined), selectedIcon: Icon(Icons.handyman_rounded, color: AppTheme.brown), label: "Jobs"),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: AppTheme.brown), label: "Earnings"),
          NavigationDestination(icon: Icon(Icons.history_rounded), selectedIcon: Icon(Icons.history_rounded, color: AppTheme.brown), label: "History"),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded, color: AppTheme.brown), label: "Profile"),
        ],
      ),
    );
  }

  // ================= TAB 0: HOME & JOBS =================
  Widget _buildHomeJobsTab(LanguageService lang) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // 2x2 Stat Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard("Today Earnings", "₹${_todayEarnings.toStringAsFixed(0)}", Icons.payments_outlined, AppTheme.darkGreen),
            _buildStatCard("Completed Jobs", "$_completedJobsCount", Icons.task_alt_rounded, AppTheme.brown),
            _buildStatCard("Pending Requests", "2", Icons.pending_actions_rounded, Colors.orange),
            _buildStatCard("Overall Rating", "⭐ 4.8", Icons.star_outline_rounded, Colors.amber.shade800),
          ],
        ),
        const SizedBox(height: 16),

        // Realtime Incoming Request Alert Card
        if (_showNewRequestBanner)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.darkGreen, Color(0xFF0D2218)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.bolt, size: 12, color: Colors.black),
                          SizedBox(width: 4),
                          Text("NEW NEARBY REQUEST", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black)),
                        ],
                      ),
                    ),
                    const Text("2.4 km away • ETA 12 min", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("Customer: Priyanshu Sharma", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const Text("AC / HVAC • Voltas Split AC 1.5 Ton", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                const Text("Issue: AC is not cooling and making noise", style: TextStyle(color: Color(0xFFA3B18A), fontSize: 11)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () => setState(() => _showNewRequestBanner = false),
                        child: const Text("Decline", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          setState(() {
                            _hasActiveJob = true;
                            _showNewRequestBanner = false;
                            _currentStatus = 'ACCEPTED';
                          });
                          ApiService.updateJobStatus(6, 'ACCEPTED', 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✓ Job Request Accepted! Customer notified.")),
                          );
                        },
                        child: const Text("ACCEPT JOB", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        if (_showNewRequestBanner) const SizedBox(height: 16),

        // Active Job Stepper Execution Card
        if (_hasActiveJob)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.brown.withValues(alpha: 0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.engineering_rounded, color: AppTheme.brown, size: 20),
                        SizedBox(width: 6),
                        Text("Active Job Execution", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.darkGreen)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.brown, borderRadius: BorderRadius.circular(12)),
                      child: Text(_currentStatus, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Stepper Visual
                _buildJobStatusStepper(),

                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 6),

                const Text("Customer Details:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const CircleAvatar(radius: 16, backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150")),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Priyanshu Sharma", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkGreen)),
                        Text("Hostel Block B, Room 304, Arya Campus, Jaipur", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Status Action Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_currentStatus == 'ACCEPTED')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkGreen),
                        icon: const Icon(Icons.navigation_rounded, size: 16, color: Colors.white),
                        label: const Text("START NAVIGATION", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _updateStatus('ON THE WAY'),
                      ),
                    if (_currentStatus == 'ON THE WAY')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brown),
                        icon: const Icon(Icons.location_on_rounded, size: 16, color: Colors.white),
                        label: const Text("ARRIVED AT LOCATION", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _updateStatus('ARRIVED'),
                      ),
                    if (_currentStatus == 'ARRIVED')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkGreen),
                        icon: const Icon(Icons.search_rounded, size: 16, color: Colors.white),
                        label: const Text("INSPECT & CREATE QUOTE", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: _showInspectionQuoteDialog,
                      ),
                    if (_currentStatus == 'REPAIRING')
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.brown),
                        icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                        label: const Text("COMPLETE & SUBMIT PROOF", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: _showCompletionProofDialog,
                      ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.darkGreen)),
                      icon: const Icon(Icons.phone_rounded, size: 14, color: AppTheme.darkGreen),
                      label: const Text("Call Customer", style: TextStyle(color: AppTheme.darkGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Calling customer +91 98765 12345..."))),
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Voice Status Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.darkGreen, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Text(lang.tr('voice_status_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(lang.tr('voice_status_sub'), style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🗣️ Voice status updated: 'Arrived at location'")),
                  );
                },
                child: const CircleAvatar(radius: 24, backgroundColor: AppTheme.brown, child: Text("🎙", style: TextStyle(fontSize: 20))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= TAB 1: EARNINGS & WALLET =================
  Widget _buildEarningsWalletTab(LanguageService lang) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Available Wallet Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.brown, Color(0xFF5A351D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppTheme.brown.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("AVAILABLE WALLET BALANCE", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
                ],
              ),
              const SizedBox(height: 10),
              Text("₹${_availableWallet.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text("Linked Bank: SBI ••••4521 (Verified ✓)", style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  icon: const Icon(Icons.arrow_downward_rounded, color: AppTheme.brown, size: 18),
                  label: const Text("WITHDRAW FUNDS TO BANK", style: TextStyle(color: AppTheme.brown, fontWeight: FontWeight.w900, fontSize: 13)),
                  onPressed: _showWithdrawDialog,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Earnings Analytics Summary
        const Text("EARNINGS ANALYTICS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(child: _buildEarningCard("Today", "₹${_todayEarnings.toStringAsFixed(0)}", Colors.green)),
            const SizedBox(width: 10),
            Expanded(child: _buildEarningCard("This Week", "₹${_thisWeekEarnings.toStringAsFixed(0)}", AppTheme.darkGreen)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildEarningCard("This Month", "₹${_thisMonthEarnings.toStringAsFixed(0)}", AppTheme.brown)),
            const SizedBox(width: 10),
            Expanded(child: _buildEarningCard("Net Payout", "₹${_netEarnings.toStringAsFixed(0)}", Colors.indigo)),
          ],
        ),

        const SizedBox(height: 20),

        // Recent Payout Transactions List
        const Text("RECENT PAYOUT TRANSACTIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 10),

        _buildTransactionItem("Withdrawal to SBI ••••4521", "Today, 10:15 AM", "-₹3,000", Colors.red),
        _buildTransactionItem("Payment from Priyanshu (AC Repair)", "Yesterday, 4:30 PM", "+₹1,450", Colors.green),
        _buildTransactionItem("Payment from Amit (Motor Service)", "10 Aug 2026", "+₹1,200", Colors.green),
      ],
    );
  }

  // ================= TAB 2: HISTORY =================
  Widget _buildHistoryTab(LanguageService lang) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text("COMPLETED REPAIR JOBS HISTORY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 12),
        _buildHistoryItem("AC Repair & Gas Top-up", "Customer: Priyanshu Sharma", "11 Aug 2026", "₹1,450", "Completed"),
        _buildHistoryItem("Water Motor Capacitor Replacement", "Customer: Rajesh V.", "10 Aug 2026", "₹950", "Completed"),
        _buildHistoryItem("Washing Machine Belt Service", "Customer: Sunita M.", "08 Aug 2026", "₹1,200", "Completed"),
      ],
    );
  }

  // ================= TAB 3: PROFILE & SETTINGS =================
  Widget _buildProfileSettingsTab(LanguageService lang) {
    final user = AuthService.instance.currentUser;
    final techName = user?.name ?? "Rahul Kumar";
    final techPhone = user?.phone ?? "+91 98765 43210";
    final techEmail = user?.email ?? "tech@test.com";

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black12)),
          child: Column(
            children: [
              const CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150")),
              const SizedBox(height: 10),
              Text(techName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.darkGreen)),
              Text("$techPhone • $techEmail", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Text("VERIFIED TECHNICIAN PARTNER ✓", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.account_balance_outlined, color: AppTheme.brown),
                title: const Text("Bank & UPI Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text("SBI ••••4521 • UPI: rahul@okaxis", style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.translate, color: AppTheme.darkGreen),
                title: const Text("Language Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(lang.languageName, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: _showLanguageDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded, color: AppTheme.brown),
                title: const Text("Switch to Customer View", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  if (widget.onSwitchToUser != null) {
                    widget.onSwitchToUser!();
                  } else {
                    AuthService.instance.switchRole('user');
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildEarningCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.darkGreen)),
              Text(date, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String customer, String date, String amount, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.darkGreen)),
              Text(customer, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.brown)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobStatusStepper() {
    final steps = ['ACCEPTED', 'ON THE WAY', 'ARRIVED', 'REPAIRING', 'COMPLETED'];
    final currentIndex = steps.indexOf(_currentStatus).clamp(0, steps.length - 1);

    return Row(
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentIndex;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.darkGreen : AppTheme.softBeige,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDone ? AppTheme.darkGreen : Colors.grey),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Text("${index + 1}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex ? AppTheme.darkGreen : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
