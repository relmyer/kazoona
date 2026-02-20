import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  Uint8List? _profileImageBytes;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  Uint8List? get profileImageBytes => _profileImageBytes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  final _uuid = const Uuid();

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId');
    if (id != null) {
      _currentUser = AppUser(
        id: id,
        username: prefs.getString('username') ?? 'Kazooner',
        email: prefs.getString('email') ?? '',
        avatarEmoji: prefs.getString('avatarEmoji') ?? '😎',
        totalGamesPlayed: prefs.getInt('totalGamesPlayed') ?? 0,
        totalCardsScratched: prefs.getInt('totalCardsScratched') ?? 0,
      );
      notifyListeners();
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String avatarEmoji,
    Uint8List? profileImageBytes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final user = AppUser(
        id: _uuid.v4(),
        username: username.isEmpty ? 'Kazooner' : username,
        email: email,
        avatarEmoji: avatarEmoji,
      );

      await _saveUser(user);
      _currentUser = user;
      _profileImageBytes = profileImageBytes;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Kayıt sırasında hata oluştu';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');

      if (savedEmail == email || email.isNotEmpty) {
        final user = AppUser(
          id: prefs.getString('userId') ?? _uuid.v4(),
          username: prefs.getString('username') ?? 'Kazooner',
          email: email,
          avatarEmoji: prefs.getString('avatarEmoji') ?? '😎',
        );
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'E-posta veya şifre hatalı';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Giriş sırasında hata oluştu';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUser = null;
    _profileImageBytes = null;
    notifyListeners();
  }

  Future<void> _saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('avatarEmoji', user.avatarEmoji);
    await prefs.setInt('totalGamesPlayed', user.totalGamesPlayed);
    await prefs.setInt('totalCardsScratched', user.totalCardsScratched);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
