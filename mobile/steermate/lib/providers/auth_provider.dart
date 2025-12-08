import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  bool _hasSeenOnboarding = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasSeenOnboarding = await _storage.getSetting<bool>('has_seen_onboarding') ?? false;
      _isAuthenticated = await _authService.isLoggedIn();
      if (_isAuthenticated) {
        _user = await _authService.getCurrentUser();
        if (_user == null) {
          // Token exists but no cached user, fetch from API
          _user = await _authService.getProfile();
        }
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        password: password,
        name: name,
      );
      // Auto-login after registration
      return await login(email: email, password: password);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      _user = await _authService.getProfile();
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfile({String? name}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.updateProfile(name: name);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setOnboardingSeen() async {
    await _storage.saveSetting('has_seen_onboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
