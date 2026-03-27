import 'package:flutter/foundation.dart';

/// Profile data shown on Home and editable on Profile.
@immutable
class UserProfile {
  const UserProfile({
    required this.email,
    this.displayName = '',
    this.bio = '',
    this.location = '',
    this.avatarBytes,
  });

  final String email;
  final String displayName;
  final String bio;
  final String location;
  final Uint8List? avatarBytes;

  factory UserProfile.fromEmail(String email) =>
      UserProfile(email: email.trim());

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? bio,
    String? location,
    Uint8List? avatarBytes,
    bool clearAvatar = false,
  }) {
    return UserProfile(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      avatarBytes: clearAvatar ? null : (avatarBytes ?? this.avatarBytes),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.email == email &&
        other.displayName == displayName &&
        other.bio == bio &&
        other.location == location &&
        listEquals(other.avatarBytes, avatarBytes);
  }

  @override
  int get hashCode {
    final b = avatarBytes;
    return Object.hash(
      email,
      displayName,
      bio,
      location,
      b == null || b.isEmpty ? 0 : Object.hash(b.length, b.first, b.last),
    );
  }
}
