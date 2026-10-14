import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/profile/logic/user_avatar.dart';

void main() {
  final appConfig = AppConfig.parse(
    apiBaseUrl: 'http://obee.local/api',
    appBaseUrl: 'http://obee.local',
  );

  test('builds initials from full name', () {
    expect(getUserInitials('Admin User'), 'AU');
  });

  test('rejects invalid required name when building initials', () {
    expect(() => getUserInitials(''), throwsStateError);
  });

  test('resolves seeded avatar to bundled asset', () {
    const user = User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'user-1',
      name: 'Admin',
      username: 'admin',
      email: 'admin@example.com',
      avatar: '/avatars/avatar-4.svg',
    );

    expect(resolveUserAvatarAsset(user), 'assets/avatars/avatar-4.svg');
    expect(resolveUserAvatarUrl(user), isNull);
  });

  testWidgets('loads bundled avatar asset', (tester) async {
    const user = User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'user-1',
      name: 'Admin',
      username: 'admin',
      email: 'admin@example.com',
      avatar: '/avatars/avatar-4.svg',
    );
    final assetPath = resolveUserAvatarAsset(user);

    await tester.pumpWidget(MaterialApp(home: SvgPicture.asset(assetPath!)));
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  test('resolves remote avatar url', () {
    const user = User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'user-1',
      name: 'Admin',
      username: 'admin',
      email: 'admin@example.com',
      avatar: '/storage/users/avatar.png',
    );

    expect(resolveUserAvatarAsset(user), isNull);
    expect(
      resolveUserAvatarUrlWithConfig(user, appConfig: appConfig),
      'http://obee.local/storage/users/avatar.png',
    );
  });

  test('rejects unsupported avatar contract', () {
    const user = User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'user-1',
      name: 'Admin',
      username: 'admin',
      email: 'admin@example.com',
      avatar: 'avatar.png',
    );

    expect(
      () => resolveUserAvatarUrlWithConfig(user, appConfig: appConfig),
      throwsFormatException,
    );
  });
}
