import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:obee_mobile/src/app/app.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/data/user_profile.dart';

final _appConfig = AppConfig.parse(
  apiBaseUrl: 'http://obee.local/api',
  appBaseUrl: 'http://obee.local',
);

void main() {
  group(
    'chat thread page',
    () {
      testWidgets(
        'Kênh công ty shows day separators and a disabled composer first',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('general_channel_company-channel')),
          );
          await tester.pumpAndSettle();

          final scaffold = tester.widget<Scaffold>(
            find.ancestor(
              of: find.byKey(const ValueKey('chat_thread_page')),
              matching: find.byType(Scaffold),
            ),
          );

          final threadContext = tester.element(
            find.byKey(const ValueKey('chat_thread_page')),
          );
          expect(
            find.byKey(const ValueKey('chat_thread_page')),
            findsOneWidget,
          );
          expect(
            scaffold.backgroundColor,
            Theme.of(threadContext).colorScheme.surface,
          );
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(find.byType(Card), findsNothing);
          expect(find.text('Hôm qua'), findsOneWidget);
          expect(find.text('Hôm nay'), findsOneWidget);
          expect(find.text('Linh'), findsOneWidget);
          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const ValueKey('chat_thread_send_button')),
                )
                .onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'sending a Kênh công ty message enables the action and appends a self bubble',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('general_channel_company-channel')),
          );
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const ValueKey('chat_thread_composer_input')),
            'Nhận được rồi.',
          );
          await tester.pump();

          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const ValueKey('chat_thread_send_button')),
                )
                .onPressed,
            isNotNull,
          );

          await tester.tap(
            find.byKey(const ValueKey('chat_thread_send_button')),
          );
          await tester.pumpAndSettle();

          expect(find.text('Nhận được rồi.'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('chat_message_self_message-local-4')),
            findsOneWidget,
          );
          expect(
            tester
                .widget<TextField>(
                  find.byKey(const ValueKey('chat_thread_composer_input')),
                )
                .controller!
                .text,
            isEmpty,
          );
        },
      );

      testWidgets(
        '1:1 thread hides repeated sender labels but keeps private alignment and send flow',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('direct_conversation_direct-minh-anh')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('chat_thread_page')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(find.text('Minh Anh'), findsOneWidget);
          expect(
            find.text('Mình đang trên đường đến văn phòng.'),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('chat_message_sender_direct-minh-anh-1')),
            findsNothing,
          );
          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const ValueKey('chat_thread_send_button')),
                )
                .onPressed,
            isNull,
          );

          await tester.enterText(
            find.byKey(const ValueKey('chat_thread_composer_input')),
            'Mình đến sau 5 phút.',
          );
          await tester.pump();

          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const ValueKey('chat_thread_send_button')),
                )
                .onPressed,
            isNotNull,
          );

          await tester.tap(
            find.byKey(const ValueKey('chat_thread_send_button')),
          );
          await tester.pumpAndSettle();

          expect(find.text('Mình đến sau 5 phút.'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('chat_message_self_message-local-3')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'group thread keeps sender labels visible on non-self bubbles',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('chat_hub_direct_content')),
            const Offset(0, -220),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('direct_conversation_group-apollo')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('chat_thread_page')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('chat_message_sender_group-apollo-1')),
            findsOneWidget,
          );
          expect(find.text('Lan'), findsOneWidget);
        },
      );

      testWidgets(
        'group thread keeps shared composer rules and appends a self reply',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('chat_hub_direct_content')),
            const Offset(0, -220),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('direct_conversation_group-apollo')),
          );
          await tester.pumpAndSettle();

          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const ValueKey('chat_thread_send_button')),
                )
                .onPressed,
            isNull,
          );

          await tester.enterText(
            find.byKey(const ValueKey('chat_thread_composer_input')),
            'Nhóm mình chốt phương án này nhé.',
          );
          await tester.pump();

          expect(
            tester
                .widget<IconButton>(
                  find.byKey(const ValueKey('chat_thread_send_button')),
                )
                .onPressed,
            isNotNull,
          );

          await tester.tap(
            find.byKey(const ValueKey('chat_thread_send_button')),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Nhóm mình chốt phương án này nhé.'),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('chat_message_self_message-local-3')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('chat_message_sender_group-apollo-1')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'group thread exposes group info and opens a standalone group details page',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('chat_hub_tab_direct')));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('chat_hub_direct_content')),
            const Offset(0, -220),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('direct_conversation_group-apollo')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('chat_thread_group_info_button')),
            findsOneWidget,
          );

          await tester.tap(
            find.byKey(const ValueKey('chat_thread_group_info_button')),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('group_info_page')), findsOneWidget);
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(find.text('Nhóm dự án Apollo'), findsWidgets);
          expect(find.text('3 thành viên'), findsOneWidget);
          expect(find.text('Admin User'), findsOneWidget);
          expect(find.text('Hoàng Lan'), findsOneWidget);
          expect(find.text('Phương Linh'), findsOneWidget);
          expect(
            tester
                .widget<OutlinedButton>(
                  find.byKey(const ValueKey('group_info_rename_action')),
                )
                .onPressed,
            isNull,
          );
          expect(
            tester
                .widget<OutlinedButton>(
                  find.byKey(const ValueKey('group_info_leave_action')),
                )
                .onPressed,
            isNull,
          );
        },
      );

      testWidgets(
        'Thông báo shows a persistent read-only banner and no composer',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('chat_hub_general_content')),
            const Offset(0, -360),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('general_channel_announcements')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('chat_thread_page')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(find.text('Thông báo'), findsWidgets);
          expect(find.text('Lịch nghỉ Tết đã được cập nhật.'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('read_only_channel_banner')),
            findsOneWidget,
          );
          expect(
            find.text('Kênh này chỉ đọc. Bạn không thể trả lời tại đây.'),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('chat_thread_composer_input')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('chat_thread_send_button')),
            findsNothing,
          );
        },
      );

      testWidgets('Kênh công ty remains writable on wide layouts', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Trò chuyện'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('general_channel_company-channel')),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('chat_thread_page')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('shell_navigation_rail')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('chat_thread_composer_input')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<IconButton>(
                find.byKey(const ValueKey('chat_thread_send_button')),
              )
              .onPressed,
          isNull,
        );
      });

      testWidgets(
        'Thông báo keeps read-only explanation visible on wide layouts',
        (tester) async {
          tester.view.physicalSize = const Size(1024, 768);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('chat_hub_general_content')),
            const Offset(0, -260),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('general_channel_announcements')),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(
            find.byKey(const ValueKey('chat_thread_page')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('shell_navigation_rail')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('read_only_channel_banner')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('chat_thread_composer_input')),
            findsNothing,
          );
        },
      );

      testWidgets(
        'Kênh chỉ đọc keeps textual and semantic explanation with enlarged text',
        (tester) async {
          final semantics = tester.ensureSemantics();
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          tester.binding.platformDispatcher.textScaleFactorTestValue = 1.8;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(
            tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
          );

          try {
            await tester.pumpWidget(_buildApp());
            await tester.pumpAndSettle();

            await tester.tap(find.text('Trò chuyện'));
            await tester.pumpAndSettle();
            await tester.drag(
              find.byKey(const ValueKey('chat_hub_general_content')),
              const Offset(0, -560),
            );
            await tester.pumpAndSettle();
            await tester.tap(
              find.byKey(const ValueKey('general_channel_announcements')),
            );
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            expect(find.text('Thông báo'), findsWidgets);
            expect(
              find.text('Kênh này chỉ đọc. Bạn không thể trả lời tại đây.'),
              findsOneWidget,
            );
            expect(
              tester
                  .getSemantics(
                    find.byKey(const ValueKey('read_only_channel_banner')),
                  )
                  .label,
              contains('Kênh chỉ đọc. Bạn không thể trả lời tại đây.'),
            );
          } finally {
            semantics.dispose();
          }
        },
      );
    },
    skip:
        'Tạm thời ngắt phần trò chuyện khỏi cấu trúc (không build, không sử dụng, chưa xóa)',
  );
}

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(_appConfig),
      attendanceApiProvider.overrideWithValue(_FakeAttendanceApi()),
      deviceLocationServiceProvider.overrideWithValue(
        DeviceLocationService(
          platform: _FakeGeolocatorPlatform(
            permission: LocationPermission.deniedForever,
          ),
        ),
      ),
      tokenStorageProvider.overrideWithValue(_MemoryTokenStorage('token-1')),
      authApiProvider.overrideWithValue(_FakeAuthApi()),
    ],
    child: const ObeeMobileApp(),
  );
}

class _FakeAuthApi implements AuthApi {
  @override
  Future<User> currentUser() async {
    return const User(
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      id: 'user-1',
      name: 'Admin User',
      username: 'admin',
      email: 'admin@example.com',
      avatar: null,
      profile: UserProfile(code: 'EMP-TEST'),
    );
  }

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

class _MemoryTokenStorage implements TokenStorage {
  _MemoryTokenStorage(this.token);

  String? token;

  @override
  Future<void> clearToken() async {
    token = null;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async {
    this.token = token;
  }
}

class _FakeAttendanceApi implements AttendanceApi {
  @override
  Future<AttendanceContext> fetchContext() async {
    return const AttendanceContext(
      user: AttendanceUserRef(id: 'user-1', name: 'User'),
      ipAddress: null,
      assignedLocations: [],
    );
  }

  @override
  Future<AttendanceDayDetail> fetchDayDetail(String date) async {
    return AttendanceDayDetail(date: date, totalWorkSeconds: 0, logs: const []);
  }

  @override
  Future<List<AttendanceRangeSummary>> fetchRange({
    required String from,
    required String to,
  }) async {
    return const [];
  }

  @override
  Future<AttendanceLog> punch(AttendanceCoordinates? coordinates) async {
    return const AttendanceLog(
      source: 'mobile',
      id: 'log-1',
      checkedAt: '2026-01-02 03:04:05',
    );
  }
}

final class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  _FakeGeolocatorPlatform({this.permission = LocationPermission.whileInUse});

  final LocationPermission permission;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;
}
