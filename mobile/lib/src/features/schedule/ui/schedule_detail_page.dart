import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/standalone_page_header.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_form_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_detail_content.dart';

class ScheduleDetailPage extends ConsumerStatefulWidget {
  const ScheduleDetailPage({super.key, required this.scheduleId});

  static const routePath = '/app/schedule/detail';

  static String location({required String scheduleId}) {
    final uri = Uri(
      path: routePath,
      queryParameters: {'scheduleId': scheduleId},
    );

    return uri.toString();
  }

  static ScheduleDetailRouteConfig parseRoute(Uri uri) {
    final scheduleId = uri.queryParameters['scheduleId'];
    if (scheduleId == null || scheduleId.isEmpty) {
      throw StateError(
        'Schedule detail route requires the scheduleId query parameter.',
      );
    }

    return ScheduleDetailRouteConfig(scheduleId: scheduleId);
  }

  final String scheduleId;

  @override
  ConsumerState<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

final class ScheduleDetailRouteConfig {
  const ScheduleDetailRouteConfig({required this.scheduleId});

  final String scheduleId;
}

enum ScheduleDetailAction { reuse, refresh }

final class ScheduleDetailPageResult {
  const ScheduleDetailPageResult._({
    required this.action,
    this.scheduleEventId,
    this.successMessage,
  });

  const ScheduleDetailPageResult.reuse({required String scheduleEventId})
    : this._(
        action: ScheduleDetailAction.reuse,
        scheduleEventId: scheduleEventId,
      );

  const ScheduleDetailPageResult.refresh({String? successMessage})
    : this._(
        action: ScheduleDetailAction.refresh,
        successMessage: successMessage,
      );

  final ScheduleDetailAction action;
  final String? scheduleEventId;
  final String? successMessage;
}

class _ScheduleDetailPageState extends ConsumerState<ScheduleDetailPage> {
  ScheduleModel? _schedule;
  String? _loadError;
  var _bootstrapping = true;
  var _hasMutated = false;

  @override
  void initState() {
    super.initState();
    Future<void>(_bootstrap);
  }

  void _popScreen() {
    if (_hasMutated) {
      context.pop(const ScheduleDetailPageResult.refresh());
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authControllerProvider).user;
    final scheduleState = ref.watch(scheduleControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    const pageTitle = 'Chi tiết lịch trình';

    ref.listen<ScheduleViewState>(
      scheduleControllerProvider,
      _handleScheduleStateChange,
    );

    final Widget page;
    if (_bootstrapping) {
      page = Scaffold(
        appBar: StandalonePageHeader(
          title: pageTitle,
          onBackPressed: _popScreen,
        ),
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    } else if (_loadError != null) {
      page = Scaffold(
        appBar: StandalonePageHeader(
          title: pageTitle,
          onBackPressed: _popScreen,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.error),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _popScreen,
                  child: const Text('Quay lại'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    } else {
      final schedule = _schedule!;
      final currentUserId = currentUser?.id ?? '';
      final isCreator = isScheduleCreator(schedule, currentUserId);
      final busy = scheduleState.isMutating;
      final canEdit =
          isCreator ||
          currentUser?.permissions?.any(
                (permission) => permission.name == 'schedule-events.update',
              ) ==
              true;

      page = Scaffold(
        appBar: StandalonePageHeader(
          title: pageTitle,
          onBackPressed: _popScreen,
          actions: [
            if (canEdit)
              HeaderActionButton(
                key: const ValueKey('schedule_detail_header_edit'),
                tooltip: 'Chỉnh sửa',
                icon: Icons.edit_outlined,
                onPressed: busy
                    ? null
                    : () => _editSchedule(
                        scheduleId: schedule.id,
                        scheduleEventId: schedule.event.id,
                      ),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [ScheduleDetailContent(schedule: schedule)],
          ),
        ),
      );
    }

    return PopScope<ScheduleDetailPageResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popScreen();
      },
      child: page,
    );
  }

  void _handleScheduleStateChange(
    ScheduleViewState? previous,
    ScheduleViewState next,
  ) {
    final message = next.errorMessage;
    if (message == null || message == previous?.errorMessage || !mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    ref.read(scheduleControllerProvider.notifier).clearFeedback();
  }

  Future<void> _bootstrap() async {
    final controller = ref.read(scheduleControllerProvider.notifier);
    await controller.initialize();

    if (!mounted) {
      return;
    }

    final schedule = await controller.fetchScheduleDetail(widget.scheduleId);
    if (!mounted) {
      return;
    }

    if (schedule == null) {
      setState(() {
        _bootstrapping = false;
        _loadError = 'Không thể tải chi tiết lịch trình.';
      });
      return;
    }

    setState(() {
      _schedule = schedule;
      _bootstrapping = false;
      _loadError = null;
    });
  }

  Future<void> _editSchedule({
    required String scheduleId,
    required String scheduleEventId,
  }) async {
    final saved = await context.push<bool>(
      ScheduleFormPage.location(
        scheduleId: scheduleId,
        scheduleEventId: scheduleEventId,
        isEditing: true,
      ),
    );

    if (!mounted || saved != true) {
      return;
    }

    _hasMutated = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật lịch trình thành công.')),
    );

    setState(() {
      _bootstrapping = true;
    });
    final controller = ref.read(scheduleControllerProvider.notifier);
    final updatedSchedule = await controller.fetchScheduleDetailAfterUpdate(
      scheduleEventId: scheduleEventId,
      occurrenceDate: _schedule!.start,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _schedule = updatedSchedule;
      _bootstrapping = false;
      _loadError = updatedSchedule == null
          ? 'Không thể tải chi tiết lịch trình.'
          : null;
    });
  }
}
