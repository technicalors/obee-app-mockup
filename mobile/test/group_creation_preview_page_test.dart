import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/chat/ui/group_creation_preview_page.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

void main() {
  testWidgets(
    'prototype-only page supports naming and member selection while keeping final action disabled',
    (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('group_creation_preview_page')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('group_creation_preview_avatar_coworker-minh-anh'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Luồng này chỉ để xem thử, chưa tạo nhóm thật trong bản phát hành này.',
        ),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('group_creation_preview_name_input')),
        'Nhóm thử nghiệm',
      );
      await tester.pump();

      expect(find.text('Nhóm thử nghiệm'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey('group_creation_preview_member_coworker-phuong-linh'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Đã chọn 1 thành viên'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.byKey(
                const ValueKey('group_creation_preview_submit_button'),
              ),
            )
            .onPressed,
        isNull,
      );

      final avatar = tester.widget<ProfileAvatar>(
        find.byKey(
          const ValueKey('group_creation_preview_avatar_coworker-phuong-linh'),
        ),
      );
      expect(avatar.user.name, 'Phương Linh');
      expect(avatar.size, 44);
    },
  );

  testWidgets(
    'prototype-only member search no-result state provides explicit recovery',
    (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('group_creation_preview_search_field')),
        'Khong tim thay',
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('group_creation_preview_no_results')),
        findsOneWidget,
      );
      expect(find.text('Không tìm thấy thành viên phù hợp.'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('group_creation_preview_no_results_reset_button'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(
          const ValueKey('group_creation_preview_no_results_reset_button'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('group_creation_preview_no_results')),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey('group_creation_preview_member_coworker-minh-anh'),
        ),
        findsOneWidget,
      );
    },
  );
}

Widget _buildPage() {
  return UncontrolledProviderScope(
    container: ProviderContainer(),
    child: MaterialApp(
      theme: buildAppTheme(),
      home: const GroupCreationPreviewPage(),
    ),
  );
}
