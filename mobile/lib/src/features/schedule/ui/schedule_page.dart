import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_detail_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/schedule_form_page.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_day_panel.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_month_calendar.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_header.dart';

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

  void _changeMonthByOffset(int offset) {
    final month = ref.read(scheduleControllerProvider).month;
    ref
        .read(scheduleControllerProvider.notifier)
        .changeMonth(DateTime(month.year, month.month + offset));
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleControllerProvider);
    final scheduleController = ref.read(scheduleControllerProvider.notifier);
    final currentUser = ref.watch(authControllerProvider).user;
    final organizationUsers = scheduleState.users;
    final cells = scheduleState.calendarCells;

    ref.listen<ScheduleViewState>(
      scheduleControllerProvider,
      _handleScheduleStateChange,
    );

    final canCreateSchedule =
        currentUser?.permissions?.any(
          (permission) => permission.name == 'schedule-events.create',
        ) ==
        true;

    final isDaySelected = _selectedDate != null;
    final selectedKey = isDaySelected ? scheduleDateKey(_selectedDate!) : null;
    final daySchedules = isDaySelected
        ? (scheduleState.schedulesByDate[selectedKey] ??
              const <ScheduleModel>[])
        : const <ScheduleModel>[];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(scheduleControllerProvider.notifier).refresh(),
          child: isDaySelected
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ScheduleHeader(
                        month: scheduleState.month,
                        selectedUserId: scheduleState.selectedUserId,
                        organizationUsers: organizationUsers,
                        visibility: scheduleState.visibility,
                        isVisibilityEnabled:
                            currentUser != null &&
                            scheduleState.selectedUserId == currentUser.id,
                        canCreateSchedule: canCreateSchedule,
                        onPrevious: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                        onNext: () => _changeMonthByOffset(1),
                        onMonthChanged: scheduleController.changeMonth,
                        onSelectedUserChanged:
                            scheduleController.setSelectedUser,
                        onVisibilityChanged: scheduleController.setVisibility,
                        onCreatePressed: _openScheduleForm,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ScheduleMonthCalendar(
                        cells: cells,
                        selectedWeekDate: _selectedDate,
                        selectedKey: selectedKey,
                        today: scheduleState.today,
                        schedulesByDate: scheduleState.schedulesByDate,
                        onDaySelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                          scheduleController.selectDate(date);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ScheduleDayPanel(
                        selectedDate: _selectedDate!,
                        daySchedules: daySchedules,
                        isLoading: scheduleState.isLoading,
                        canCreateSchedule: canCreateSchedule,
                        onCreatePressed: _openScheduleForm,
                        onSchedulePressed: _openScheduleDetail,
                        onClose: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: ScheduleHeader(
                        month: scheduleState.month,
                        selectedUserId: scheduleState.selectedUserId,
                        organizationUsers: organizationUsers,
                        visibility: scheduleState.visibility,
                        isVisibilityEnabled:
                            currentUser != null &&
                            scheduleState.selectedUserId == currentUser.id,
                        canCreateSchedule: canCreateSchedule,
                        onPrevious: () => _changeMonthByOffset(-1),
                        onNext: () => _changeMonthByOffset(1),
                        onMonthChanged: scheduleController.changeMonth,
                        onSelectedUserChanged:
                            scheduleController.setSelectedUser,
                        onVisibilityChanged: scheduleController.setVisibility,
                        onCreatePressed: _openScheduleForm,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            final velocity = details.primaryVelocity;
                            if (velocity != null) {
                              if (velocity < -200) {
                                _changeMonthByOffset(1);
                              } else if (velocity > 200) {
                                _changeMonthByOffset(-1);
                              }
                            }
                          },
                          child: ScheduleMonthCalendar(
                            cells: cells,
                            selectedKey: null,
                            today: scheduleState.today,
                            schedulesByDate: scheduleState.schedulesByDate,
                            onDaySelected: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                              scheduleController.selectDate(date);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
