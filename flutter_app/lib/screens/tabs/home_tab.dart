import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../widgets/brand_hero_icon.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _refreshing = false;

  String get _greetingName {
    final n = widget.profile.displayName.trim();
    if (n.isNotEmpty) return n;
    final local = widget.profile.email.split('@').first;
    if (local.isEmpty) return 'there';
    final segment = local.split(RegExp(r'[._-]')).firstWhere(
          (s) => s.isNotEmpty,
          orElse: () => local,
        );
    return segment[0].toUpperCase() +
        (segment.length > 1 ? segment.substring(1) : '');
  }

  String get _initial {
    final n = widget.profile.displayName.trim();
    if (n.isNotEmpty) return n[0].toUpperCase();
    final local = widget.profile.email.split('@').first;
    if (local.isEmpty) return '?';
    return local[0].toUpperCase();
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bioPreview = widget.profile.bio.trim();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      edgeOffset: 12,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Card(
            elevation: 0,
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BrandHeroIcon(
                        size: 30,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: scheme.primaryContainer,
                        backgroundImage: widget.profile.avatarBytes != null
                            ? MemoryImage(widget.profile.avatarBytes!)
                            : null,
                        child: widget.profile.avatarBytes == null
                            ? Text(
                                _initial,
                                style: TextStyle(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $_greetingName',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.profile.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (_refreshing)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  if (bioPreview.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      bioPreview,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                  ],
                  if (widget.profile.location.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 18, color: scheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.profile.location.trim(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh. Edit your photo and details in Profile.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'At a glance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.notifications_active_outlined,
                  label: 'Alerts',
                  value: '0 new',
                  color: scheme.tertiaryContainer,
                  onColor: scheme.onTertiaryContainer,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: const Text('You are all caught up.'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.bookmark_outline_rounded,
                  label: 'Saved',
                  value: '3 items',
                  color: scheme.secondaryContainer,
                  onColor: scheme.onSecondaryContainer,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: const Text('Saved items (demo data).'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Shortcuts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionChip(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Open the Discover tab to search and filter.'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionChip(
                  icon: Icons.edit_outlined,
                  label: 'Profile',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile tab — add a photo and your info.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color onColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: onColor, size: 26),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: onColor.withValues(alpha: 0.85),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: onColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
