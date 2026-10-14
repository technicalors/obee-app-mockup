import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/chat/ui/chat_hub_page.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/chat_conversation_avatar.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/unread_count_indicator.dart';

void main() {
  testWidgets('General tab shows writable and read-only channels', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('chat_hub_general_content')),
      findsOneWidget,
    );
    expect(find.byType(Card), findsNothing);
    expect(find.text('Kênh công ty'), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Chỉ đọc'), findsNothing);
    expect(
      find.byKey(
        const ValueKey('general_channel_read_only_icon_announcements'),
      ),
      findsOneWidget,
    );
    expect(find.text('Cộng đồng'), findsNothing);
    expect(find.text('Chung'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('chat_hub_tab_general')),
        matching: find.byType(UnreadCountIndicator),
      ),
      findsOneWidget,
    );
  });

  testWidgets('General channel rows render preview metadata and unread state', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(find.text('Linh: Họp nhanh bắt đầu lúc 09:00.'), findsOneWidget);
    expect(find.text('HR: Lịch nghỉ Tết đã được cập nhật.'), findsOneWidget);
    expect(find.text('09:12'), findsOneWidget);
    expect(find.text('Hôm qua'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('general_channel_unread_company-channel')),
      findsOneWidget,
    );

    final companyPreview = tester.widget<Text>(
      find.text('Linh: Họp nhanh bắt đầu lúc 09:00.'),
    );
    final announcementPreview = tester.widget<Text>(
      find.text('HR: Lịch nghỉ Tết đã được cập nhật.'),
    );
    expect(companyPreview.maxLines, 1);
    expect(companyPreview.overflow, TextOverflow.ellipsis);
    expect(announcementPreview.maxLines, 1);
    expect(announcementPreview.overflow, TextOverflow.ellipsis);
  });

  testWidgets('General channel rows expose readable semantic state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    try {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      final companySemantics = tester.getSemantics(
        find.byKey(const ValueKey('general_channel_company-channel')),
      );
      final announcementsSemantics = tester.getSemantics(
        find.byKey(const ValueKey('general_channel_announcements')),
      );

      expect(
        companySemantics.label,
        contains('Kênh công ty, kênh có thể trả lời, 2 chưa đọc, 09:12'),
      );
      expect(
        announcementsSemantics.label,
        contains('Thông báo, kênh chỉ đọc, không có tin chưa đọc, Hôm qua'),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('General channel avatars use the expected icon treatment', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    final companyAvatar = tester.widget<ChatConversationAvatar>(
      find.byKey(const ValueKey('general_channel_avatar_company-channel')),
    );
    final announcementAvatar = tester.widget<ChatConversationAvatar>(
      find.byKey(const ValueKey('general_channel_avatar_announcements')),
    );

    expect(companyAvatar.icon, Icons.apartment_outlined);
    expect(announcementAvatar.icon, Icons.campaign_outlined);
  });
}

Widget _buildPage() {
  return UncontrolledProviderScope(
    container: ProviderContainer(),
    child: MaterialApp(
      theme: buildAppTheme(),
      home: const Scaffold(body: ChatHubPage()),
    ),
  );
}
