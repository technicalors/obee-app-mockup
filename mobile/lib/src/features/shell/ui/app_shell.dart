import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/app/ui_variant.dart';
import 'package:obee_mobile/src/core/widgets/app_top_bar.dart';

enum AppShellIcon {
  attendance,
  chat,
  leave,
  requests,
  schedule,
  profile,
  notifications,
}

const _wideShellBreakpoint = 840.0;

class AppShell extends StatelessWidget {
  const AppShell({required this.child, this.showTasks = isUiV2, super.key});

  final Widget child;

  /// The "Công việc" tab ships only in the `/mobile2` preview build.
  final bool showTasks;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final destinations = _destinations(showTasks: showTasks);
    final selectedIndex = _selectedIndex(location, destinations);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSideNavigation = constraints.maxWidth >= _wideShellBreakpoint;

        return Scaffold(
          body: useSideNavigation
              ? Row(
                  children: [
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
                        child: NavigationRail(
                          key: const ValueKey('shell_navigation_rail'),
                          selectedIndex: selectedIndex,
                          onDestinationSelected: (index) =>
                              context.go(destinations[index].path),
                          labelType: NavigationRailLabelType.all,
                          destinations: destinations
                              .map(
                                (destination) => NavigationRailDestination(
                                  icon: Icon(destination.icon),
                                  label: Text(destination.label),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 960),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                )
              : child,
          bottomNavigationBar: useSideNavigation
              ? null
              : NavigationBar(
                  key: const ValueKey('shell_navigation_bar'),
                  height: 64,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      context.go(destinations[index].path),
                  destinations: destinations
                      .map(
                        (destination) => NavigationDestination(
                          icon: Icon(destination.icon),
                          label: destination.label,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class PlaceholderFeaturePage extends ConsumerWidget {
  const PlaceholderFeaturePage({
    required this.icon,
    required this.title,
    this.action,
    super.key,
  });

  final AppShellIcon icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppTopBar(
        title: title,
        actions: action != null ? [action!] : null,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(authControllerProvider.notifier).refreshCurrentUser(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _iconData(icon),
                                size: 44,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tính năng này đang được phát triển và sẽ sớm có mặt.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

List<_ShellDestination> _destinations({required bool showTasks}) {
  return [
    _ShellDestination(
      path: '/app/attendance',
      label: 'Chấm công',
      icon: Icons.access_time,
    ),
    // Tạm thời ngắt phần trò chuyện khỏi cấu trúc (không build, không sử dụng, chưa xóa)
    // _ShellDestination(
    //   path: '/app/chat',
    //   label: 'Trò chuyện',
    //   icon: Icons.chat_outlined,
    // ),
    _ShellDestination(
      path: '/app/requests',
      label: 'Yêu cầu',
      icon: Icons.assignment_outlined,
    ),
    _ShellDestination(
      path: '/app/schedule',
      label: 'Lịch trình',
      icon: Icons.calendar_month_outlined,
    ),
    if (showTasks)
      _ShellDestination(
        path: '/app/tasks',
        label: 'Công việc',
        icon: Icons.task_alt,
      ),
    _ShellDestination(
      path: '/app/profile',
      label: 'Hồ sơ',
      icon: Icons.person_outline,
    ),
  ];
}

int _selectedIndex(String location, List<_ShellDestination> destinations) {
  final index = destinations.indexWhere(
    (destination) =>
        location == destination.path ||
        location.startsWith('${destination.path}/'),
  );

  return index < 0 ? 0 : index;
}

IconData _iconData(AppShellIcon icon) {
  return switch (icon) {
    AppShellIcon.attendance => Icons.access_time,
    AppShellIcon.chat => Icons.chat_bubble_outline,
    AppShellIcon.leave => Icons.event_available_outlined,
    AppShellIcon.requests => Icons.assignment_outlined,
    AppShellIcon.schedule => Icons.calendar_month_outlined,
    AppShellIcon.profile => Icons.person_outline,
    AppShellIcon.notifications => Icons.notifications_none,
  };
}
