import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _DiscoverCategory {
  all,
  trending,
  food,
  outdoors,
  culture,
  nightlife,
  family,
}

enum _DiscoverSort { featured, az, za }

extension on _DiscoverCategory {
  String get label {
    switch (this) {
      case _DiscoverCategory.all:
        return 'All';
      case _DiscoverCategory.trending:
        return 'Trending';
      case _DiscoverCategory.food:
        return 'Food';
      case _DiscoverCategory.outdoors:
        return 'Outdoors';
      case _DiscoverCategory.culture:
        return 'Culture';
      case _DiscoverCategory.nightlife:
        return 'Nightlife';
      case _DiscoverCategory.family:
        return 'Family';
    }
  }

  IconData get icon {
    switch (this) {
      case _DiscoverCategory.all:
        return Icons.dashboard_outlined;
      case _DiscoverCategory.trending:
        return Icons.local_fire_department_outlined;
      case _DiscoverCategory.food:
        return Icons.restaurant_outlined;
      case _DiscoverCategory.outdoors:
        return Icons.park_outlined;
      case _DiscoverCategory.culture:
        return Icons.museum_outlined;
      case _DiscoverCategory.nightlife:
        return Icons.nightlife_outlined;
      case _DiscoverCategory.family:
        return Icons.family_restroom_outlined;
    }
  }
}

class _Place {
  const _Place({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.rating,
    required this.distanceLabel,
    required this.highlights,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final _DiscoverCategory category;
  final double rating;
  final String distanceLabel;
  final List<String> highlights;
}

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  static const List<_Place> _all = [
    _Place(
      id: 'nearby',
      title: 'Nearby picks',
      subtitle: 'Curated for your area',
      icon: Icons.place_outlined,
      category: _DiscoverCategory.trending,
      rating: 4.7,
      distanceLabel: '0.8 km',
      highlights: ['Open now', 'Locals love it'],
    ),
    _Place(
      id: 'trending',
      title: 'Trending',
      subtitle: 'Popular this week',
      icon: Icons.local_fire_department_outlined,
      category: _DiscoverCategory.trending,
      rating: 4.9,
      distanceLabel: '12 min',
      highlights: ['Busy evenings', 'Photo spots'],
    ),
    _Place(
      id: 'weekend',
      title: 'Weekend ideas',
      subtitle: 'Short trips & events',
      icon: Icons.event_outlined,
      category: _DiscoverCategory.culture,
      rating: 4.5,
      distanceLabel: '25 min',
      highlights: ['This Saturday', 'Tickets available'],
    ),
    _Place(
      id: 'food',
      title: 'Food & drink',
      subtitle: 'Cafés and restaurants',
      icon: Icons.restaurant_outlined,
      category: _DiscoverCategory.food,
      rating: 4.6,
      distanceLabel: '1.2 km',
      highlights: ['Outdoor seating', 'Vegan options'],
    ),
    _Place(
      id: 'outdoors',
      title: 'Outdoors',
      subtitle: 'Parks and trails',
      icon: Icons.forest_outlined,
      category: _DiscoverCategory.outdoors,
      rating: 4.8,
      distanceLabel: '3.4 km',
      highlights: ['Easy trail', 'Dog friendly'],
    ),
    _Place(
      id: 'culture',
      title: 'Culture',
      subtitle: 'Museums and shows',
      icon: Icons.museum_outlined,
      category: _DiscoverCategory.culture,
      rating: 4.4,
      distanceLabel: '2.1 km',
      highlights: ['Guided tours', 'Family discount'],
    ),
    _Place(
      id: 'nightlife',
      title: 'Nightlife',
      subtitle: 'Music and venues',
      icon: Icons.nightlife_outlined,
      category: _DiscoverCategory.nightlife,
      rating: 4.3,
      distanceLabel: '1.8 km',
      highlights: ['Live music', 'Late hours'],
    ),
    _Place(
      id: 'family',
      title: 'Family',
      subtitle: 'Kid-friendly spots',
      icon: Icons.family_restroom_outlined,
      category: _DiscoverCategory.family,
      rating: 4.7,
      distanceLabel: '4 km',
      highlights: ['Play area', 'Parking'],
    ),
  ];

  final _search = TextEditingController();
  _DiscoverCategory _category = _DiscoverCategory.all;
  _DiscoverSort _sort = _DiscoverSort.featured;
  bool _gridView = false;
  final Set<String> _savedIds = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<_Place> get _result {
    var list = _category == _DiscoverCategory.all
        ? List<_Place>.from(_all)
        : _all.where((p) => p.category == _category).toList();

    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (p) =>
                p.title.toLowerCase().contains(q) ||
                p.subtitle.toLowerCase().contains(q) ||
                p.highlights.any((h) => h.toLowerCase().contains(q)),
          )
          .toList();
    }

    switch (_sort) {
      case _DiscoverSort.featured:
        break;
      case _DiscoverSort.az:
        list.sort((a, b) => a.title.compareTo(b.title));
      case _DiscoverSort.za:
        list.sort((a, b) => b.title.compareTo(a.title));
    }
    return list;
  }

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() {});
  }

  void _toggleSave(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _search.clear();
      _category = _DiscoverCategory.all;
      _sort = _DiscoverSort.featured;
    });
  }

  void _showPlaceDetail(_Place place) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            final saved = _savedIds.contains(place.id);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(ctx).bottom + 16,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.primary,
                                scheme.primary.withValues(alpha: 0.75),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            place.icon,
                            color: scheme.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                place.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            _toggleSave(place.id);
                            setModal(() {});
                          },
                          icon: Icon(
                            saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          ),
                          tooltip: saved ? 'Saved' : 'Save',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.star_rounded,
                          label: place.rating.toStringAsFixed(1),
                          color: scheme.tertiaryContainer,
                          onColor: scheme.onTertiaryContainer,
                        ),
                        _MetaChip(
                          icon: Icons.near_me_outlined,
                          label: place.distanceLabel,
                          color: scheme.secondaryContainer,
                          onColor: scheme.onSecondaryContainer,
                        ),
                        Chip(
                          avatar: Icon(
                            place.category.icon,
                            size: 18,
                            color: scheme.primary,
                          ),
                          label: Text(place.category.label),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Highlights',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...place.highlights.map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 20,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                h,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Directions to ${place.title} (demo)'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.directions_outlined),
                            label: const Text('Directions'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.explore_rounded),
                            label: const Text('Got it'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = _result;
    final showFeaturedStrip = _category == _DiscoverCategory.all &&
        _search.text.isEmpty &&
        items.length >= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: _search,
                  hintText: 'Search places, highlights…',
                  leading: const Icon(Icons.search_rounded),
                  trailing: [
                    if (_search.text.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          setState(() => _search.clear());
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                  onChanged: (_) => setState(() {}),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    scheme.surfaceContainerHighest,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: _gridView ? 'List view' : 'Grid view',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _gridView = !_gridView);
                },
                icon: Icon(
                  _gridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                ),
              ),
              PopupMenuButton<_DiscoverSort>(
                tooltip: 'Sort',
                initialValue: _sort,
                onSelected: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _sort = v);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: _DiscoverSort.featured,
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.auto_awesome_outlined),
                      title: Text('Featured order'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: _DiscoverSort.az,
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.sort_by_alpha_rounded),
                      title: Text('Title A → Z'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: _DiscoverSort.za,
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.sort_by_alpha_rounded),
                      title: Text('Title Z → A'),
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.sort_rounded, color: scheme.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final c in _DiscoverCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(
                      c.icon,
                      size: 18,
                      color: _category == c
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _category = selected ? c : _DiscoverCategory.all;
                      });
                    },
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Row(
            children: [
              Text(
                '${items.length} place${items.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (_savedIds.isNotEmpty) ...[
                const SizedBox(width: 8),
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text('${_savedIds.length} saved'),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
              const Spacer(),
              Icon(Icons.sort_rounded, size: 14, color: scheme.outline),
              const SizedBox(width: 4),
              Text(
                _sort == _DiscoverSort.featured
                    ? 'Featured'
                    : _sort == _DiscoverSort.az
                        ? 'A–Z'
                        : 'Z–A',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.outline,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            child: items.isEmpty
                ? _DiscoverEmpty(
                    key: const ValueKey('discover_empty'),
                    scheme: scheme,
                    onClearFilters: _resetFilters,
                  )
                : _gridView
                    ? _DiscoverGrid(
                        key: ValueKey('grid_${items.length}_${_category.name}'),
                        items: items,
                        savedIds: _savedIds,
                        onSaveToggle: _toggleSave,
                        onOpen: _showPlaceDetail,
                        onRefresh: _onRefresh,
                      )
                    : _DiscoverList(
                        key: ValueKey('list_${items.length}_${_category.name}'),
                        items: items,
                        savedIds: _savedIds,
                        onSaveToggle: _toggleSave,
                        onOpen: _showPlaceDetail,
                        onRefresh: _onRefresh,
                        showFeaturedStrip: showFeaturedStrip,
                        featured: items.take(3).toList(),
                      ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: onColor),
      label: Text(label),
      backgroundColor: color,
      labelStyle: TextStyle(color: onColor, fontWeight: FontWeight.w600),
      side: BorderSide.none,
    );
  }
}

class _DiscoverEmpty extends StatelessWidget {
  const _DiscoverEmpty({
    super.key,
    required this.scheme,
    required this.onClearFilters,
  });

  final ColorScheme scheme;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 56,
              color: scheme.primary.withValues(alpha: 0.65),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing here yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different category or clear your search to see more places.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Reset filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverGrid extends StatelessWidget {
  const _DiscoverGrid({
    super.key,
    required this.items,
    required this.savedIds,
    required this.onSaveToggle,
    required this.onOpen,
    required this.onRefresh,
  });

  final List<_Place> items;
  final Set<String> savedIds;
  final ValueChanged<String> onSaveToggle;
  final ValueChanged<_Place> onOpen;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: 8,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.88,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final p = items[i];
          return _PlaceCard(
            place: p,
            dense: true,
            saved: savedIds.contains(p.id),
            onSaveToggle: () => onSaveToggle(p.id),
            onOpen: () => onOpen(p),
          );
        },
      ),
    );
  }
}

class _DiscoverList extends StatelessWidget {
  const _DiscoverList({
    super.key,
    required this.items,
    required this.savedIds,
    required this.onSaveToggle,
    required this.onOpen,
    required this.onRefresh,
    required this.showFeaturedStrip,
    required this.featured,
  });

  final List<_Place> items;
  final Set<String> savedIds;
  final ValueChanged<String> onSaveToggle;
  final ValueChanged<_Place> onOpen;
  final Future<void> Function() onRefresh;
  final bool showFeaturedStrip;
  final List<_Place> featured;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      edgeOffset: 8,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (showFeaturedStrip) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured for you',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 132,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: featured.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final p = featured[i];
                          return _FeaturedCard(
                            place: p,
                            onTap: () => onOpen(p),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = items[i];
                return _PlaceCard(
                  place: p,
                  dense: false,
                  saved: savedIds.contains(p.id),
                  onSaveToggle: () => onSaveToggle(p.id),
                  onOpen: () => onOpen(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.place,
    required this.onTap,
  });

  final _Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        place.icon,
                        color: scheme.onPrimaryContainer,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.star_rounded, color: scheme.tertiary, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      place.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  place.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  place.distanceLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.dense,
    required this.saved,
    required this.onSaveToggle,
    required this.onOpen,
  });

  final _Place place;
  final bool dense;
  final bool saved;
  final VoidCallback onSaveToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (dense) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary.withValues(alpha: 0.9),
                            scheme.primary.withValues(alpha: 0.55),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        place.icon,
                        color: scheme.onPrimary,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onSaveToggle,
                      icon: Icon(
                        saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        color: saved ? scheme.primary : scheme.outline,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  place.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: scheme.tertiary),
                    const SizedBox(width: 2),
                    Text(
                      place.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·',
                      style: TextStyle(color: scheme.outline),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.distanceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primaryContainer,
                      scheme.primaryContainer.withValues(alpha: 0.65),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  place.icon,
                  color: scheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                          avatar: Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: scheme.tertiary,
                          ),
                          label: Text(place.rating.toStringAsFixed(1)),
                        ),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                          avatar: Icon(
                            Icons.near_me_outlined,
                            size: 16,
                            color: scheme.primary,
                          ),
                          label: Text(place.distanceLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSaveToggle,
                icon: Icon(
                  saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  color: saved ? scheme.primary : scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
