import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/chat/ui/new_direct_chat_page.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

void main() {
  testWidgets(
    'picker renders without card wrapper and shows coworker avatars',
    (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
      expect(
        find.byKey(const ValueKey('new_direct_chat_page')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('new_direct_chat_avatar_coworker-minh-anh')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('new_direct_chat_avatar_coworker-phuong-linh'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('coworker avatars use ProfileAvatar', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    final avatar = tester.widget<ProfileAvatar>(
      find.byKey(const ValueKey('new_direct_chat_avatar_coworker-minh-anh')),
    );

    expect(avatar.user.name, 'Minh Anh');
    expect(avatar.size, 44);
  });
}

Widget _buildPage() {
  return UncontrolledProviderScope(
    container: ProviderContainer(),
    child: MaterialApp(theme: buildAppTheme(), home: const NewDirectChatPage()),
  );
}
