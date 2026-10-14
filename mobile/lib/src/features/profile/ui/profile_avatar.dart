import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/profile/logic/user_avatar.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.user,
    this.size = 96,
    this.onTap,
    this.showEditBadge = false,
    super.key,
  });

  final User user;
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  @override
  Widget build(BuildContext context) {
    final avatarAsset = resolveUserAvatarAsset(user);
    final avatarUrl = resolveUserAvatarUrl(user);
    final initials = getUserInitials(user.name);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              color: colorScheme.primaryContainer,
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarAsset != null
                ? SvgPicture.asset(avatarAsset, fit: BoxFit.cover)
                : avatarUrl != null && avatarUrl.endsWith('.svg')
                ? SvgPicture.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) =>
                        _AvatarFallback(initials: initials, size: size),
                  )
                : avatarUrl != null
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _AvatarFallback(initials: initials, size: size),
                  )
                : _AvatarFallback(initials: initials, size: size),
          ),
          if (showEditBadge)
            Positioned(
              right: -2,
              top: size - 34,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.3,
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
