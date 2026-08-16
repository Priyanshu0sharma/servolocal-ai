import 'dart:async';
import 'package:flutter/material.dart';

class ServoLocal18StepUserApp extends StatefulWidget {
  const ServoLocal18StepUserApp({super.key});

  @override
  State<ServoLocal18StepUserApp> createState() => _ServoLocal18StepUserAppState();
}

class _ServoLocal18StepUserAppState extends State<ServoLocal18StepUserApp> {
  int _currentStep = 1;
  bool _isVoiceRecording = false;
  String _selectedPayment = 'UPI';
  int _rating = 5;
  Timer? _autoAdvanceTimer;

  final List<Map<String, dynamic>> _stepsList = [
    {'num': 1, 'id': 'login', 'title': 'Login'},
    {'num': 2, 'id': 'home', 'title': 'Home'},
    {'num': 3, 'id': 'upload', 'title': 'Upload Issue'},
    {'num': 4, 'id': 'describe', 'title': 'Describe Issue'},
    {'num': 5, 'id': 'analysis', 'title': 'AI Analysis'},
    {'num': 6, 'id': 'matching', 'title': 'Tech Matching'},
    {'num': 7, 'id': 'bestmatch', 'title': 'Best Match'},
    {'num': 8, 'id': 'accepted', 'title': 'Accepted'},
    {'num': 9, 'id': 'tracking', 'title': 'Live Tracking'},
    {'num': 10, 'id': 'arrived', 'title': 'Tech Arrived'},
    {'num': 11, 'id': 'quote', 'title': 'Repair Quote'},
    {'num': 12, 'id': 'inprogress', 'title': 'Repairing'},
    {'num': 13, 'id': 'completed', 'title': 'Completed'},
    {'num': 14, 'id': 'proof', 'title': 'Before / After'},
    {'num': 15, 'id': 'payment', 'title': 'Payment'},
    {'num': 16, 'id': 'success', 'title': 'Payment Success'},
    {'num': 17, 'id': 'review', 'title': 'Rate & Review'},
    {'num': 18, 'id': 'history', 'title': 'Service History'},
  ];

  void _goToStep(int stepNum) {
    _autoAdvanceTimer?.cancel();
    setState(() {
      _currentStep = stepNum.clamp(1, 18);
    });

    // Fast Prototype Auto-advance for Step 5 & Step 6 (1 sec)
    if (_currentStep == 5) {
      _autoAdvanceTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted && _currentStep == 5) _goToStep(6);
      });
    } else if (_currentStep == 6) {
      _autoAdvanceTimer = Timer(const Duration(milliseconds: 1000), () {
        if (mounted && _currentStep == 6) _goToStep(7);
      });
    }
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04241B),
        elevation: 4,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text("⚙️", style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "SERVOLOCAL AI",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    "All Machines. All Industries. One Smart Repair Platform.",
                    style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 10, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            color: const Color(0xFF063E2F),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: _stepsList.length,
              itemBuilder: (context, index) {
                final step = _stepsList[index];
                final isSelected = step['num'] == _currentStep;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _goToStep(step['num']),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF10B981) : Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF10B981) : Colors.white24,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: Colors.black26,
                            child: Text(
                              "${step['num']}",
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            step['title'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildCurrentScreenContent(),
              ),
            ),
            _buildBottomFeaturesBanner(),
          ],
        ),
      ),
      bottomNavigationBar: _buildVisibleBottomNavigationBar(),
    );
  }

  // High-Contrast Visible Bottom Navigation Bar with Icons
  Widget _buildVisibleBottomNavigationBar() {
    int navIndex = 0;
    if (_currentStep == 2) navIndex = 0; // Home
    else if (_currentStep == 18) navIndex = 1; // Requests
    else if (_currentStep == 15 || _currentStep == 16) navIndex = 3; // Payments
    else if (_currentStep == 1) navIndex = 4; // Profile

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      height: 65,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, "Home", 2),
          _buildNavItem(1, Icons.assignment_rounded, "Requests", 18),
          
          // Center Floating Plus Button for New Request (Step 3 Upload)
          InkWell(
            onTap: () => _goToStep(3),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF064E3B),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),

          _buildNavItem(3, Icons.account_balance_wallet_rounded, "Payments", 15),
          _buildNavItem(4, Icons.person_rounded, "Profile", 1),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int targetStep) {
    bool isSelected = false;
    if (index == 0 && _currentStep == 2) isSelected = true;
    if (index == 1 && _currentStep == 18) isSelected = true;
    if (index == 3 && (_currentStep == 15 || _currentStep == 16)) isSelected = true;
    if (index == 4 && _currentStep == 1) isSelected = true;

    final color = isSelected ? const Color(0xFF064E3B) : const Color(0xFF6B7280);

    return InkWell(
      onTap: () => _goToStep(targetStep),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreenContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Login();
      case 2:
        return _buildStep2Home();
      case 3:
        return _buildStep3Upload();
      case 4:
        return _buildStep4Describe();
      case 5:
        return _buildStep5AIAnalysis();
      case 6:
        return _buildStep6TechnicianMatching();
      case 7:
        return _buildStep7BestMatch();
      case 8:
        return _buildStep8RequestAccepted();
      case 9:
        return _buildStep9LiveTracking();
      case 10:
        return _buildStep10TechArrived();
      case 11:
        return _buildStep11RepairQuote();
      case 12:
        return _buildStep12RepairInProgress();
      case 13:
        return _buildStep13Completed();
      case 14:
        return _buildStep14BeforeAfter();
      case 15:
        return _buildStep15Payment();
      case 16:
        return _buildStep16PaymentSuccess();
      case 17:
        return _buildStep17RateReview();
      case 18:
        return _buildStep18ServiceHistory();
      default:
        return _buildStep1Login();
    }
  }

  // ---------------------------------------------------------------------------
  // STEP 1: LOGIN
  // ---------------------------------------------------------------------------
  Widget _buildStep1Login() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: const Center(child: Text("⚙️", style: TextStyle(fontSize: 36))),
        ),
        const SizedBox(height: 12),
        const Text("SERVOLOCAL AI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF064E3B))),
        const Text("Smart Repair. Instant Help.", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Welcome Back!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              const Text("Login to continue", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              const Text("Mobile Number", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: const Text("+91", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter mobile number",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                      controller: TextEditingController(text: "98765 12345"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text("Password", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                controller: TextEditingController(text: "••••••••"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF064E3B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _goToStep(2),
                  child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _goToStep(2),
                icon: const Text("🌐"),
                label: const Text("Continue with Google", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: HOME
  // ---------------------------------------------------------------------------
  Widget _buildStep2Home() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Good Morning,", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("Arjun Industries 👋", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                Text("📍 Jaipur, Rajasthan ▾", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
              ],
            ),
            const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.notifications_none_rounded, color: Color(0xFF064E3B))),
          ],
        ),
        const SizedBox(height: 16),

        // Hero Card
        InkWell(
          onTap: () => _goToStep(3),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF022C22)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Report a Repair Issue", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text("Upload machine photo/video\nand get help instantly", style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11)),
                  ],
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Color(0xFF064E3B), size: 28),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text("My Active Requests", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
          child: const Center(
            child: Text("No active jobs\nTap + to create new request", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ),

        const SizedBox(height: 20),
        const Text("Recent Requests", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildRecentJobCard("CNC Milling Machine", "Spindle Motor Issue", "10 May 2024", "Completed"),
        const SizedBox(height: 8),
        _buildRecentJobCard("Hydraulic Press", "Oil Leak Issue", "02 May 2024", "Completed"),
      ],
    );
  }

  Widget _buildRecentJobCard(String title, String sub, String date, String status) {
    return InkWell(
      onTap: () => _goToStep(13),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text("⚙️", style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: const TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3: UPLOAD ISSUE
  // ---------------------------------------------------------------------------
  Widget _buildStep3Upload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload Machine Photo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Take a clear photo of the machine having the issue", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF064E3B), width: 2),
            image: const DecorationImage(
              image: NetworkImage("https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMediaButton(Icons.camera_alt, "Camera"),
            _buildMediaButton(Icons.photo_library, "Gallery"),
            _buildMediaButton(Icons.videocam, "Video"),
          ],
        ),
        const SizedBox(height: 12),
        const Center(child: Text("You can upload up to 5 photos and 1 video", style: TextStyle(fontSize: 11, color: Colors.grey))),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () => _goToStep(4),
            child: const Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF10B981))),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF064E3B)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 4: DESCRIBE ISSUE
  // ---------------------------------------------------------------------------
  Widget _buildStep4Describe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Describe the Issue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Tell us what's happening", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Type your problem in detail...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(text: "Spindle motor not rotating and making unusual noise."),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Or describe by voice", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isVoiceRecording = !_isVoiceRecording),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF064E3B),
                  child: Icon(_isVoiceRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isVoiceRecording ? "Recording voice..." : "Tap to record",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _isVoiceRecording ? Colors.red : Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () => _goToStep(5),
            child: const Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 5: AI ANALYSIS
  // ---------------------------------------------------------------------------
  Widget _buildStep5AIAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF03231A), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Text("AI is Analyzing...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("Please wait while our AI analyzes your machine & issue", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11)),
          const SizedBox(height: 24),
          const CircleAvatar(radius: 44, backgroundColor: Color(0xFF064E3B), child: Text("🧠", style: TextStyle(fontSize: 40))),
          const SizedBox(height: 24),
          _buildCheckItem("Reading machine details"),
          _buildCheckItem("Analyzing image/video"),
          _buildCheckItem("Identifying machine type"),
          _buildCheckItem("Detecting possible issue"),
          _buildCheckItem("Estimating severity"),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Analyzing...", style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 12, fontWeight: FontWeight.bold)),
              Text("72%", style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: 0.72, color: const Color(0xFF10B981), backgroundColor: Colors.white12),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _goToStep(6),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text("Skip to Matching (Fast)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 6: TECHNICIAN MATCHING
  // ---------------------------------------------------------------------------
  Widget _buildStep6TechnicianMatching() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF03231A), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Text("Finding the Right Technicians...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const CircleAvatar(radius: 44, backgroundColor: Color(0xFF064E3B), child: Text("📡", style: TextStyle(fontSize: 40))),
          const SizedBox(height: 24),
          _buildCheckItem("Searching nearby technicians"),
          _buildCheckItem("Checking skills & experience"),
          _buildCheckItem("Checking availability"),
          _buildCheckItem("Matching best technician"),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Searching...", style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 12, fontWeight: FontWeight.bold)),
              Text("65%", style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: 0.65, color: const Color(0xFF10B981), backgroundColor: Colors.white12),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _goToStep(7),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text("See Best Match (Fast)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 7: BEST MATCH FOUND
  // ---------------------------------------------------------------------------
  Widget _buildStep7BestMatch() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF064E3B), borderRadius: BorderRadius.circular(16)),
          child: const Column(
            children: [
              Text("Best Match for You", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Verified • Skilled • Nearby", style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            children: [
              const CircleAvatar(radius: 36, backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150")),
              const SizedBox(height: 8),
              const Text("Rahul Kumar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Text("CNC Specialist", style: TextStyle(color: Color(0xFF064E3B), fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              const Text("⭐ 4.8 (128) • 3.2 km away", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text("ETA 15 min", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF064E3B), fontSize: 11)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Chip(label: Text("✓ Verified", style: TextStyle(fontSize: 10, color: Color(0xFF065F46))), backgroundColor: Color(0xFFECFDF5)),
                  SizedBox(width: 4),
                  Chip(label: Text("✓ 5+ Yrs", style: TextStyle(fontSize: 10, color: Color(0xFF065F46))), backgroundColor: Color(0xFFECFDF5)),
                  SizedBox(width: 4),
                  Chip(label: Text("✓ CNC Expert", style: TextStyle(fontSize: 10, color: Color(0xFF065F46))), backgroundColor: Color(0xFFECFDF5)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () => _goToStep(8),
            child: const Text("Send Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 8: REQUEST ACCEPTED
  // ---------------------------------------------------------------------------
  Widget _buildStep8RequestAccepted() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF064E3B), borderRadius: BorderRadius.circular(16)),
          child: const Column(
            children: [
              Text("Request Accepted!", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("Technician is on the way", style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildTimelineStep("Request Accepted", "10:15 AM", true),
        _buildTimelineStep("On the way", "10:17 AM", true),
        _buildTimelineStep("Arriving Soon", "-", false),
        _buildTimelineStep("Inspection", "-", false),
        _buildTimelineStep("Repairing", "-", false),
        _buildTimelineStep("Completed", "-", false),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToStep(9),
                child: const Text("Chat"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
                onPressed: () => _goToStep(9),
                child: const Text("Call", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineStep(String label, String time, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: done ? const Color(0xFF10B981) : Colors.grey, size: 18),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(fontWeight: done ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 9: LIVE TRACKING
  // ---------------------------------------------------------------------------
  Widget _buildStep9LiveTracking() {
    return Column(
      children: [
        const Text("Rahul Kumar is on the way", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, size: 48, color: Color(0xFF064E3B)),
                Text("Live GPS Route Map (3.2 km away)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
          onPressed: () => _goToStep(10),
          child: const Text("Share Live Location", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 10: TECHNICIAN ARRIVED
  // ---------------------------------------------------------------------------
  Widget _buildStep10TechArrived() {
    return Column(
      children: [
        const Text("Technician Arrived", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Rahul Kumar has reached your location.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            children: const [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150")),
              SizedBox(height: 6),
              Text("Rahul Kumar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("CNC Specialist", style: TextStyle(color: Color(0xFF064E3B), fontWeight: FontWeight.bold, fontSize: 12)),
              SizedBox(height: 6),
              Chip(label: Text("✓ Identity Verified", style: TextStyle(color: Color(0xFF065F46), fontSize: 11)), backgroundColor: Color(0xFFECFDF5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
            onPressed: () => _goToStep(11),
            child: const Text("Start Inspection", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 11: REPAIR QUOTE
  // ---------------------------------------------------------------------------
  Widget _buildStep11RepairQuote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Repair Quote", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("After inspection", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            children: [
              _buildQuoteRow("Spindle Motor", "₹1,200"),
              _buildQuoteRow("Bearing Set", "₹400"),
              _buildQuoteRow("Coupling", "₹300"),
              _buildQuoteRow("Labour Charge", "₹500"),
              _buildQuoteRow("Platform Fee", "₹150"),
              const Divider(),
              _buildQuoteRow("Total Payable", "₹2,550", isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
            onPressed: () => _goToStep(12),
            child: const Text("Approve Quote", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteRow(String title, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500, fontSize: isTotal ? 15 : 13)),
          Text(price, style: TextStyle(fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold, fontSize: isTotal ? 16 : 13, color: const Color(0xFF064E3B))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 12: REPAIR IN PROGRESS
  // ---------------------------------------------------------------------------
  Widget _buildStep12RepairInProgress() {
    return Column(
      children: [
        const Text("Repair in Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("We'll keep you updated", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        _buildTimelineStep("Inspection Done", "✓", true),
        _buildTimelineStep("Quote Approved", "✓", true),
        _buildTimelineStep("Repairing Now", "●", true),
        _buildTimelineStep("Testing", "-", false),
        _buildTimelineStep("Completed", "-", false),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
          onPressed: () => _goToStep(13),
          child: const Text("Proceed to Completion", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 13: COMPLETED
  // ---------------------------------------------------------------------------
  Widget _buildStep13Completed() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const CircleAvatar(radius: 36, backgroundColor: Color(0xFF10B981), child: Icon(Icons.check, color: Colors.white, size: 44)),
        const SizedBox(height: 14),
        const Text("Repair Completed!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text("Machine is working fine.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
            onPressed: () => _goToStep(14),
            child: const Text("View Details & Proof", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 14: BEFORE / AFTER
  // ---------------------------------------------------------------------------
  Widget _buildStep14BeforeAfter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Work Completed", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Here is the proof", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text("Before", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(height: 110, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  const Text("After", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF064E3B))),
                  const SizedBox(height: 4),
                  Container(height: 110, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12))),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
            onPressed: () => _goToStep(15),
            child: const Text("Proceed to Payment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 15: PAYMENT
  // ---------------------------------------------------------------------------
  Widget _buildStep15Payment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Payment Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        _buildQuoteRow("Total Payable", "₹2,550", isTotal: true),
        const SizedBox(height: 16),
        const Text("Choose Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(
          title: const Text("UPI"),
          leading: Radio(value: 'UPI', groupValue: _selectedPayment, onChanged: (val) => setState(() => _selectedPayment = val.toString())),
        ),
        ListTile(
          title: const Text("Card"),
          leading: Radio(value: 'Card', groupValue: _selectedPayment, onChanged: (val) => setState(() => _selectedPayment = val.toString())),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
            onPressed: () => _goToStep(16),
            child: const Text("Pay ₹2,550", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 16: PAYMENT SUCCESS
  // ---------------------------------------------------------------------------
  Widget _buildStep16PaymentSuccess() {
    return Column(
      children: [
        const CircleAvatar(radius: 36, backgroundColor: Color(0xFF10B981), child: Icon(Icons.check, color: Colors.white, size: 44)),
        const SizedBox(height: 14),
        const Text("Payment Successful!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text("₹2,550 Paid Successfully", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
            onPressed: () => _goToStep(17),
            child: const Text("Rate & Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 17: RATE & REVIEW
  // ---------------------------------------------------------------------------
  Widget _buildStep17RateReview() {
    return Column(
      children: [
        const Text("Rate Your Experience", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("How was our service?", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (idx) {
            return IconButton(
              icon: Icon(idx < _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
              onPressed: () => setState(() => _rating = idx + 1),
            );
          }),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF064E3B)),
            onPressed: () => _goToStep(18),
            child: const Text("Submit Review", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 18: SERVICE HISTORY
  // ---------------------------------------------------------------------------
  Widget _buildStep18ServiceHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Service History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        _buildRecentJobCard("CNC Milling Machine", "Spindle Motor Issue", "10 May 2024", "Completed"),
        const SizedBox(height: 8),
        _buildRecentJobCard("Hydraulic Press", "Oil Leak Issue", "02 May 2024", "Completed"),
        const SizedBox(height: 8),
        _buildRecentJobCard("Air Compressor", "Not Starting", "25 Apr 2024", "Completed"),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _goToStep(1),
            child: const Text("Back to Start (Step 1)"),
          ),
        ),
      ],
    );
  }

  // Bottom summary features banner
  Widget _buildBottomFeaturesBanner() {
    return Container(
      color: const Color(0xFF04241B),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Text("⚡ AI Powered", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          Text("⚙️ All Machines", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          Text("🛡️ Verified", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          Text("📄 Digital Proof", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
