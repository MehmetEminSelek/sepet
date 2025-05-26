import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Demo authentication service - Firebase olmadan test için
class DemoAuthService {
  static final DemoAuthService _instance = DemoAuthService._internal();
  factory DemoAuthService() => _instance;
  DemoAuthService._internal();

  // Stream controller for auth state
  final StreamController<DemoUser?> _authStateController =
      StreamController<DemoUser?>.broadcast();

  DemoUser? _currentUser;

  // Demo kullanıcılar - test için
  static final Map<String, DemoUserData> _demoUsers = {
    'dev@sepet.com': DemoUserData(
      uid: 'demo_dev_001',
      email: 'dev@sepet.com',
      password: 'dev123',
      displayName: 'Geliştirici',
    ),
    'test@sepet.com': DemoUserData(
      uid: 'demo_test_002',
      email: 'test@sepet.com',
      password: 'test123',
      displayName: 'Test Kullanıcısı',
    ),
    'demo@sepet.com': DemoUserData(
      uid: 'demo_user_003',
      email: 'demo@sepet.com',
      password: 'demo123',
      displayName: 'Demo User',
    ),
    'admin@sepet.com': DemoUserData(
      uid: 'demo_admin_004',
      email: 'admin@sepet.com',
      password: 'admin123',
      displayName: 'Admin',
    ),
  };

  // Auth state stream
  Stream<DemoUser?> get authStateChanges => _authStateController.stream;

  // Current user
  DemoUser? get currentUser => _currentUser;

  // Current user model
  Future<UserModel?> get currentUserModel async {
    if (_currentUser == null) return null;

    return UserModel(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      displayName: _currentUser!.displayName,
      photoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastLoginAt: DateTime.now(),
    );
  }

  // Initialize - check for saved session
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('demo_current_user');

    if (savedUserId != null) {
      // Kullanıcıyı geri yükle
      final userData = _demoUsers.values.firstWhere(
        (user) => user.uid == savedUserId,
        orElse: () => _demoUsers.values.first,
      );

      _currentUser = DemoUser(
        uid: userData.uid,
        email: userData.email,
        displayName: userData.displayName,
      );

      _authStateController.add(_currentUser);
    } else {
      _authStateController.add(null);
    }
  }

  // Email/Password ile giriş yap
  Future<DemoUser?> signInWithEmailPassword(
      String email, String password) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay

    final userData = _demoUsers[email.toLowerCase()];

    if (userData == null) {
      throw 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
    }

    if (userData.password != password) {
      throw 'Yanlış şifre';
    }

    _currentUser = DemoUser(
      uid: userData.uid,
      email: userData.email,
      displayName: userData.displayName,
    );

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('demo_current_user', _currentUser!.uid);

    _authStateController.add(_currentUser);

    return _currentUser;
  }

  // Email/Password ile kayıt ol
  Future<DemoUser?> registerWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate network delay

    if (_demoUsers.containsKey(email.toLowerCase())) {
      throw 'Bu e-posta adresi zaten kullanımda';
    }

    if (password.length < 6) {
      throw 'Şifre en az 6 karakter olmalı';
    }

    // Yeni kullanıcı oluştur
    final newUid = 'demo_new_${DateTime.now().millisecondsSinceEpoch}';
    final newUserData = DemoUserData(
      uid: newUid,
      email: email.toLowerCase(),
      password: password,
      displayName: displayName,
    );

    _demoUsers[email.toLowerCase()] = newUserData;

    _currentUser = DemoUser(
      uid: newUid,
      email: email.toLowerCase(),
      displayName: displayName,
    );

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('demo_current_user', _currentUser!.uid);

    _authStateController.add(_currentUser);

    return _currentUser;
  }

  // Google ile giriş yap (demo)
  Future<DemoUser?> signInWithGoogle() async {
    await Future.delayed(
        const Duration(milliseconds: 600)); // Simulate network delay

    // Google demo kullanıcısı
    _currentUser = DemoUser(
      uid: 'demo_google_001',
      email: 'google.user@gmail.com',
      displayName: 'Google Demo User',
    );

    // Save session
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('demo_current_user', _currentUser!.uid);

    _authStateController.add(_currentUser);

    return _currentUser;
  }

  // Şifre sıfırlama (demo)
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_demoUsers.containsKey(email.toLowerCase())) {
      throw 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
    }

    // Demo - sadece başarı mesajı
  }

  // Çıkış yap
  Future<void> signOut() async {
    _currentUser = null;

    // Clear session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('demo_current_user');

    _authStateController.add(null);
  }

  // Demo kullanıcı listesi (debug için)
  Map<String, String> get demoUserCredentials {
    return _demoUsers.map(
        (email, userData) => MapEntry(email, 'Şifre: ${userData.password}'));
  }

  void dispose() {
    _authStateController.close();
  }
}

// Demo user sınıfları
class DemoUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;

  DemoUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

class DemoUserData {
  final String uid;
  final String email;
  final String password;
  final String displayName;

  DemoUserData({
    required this.uid,
    required this.email,
    required this.password,
    required this.displayName,
  });
}
