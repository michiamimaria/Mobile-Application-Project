import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local demo storage for email → password and display names. Not for production.
class AccountStore {
  AccountStore._();
  static final AccountStore instance = AccountStore._();

  static const _prefsKey = 'mobilni_demo_accounts_v1';
  static const _namesKey = 'mobilni_demo_display_names_v1';

  final Map<String, String> _passwordByEmail = {};
  final Map<String, String> _displayNameByEmail = {};

  Future<void> load() async {
    _passwordByEmail.clear();
    _displayNameByEmail.clear();
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _passwordByEmail.addEntries(
          map.entries.map((e) => MapEntry(e.key, e.value as String)),
        );
      } catch (_) {}
    }

    final namesRaw = prefs.getString(_namesKey);
    if (namesRaw != null && namesRaw.isNotEmpty) {
      try {
        final map = jsonDecode(namesRaw) as Map<String, dynamic>;
        _displayNameByEmail.addEntries(
          map.entries.map((e) => MapEntry(e.key, e.value as String)),
        );
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_passwordByEmail));
    await prefs.setString(_namesKey, jsonEncode(_displayNameByEmail));
  }

  String displayNameFor(String email) {
    return _displayNameByEmail[email.trim().toLowerCase()] ?? '';
  }

  /// Returns `null` on success, or an error message.
  Future<String?> register(
    String email,
    String password,
    String displayName,
  ) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty) return 'Enter an email address.';
    if (!e.contains('@')) return 'Enter a valid email.';
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (_passwordByEmail.containsKey(e)) {
      return 'This email is already registered. Sign in instead.';
    }
    _passwordByEmail[e] = password;
    _displayNameByEmail[e] = displayName.trim();
    await _save();
    return null;
  }

  /// Returns `null` on success, or an error message.
  Future<String?> login(String email, String password) async {
    final e = email.trim().toLowerCase();
    if (e.isEmpty) return 'Enter your email.';
    if (!_passwordByEmail.containsKey(e)) {
      return 'No account for this email. Create an account first.';
    }
    if (_passwordByEmail[e] != password) {
      return 'Incorrect password.';
    }
    return null;
  }
}
