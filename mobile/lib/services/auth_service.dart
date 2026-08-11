import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  UserModel? _currentUser;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isTechnician => _currentUser?.role == 'technician';
  bool get isInitialized => _isInitialized;

  static const String _userPrefKey = 'aetherion_auth_user';

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_userPrefKey);
      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(userJsonStr);
        _currentUser = UserModel.fromJson(data);
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> loginWithPhone({
    required String phone,
    required String otp,
    required String role,
  }) async {
    // 1. Try backend login
    final res = await ApiService.login(
      phone: phone,
      password: otp,
      role: role,
    );

    if (res != null && res['success'] == true && res['user'] != null) {
      _currentUser = UserModel.fromJson(
        res['user'],
        token: res['token'],
        technicianProfile: res['technician'],
      );
      await _saveSession();
      notifyListeners();
      return true;
    }

    // 2. Offline / Demo Fallback (Resilient for hackathons and offline presentations)
    final isTech = role == 'technician';
    _currentUser = UserModel(
      id: isTech ? 1 : 1,
      name: isTech ? "Rahul Kumar" : "Priyanshu",
      email: isTech ? "tech@test.com" : "user@test.com",
      phone: phone.isNotEmpty ? phone : (isTech ? "+91 98765 43210" : "+91 98765 12345"),
      role: role,
      avatar: isTech
          ? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"
          : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
      address: isTech ? "Sector 3, Mansarovar, Jaipur" : "B-42, Vaishali Nagar, Jaipur, Rajasthan",
      token: "demo-local-token",
      technicianProfile: isTech
          ? {
              "id": 1,
              "name": "Rahul Kumar",
              "speciality": "AC Specialist",
              "rating": 4.8,
              "is_online": true,
              "today_earnings": 2850.0,
              "completed_jobs_count": 4,
            }
          : null,
    );

    await _saveSession();
    notifyListeners();
    return true;
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
    required String role,
  }) async {
    final res = await ApiService.login(
      email: email,
      password: password,
      role: role,
    );

    if (res != null && res['success'] == true && res['user'] != null) {
      _currentUser = UserModel.fromJson(
        res['user'],
        token: res['token'],
        technicianProfile: res['technician'],
      );
      await _saveSession();
      notifyListeners();
      return true;
    }

    // Offline fallback
    final isTech = role == 'technician' || email.contains('tech');
    _currentUser = UserModel(
      id: 1,
      name: isTech ? "Rahul Kumar" : (email.split('@').first.isNotEmpty ? email.split('@').first : "Priyanshu"),
      email: email,
      phone: isTech ? "+91 98765 43210" : "+91 98765 12345",
      role: isTech ? 'technician' : 'user',
      avatar: isTech
          ? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"
          : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
      address: isTech ? "Sector 3, Mansarovar, Jaipur" : "Vaishali Nagar, Jaipur",
      token: "demo-local-token",
    );

    await _saveSession();
    notifyListeners();
    return true;
  }

  Future<void> quickDemoLogin(String role) async {
    if (role == 'technician') {
      await loginWithPhone(
        phone: "+91 98765 43210",
        otp: "1234",
        role: "technician",
      );
    } else {
      await loginWithPhone(
        phone: "+91 98765 12345",
        otp: "1234",
        role: "user",
      );
    }
  }

  Future<void> switchRole(String newRole) async {
    if (_currentUser == null) return;
    _currentUser = UserModel(
      id: _currentUser!.id,
      name: newRole == 'technician' ? "Rahul Kumar" : "Priyanshu",
      email: newRole == 'technician' ? "tech@test.com" : "user@test.com",
      phone: _currentUser!.phone,
      role: newRole,
      avatar: newRole == 'technician'
          ? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"
          : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150",
      address: _currentUser!.address,
      token: _currentUser!.token,
    );
    await _saveSession();
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userPrefKey);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _saveSession() async {
    if (_currentUser == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(_currentUser!.toJson());
      await prefs.setString(_userPrefKey, jsonStr);
    } catch (_) {}
  }
}
