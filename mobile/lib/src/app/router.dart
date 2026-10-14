import 'package:obee_mobile/src/features/auth/ui/auth_bootstrap_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/attendance/ui/attendance_page.dart';
import 'package:obee_mobile/src/features/auth/ui/login_page.dart';
// Tạm thời ngắt phần trò chuyện khỏi cấu trúc (không build, không sử dụng, chưa xóa)
// import 'package:obee_mobile/src/features/chat/ui/chat_hub_page.dart';
// import 'package:obee_mobile/src/features/chat/ui/group_creation_preview_page.dart';
// import 'package:obee_mobile/src/features/chat/ui/group_info_page.dart';
// import 'package:obee_mobile/src/features/chat/ui/chat_thread_page.dart';
// import 'package:obee_mobile/src/features/chat/ui/new_direct_chat_page.dart';
import 'package:obee_mobile/src/features/requests/ui/create_business_trip_request_page.dart';
import 'package:obee_mobile/src/features/requests/ui/create_leave_request_page.dart';
import 'package:obee_mobile/src/features/requests/ui/request_detail_page.dart';
import 'package:obee_mobile/src/features/requests/ui/request_list_page.dart';
import 'package:obee_mobile/src/features/profile/ui/edit_profile_page.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_detail_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_form_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_page.dart';
import 'package:obee_mobile/src/features/shell/ui/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();

  ref
    ..onDispose(refreshNotifier.dispose)
    ..listen<AuthState>(authControllerProvider, (previous, next) {
      final didLoadingChange =
          previous?.isRestoring != next.isRestoring ||
          previous?.restoreFailed != next.restoreFailed;
      final didAuthStateChange =
          previous?.isAuthenticated != next.isAuthenticated;

      if (didLoadingChange || didAuthStateChange) {
        refreshNotifier.notify();
      }
    });

  final router = GoRouter(
    initialLocation: '/app/attendance',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final isLogin = state.matchedLocation == '/login';

      if (auth.isRestoring || auth.restoreFailed) {
        return state.matchedLocation == '/bootstrap' ? null : '/bootstrap';
      }
      if (state.matchedLocation == '/bootstrap') {
        return auth.isAuthenticated ? '/app/attendance' : '/login';
      }

      if (!auth.isAuthenticated) {
        return isLogin ? null : '/login';
      }

      return isLogin ? '/app/attendance' : null;
    },
    routes: [
      GoRoute(
        path: '/bootstrap',
        builder: (context, state) => const AuthBootstrapPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      // Tạm thời ngắt phần trò chuyện khỏi cấu trúc (không build, không sử dụng, chưa xóa)
      // GoRoute(
      //   path: '/app/chat/new-direct',
      //   builder: (context, state) => const NewDirectChatPage(),
      // ),
      // GoRoute(
      //   path: '/app/chat/thread/:conversationId',
      //   builder: (context, state) => ChatThreadPage(
      //     conversationId: state.pathParameters['conversationId']!,
      //   ),
      // ),
      // GoRoute(
      //   path: '/app/chat/group-info/:conversationId',
      //   builder: (context, state) => GroupInfoPage(
      //     conversationId: state.pathParameters['conversationId']!,
      //   ),
      // ),
      // GoRoute(
      //   path: '/app/chat/prototype-group-creation',
      //   builder: (context, state) => const GroupCreationPreviewPage(),
      // ),
      GoRoute(
        path: '/app/requests/create-leave',
        builder: (context, state) => CreateLeaveRequestPage(
          requestId: state.uri.queryParameters['requestId'],
        ),
      ),
      GoRoute(
        path: '/app/requests/create-trip',
        builder: (context, state) => CreateBusinessTripRequestPage(
          requestId: state.uri.queryParameters['requestId'],
        ),
      ),
      GoRoute(
        path: '/app/requests/:id',
        builder: (context, state) =>
            RequestDetailPage(requestId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: ScheduleDetailPage.routePath,
        builder: (context, state) {
          final config = ScheduleDetailPage.parseRoute(state.uri);

          return ScheduleDetailPage(scheduleId: config.scheduleId);
        },
      ),
      GoRoute(
        path: ScheduleFormPage.routePath,
        builder: (context, state) {
          final config = ScheduleFormPage.parseRoute(state.uri);

          return ScheduleFormPage(
            scheduleEventId: config.scheduleEventId,
            isEditing: config.isEditing,
            scheduleId: config.scheduleId,
          );
        },
      ),
      GoRoute(
        path: '/app/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/app/attendance',
            builder: (context, state) => const AttendancePage(),
          ),
          // Tạm thời ngắt phần trò chuyện khỏi cấu trúc (không build, không sử dụng, chưa xóa)
          // GoRoute(
          //   path: '/app/chat',
          //   builder: (context, state) => const ChatHubPage(),
          // ),
          GoRoute(
            path: '/app/requests',
            builder: (context, state) => const RequestListPage(),
          ),
          GoRoute(
            path: '/app/leave',
            redirect: (context, state) => '/app/requests',
          ),
          GoRoute(
            path: '/app/schedule',
            // This route used to return a placeholder feature page. Keeping the
            // path stable avoids any shell or navigation changes elsewhere.
            builder: (context, state) => const SchedulePage(),
          ),
          GoRoute(
            path: '/app/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/app/notifications',
            // Tạm thời ngắt tính năng thông báo.
            redirect: (context, state) => '/app/attendance',
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

final class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
