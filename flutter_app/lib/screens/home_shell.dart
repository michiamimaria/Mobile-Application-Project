import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import 'tabs/discover_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.userEmail,
    required this.profile,
    required this.onProfileChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  final String userEmail;
  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late List<Widget> _pages;

  void _buildPages() {
    _pages = [
      HomeTab(profile: widget.profile),
      const DiscoverTab(),
      ProfileTab(
        profile: widget.profile,
        onProfileChanged: widget.onProfileChanged,
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        onLogout: _confirmLogout,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userEmail != widget.userEmail ||
        oldWidget.themeMode != widget.themeMode ||
        oldWidget.profile != widget.profile) {
      _buildPages();
    }
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.logout_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      widget.onLogout();
    }
  }

  String get _title {
    switch (_index) {
      case 0:
        return 'Home';
      case 1:
        return 'Discover';
      case 2:
        return 'Profile';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: Text(
            _title,
            key: ValueKey<String>(_title),
          ),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i != _index) {
            HapticFeedback.selectionClick();
          }
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
