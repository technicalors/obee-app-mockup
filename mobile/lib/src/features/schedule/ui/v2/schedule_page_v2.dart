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
import 'package:obee_mobile/src/features/schedule/ui/v2/widgets/schedule_v2_day_agenda.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_day_panel.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_header.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_month_calendar.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_swipe_pager.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_year_view.dart';

/// Alternative schedule layout (HyperOS calendar style) built into the
/// `/mobile2` preview via `OBEE_UI_VARIANT=v2`. It shares the controller,
/// detail and form pages with [SchedulePage]; only the presentation differs.
class SchedulePageV2 extends ConsumerStatefulWidget {
  const SchedulePageV2({super.key, this.now});

  final DateTime? now;

  @override
  ConsumerState<SchedulePageV2> createState() => _SchedulePageV2State();
}

class _SchedulePageV2State extends ConsumerState<SchedulePageV2> {
  /// Last swipe direction, used to slide the incoming page from that side.
  int _pageDirection = 1;

  /// Day whose drawer is open in the month view; null shows the full grid.
  DateTime? _openDay;

  ScheduleController get _controller =>
      ref.read(scheduleControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    unawaited(Future<void>(() => _controller.initialize(now: widget.now)));
  }

  Future<void> _openScheduleDetail(ScheduleModel schedule) async {
    final result = await context.push<ScheduleDetailPageResult>(
      ScheduleDetailPage.location(scheduleId: schedule.id),
    );
    if (!mounted) {
      return;
    }

    switch (result?.action) {
      case ScheduleDetailAction.reuse:
        await _openScheduleForm(
          scheduleId: schedule.id,
          scheduleEventId: result!.scheduleEventId,
        );
      case ScheduleDetailAction.refresh:
        await _controller.reloadSchedulesSilently();
        final successMessage = result?.successMessage;
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
  }) async {
    final saved = await context.push<bool>(
      ScheduleFormPage.location(
        scheduleId: scheduleId,
        scheduleEventId: scheduleEventId,
      ),
    );
    if (!mounted || saved != true) {
      return;
    }

    _showSnackBar('Tạo lịch trình mới thành công.');
    await _controller.reloadSchedulesSilently();
  }

  Future<void> _openCreateForm() {
    _controller.prepareCreate();
    return _openScheduleForm();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleScheduleStateChange(
    ScheduleViewState? previous,
    ScheduleViewState next,
  ) {
    final message = next.errorMessage;
    if (message == null || message == previous?.errorMessage || !mounted) {
      return;
    }

    _showSnackBar(message);
    _controller.clearFeedback();
  }

  void _shiftRange(int offset) {
    setState(() => _pageDirection = offset);
    _controller.shiftRange(offset);
  }

  /// Days outside the visible month (leading/trailing cells) jump to it.
  /// In the month view, tapping a day also opens its drawer.
  Future<void> _selectDay(DateTime date) async {
    final state = ref.read(scheduleControllerProvider);
    final isMonth = state.viewMode == ScheduleViewMode.month;
    if (isMonth) {
      setState(() => _openDay = date);
    }
    if (isMonth && !isSameScheduleMonth(state.month, date)) {
      setState(() => _pageDirection = date.isBefore(state.month) ? -1 : 1);
      await _controller.changeMonth(date);
    }
    _controller.selectDate(date);
  }

  void _closeDay() {
    setState(() => _openDay = null);
  }

  void _goToToday() {
    final today = ref.read(scheduleControllerProvider).today;
    if (_openDay != null) {
      setState(() => _openDay = today);
    }
    _controller.goToToday();
  }

  void _changeMonth(DateTime month) {
    _closeDay();
    _controller.changeMonth(month);
  }

  void _setViewMode(ScheduleViewMode mode) {
    _closeDay();
    _controller.setViewMode(mode);
  }

  void _openMonthFromYear(DateTime month) {
    _closeDay();
    _controller.openMonth(month);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleControllerProvider);
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

    // Tinted page so the rounded day tiles stand out (Google Calendar style).
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Same compact header as layout v1: title, today, view, filters.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              child: ScheduleHeader(
                viewMode: state.viewMode,
                month: state.month,
                focusedDate: state.selectedDate,
                today: state.today,
                selectedUserId: state.selectedUserId,
                organizationUsers: state.users,
                visibility: state.visibility,
                isVisibilityEnabled:
                    currentUser != null &&
                    state.selectedUserId == currentUser.id,
                onMonthChanged: _changeMonth,
                onTodayPressed: _goToToday,
                onViewModeChanged: _setViewMode,
                onSelectedUserChanged: _controller.setSelectedUser,
                onVisibilityChanged: _controller.setVisibility,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _controller.refresh,
                child: _buildBody(state, canCreateSchedule),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ScheduleViewState state, bool canCreateSchedule) {
    if (state.viewMode == ScheduleViewMode.year) {
      return ScheduleSwipePager(
        pageKey: ValueKey('v2-year-${state.month.year}'),
        direction: _pageDirection,
        onShift: _shiftRange,
        child: ScheduleYearView(
          year: state.month.year,
          today: state.today,
          schedulesByDate: state.schedulesByDate,
          roundedToday: true,
          onMonthSelected: _openMonthFromYear,
        ),
      );
    }

    if (state.viewMode == ScheduleViewMode.month) {
      return _buildMonthBody(state, canCreateSchedule);
    }

    // Week view: the selected date's row of the rounded grid, with that
    // day's agenda below.
    final selectedKey = scheduleDateKey(state.selectedDate);
    final calendar = ScheduleMonthCalendar(
      cells: state.calendarCells,
      selectedKey: selectedKey,
      selectedWeekDate: state.selectedDate,
      today: state.today,
      schedulesByDate: state.schedulesByDate,
      onDaySelected: _selectDay,
      rounded: true,
    );
    final pageKey =
        'v2-week-${scheduleDateKey(scheduleWeekStart(state.selectedDate))}';

    // One scroll view keeps the grid and agenda usable on short screens.
    return ListView(
      key: const ValueKey('schedule-v2-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      // Room for the floating add button below the last agenda card.
      padding: const EdgeInsets.only(bottom: 72),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ScheduleSwipePager(
            pageKey: ValueKey(pageKey),
            direction: _pageDirection,
            onShift: _shiftRange,
            child: calendar,
          ),
        ),
        Divider(
          height: 24,
          indent: 16,
          endIndent: 16,
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        ScheduleV2DayAgenda(
          date: state.selectedDate,
          schedules: state.schedulesByDate[selectedKey] ?? const [],
          isLoading: state.isLoading,
          onSchedulePressed: _openScheduleDetail,
          onCreatePressed: canCreateSchedule ? _openCreateForm : null,
        ),
      ],
    );
  }

  /// Same interaction as layout v1: the full rounded grid, and tapping a day
  /// collapses it to that week with the day drawer underneath.
  Widget _buildMonthBody(ScheduleViewState state, bool canCreateSchedule) {
    final openDay = _openDay;

    if (openDay == null) {
      return ScheduleSwipePager(
        pageKey: ValueKey('v2-month-${scheduleDateKey(state.month)}'),
        direction: _pageDirection,
        onShift: _shiftRange,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: ScheduleMonthCalendar(
            cells: state.calendarCells,
            selectedKey: null,
            today: state.today,
            schedulesByDate: state.schedulesByDate,
            onDaySelected: _selectDay,
            rounded: true,
          ),
        ),
      );
    }

    final openKey = scheduleDateKey(openDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ScheduleMonthCalendar(
            cells: state.calendarCells,
            selectedWeekDate: openDay,
            selectedKey: openKey,
            today: state.today,
            schedulesByDate: state.schedulesByDate,
            onDaySelected: _selectDay,
            rounded: true,
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ScheduleDayPanel(
            selectedDate: openDay,
            daySchedules: state.schedulesByDate[openKey] ?? const [],
            isLoading: state.isLoading,
            canCreateSchedule: canCreateSchedule,
            onCreatePressed: _openCreateForm,
            onSchedulePressed: _openScheduleDetail,
            onClose: _closeDay,
          ),
        ),
      ],
    );
  }
}
