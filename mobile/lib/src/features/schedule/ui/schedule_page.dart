import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_detail_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_form_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_day_panel.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_month_calendar.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_swipe_pager.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_header.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_week_time_grid.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_year_view.dart';

/// Authenticated schedule route for the mobile app.
/// The page keeps view-local state here and delegates all backend work to the
/// injected schedule API service.
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key, this.now, this.initialSelectedDate});

  final DateTime? now;
  final DateTime? initialSelectedDate;

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialSelectedDate;
    unawaited(
      Future<void>(() {
        return ref
            .read(scheduleControllerProvider.notifier)
            .initialize(now: widget.now);
      }),
    );
  }

  Future<void> _openScheduleDetail(ScheduleModel schedule) async {
    final result = await context.push<ScheduleDetailPageResult>(
      ScheduleDetailPage.location(scheduleId: schedule.id),
    );

    if (!mounted) {
      return;
    }

    final successMessage = result?.successMessage;

    switch (result?.action) {
      case ScheduleDetailAction.reuse:
        await _openScheduleForm(
          scheduleId: schedule.id,
          scheduleEventId: result!.scheduleEventId,
        );
      case ScheduleDetailAction.refresh:
        await ref
            .read(scheduleControllerProvider.notifier)
            .reloadSchedulesSilently();
        if (mounted && successMessage != null) {
          _showSnackBar(successMessage);
        }
      case null:
        break;
    }
  }

  Future<void> _openScheduleForm({
    String? scheduleId,
    String? scheduleEventId,
    bool isEditing = false,
  }) async {
    final saved = await context.push<bool>(
      ScheduleFormPage.location(
        scheduleId: scheduleId,
        scheduleEventId: scheduleEventId,
        isEditing: isEditing,
      ),
    );

    if (!mounted || saved != true) {
      return;
    }

    _showSnackBar('Tạo lịch trình mới thành công.');

    await ref
        .read(scheduleControllerProvider.notifier)
        .reloadSchedulesSilently();
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
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

  /// Last swipe direction, used to slide the incoming page from that side.
  int _pageDirection = 1;

  void _shiftRange(int offset) {
    setState(() {
      _pageDirection = offset;
    });
    ref.read(scheduleControllerProvider.notifier).shiftRange(offset);
  }

  void _selectDay(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    ref.read(scheduleControllerProvider.notifier).selectDate(date);
  }

  void _closeDay() {
    setState(() {
      _selectedDate = null;
    });
  }

  void _goToToday() {
    final controller = ref.read(scheduleControllerProvider.notifier);
    final today = ref.read(scheduleControllerProvider).today;
    setState(() {
      if (_selectedDate != null) {
        _selectedDate = today;
      }
    });
    controller.goToToday();
  }

  void _changeMonth(DateTime month) {
    setState(() {
      _selectedDate = null;
    });
    ref.read(scheduleControllerProvider.notifier).changeMonth(month);
  }

  void _setViewMode(ScheduleViewMode mode) {
    setState(() {
      _selectedDate = null;
    });
    ref.read(scheduleControllerProvider.notifier).setViewMode(mode);
  }

  /// Drills from the week header into that day's agenda in the month view.
  void _openDayFromWeek(DateTime date) {
    final controller = ref.read(scheduleControllerProvider.notifier);
    setState(() {
      _selectedDate = date;
    });
    controller.setViewMode(ScheduleViewMode.month);
    if (!isSameScheduleMonth(
      ref.read(scheduleControllerProvider).month,
      date,
    )) {
      controller.changeMonth(date);
    }
    controller.selectDate(date);
  }

  void _openMonthFromYear(DateTime month) {
    setState(() {
      _selectedDate = null;
    });
    ref.read(scheduleControllerProvider.notifier).openMonth(month);
  }

  Future<void> _openCreateForm({DateTime? start}) {
    ref.read(scheduleControllerProvider.notifier).prepareCreate(start: start);
    return _openScheduleForm();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleControllerProvider);
    final scheduleController = ref.read(scheduleControllerProvider.notifier);
    final currentUser = ref.watch(authControllerProvider).user;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<ScheduleViewState>(
      scheduleControllerProvider,
      _handleScheduleStateChange,
    );

    final canCreateSchedule =
        currentUser?.permissions?.any(
          (permission) => permission.name == 'schedule-events.create',
        ) ==
        true;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: canCreateSchedule
          ? FloatingActionButton(
              key: const ValueKey('schedule-create-fab'),
              tooltip: 'Thêm lịch trình mới',
              onPressed: _openCreateForm,
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(scheduleControllerProvider.notifier).refresh(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                child: ScheduleHeader(
                  viewMode: scheduleState.viewMode,
                  month: scheduleState.month,
                  focusedDate: scheduleState.selectedDate,
                  today: scheduleState.today,
                  selectedUserId: scheduleState.selectedUserId,
                  organizationUsers: scheduleState.users,
                  visibility: scheduleState.visibility,
                  isVisibilityEnabled:
                      currentUser != null &&
                      scheduleState.selectedUserId == currentUser.id,
                  onMonthChanged: _changeMonth,
                  onTodayPressed: _goToToday,
                  onViewModeChanged: _setViewMode,
                  onSelectedUserChanged: scheduleController.setSelectedUser,
                  onVisibilityChanged: scheduleController.setVisibility,
                ),
              ),
              Expanded(
                child: switch (scheduleState.viewMode) {
                  ScheduleViewMode.month => _buildMonthBody(
                    scheduleState,
                    canCreateSchedule,
                  ),
                  ScheduleViewMode.week => ScheduleSwipePager(
                    pageKey: ValueKey(
                      'week-${scheduleDateKey(scheduleWeekStart(scheduleState.selectedDate))}',
                    ),
                    direction: _pageDirection,
                    onShift: _shiftRange,
                    child: ScheduleWeekTimeGrid(
                      days: buildWeekDays(scheduleState.selectedDate),
                      today: scheduleState.today,
                      schedulesByDate: scheduleState.schedulesByDate,
                      onSchedulePressed: _openScheduleDetail,
                      onDaySelected: _openDayFromWeek,
                      onSlotPressed: canCreateSchedule
                          ? (start) => _openCreateForm(start: start)
                          : null,
                    ),
                  ),
                  ScheduleViewMode.year => ScheduleSwipePager(
                    pageKey: ValueKey('year-${scheduleState.month.year}'),
                    direction: _pageDirection,
                    onShift: _shiftRange,
                    child: ScheduleYearView(
                      year: scheduleState.month.year,
                      today: scheduleState.today,
                      schedulesByDate: scheduleState.schedulesByDate,
                      onMonthSelected: _openMonthFromYear,
                    ),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthBody(ScheduleViewState scheduleState, bool canCreate) {
    final selectedDate = _selectedDate;

    if (selectedDate == null) {
      return ScheduleSwipePager(
        pageKey: ValueKey('month-${scheduleDateKey(scheduleState.month)}'),
        direction: _pageDirection,
        onShift: _shiftRange,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: ScheduleMonthCalendar(
            cells: scheduleState.calendarCells,
            selectedKey: null,
            today: scheduleState.today,
            schedulesByDate: scheduleState.schedulesByDate,
            onDaySelected: _selectDay,
          ),
        ),
      );
    }

    final selectedKey = scheduleDateKey(selectedDate);

    // Day selected: collapse the grid to that week and show the day's agenda.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ScheduleMonthCalendar(
            cells: scheduleState.calendarCells,
            selectedWeekDate: selectedDate,
            selectedKey: selectedKey,
            today: scheduleState.today,
            schedulesByDate: scheduleState.schedulesByDate,
            onDaySelected: _selectDay,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ScheduleDayPanel(
            selectedDate: selectedDate,
            daySchedules:
                scheduleState.schedulesByDate[selectedKey] ??
                const <ScheduleModel>[],
            isLoading: scheduleState.isLoading,
            canCreateSchedule: canCreate,
            onCreatePressed: _openCreateForm,
            onSchedulePressed: _openScheduleDetail,
            onClose: _closeDay,
          ),
        ),
      ],
    );
  }
}
