import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hindi, hinglish }

class LanguageService extends ChangeNotifier {
  static final LanguageService instance = LanguageService._internal();
  LanguageService._internal();

  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;

  String get languageCode {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.hinglish:
        return 'hinglish';
      case AppLanguage.english:
        return 'en';
    }
  }

  String get languageName {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return 'हिंदी (Hindi)';
      case AppLanguage.hinglish:
        return 'Hinglish (हिंदी + English)';
      case AppLanguage.english:
        return 'English';
    }
  }

  static const String _prefKey = 'aetherion_app_language';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'hi') {
        _currentLanguage = AppLanguage.hindi;
      } else if (saved == 'hinglish') {
        _currentLanguage = AppLanguage.hinglish;
      } else {
        _currentLanguage = AppLanguage.english;
      }
    } catch (_) {
      _currentLanguage = AppLanguage.english;
    }
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);
    } catch (_) {}
  }

  String tr(String key) {
    final dict = _translations[languageCode] ?? _translations['en']!;
    return dict[key] ?? _translations['en']?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // General & Nav
      'app_name': 'AETHERION',
      'nav_home': 'Home',
      'nav_how_it_works': 'How It Works',
      'nav_services': 'Services',
      'nav_bookings': 'Bookings',
      'nav_profile': 'Profile',
      'connected_prototype': 'CONNECTED PROTOTYPE',
      'language': 'Language',
      'change_language': 'Change Language',
      'server_ip': 'Backend Server IP',
      'logout': 'Log Out',
      'cancel': 'Cancel',
      'save_connect': 'Save & Connect',
      'view_all': 'View all',
      'active_portal': 'Active Portal',
      'tap_to_switch': 'Tap to Switch',

      // Login Screen
      'login_title': 'AETHERION',
      'login_sub': 'AI-Powered On-Demand Repair Service',
      'select_portal': 'SELECT LOGIN PORTAL:',
      'user_customer': 'Customer / User',
      'staff_tech': 'Technician / Staff',
      'user_login_title': 'Customer Sign In',
      'staff_login_title': 'Technician Sign In',
      'phone_number': 'Registered Phone Number',
      'otp_code': '4-Digit OTP Code',
      'auto_fill_otp': 'Auto-Fill Demo OTP: 1234',
      'email_address': 'Email Address',
      'password': 'Password',
      'login_btn_user': 'Login to Customer Portal',
      'login_btn_staff': 'Login to Staff Portal',
      'direct_access': 'Direct 1-Tap Portal Access:',
      'enter': 'Enter',

      // Home Screen
      'greeting_hello': 'Hello',
      'how_can_help': 'How can we help you today?',
      'report_problem': 'Report a Problem',
      'report_problem_sub': 'Get instant AI diagnosis & find verified technicians',
      'how_aetherion_works_card': 'How Aetherion Works',
      'how_aetherion_works_sub': '8-step seamless AI & dispatch workflow',
      'active_service': 'Active Service',
      'track_live': 'Track Live',
      'recent_services': 'Recent Services',
      'completed': 'Completed',
      'are_you_technician': 'Are you a Technician?',
      'switch_to_tech': 'Switch to technician job portal',
      'tech_view_btn': 'Tech View 👨‍🔧',

      // AI Diagnosis Screen
      'ai_diagnosis_title': 'AI Problem Diagnosis',
      'describe_problem': 'Describe the Problem',
      'describe_hint': 'e.g. AC is not cooling and outdoor unit is making unusual noise...',
      'upload_media_title': 'Upload Photo / Video (Required for AI)',
      'take_photo': 'Take Photo',
      'choose_gallery': 'Choose Gallery',
      'record_video': 'Record Video',
      'sample_photos': 'Or Select Sample Image for Quick Test:',
      'media_attached': 'Image / Video Attached',
      'remove_media': 'Remove',
      'run_ai_btn': '⚡ Run AI Problem Diagnosis',
      'analyzing_ai': 'Multi-Modal AI Engine Analyzing...',
      'detected_issue': 'DETECTED ISSUE',
      'confidence': 'Confidence',
      'severity': 'Severity',
      'possible_causes': 'Possible Causes',
      'required_parts': 'Required Parts',
      'estimated_cost': 'Estimated Cost',
      'no_hidden_charges': '✓ Transparent pricing • No hidden charges',
      'find_technician_btn': 'Find Nearby Verified Technician →',

      // Technicians List
      'tech_nearby_title': 'Technicians Nearby',
      'visit_charge': 'Visit Charge',
      'km_away': 'km away',
      'select_tech_btn': 'Select Tech',

      // Live Tracking
      'live_tracking_title': 'Live Tracking',
      'tech_on_the_way': 'On the way to your location',
      'mock_gps': 'Live GPS Navigation',
      'status_accepted': 'Request Accepted',
      'status_on_the_way': 'On the way',
      'status_arrived': 'Arrived at location',
      'status_repairing': 'Repair & Inspection in progress',
      'status_completed': 'Repair Completed',
      'call_tech': '📞 Call Technician',
      'view_proof_pay': 'View Repair Proof & Pay',

      // Payment & Proof
      'payment_proof_title': 'Payment & Digital Proof',
      'repair_summary': 'Repair Cost Summary',
      'labour': 'Labour Charge',
      'parts': 'Required Replacement Parts',
      'service_charge': 'Platform Service Fee',
      'total_amount': 'Total Amount Payable',
      'repair_proof': 'Digital Repair Proof',
      'before': 'Before Repair',
      'after': 'After Repair',
      'payment_method': 'Payment Method',
      'pay_now': 'Pay',
      'pay_success': 'Payment Successful!',
      'txn_id': 'Transaction ID',
      'rate_experience': 'Rate Your Experience',
      'leave_feedback': 'Leave feedback / comments...',
      'submit_feedback': 'Submit Feedback',

      // Technician Screen
      'tech_portal_title': 'Technician Partner Portal',
      'todays_jobs': "Today's Jobs",
      'pending': 'Pending',
      'today_earnings': 'Today Earnings',
      'rating': 'Rating',
      'voice_status_title': '🗣️ Voice Status Update',
      'voice_status_sub': "Hold mic & speak: 'Arrived at location' or 'Repair complete'",
      'active_job_execution': 'Active Job Execution',
      'status_arrived_btn': '📍 Arrived',
      'status_repairing_btn': '🔧 Repairing',
      'status_completed_btn': '✅ Completed',
      'switch_to_user_view': 'Switch to Customer App View',
      'sign_out': 'Sign Out',

      // Profile Screen
      'profile_title': 'My Profile',
      'customer_account': 'Customer Account',
      'switch_to_tech_view': 'Switch to Technician View',
      'switch_to_tech_sub': 'Go to partner jobs & earnings dashboard',
      'backend_server_config': 'Backend Server Config',
      'backend_server_sub': 'Configure IP for physical device connection',
      'language_settings': 'Language Settings',
      'language_settings_sub': 'Choose English, Hindi, or Hinglish',
      'how_it_works_menu': 'How Aetherion Works (Workflow)',
      'how_it_works_menu_sub': 'Detailed 8-step AI & repair process',
      'sign_out_sub': 'Sign out of current account',

      // How It Works Content
      'how_works_title': 'HOW AETHERION WORKS',
      'how_works_subtitle': 'Complete End-to-End AI Diagnostic & Repair Flow',
      'one_line_flow_title': 'ONE-LINE FLOW DIAGRAM',
      'one_line_flow_content': '📷 Capture Issue → 🤖 AI Diagnosis → 📍 Nearby Matching → 📲 Technician Request → 🔧 Repair → 📸 Proof → 💳 Payment → ⭐ Feedback',
      'main_usp_title': 'MAIN USP',
      'main_usp_quote': '“User sirf problem ki photo/video bhejta hai — Aetherion AI diagnosis se lekar nearby verified technician dispatch aur repair completion tak poora workflow connect karta hai.”',
      'step_1_title': '1. User Reports Issue',
      'step_1_desc': 'User app se problem ki photo/video capture karta hai, issue describe karta hai aur location share karta hai.',
      'step_2_title': '2. AI Analyses the Problem',
      'step_2_desc': 'AI uploaded image/video ko analyse karke problem type, severity, possible cause, required parts aur estimated repair cost identify karta hai.',
      'step_3_title': '3. Smart Technician Matching',
      'step_3_desc': 'System user ki location ke basis par nearby available & verified technicians ko identify karta hai.',
      'step_4_title': '4. Request is Dispatched',
      'step_4_desc': 'Nearby technicians ko service request + problem details + AI diagnosis + estimated cost milta hai.',
      'step_5_title': '5. Technician Accepts & Reaches',
      'step_5_desc': 'Technician request accept karta hai aur user ko live status / location updates milte hain.',
      'step_6_title': '6. Repair & Status Updates',
      'step_6_desc': 'Technician Arrived → Inspection → Repairing → Testing status update karta hai.',
      'step_7_title': '7. Completion & Proof',
      'step_7_desc': 'Repair complete hone par technician before/after photos + parts used + final cost submit karta hai.',
      'step_8_title': '8. Payment & Feedback',
      'step_8_desc': 'User payment complete karta hai aur rating + feedback deta hai.',
    },
    'hi': {
      // General & Nav
      'app_name': 'AETHERION',
      'nav_home': 'होम',
      'nav_how_it_works': 'कार्यप्रणाली',
      'nav_services': 'सेवाएं',
      'nav_bookings': 'बुकिंग्स',
      'nav_profile': 'प्रोफाइल',
      'connected_prototype': 'कनेक्टेड प्रोटोटाइप',
      'language': 'भाषा',
      'change_language': 'भाषा बदलें',
      'server_ip': 'बैकएंड सर्वर आईपी',
      'logout': 'लॉगआउट',
      'cancel': 'रद्द करें',
      'save_connect': 'सहेजें और कनेक्ट करें',
      'view_all': 'सभी देखें',
      'active_portal': 'सक्रिय पोर्टल',
      'tap_to_switch': 'बदलने के लिए टैप करें',

      // Login Screen
      'login_title': 'AETHERION',
      'login_sub': 'एआई-संचालित ऑन-डिमांड मरम्मत सेवा',
      'select_portal': 'लॉगिन पोर्टल चुनें:',
      'user_customer': 'ग्राहक / उपयोगकर्ता',
      'staff_tech': 'कारीगर / तकनीशियन',
      'user_login_title': 'ग्राहक लॉगिन',
      'staff_login_title': 'तकनीशियन लॉगिन',
      'phone_number': 'पंजीकृत मोबाइल नंबर',
      'otp_code': '4-अंकों का ओटीपी',
      'auto_fill_otp': 'डेमो ओटीपी भरें: 1234',
      'email_address': 'ईमेल पता',
      'password': 'पासवर्ड',
      'login_btn_user': 'ग्राहक पोर्टल में प्रवेश करें',
      'login_btn_staff': 'तकनीशियन पोर्टल में प्रवेश करें',
      'direct_access': 'सीधा 1-टैप पोर्टल प्रवेश:',
      'enter': 'प्रवेश',

      // Home Screen
      'greeting_hello': 'नमस्ते',
      'how_can_help': 'आज हम आपकी क्या मदद कर सकते हैं?',
      'report_problem': 'समस्या दर्ज करें',
      'report_problem_sub': 'तुरंत एआई निदान प्राप्त करें और कुशल कारीगर पाएं',
      'how_aetherion_works_card': 'Aetherion कैसे काम करता है',
      'how_aetherion_works_sub': '8-चरणीय संपूर्ण एआई और मरम्मत प्रक्रिया',
      'active_service': 'सक्रिय सेवा',
      'track_live': 'लाइव ट्रैक करें',
      'recent_services': 'हाल की सेवाएं',
      'completed': 'पूर्ण',
      'are_you_technician': 'क्या आप तकनीशियन हैं?',
      'switch_to_tech': 'तकनीशियन जॉब पोर्टल पर जाएं',
      'tech_view_btn': 'कारीगर व्यू 👨‍🔧',

      // AI Diagnosis Screen
      'ai_diagnosis_title': 'एआई समस्या निदान',
      'describe_problem': 'समस्या का विवरण दें',
      'describe_hint': 'उदा. एसी कूलिंग नहीं कर रहा और बाहरी यूनिट से आवाज आ रही है...',
      'upload_media_title': 'फोटो / वीडियो अपलोड करें (एआई के लिए आवश्यक)',
      'take_photo': 'फोटो खींचें',
      'choose_gallery': 'गैलरी से चुनें',
      'record_video': 'वीडियो बनाएं',
      'sample_photos': 'या त्वरित परीक्षण के लिए नमूना फोटो चुनें:',
      'media_attached': 'फोटो / वीडियो संलग्न',
      'remove_media': 'हटाएं',
      'run_ai_btn': '⚡ एआई समस्या निदान चलाएं',
      'analyzing_ai': 'मल्टी-मॉडल एआई विश्लेषण कर रहा है...',
      'detected_issue': 'पहचानी गई समस्या',
      'confidence': 'सटीकता',
      'severity': 'गंभीरता',
      'possible_causes': 'संभावित कारण',
      'required_parts': 'आवश्यक स्पेयर पार्ट्स',
      'estimated_cost': 'अनुमानित लागत',
      'no_hidden_charges': '✓ पारदर्शी मूल्य • कोई छिपा हुआ शुल्क नहीं',
      'find_technician_btn': 'निकटतम सत्यापित तकनीशियन खोजें →',

      // Technicians List
      'tech_nearby_title': 'निकटतम उपलब्ध तकनीशियन',
      'visit_charge': 'विजिट शुल्क',
      'km_away': 'किमी दूर',
      'select_tech_btn': 'चुनें',

      // Live Tracking
      'live_tracking_title': 'लाइव ट्रैकिंग',
      'tech_on_the_way': 'आपके पते पर आ रहे हैं',
      'mock_gps': 'लाइव जीपीएस नेविगेशन',
      'status_accepted': 'अनुरोध स्वीकार किया',
      'status_on_the_way': 'रास्ते में हैं',
      'status_arrived': 'पहुंच गए',
      'status_repairing': 'निरीक्षण एवं मरम्मत जारी',
      'status_completed': 'मरम्मत पूर्ण',
      'call_tech': '📞 तकनीशियन को कॉल करें',
      'view_proof_pay': 'मरम्मत प्रमाण देखें और भुगतान करें',

      // Payment & Proof
      'payment_proof_title': 'भुगतान एवं डिजिटल प्रमाण',
      'repair_summary': 'मरम्मत लागत सारांश',
      'labour': 'मजदूरी शुल्क',
      'parts': 'स्पेयर पार्ट्स लागत',
      'service_charge': 'प्लेटफ़ॉर्म सेवा शुल्क',
      'total_amount': 'कुल देय राशि',
      'repair_proof': 'डिजिटल मरम्मत प्रमाण',
      'before': 'मरम्मत से पहले',
      'after': 'मरम्मत के बाद',
      'payment_method': 'भुगतान माध्यम',
      'pay_now': 'भुगतान करें',
      'pay_success': 'भुगतान सफल रहा!',
      'txn_id': 'लेनदेन आईडी',
      'rate_experience': 'अपना अनुभव रेट करें',
      'leave_feedback': 'अपनी राय / समीक्षा लिखें...',
      'submit_feedback': 'समीक्षा सबमिट करें',

      // Technician Screen
      'tech_portal_title': 'तकनीशियन पार्टनर पोर्टल',
      'todays_jobs': "आज के कार्य",
      'pending': 'लंबित',
      'today_earnings': 'आज की कमाई',
      'rating': 'रेटिंग',
      'voice_status_title': '🗣️ वॉयस स्टेटस अपडेट',
      'voice_status_sub': "माइक दबाकर बोलें: 'मैं पहुंच गया' या 'मरम्मत पूरी हुई'",
      'active_job_execution': 'सक्रिय कार्य संपादन',
      'status_arrived_btn': '📍 पहुंच गए',
      'status_repairing_btn': '🔧 मरम्मत जारी',
      'status_completed_btn': '✅ पूर्ण हुआ',
      'switch_to_user_view': 'ग्राहक ऐप पर जाएं',
      'sign_out': 'लॉगआउट',

      // Profile Screen
      'profile_title': 'मेरी प्रोफाइल',
      'customer_account': 'ग्राहक खाता',
      'switch_to_tech_view': 'तकनीशियन पोर्टल पर जाएं',
      'switch_to_tech_sub': 'जॉब्स और कमाई डैशबोर्ड देखें',
      'backend_server_config': 'बैकएंड सर्वर सेटिंग्स',
      'backend_server_sub': 'डिवाइस कनेक्शन के लिए आईपी कॉन्फ़िगर करें',
      'language_settings': 'भाषा सेटिंग्स',
      'language_settings_sub': 'अंग्रेजी, हिंदी या हिंग्लिश चुनें',
      'how_it_works_menu': 'Aetherion कार्यप्रणाली (Workflow)',
      'how_it_works_menu_sub': 'विस्तृत 8-चरणीय एआई एवं मरम्मत प्रक्रिया',
      'sign_out_sub': 'वर्तमान खाते से लॉगआउट करें',

      // How It Works Content
      'how_works_title': 'HOW AETHERION WORKS',
      'how_works_subtitle': 'संपूर्ण एंड-टू-एंड एआई डायग्नोस्टिक एवं रिपेयर वर्कफ़्लो',
      'one_line_flow_title': 'वन-लाइन फ्लो डायग्राम',
      'one_line_flow_content': '📷 Capture Issue → 🤖 AI Diagnosis → 📍 Nearby Matching → 📲 Technician Request → 🔧 Repair → 📸 Proof → 💳 Payment → ⭐ Feedback',
      'main_usp_title': 'मुख्य यूएसपी (MAIN USP)',
      'main_usp_quote': '“User sirf problem ki photo/video bhejta hai — Aetherion AI diagnosis se lekar nearby verified technician dispatch aur repair completion tak poora workflow connect karta hai.”',
      'step_1_title': '1. User Reports Issue',
      'step_1_desc': 'User app se problem ki photo/video capture karta hai, issue describe karta hai aur location share karta hai.',
      'step_2_title': '2. AI Analyses the Problem',
      'step_2_desc': 'AI uploaded image/video ko analyse karke problem type, severity, possible cause, required parts aur estimated repair cost identify karta hai.',
      'step_3_title': '3. Smart Technician Matching',
      'step_3_desc': 'System user ki location ke basis par nearby available & verified technicians ko identify karta hai.',
      'step_4_title': '4. Request is Dispatched',
      'step_4_desc': 'Nearby technicians ko service request + problem details + AI diagnosis + estimated cost milta hai.',
      'step_5_title': '5. Technician Accepts & Reaches',
      'step_5_desc': 'Technician request accept karta hai aur user ko live status / location updates milte hain.',
      'step_6_title': '6. Repair & Status Updates',
      'step_6_desc': 'Technician Arrived → Inspection → Repairing → Testing status update karta hai.',
      'step_7_title': '7. Completion & Proof',
      'step_7_desc': 'Repair complete hone par technician before/after photos + parts used + final cost submit karta hai.',
      'step_8_title': '8. Payment & Feedback',
      'step_8_desc': 'User payment complete karta hai aur rating + feedback deta hai.',
    },
    'hinglish': {
      // General & Nav
      'app_name': 'AETHERION',
      'nav_home': 'Home',
      'nav_how_it_works': 'How It Works',
      'nav_services': 'Services',
      'nav_bookings': 'Bookings',
      'nav_profile': 'Profile',
      'connected_prototype': 'CONNECTED PROTOTYPE',
      'language': 'Language / भाषा',
      'change_language': 'Language Change Karein',
      'server_ip': 'Backend Server IP',
      'logout': 'Log Out',
      'cancel': 'Cancel',
      'save_connect': 'Save & Connect',
      'view_all': 'View all',
      'active_portal': 'Active Portal',
      'tap_to_switch': 'Tap to Switch',

      // Login Screen
      'login_title': 'AETHERION',
      'login_sub': 'AI-Powered On-Demand Repair Service',
      'select_portal': 'SELECT LOGIN PORTAL:',
      'user_customer': 'Customer / User',
      'staff_tech': 'Technician / Staff',
      'user_login_title': 'Customer Sign In',
      'staff_login_title': 'Technician Sign In',
      'phone_number': 'Registered Phone Number',
      'otp_code': '4-Digit OTP Code',
      'auto_fill_otp': 'Auto-Fill Demo OTP: 1234',
      'email_address': 'Email Address',
      'password': 'Password',
      'login_btn_user': 'Customer Portal me Login Karein',
      'login_btn_staff': 'Technician Portal me Login Karein',
      'direct_access': 'Direct 1-Tap Portal Access:',
      'enter': 'Enter',

      // Home Screen
      'greeting_hello': 'Hello',
      'how_can_help': 'Hum aapki kya madad kar sakte hain?',
      'report_problem': 'Report a Problem',
      'report_problem_sub': 'Instant AI diagnosis payein aur verified technician book karein',
      'how_aetherion_works_card': 'How Aetherion Works',
      'how_aetherion_works_sub': '8-step complete AI & repair workflow',
      'active_service': 'Active Service',
      'track_live': 'Track Live',
      'recent_services': 'Recent Services',
      'completed': 'Completed',
      'are_you_technician': 'Kya aap Technician hain?',
      'switch_to_tech': 'Technician job portal par switch karein',
      'tech_view_btn': 'Tech View 👨‍🔧',

      // AI Diagnosis Screen
      'ai_diagnosis_title': 'AI Problem Diagnosis',
      'describe_problem': 'Problem Describe Karein',
      'describe_hint': 'e.g. AC cooling nahi kar raha aur outdoor unit se unusual sound aa rahi hai...',
      'upload_media_title': 'Photo / Video Upload Karein (AI Diagnosis ke liye)',
      'take_photo': 'Photo Kheenche',
      'choose_gallery': 'Gallery se Chunein',
      'record_video': 'Video Banayein',
      'sample_photos': 'Ya Quick Test ke liye Sample Photo Chunein:',
      'media_attached': 'Photo / Video Attached',
      'remove_media': 'Remove',
      'run_ai_btn': '⚡ Run AI Problem Diagnosis',
      'analyzing_ai': 'Multi-Modal AI Engine Analyze kar raha hai...',
      'detected_issue': 'DETECTED ISSUE',
      'confidence': 'Confidence',
      'severity': 'Severity',
      'possible_causes': 'Possible Causes',
      'required_parts': 'Required Parts',
      'estimated_cost': 'Estimated Cost',
      'no_hidden_charges': '✓ Transparent Pricing • No Hidden Charges',
      'find_technician_btn': 'Nearby Verified Technician Dhoondein →',

      // Technicians List
      'tech_nearby_title': 'Nearby Verified Technicians',
      'visit_charge': 'Visit Charge',
      'km_away': 'km door',
      'select_tech_btn': 'Select Tech',

      // Live Tracking
      'live_tracking_title': 'Live Tracking',
      'tech_on_the_way': 'Aapki location par aa rahe hain',
      'mock_gps': 'Live GPS Navigation',
      'status_accepted': 'Accepted',
      'status_on_the_way': 'On the way',
      'status_arrived': 'Arrived',
      'status_repairing': 'Repairing & Inspection',
      'status_completed': 'Completed',
      'call_tech': '📞 Technician ko Call Karein',
      'view_proof_pay': 'Repair Proof Dekhein & Pay Karein',

      // Payment & Proof
      'payment_proof_title': 'Payment & Digital Proof',
      'repair_summary': 'Repair Cost Summary',
      'labour': 'Labour Charge',
      'parts': 'Required Parts Cost',
      'service_charge': 'Service Charge',
      'total_amount': 'Total Payable Amount',
      'repair_proof': 'Digital Repair Proof',
      'before': 'Before Repair',
      'after': 'After Repair',
      'payment_method': 'Payment Method',
      'pay_now': 'Pay Karein',
      'pay_success': 'Payment Successful!',
      'txn_id': 'Transaction ID',
      'rate_experience': 'Rate Your Experience',
      'leave_feedback': 'Feedback likhein...',
      'submit_feedback': 'Submit Feedback',

      // Technician Screen
      'tech_portal_title': 'Technician Partner Portal',
      'todays_jobs': "Today's Jobs",
      'pending': 'Pending',
      'today_earnings': 'Today Earnings',
      'rating': 'Rating',
      'voice_status_title': '🗣️ Voice Status Update',
      'voice_status_sub': "Mic hold karke bolein: 'Main pahunch gaya' ya 'Repair complete'",
      'active_job_execution': 'Active Job Execution',
      'status_arrived_btn': '📍 Arrived',
      'status_repairing_btn': '🔧 Repairing',
      'status_completed_btn': '✅ Completed',
      'switch_to_user_view': 'Customer App View par Switch Karein',
      'sign_out': 'Log Out',

      // Profile Screen
      'profile_title': 'My Profile',
      'customer_account': 'Customer Account',
      'switch_to_tech_view': 'Technician View par Switch Karein',
      'switch_to_tech_sub': 'Partner jobs aur earnings dashboard',
      'backend_server_config': 'Backend Server Config',
      'backend_server_sub': 'Physical device connection ke liye IP configure karein',
      'language_settings': 'Language Settings',
      'language_settings_sub': 'English, Hindi ya Hinglish select karein',
      'how_it_works_menu': 'How Aetherion Works (Workflow)',
      'how_it_works_menu_sub': 'Complete 8-step AI & repair flow',
      'sign_out_sub': 'Current account se sign out karein',

      // How It Works Content
      'how_works_title': 'HOW AETHERION WORKS',
      'how_works_subtitle': 'Complete End-to-End AI Diagnostic & Repair Flow',
      'one_line_flow_title': 'ONE-LINE FLOW DIAGRAM',
      'one_line_flow_content': '📷 Capture Issue → 🤖 AI Diagnosis → 📍 Nearby Matching → 📲 Technician Request → 🔧 Repair → 📸 Proof → 💳 Payment → ⭐ Feedback',
      'main_usp_title': 'MAIN USP',
      'main_usp_quote': '“User sirf problem ki photo/video bhejta hai — Aetherion AI diagnosis se lekar nearby verified technician dispatch aur repair completion tak poora workflow connect karta hai.”',
      'step_1_title': '1. User Reports Issue',
      'step_1_desc': 'User app se problem ki photo/video capture karta hai, issue describe karta hai aur location share karta hai.',
      'step_2_title': '2. AI Analyses the Problem',
      'step_2_desc': 'AI uploaded image/video ko analyse karke problem type, severity, possible cause, required parts aur estimated repair cost identify karta hai.',
      'step_3_title': '3. Smart Technician Matching',
      'step_3_desc': 'System user ki location ke basis par nearby available & verified technicians ko identify karta hai.',
      'step_4_title': '4. Request is Dispatched',
      'step_4_desc': 'Nearby technicians ko service request + problem details + AI diagnosis + estimated cost milta hai.',
      'step_5_title': '5. Technician Accepts & Reaches',
      'step_5_desc': 'Technician request accept karta hai aur user ko live status / location updates milte hain.',
      'step_6_title': '6. Repair & Status Updates',
      'step_6_desc': 'Technician Arrived → Inspection → Repairing → Testing status update karta hai.',
      'step_7_title': '7. Completion & Proof',
      'step_7_desc': 'Repair complete hone par technician before/after photos + parts used + final cost submit karta hai.',
      'step_8_title': '8. Payment & Feedback',
      'step_8_desc': 'User payment complete karta hai aur rating + feedback deta hai.',
    },
  };
}
