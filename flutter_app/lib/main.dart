import 'package:flutter/material.dart';

import 'models/user_profile.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loggedIn = false;
  ThemeMode _themeMode = ThemeMode.system;
  String? _userEmail;
  UserProfile? _profile;

  void _handleAuthSuccess(String email, {required String displayName}) {
    final e = email.trim();
    setState(() {
      _loggedIn = true;
      _userEmail = e;
      _profile = UserProfile.fromEmail(e).copyWith(
        displayName: displayName.trim(),
      );
    });
  }

  void _handleLoggedOut() {
    setState(() {
      _loggedIn = false;
      _userEmail = null;
      _profile = null;
    });
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  void _onProfileChanged(UserProfile profile) {
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luggage Checker',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.88,
          maxScaleFactor: 1.28,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: _loggedIn && _userEmail != null && _profile != null
            ? HomeShell(
                key: const ValueKey('home'),
                userEmail: _userEmail!,
                profile: _profile!,
                onProfileChanged: _onProfileChanged,
                themeMode: _themeMode,
                onThemeModeChanged: _setThemeMode,
                onLogout: _handleLoggedOut,
              )
            : AuthScreen(
                key: const ValueKey('auth'),
                onSuccess: _handleAuthSuccess,
              ),
      ),
    );
  }
}
