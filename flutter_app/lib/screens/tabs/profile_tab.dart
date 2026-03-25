import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onLogout,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final Future<void> Function() onLogout;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.displayName);
    _bioCtrl = TextEditingController(text: widget.profile.bio);
    _locationCtrl = TextEditingController(text: widget.profile.location);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile != widget.profile) {
      if (_nameCtrl.text != widget.profile.displayName) {
        _nameCtrl.text = widget.profile.displayName;
      }
      if (_bioCtrl.text != widget.profile.bio) {
        _bioCtrl.text = widget.profile.bio;
      }
      if (_locationCtrl.text != widget.profile.location) {
        _locationCtrl.text = widget.profile.location;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String get _avatarLetter {
    final n = widget.profile.displayName.trim();
    if (n.isNotEmpty) return n[0].toUpperCase();
    final local = widget.profile.email.split('@').first;
    if (local.isEmpty) return '?';
    return local[0].toUpperCase();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
      );
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      widget.onProfileChanged(
        widget.profile.copyWith(
          avatarBytes: bytes,
          displayName: _nameCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
        ),
      );
    } catch (e, st) {
      assert(() {
        debugPrint('Image pick failed: $e\n$st');
        return true;
      }());
      if (!mounted) return;
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the image picker. Check browser permissions.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not load the image. Try again or pick a smaller file.',
            ),
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            if (widget.profile.avatarBytes != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: scheme.error),
                title: Text(
                  'Remove photo',
                  style: TextStyle(color: scheme.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onProfileChanged(
                    widget.profile.copyWith(
                      clearAvatar: true,
                      displayName: _nameCtrl.text.trim(),
                      bio: _bioCtrl.text.trim(),
                      location: _locationCtrl.text.trim(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    widget.onProfileChanged(
      widget.profile.copyWith(
        displayName: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text('Profile saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          'Photo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: scheme.primaryContainer,
                      backgroundImage: widget.profile.avatarBytes != null
                          ? MemoryImage(widget.profile.avatarBytes!)
                          : null,
                      child: widget.profile.avatarBytes == null
                          ? Text(
                              _avatarLetter,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: scheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Material(
                        color: scheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _showPhotoOptions,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile picture',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the camera to use gallery${kIsWeb ? '' : ' or camera'}, or remove the photo.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showPhotoOptions,
                        child: const Text('Change photo'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'About you',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Email',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.profile.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    hintText: 'How we greet you on Home',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'City / region',
                    hintText: 'Optional — e.g. Skopje',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bioCtrl,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'A short line about you',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save profile'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto_rounded, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined, size: 18),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined, size: 18),
            ),
          ],
          selected: {widget.themeMode},
          onSelectionChanged: (s) {
            if (s.isNotEmpty) widget.onThemeModeChanged(s.first);
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Support',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                subtitle: const Text('Notifications, privacy (demo)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: const Text('Settings are not wired in this demo.'),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Help & FAQ'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: const Text('Help center (demo).'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Mobilni v1.0.0',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.outline,
                ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => widget.onLogout(),
          icon: Icon(Icons.logout_rounded, color: scheme.error),
          label: Text(
            'Sign out',
            style: TextStyle(
              color: scheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.errorContainer.withValues(alpha: 0.55),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
