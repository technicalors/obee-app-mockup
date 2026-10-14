import 'dart:async';

import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_problem.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_calendar.dart';

final scheduleControllerProvider =
    NotifierProvider<ScheduleController, ScheduleViewState>(
      ScheduleController.new,
    );

class ScheduleController extends Notifier<ScheduleViewState> {
  late ScheduleApi _scheduleApi;
  int _scheduleLoad = 0;
  int _userLoad = 0;
  CancelToken? _scheduleCancellation;

  @override
  ScheduleViewState build() {
    _scheduleApi = ref.watch(scheduleApiProvider);
    ref.onDispose(() => _scheduleCancellation?.cancel());
    ref.listen(
      authControllerProvider.select(
        (auth) => (auth.user?.organizationId, auth.user?.rootOrganizationId),
      ),
      (previous, next) {
        if (!state.isInitialized) return;
        state = state.copyWith(
          users: const [],
          selectedUserId: ref.read(authControllerProvider).user?.id,
        );
        unawaited(Future.wait([_loadUsers(), _loadSchedules()]));
      },
    );

    return ScheduleViewState.initial();
  }

  Future<void> initialize({DateTime? now}) async {
    if (state.isInitialized) {
      return;
    }

    final today = _normalizeDate(now ?? scheduleToday());
    final month = scheduleMonthAnchor(today);

    final currentUserId = ref.read(authControllerProvider).user?.id;

    state = state.copyWith(
      isInitialized: true,
      today: today,
      month: month,
      selectedDate: initialScheduleSelectedDate(month, today),
      selectedUserId: currentUserId,
    );

    await Future.wait([_loadSchedules(), _loadUsers()]);
  }

  void clearFeedback() {
    state = state.copyWith(errorMessage: null);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: _normalizeDate(date));
  }

  Future<void> refresh() async {
    await ref.read(authControllerProvider.notifier).refreshCurrentUser();
    if (!ref.mounted) return;
    await Future.wait([_loadSchedules(), _loadUsers()]);
  }

  Future<void> changeMonth(DateTime month) async {
    final anchor = scheduleMonthAnchor(month);

    state = state.copyWith(
      month: anchor,
      selectedDate: initialScheduleSelectedDate(anchor, state.today),
    );

    await _loadSchedules();
  }

  Future<void> goToToday() {
    return changeMonth(state.today);
  }

  Future<void> setVisibility(ScheduleVisibilityFilter visibility) async {
    if (_selectedUserFilter != null &&
        visibility != ScheduleVisibilityFilter.all) {
      return;
    }

    state = state.copyWith(visibility: visibility);
    await _loadSchedules();
  }

  Future<void> setSelectedUser(String userId) async {
    final currentUserId = ref.read(authControllerProvider).user?.id;
    final isViewingOwnSchedules =
        currentUserId == null || userId == currentUserId;

    state = state.copyWith(
      selectedUserId: userId,
      visibility: isViewingOwnSchedules
          ? state.visibility
          : ScheduleVisibilityFilter.all,
    );
    await _loadSchedules();
  }

  ScheduleDraft? buildCreateDraft() {
    final currentUser = ref.read(authControllerProvider).user;
    if (currentUser == null) {
      return null;
    }

    return ScheduleDraft.forCreate(
      currentUserId: currentUser.id,
      selectedDate: state.selectedDate,
    );
  }

  Future<ScheduleModel?> fetchScheduleDetail(String scheduleId) async {
    try {
      return await _scheduleApi.fetchScheduleDetail(scheduleId);
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          errorMessage: _messageForError(
            error,
            fallbackMessage: 'Không thể tải chi tiết lịch trình.',
          ),
        );
      }

      return null;
    }
  }

  Future<void> createSchedule(ScheduleDraft draft) async {
    try {
      await _scheduleApi.createSchedule(draft);
    } catch (error) {
      throw FormatException(
        _messageForError(error, fallbackMessage: 'Không thể lưu lịch trình.'),
      );
    }
  }

  Future<ScheduleModel?> fetchScheduleDetailAfterUpdate({
    required String scheduleEventId,
    required DateTime occurrenceDate,
  }) async {
    try {
      // Saving regenerates occurrence IDs. Resolve through the stable event ID.
      final schedules = await _scheduleApi.fetchSchedules(
        eventId: scheduleEventId,
        visibility: ScheduleVisibilityFilter.all,
      );
      if (schedules.isEmpty) {
        throw const FormatException('Không thể tải chi tiết lịch trình.');
      }

      // Keep the viewed day for repeats; a changed pattern/date opens the first
      // occurrence in the API's chronological order.
      return schedules.firstWhere(
        (schedule) =>
            scheduleDateKey(schedule.start) == scheduleDateKey(occurrenceDate),
        orElse: () => schedules.first,
      );
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          errorMessage: _messageForError(
            error,
            fallbackMessage: 'Không thể tải chi tiết lịch trình.',
          ),
        );
      }
      return null;
    }
  }

  Future<void> updateSchedule({
    required String scheduleEventId,
    required ScheduleDraft draft,
  }) async {
    try {
      await _scheduleApi.updateSchedule(
        scheduleEventId: scheduleEventId,
        draft: draft,
      );
    } catch (error) {
      throw FormatException(
        _messageForError(error, fallbackMessage: 'Không thể lưu lịch trình.'),
      );
    }
  }

  Future<bool> joinSchedule(String scheduleEventId) async {
    state = state.copyWith(isMutating: true, errorMessage: null);

    try {
      await _scheduleApi.joinSchedule(scheduleEventId);
      return true;
    } catch (error) {
      if (!ref.mounted) {
        return false;
      }

      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageForError(
          error,
          fallbackMessage: 'Không thể tham gia lịch trình.',
        ),
      );
      return false;
    } finally {
      if (ref.mounted && state.isMutating) {
        state = state.copyWith(isMutating: false);
      }
    }
  }

  Future<bool> leaveSchedule(String scheduleEventId) async {
    state = state.copyWith(isMutating: true, errorMessage: null);

    try {
      await _scheduleApi.leaveSchedule(scheduleEventId);
      return true;
    } catch (error) {
      if (!ref.mounted) {
        return false;
      }

      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageForError(
          error,
          fallbackMessage: 'Không thể rời lịch trình.',
        ),
      );
      return false;
    } finally {
      if (ref.mounted && state.isMutating) {
        state = state.copyWith(isMutating: false);
      }
    }
  }

  Future<bool> deleteSchedule(String scheduleEventId) async {
    state = state.copyWith(isMutating: true, errorMessage: null);

    try {
      await _scheduleApi.deleteSchedule(scheduleEventId);
      return true;
    } catch (error) {
      if (!ref.mounted) {
        return false;
      }

      state = state.copyWith(
        isMutating: false,
        errorMessage: _messageForError(
          error,
          fallbackMessage: 'Không thể xóa lịch trình.',
        ),
      );
      return false;
    } finally {
      if (ref.mounted && state.isMutating) {
        state = state.copyWith(isMutating: false);
      }
    }
  }

  Future<void> reloadSchedulesSilently() {
    return _loadSchedules(silent: true);
  }

  Future<void> _loadSchedules({bool silent = false}) async {
    final request = ++_scheduleLoad;
    _scheduleCancellation?.cancel();
    final cancellation = CancelToken();
    _scheduleCancellation = cancellation;
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final visibleRange = scheduleVisibleRange(state.month);
      final schedules = await _scheduleApi.fetchSchedules(
        cancelToken: cancellation,
        endFrom: visibleRange.start,
        startTo: visibleRange.end,
        userIds: _selectedUserFilter,
        visibility: state.visibility,
      );

      if (!ref.mounted || request != _scheduleLoad) {
        return;
      }

      state = state.copyWith(schedules: schedules, isLoading: false);
    } catch (error) {
      if (!ref.mounted || request != _scheduleLoad) {
        return;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageForError(
          error,
          fallbackMessage: 'Không thể tải lịch trình.',
        ),
      );
    }
  }

  Future<void> _loadUsers() async {
    final request = ++_userLoad;
    state = state.copyWith(isUsersLoading: true);

    try {
      final rootOrganizationId = ref
          .read(authControllerProvider)
          .user
          ?.rootOrganizationId;
      final users = rootOrganizationId == null
          ? <UserTreeSelectionUser>[]
          : await _scheduleApi.fetchUsers(
              rootOrganizationId: rootOrganizationId,
            );
      if (!ref.mounted || request != _userLoad) {
        return;
      }

      state = state.copyWith(users: users, isUsersLoading: false);
    } catch (error) {
      if (!ref.mounted || request != _userLoad) {
        return;
      }

      state = state.copyWith(
        isUsersLoading: false,
        errorMessage: _messageForError(
          error,
          fallbackMessage: 'Không thể tải danh sách người dùng.',
        ),
      );
    }
  }

  String? get _selectedUserFilter {
    final currentUserId = ref.read(authControllerProvider).user?.id;
    final selectedUserId = state.selectedUserId;

    if (selectedUserId == null || selectedUserId == currentUserId) {
      return null;
    }

    return selectedUserId;
  }
}

class ScheduleViewState {
  ScheduleViewState({
    required this.isInitialized,
    required this.today,
    required this.month,
    required this.selectedDate,
    required this.selectedUserId,
    required this.visibility,
    required this.isLoading,
    required this.isUsersLoading,
    required this.isMutating,
    required this.schedules,
    required this.users,
    required this.errorMessage,
  });

  factory ScheduleViewState.initial() {
    final today = _normalizeDate(scheduleToday());

    return ScheduleViewState(
      isInitialized: false,
      today: today,
      month: scheduleMonthAnchor(today),
      selectedDate: today,
      selectedUserId: null,
      visibility: ScheduleVisibilityFilter.participated,
      isLoading: true,
      isUsersLoading: true,
      isMutating: false,
      schedules: const [],
      users: const [],
      errorMessage: null,
    );
  }

  final bool isInitialized;
  final DateTime today;
  final DateTime month;
  final DateTime selectedDate;
  final String? selectedUserId;
  final ScheduleVisibilityFilter visibility;
  final bool isLoading;
  final bool isUsersLoading;
  final bool isMutating;
  final List<ScheduleModel> schedules;
  final List<UserTreeSelectionUser> users;
  final String? errorMessage;

  Map<String, List<ScheduleModel>> get schedulesByDate {
    return groupSchedulesByDate(schedules);
  }

  List<ScheduleModel> get daySchedules {
    return schedulesByDate[scheduleDateKey(selectedDate)] ?? const [];
  }

  List<ScheduleCalendarCell> get calendarCells {
    return buildScheduleCalendar(month);
  }

  ScheduleViewState copyWith({
    bool? isInitialized,
    DateTime? today,
    DateTime? month,
    DateTime? selectedDate,
    String? selectedUserId,
    ScheduleVisibilityFilter? visibility,
    bool? isLoading,
    bool? isUsersLoading,
    bool? isMutating,
    List<ScheduleModel>? schedules,
    List<UserTreeSelectionUser>? users,
    Object? errorMessage = _notChanged,
  }) {
    return ScheduleViewState(
      isInitialized: isInitialized ?? this.isInitialized,
      today: today ?? this.today,
      month: month ?? this.month,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      visibility: visibility ?? this.visibility,
      isLoading: isLoading ?? this.isLoading,
      isUsersLoading: isUsersLoading ?? this.isUsersLoading,
      isMutating: isMutating ?? this.isMutating,
      schedules: schedules ?? this.schedules,
      users: users ?? this.users,
      errorMessage: errorMessage == _notChanged
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _notChanged = Object();

DateTime _normalizeDate(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _messageForError(Object error, {required String fallbackMessage}) {
  return switch (error) {
    DioException(error: final ApiProblemException problem) => problemMessage(
      problem.problem,
    ),
    FormatException(:final message) => message,
    _ => fallbackMessage,
  };
}
