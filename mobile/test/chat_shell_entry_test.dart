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
import 'package:obee_mobile/src/features/chat/ui/widgets/unread_count_indicator.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

final _appConfig = AppConfig.parse(
  apiBaseUrl: 'http://obee.local/api',
  appBaseUrl: 'http://obee.local',
);

void main() {
  group(
    'chat shell entry',
    () {
      testWidgets(
        'authenticated user can open Trò chuyện from shell navigation',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(_buildApp());
          await tester.pumpAndSettle();

          expect(find.text('Trò chuyện'), findsOneWidget);
          expect(find.byKey(const ValueKey('chat_hub_page')), findsNothing);

          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('chat_hub_page')), findsOneWidget);
          expect(
            find.byKey(const ValueKey('chat_hub_general_content')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'selected Trò chuyện hub tab persists across shell navigation',
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

          expect(
            find.byKey(const ValueKey('chat_hub_direct_content')),
            findsOneWidget,
          );

          await tester.tap(find.text('Chấm công'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Trò chuyện'));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('chat_hub_direct_content')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Kênh công ty opens the writable thread from the shell flow',
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

          expect(
            find.byKey(const ValueKey('chat_thread_page')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(find.text('Kênh công ty'), findsWidgets);
        },
      );

      testWidgets('Thông báo opens the read-only thread from the shell flow', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_buildApp());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Trò chuyện'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('general_channel_announcements')),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('chat_thread_page')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('shell_navigation_bar')),
          findsNothing,
        );
        expect(find.text('Thông báo'), findsWidgets);
        expect(
          find.byKey(const ValueKey('read_only_channel_banner')),
          findsOneWidget,
        );
      });

      testWidgets(
        'Direct conversations open the existing thread route from shell flow',
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
          expect(find.text('Minh Anh'), findsWidgets);
          expect(
            find.text('Mình đang trên đường đến văn phòng.'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Chat hub shows tab unread badges while keeping row unread cues',
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
          expect(
            find.byKey(
              const ValueKey('direct_conversation_unread_direct-minh-anh'),
            ),
            findsOneWidget,
          );
          expect(
            find.byKey(
              const ValueKey('direct_conversation_unread_group-apollo'),
            ),
            findsNothing,
          );
        },
      );

      testWidgets(
        'Filtered direct conversations still open the existing thread route',
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

          await tester.enterText(
            find.byKey(const ValueKey('direct_chat_search_field')),
            'Lan',
          );
          await tester.pumpAndSettle();

          expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
          expect(find.text('Minh Anh'), findsNothing);

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
          expect(find.text('Nhóm dự án Apollo'), findsWidgets);
          expect(
            find.text('Bản build mới đã sẵn sàng để kiểm tra.'),
            findsOneWidget,
          );
        },
      );

      testWidgets('Start chat opens a dedicated coworker picker route', (
        tester,
      ) async {
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
          find.byKey(const ValueKey('chat_hub_start_direct_fab')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('chat_hub_start_direct_menu_action')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('new_direct_chat_page')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('shell_navigation_bar')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('new_direct_chat_search_field')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('direct_chat_search_field')),
          findsNothing,
        );
        expect(find.text('Minh Anh'), findsOneWidget);
        expect(find.text('Phương Linh'), findsOneWidget);
      });

      testWidgets(
        'Selecting an existing coworker reuses the current 1:1 thread route',
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
            find.byKey(const ValueKey('chat_hub_start_direct_fab')),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('chat_hub_start_direct_menu_action')),
          );
          await tester.pumpAndSettle();

          await tester.tap(
            find.byKey(
              const ValueKey('new_direct_chat_coworker_coworker-minh-anh'),
            ),
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
          expect(find.text('Minh Anh'), findsWidgets);
          expect(
            find.text('Mình đang trên đường đến văn phòng.'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Selecting a new coworker opens a fresh writable direct thread shell',
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
            find.byKey(const ValueKey('chat_hub_start_direct_fab')),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('chat_hub_start_direct_menu_action')),
          );
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const ValueKey('new_direct_chat_search_field')),
            'Phương',
          );
          await tester.pumpAndSettle();

          expect(find.text('Phương Linh'), findsOneWidget);
          expect(find.text('Minh Anh'), findsNothing);
          expect(
            find.byKey(const ValueKey('new_direct_chat_search_reset_button')),
            findsOneWidget,
          );

          await tester.tap(
            find.byKey(
              const ValueKey('new_direct_chat_coworker_coworker-phuong-linh'),
            ),
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
          expect(find.text('Phương Linh'), findsWidgets);
          expect(
            find.byKey(const ValueKey('chat_thread_composer_input')),
            findsOneWidget,
          );
          expect(find.text('Chưa có tin nhắn nào.'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('read_only_channel_banner')),
            findsNothing,
          );
        },
      );

      testWidgets(
        'returning from a replied group thread keeps direct list preview and group type state',
        (tester) async {
          final semantics = tester.ensureSemantics();
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          try {
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

            await tester.enterText(
              find.byKey(const ValueKey('chat_thread_composer_input')),
              'Nhóm mình chốt phương án này nhé.',
            );
            await tester.pump();
            await tester.tap(
              find.byKey(const ValueKey('chat_thread_send_button')),
            );
            await tester.pumpAndSettle();

            await tester.tap(
              find.byKey(const ValueKey('chat_thread_back_button')),
            );
            await tester.pumpAndSettle();

            expect(
              find.byKey(const ValueKey('chat_hub_direct_content')),
              findsOneWidget,
            );
            expect(find.text('Nhóm dự án Apollo'), findsOneWidget);
            expect(
              find.text('Admin User: Nhóm mình chốt phương án này nhé.'),
              findsOneWidget,
            );

            final groupSemantics = tester.getSemantics(
              find.byKey(const ValueKey('direct_conversation_group-apollo')),
            );
            expect(groupSemantics.label, contains('cuộc trò chuyện nhóm'));
          } finally {
            semantics.dispose();
          }
        },
      );

      testWidgets(
        'group info opens from the shipped group thread as a standalone route',
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

          await tester.tap(
            find.byKey(const ValueKey('chat_thread_group_info_button')),
          );
          await tester.pumpAndSettle();

          expect(find.byKey(const ValueKey('group_info_page')), findsOneWidget);
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(find.text('Thông tin nhóm'), findsOneWidget);
          expect(find.text('Nhóm dự án Apollo'), findsWidgets);
          final avatar = tester.widget<ProfileAvatar>(
            find.byKey(const ValueKey('group_info_avatar_member-hoang-lan')),
          );
          expect(avatar.user.name, 'Hoàng Lan');
          expect(avatar.size, 44);
        },
      );

      testWidgets(
        'prototype-only group creation opens as a standalone review route',
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
            find.byKey(const ValueKey('chat_hub_start_direct_fab')),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const ValueKey('chat_hub_group_creation_menu_action')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('group_creation_preview_page')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('shell_navigation_bar')),
            findsNothing,
          );
          expect(find.text('Tạo nhóm (Bản xem trước)'), findsOneWidget);
          expect(
            find.text(
              'Luồng này chỉ để xem thử, chưa tạo nhóm thật trong bản phát hành này.',
            ),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'returning from a replied 1:1 thread shows fresh Direct list preview state',
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

          await tester.enterText(
            find.byKey(const ValueKey('chat_thread_composer_input')),
            'Mình đến sau 5 phút.',
          );
          await tester.pump();
          await tester.tap(
            find.byKey(const ValueKey('chat_thread_send_button')),
          );
          await tester.pumpAndSettle();

          await tester.tap(
            find.byKey(const ValueKey('chat_thread_back_button')),
          );
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('chat_hub_direct_content')),
            findsOneWidget,
          );
          expect(find.text('Admin User: Mình đến sau 5 phút.'), findsOneWidget);
          expect(find.text('Minh Anh'), findsOneWidget);
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
