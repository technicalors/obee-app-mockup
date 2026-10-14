import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/chat/data/chat_conversation.dart';
import 'package:obee_mobile/src/features/chat/data/chat_coworker.dart';
import 'package:obee_mobile/src/features/chat/data/chat_group_info.dart';
import 'package:obee_mobile/src/features/chat/data/chat_repository.dart';
import 'package:obee_mobile/src/features/chat/data/chat_thread.dart';
import 'package:obee_mobile/src/features/chat/ui/chat_hub_page.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/chat_conversation_avatar.dart';
import 'package:obee_mobile/src/features/chat/ui/widgets/unread_count_indicator.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

void main() {
  testWidgets('Chat hub defaults to General and can switch to Direct', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNothing);
    expect(find.text('Trò chuyện'), findsOneWidget);
    expect(
      find.text(
        'Chọn không gian phù hợp để theo dõi trao đổi chung hoặc cuộc trò chuyện riêng.',
      ),
      findsNothing,
    );
    expect(find.text('Chung'), findsWidgets);
    expect(find.text('Riêng tư'), findsWidgets);
    expect(find.byType(UnreadCountIndicator), findsNWidgets(3));
    expect(find.text('Cộng đồng'), findsNothing);
    expect(find.text('Không gian riêng'), findsNothing);
    expect(
      find.byKey(const ValueKey('chat_hub_general_content')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('chat_hub_direct_content')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('chat_hub_general_content')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('chat_hub_direct_content')),
      findsOneWidget,
    );
    expect(find.text('Minh Anh'), findsOneWidget);
    expect(
      find.text(
        'Mở lại các cuộc trò chuyện gần đây để tiếp tục trao đổi 1:1 hoặc trong nhóm.',
      ),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('chat_hub_start_direct_fab')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('chat_hub_entry_menu_actions')),
      findsNothing,
    );
    expect(find.text('Tạo nhóm'), findsNothing);
    await tester.drag(
      find.byKey(const ValueKey('chat_hub_direct_content')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
  });

  testWidgets('selected tab persists when hub page rebuilds in same session', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_buildPage(container: container));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('chat_hub_direct_content')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(_buildPage(container: container));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('chat_hub_direct_content')),
      findsOneWidget,
    );
  });

  testWidgets('unselected tab unread count is slightly dimmed', (tester) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    final generalIndicator = tester.widget<UnreadCountIndicator>(
      find.descendant(
        of: find.byKey(const ValueKey('chat_hub_tab_general')),
        matching: find.byType(UnreadCountIndicator),
      ),
    );
    final directIndicator = tester.widget<UnreadCountIndicator>(
      find.descendant(
        of: find.byKey(const ValueKey('chat_hub_tab_direct')),
        matching: find.byType(UnreadCountIndicator),
      ),
    );

    expect(generalIndicator.dimmed, isFalse);
    expect(directIndicator.dimmed, isTrue);
  });

  testWidgets(
    'Chat hub keeps tab labels and unread badges visible with enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildPage(textScaleFactor: 1.8));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Chung'), findsWidgets);
      expect(find.text('Riêng tư'), findsWidgets);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('chat_hub_tab_general')),
          matching: find.byType(UnreadCountIndicator),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('chat_hub_tab_direct')),
          matching: find.byType(UnreadCountIndicator),
        ),
        findsOneWidget,
      );

      await tester.drag(
        find.byKey(const ValueKey('chat_hub_general_content')),
        const Offset(0, -260),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thông báo'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('chat_hub_general_content')),
        findsOneWidget,
      );
    },
  );

  testWidgets('Direct tab shows recency-sorted 1:1 and group conversations', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('chat_hub_direct_content')),
      findsOneWidget,
    );
    expect(find.text('Minh Anh'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('chat_hub_direct_content')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
    expect(
      find.text('Lan: Bản build mới đã sẵn sàng để kiểm tra.'),
      findsOneWidget,
    );
    expect(
      find.text('Minh Anh: Mình đang trên đường đến văn phòng.'),
      findsOneWidget,
    );
    expect(find.text('08:45'), findsOneWidget);
    expect(find.text('Hôm nay'), findsOneWidget);

    final oneToOnePreview = tester.widget<Text>(
      find.text('Minh Anh: Mình đang trên đường đến văn phòng.'),
    );
    final groupPreview = tester.widget<Text>(
      find.text('Lan: Bản build mới đã sẵn sàng để kiểm tra.'),
    );
    expect(oneToOnePreview.maxLines, 1);
    expect(oneToOnePreview.overflow, TextOverflow.ellipsis);
    expect(groupPreview.maxLines, 1);
    expect(groupPreview.overflow, TextOverflow.ellipsis);

    final firstConversationTop = tester.getTopLeft(
      find.byKey(const ValueKey('direct_conversation_direct-minh-anh')),
    );
    final secondConversationTop = tester.getTopLeft(
      find.byKey(const ValueKey('direct_conversation_group-apollo')),
    );

    expect(firstConversationTop.dy, lessThan(secondConversationTop.dy));
  });

  testWidgets(
    'Direct tab shows unread distinction with tab-level aggregate badge',
    (tester) async {
      final semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(_buildPage());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byKey(const ValueKey('chat_hub_tab_direct')),
            matching: find.byType(UnreadCountIndicator),
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(
            const ValueKey('direct_conversation_unread_direct-minh-anh'),
          ),
          findsOneWidget,
        );
        expect(find.text('1:1'), findsNothing);
        await tester.drag(
          find.byKey(const ValueKey('chat_hub_direct_content')),
          const Offset(0, -220),
        );
        await tester.pumpAndSettle();
        expect(find.text('Nhóm'), findsNothing);

        final unreadPreview = tester.widget<Text>(
          find.text('Minh Anh: Mình đang trên đường đến văn phòng.'),
        );
        final readPreview = tester.widget<Text>(
          find.text('Lan: Bản build mới đã sẵn sàng để kiểm tra.'),
        );

        expect(unreadPreview.style?.fontWeight, FontWeight.w700);
        expect(readPreview.style?.fontWeight, FontWeight.w500);
        expect(
          tester
              .getTopLeft(
                find.byKey(
                  const ValueKey('direct_conversation_unread_direct-minh-anh'),
                ),
              )
              .dy,
          greaterThan(tester.getTopLeft(find.text('08:45')).dy),
        );

        final directSemantics = tester.getSemantics(
          find.byKey(const ValueKey('direct_conversation_direct-minh-anh')),
        );
        final groupSemantics = tester.getSemantics(
          find.byKey(const ValueKey('direct_conversation_group-apollo')),
        );

        expect(directSemantics.label, contains('cuộc trò chuyện 1:1'));
        expect(directSemantics.label, contains('2 tin chưa đọc'));
        expect(groupSemantics.label, contains('cuộc trò chuyện nhóm'));
        expect(groupSemantics.label, contains('không có tin chưa đọc'));
        expect(find.text('2'), findsWidgets);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'Direct tab keeps Start chat separate from existing-conversation search',
    (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('chat_hub_start_direct_fab')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('direct_chat_search_field')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Mở lại các cuộc trò chuyện gần đây để tiếp tục trao đổi 1:1 hoặc trong nhóm.',
        ),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('new_direct_chat_search_field')),
        findsNothing,
      );
      expect(find.text('Bắt đầu trò chuyện'), findsNothing);
      expect(find.text('Tạo nhóm'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('chat_hub_start_direct_fab')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('chat_hub_entry_menu_actions')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('chat_hub_start_direct_menu_action')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('chat_hub_group_creation_menu_action')),
        findsOneWidget,
      );
      expect(find.text('Bắt đầu trò chuyện'), findsOneWidget);
      expect(find.text('Tạo nhóm (Bản xem trước)'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('direct_chat_search_field')),
        'Lan',
      );
      await tester.pumpAndSettle();

      expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
      expect(find.text('Minh Anh'), findsNothing);
      expect(
        find.byKey(const ValueKey('chat_hub_start_direct_fab')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('chat_hub_entry_menu_actions')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Direct search filters existing conversations by conversation and participant name',
    (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('direct_chat_search_field')),
        'Lan',
      );
      await tester.pumpAndSettle();

      expect(find.text('Lan'), findsOneWidget);
      expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
      expect(find.text('Minh Anh'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('direct_chat_search_field')),
        'Minh',
      );
      await tester.pumpAndSettle();

      expect(find.text('Minh'), findsOneWidget);
      expect(find.text('Minh Anh'), findsOneWidget);
      expect(find.text('Nhóm dự án Apollo'), findsNothing);
    },
  );

  testWidgets(
    'Direct search shows a no-result state and reset restores the full list',
    (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('direct_chat_search_field')),
        'Khong tim thay',
      );
      await tester.pumpAndSettle();

      expect(find.text('Khong tim thay'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('direct_chat_no_results')),
        findsOneWidget,
      );
      expect(find.text('Không có cuộc trò chuyện phù hợp.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('direct_chat_no_results_reset_button')),
        findsOneWidget,
      );
      expect(find.text('Minh Anh'), findsNothing);
      expect(find.text('Nhóm dự án Apollo'), findsNothing);

      await tester.drag(
        find.byKey(const ValueKey('chat_hub_direct_content')),
        const Offset(0, -220),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('direct_chat_no_results_reset_button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('direct_chat_no_results')),
        findsNothing,
      );
      expect(find.text('Minh Anh'), findsOneWidget);
      expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
    },
  );

  testWidgets(
    'Direct tab shows an empty state that points to the floating menu when there are no conversations',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(
            _EmptyDirectChatRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildPage(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('direct_chat_empty_state')),
        findsOneWidget,
      );
      expect(find.text('Chưa có cuộc trò chuyện nào.'), findsOneWidget);
      expect(
        find.text(
          'Dùng nút ở góc dưới để bắt đầu trò chuyện hoặc xem thử tạo nhóm.',
        ),
        findsOneWidget,
      );
      expect(find.text('Bắt đầu trò chuyện'), findsNothing);
      expect(find.text('Tạo nhóm'), findsNothing);
      expect(
        find.byKey(const ValueKey('chat_hub_start_direct_fab')),
        findsOneWidget,
      );
      expect(find.text('Minh Anh'), findsNothing);
      expect(find.text('Nhóm dự án Apollo'), findsNothing);
    },
  );

  testWidgets(
    'Tab bar hides unread badges when both sections have zero unread',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          chatRepositoryProvider.overrideWithValue(_ZeroUnreadChatRepository()),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildPage(container: container));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('chat_hub_tab_general')),
          matching: find.byType(UnreadCountIndicator),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('chat_hub_tab_direct')),
          matching: find.byType(UnreadCountIndicator),
        ),
        findsNothing,
      );
      expect(find.text('Chung'), findsWidgets);
      expect(find.text('Riêng tư'), findsWidgets);
    },
  );

  testWidgets('Direct search query persists when switching hub tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('direct_chat_search_field')),
      'Lan',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('chat_hub_tab_general')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
    await tester.pumpAndSettle();

    expect(find.text('Lan'), findsOneWidget);
    expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
    expect(find.text('Minh Anh'), findsNothing);
  });

  testWidgets(
    'Direct floating action button stays fixed while the list scrolls',
    (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
      await tester.pumpAndSettle();

      final fabBefore = tester.getTopLeft(
        find.byKey(const ValueKey('chat_hub_start_direct_fab')),
      );

      await tester.drag(
        find.byKey(const ValueKey('chat_hub_direct_content')),
        const Offset(0, -220),
      );
      await tester.pumpAndSettle();

      final fabAfter = tester.getTopLeft(
        find.byKey(const ValueKey('chat_hub_start_direct_fab')),
      );

      expect(fabAfter, fabBefore);
      expect(
        tester
            .getBottomRight(
              find.byKey(const ValueKey('direct_conversation_group-apollo')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const ValueKey('chat_hub_start_direct_fab')),
              )
              .dy,
        ),
      );
    },
  );

  testWidgets(
    'Direct floating action button expands and collapses menu actions',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_buildPage());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('chat_hub_entry_menu_actions')),
          findsNothing,
        );
        expect(
          tester
              .getSemantics(
                find.byKey(const ValueKey('chat_hub_start_direct_fab')),
              )
              .label,
          contains('Mở menu bắt đầu trò chuyện'),
        );

        await tester.tap(
          find.byKey(const ValueKey('chat_hub_start_direct_fab')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('chat_hub_entry_menu_actions')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('chat_hub_start_direct_menu_action')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('chat_hub_group_creation_menu_action')),
          findsOneWidget,
        );
        expect(find.text('Tạo nhóm (Bản xem trước)'), findsOneWidget);
        expect(
          tester
              .getSemantics(
                find.byKey(const ValueKey('chat_hub_start_direct_fab')),
              )
              .label,
          contains('Đóng menu bắt đầu trò chuyện'),
        );

        await tester.tap(
          find.byKey(const ValueKey('chat_hub_start_direct_fab')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('chat_hub_entry_menu_actions')),
          findsNothing,
        );
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'Expanded Direct entry menu keeps the last conversation visible with enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildPage(textScaleFactor: 1.8));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('chat_hub_start_direct_fab')));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('chat_hub_direct_content')),
        const Offset(0, -220),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('direct_conversation_group-apollo')),
        findsOneWidget,
      );
      expect(
        tester
            .getBottomRight(
              find.byKey(const ValueKey('direct_conversation_group-apollo')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(
                  const ValueKey('chat_hub_group_creation_menu_action'),
                ),
              )
              .dy,
        ),
      );
    },
  );

  testWidgets('Direct conversation rows use profile avatars and group icons', (
    tester,
  ) async {
    await tester.pumpWidget(_buildPage());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
    await tester.pumpAndSettle();

    final personAvatar = tester.widget<ProfileAvatar>(
      find.byKey(const ValueKey('direct_conversation_avatar_direct-minh-anh')),
    );
    await tester.drag(
      find.byKey(const ValueKey('chat_hub_direct_content')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();

    final groupAvatar = tester.widget<ChatConversationAvatar>(
      find.byKey(const ValueKey('direct_conversation_avatar_group-apollo')),
    );

    expect(personAvatar.user.name, 'Minh Anh');
    expect(personAvatar.size, 44);
    expect(groupAvatar.icon, Icons.group_outlined);
  });
}

Widget _buildPage({ProviderContainer? container, double textScaleFactor = 1}) {
  return UncontrolledProviderScope(
    container: container ?? ProviderContainer(),
    child: MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: child!,
        );
      },
      home: const Scaffold(body: ChatHubPage()),
    ),
  );
}

final class _EmptyDirectChatRepository implements ChatRepository {
  @override
  Future<List<ChatConversation>> loadDirectConversations() async {
    return const <ChatConversation>[];
  }

  @override
  Future<List<ChatConversation>> loadGeneralChannels() async {
    return const <ChatConversation>[];
  }

  @override
  Future<ChatGroupInfo> loadGroupInfo(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ChatCoworker>> loadCoworkers() async {
    return const <ChatCoworker>[];
  }

  @override
  Future<ChatThread> loadThread(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<String> openDirectConversationForCoworker(String coworkerId) {
    throw UnimplementedError();
  }

  @override
  Future<ChatThread> sendThreadMessage({
    required String conversationId,
    required String text,
  }) {
    throw UnimplementedError();
  }
}

final class _ZeroUnreadChatRepository implements ChatRepository {
  @override
  Future<List<ChatConversation>> loadDirectConversations() async {
    return const [
      ChatConversation(
        kind: ChatConversationKind.oneToOne,
        id: 'direct-zero',
        title: 'Minh Anh',
        previewText: 'Chưa có tin mới.',
        timestampLabel: '08:45',
        avatarKind: ChatConversationAvatarKind.person,
        participantNames: ['Minh Anh'],
        participantUser: User(
          createdAt: '2026-01-01T00:00:00Z',
          updatedAt: '2026-01-01T00:00:00Z',
          id: 'user-minh-anh-zero',
          name: 'Minh Anh',
          username: 'minh.anh',
          email: 'minh.anh@obee.test',
          avatar: null,
        ),
        unreadCount: 0,
      ),
    ];
  }

  @override
  Future<List<ChatConversation>> loadGeneralChannels() async {
    return const [
      ChatConversation(
        kind: ChatConversationKind.general,
        id: 'general-zero',
        title: 'Kênh công ty',
        previewText: 'Không có tin chưa đọc.',
        timestampLabel: '09:12',
        avatarKind: ChatConversationAvatarKind.organization,
        unreadCount: 0,
      ),
    ];
  }

  @override
  Future<ChatGroupInfo> loadGroupInfo(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ChatCoworker>> loadCoworkers() async {
    return const <ChatCoworker>[];
  }

  @override
  Future<ChatThread> loadThread(String conversationId) {
    throw UnimplementedError();
  }

  @override
  Future<String> openDirectConversationForCoworker(String coworkerId) {
    throw UnimplementedError();
  }

  @override
  Future<ChatThread> sendThreadMessage({
    required String conversationId,
    required String text,
  }) {
    throw UnimplementedError();
  }
}
