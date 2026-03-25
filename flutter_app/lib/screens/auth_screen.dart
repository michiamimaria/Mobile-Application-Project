import 'package:flutter/material.dart';

import '../services/account_store.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Shows **Create account** first, with a switch to Sign in.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.onAuthenticated,
  });

  final void Function(String email, {String displayName}) onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _showRegister = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _showRegister
          ? RegisterScreen(
              key: const ValueKey('register'),
              onRegister: AccountStore.instance.register,
              onRegistered: widget.onAuthenticated,
              onGoToLogin: () => setState(() => _showRegister = false),
            )
          : LoginScreen(
              key: const ValueKey('login'),
              onLogin: AccountStore.instance.login,
              onAuthenticated: (email) {
                widget.onAuthenticated(
                  email,
                  displayName: AccountStore.instance.displayNameFor(email),
                );
              },
              onGoToRegister: () => setState(() => _showRegister = true),
            ),
    );
  }
}
