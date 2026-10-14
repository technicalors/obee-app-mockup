import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';

final _bundledAvatarPattern = RegExp(r'^/avatars/(avatar-\d+\.svg)$');

String getUserInitials(String name) {
  final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);

  if (parts.isEmpty) {
    throw StateError('User name contract is invalid.');
  }

  if (parts.length == 1) {
    return parts.first[0].toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String? resolveUserAvatarAsset(User user) {
  final avatar = user.avatar;
  if (avatar == null) {
    return null;
  }

  final match = _bundledAvatarPattern.firstMatch(avatar);
  if (match == null) {
    return null;
  }

  return 'assets/avatars/${match.group(1)}';
}

String? resolveUserAvatarUrl(User user) {
  final avatar = user.avatar;
  if (avatar == null) {
    return null;
  }

  if (_bundledAvatarPattern.hasMatch(avatar)) {
    return null;
  }

  if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
    return avatar;
  }

  return resolveUserAvatarUrlWithConfig(user, appConfig: AppConfig.current);
}

String? resolveUserAvatarUrlWithConfig(
  User user, {
  required AppConfig appConfig,
}) {
  final avatar = user.avatar;
  if (avatar == null || _bundledAvatarPattern.hasMatch(avatar)) {
    return null;
  }

  if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
    return avatar;
  }

  if (!avatar.startsWith('/') &&
      !avatar.startsWith('upload/') &&
      !avatar.startsWith('storage/')) {
    throw FormatException('User avatar contract is invalid: $avatar');
  }

  final normalized = avatar.startsWith('/') ? avatar : '/$avatar';
  return appConfig.appBaseUri.resolve(normalized).toString();
}
