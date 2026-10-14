import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/location/device_location_service.dart';
import 'package:obee_mobile/src/core/network/api_problem.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_api.dart';
import 'package:obee_mobile/src/features/attendance/data/attendance_models.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_date.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_formatters.dart';
import 'package:obee_mobile/src/features/attendance/logic/attendance_rules.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';

final attendanceControllerProvider =
    NotifierProvider<AttendanceController, AttendanceState>(
      AttendanceController.new,
    );

class AttendanceController extends Notifier<AttendanceState> {
  late AttendanceApi _attendanceApi;
  late DeviceLocationService _locationService;
  int _contextLoad = 0;
  int _dayLoad = 0;
  int _rangeLoad = 0;
  int _positionLoad = 0;

  @override
  AttendanceState build() {
    _attendanceApi = ref.watch(attendanceApiProvider);
    _locationService = ref.watch(deviceLocationServiceProvider);

    final today = attendanceToday();
    final calendarMonthStart = getAttendanceMonthStartValue(attendanceNow());

    return AttendanceState(
      today: today,
      selectedDate: today,
      calendarMonthStart: calendarMonthStart,
    );
  }

  Future<void> refreshForCurrentDay() async {
    final today = attendanceToday();
    if (state.today != today) {
      state = AttendanceState(
        today: today,
        selectedDate: today,
        calendarMonthStart: getAttendanceMonthStartValue(attendanceNow()),
      );
    }
    await bootstrap();
  }

  Future<void> refresh() async {
    final today = attendanceToday();
    if (state.today != today) {
      state = AttendanceState(
        today: today,
        selectedDate: today,
        calendarMonthStart: getAttendanceMonthStartValue(attendanceNow()),
      );
    }

    // Location has its own loading state and may wait up to 15 seconds.
    // Pull-to-refresh finishes when the server data is ready.
    unawaited(requestCurrentPosition());
    await Future.wait([
      ref.read(authControllerProvider.notifier).refreshCurrentUser(),
      loadContext(),
      loadTodayLogs(),
      loadRange(
        state.calendarMonthStart,
        getAttendanceMonthEndValue(state.calendarMonthStart),
      ),
      if (state.selectedDate != state.today) openDayDetail(state.selectedDate),
    ]);
  }

  Future<void> openLocationSettings() => _locationService.openSettings();

  Future<void> bootstrap() async {
    final monthEnd = getAttendanceMonthEndValue(state.calendarMonthStart);
    await Future.wait([
      loadContext(),
      loadTodayLogs(),
      loadRange(state.calendarMonthStart, monthEnd),
      requestCurrentPosition(),
    ]);
  }

  AttendanceEvaluation? get bestEvaluation {
    final context = state.contextData;
    if (context == null) {
      return null;
    }

    return selectBestEvaluation(
      context.assignedLocations,
      state.position,
      context.ipAddress,
    );
  }

  Future<void> loadContext() async {
    final request = ++_contextLoad;
    state = state.copyWith(
      loadingContext: true,
      feedbackMessage: null,
      contextData: null,
    );

    try {
      final context = await _attendanceApi.fetchContext();
      if (!ref.mounted || request != _contextLoad) {
        return;
      }

      state = state.copyWith(contextData: context, loadingContext: false);
    } catch (error) {
      if (!ref.mounted || request != _contextLoad) return;
      _setFeedbackMessage(_messageForError(error));
      state = state.copyWith(loadingContext: false);
    }
  }

  Future<void> loadTodayLogs() async {
    state = state.copyWith(loadingTodayLogs: true, feedbackMessage: null);

    try {
      final detail = await _attendanceApi.fetchDayDetail(state.today);
      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(todayDetail: detail, loadingTodayLogs: false);
    } catch (error) {
      if (!ref.mounted) return;
      _setFeedbackMessage(_messageForError(error));
      state = state.copyWith(loadingTodayLogs: false);
    }
  }

  Future<void> loadRange(String from, String to) async {
    final request = ++_rangeLoad;
    try {
      final summaries = await _attendanceApi.fetchRange(from: from, to: to);
      if (!ref.mounted || request != _rangeLoad) {
        return;
      }

      state = state.copyWith(rangeSummaries: summaries);
    } catch (error) {
      if (!ref.mounted || request != _rangeLoad) return;
      _setFeedbackMessage(_messageForError(error));
    }
  }

  Future<void> openDayDetail(String date) async {
    final request = ++_dayLoad;
    state = state.copyWith(
      selectedDate: date,
      loadingSelectedDay: true,
      selectedDayDetail: null,
      feedbackMessage: null,
    );

    try {
      final detail = await _attendanceApi.fetchDayDetail(date);
      if (!ref.mounted || request != _dayLoad) {
        return;
      }

      state = state.copyWith(
        selectedDayDetail: detail,
        loadingSelectedDay: false,
      );
    } catch (error) {
      if (!ref.mounted || request != _dayLoad) return;
      _setFeedbackMessage(_messageForError(error));
      state = state.copyWith(loadingSelectedDay: false);
    }
  }

  Future<void> requestCurrentPosition() async {
    final request = ++_positionLoad;
    state = state.copyWith(
      positionState: PositionState.loading,
      position: null,
    );

    try {
      final result = await _locationService.getCurrentLocation();
      if (!ref.mounted || request != _positionLoad) {
        return;
      }

      switch (result.status) {
        case DeviceLocationStatus.serviceDisabled:
          state = state.copyWith(positionState: PositionState.failed);
          return;
        case DeviceLocationStatus.permissionDeniedForever:
          state = state.copyWith(positionState: PositionState.deniedForever);
          return;
        case DeviceLocationStatus.permissionDenied:
          state = state.copyWith(positionState: PositionState.denied);
          return;
        case DeviceLocationStatus.ready:
          state = state.copyWith(
            position: AttendanceCoordinates(
              latitude: result.latitude!,
              longitude: result.longitude!,
            ),
            positionState: PositionState.ready,
          );
          return;
      }
    } catch (_) {
      if (!ref.mounted || request != _positionLoad) {
        return;
      }

      state = state.copyWith(positionState: PositionState.failed);
    }
  }

  Future<void> punch() async {
    if (state.punching) return;
    state = state.copyWith(punching: true, feedbackMessage: null);
    await Future.wait([loadContext(), requestCurrentPosition()]);
    if (!ref.mounted) return;
    if (state.contextData?.hasShiftToday != true) {
      state = state.copyWith(punching: false);
      _setFeedbackMessage(
        state.contextData?.hasShiftToday == false
            ? 'attendanceNoShift'
            : 'attendanceConnectError',
      );
      return;
    }

    final evaluation = bestEvaluation;
    if (evaluation?.eligibility.eligible != true) {
      state = state.copyWith(punching: false);
      final context = state.contextData;
      _setFeedbackMessage(
        context?.assignedLocations.isEmpty ?? true
            ? 'attendanceNoAssignedLocation'
            : 'attendanceNotEligible',
      );
      return;
    }

    state = state.copyWith(punching: true, feedbackMessage: null);

    try {
      await _attendanceApi.punch(state.position);
      if (!ref.mounted) {
        return;
      }

      _setFeedbackMessage('attendanceRecorded');

      await Future.wait([
        loadContext(),
        loadTodayLogs(),
        loadRange(
          state.calendarMonthStart,
          getAttendanceMonthEndValue(state.calendarMonthStart),
        ),
      ]);
    } catch (error) {
      if (!ref.mounted) return;
      _setFeedbackMessage(_messageForError(error));
    } finally {
      if (ref.mounted) {
        state = state.copyWith(punching: false);
      }
    }
  }

  Future<void> updateCalendarMonth(String nextMonthStart) async {
    final nextMonthEnd = getAttendanceMonthEndValue(nextMonthStart);
    state = state.copyWith(calendarMonthStart: nextMonthStart);
    await loadRange(nextMonthStart, nextMonthEnd);

    if (state.selectedDate.compareTo(nextMonthStart) < 0 ||
        state.selectedDate.compareTo(nextMonthEnd) > 0) {
      await openDayDetail(nextMonthStart);
    }
  }

  Future<void> shiftCalendarMonth(int deltaMonths) async {
    await updateCalendarMonth(
      shiftAttendanceMonthValue(state.calendarMonthStart, deltaMonths),
    );
  }

  void clearFeedbackMessage() {
    state = state.copyWith(feedbackMessage: null);
  }

  void _setFeedbackMessage(String message) {
    state = state.copyWith(feedbackMessage: message);
  }

  String _messageForError(Object error) {
    if (error is DioException) {
      final apiError = error.error;
      if (apiError is ApiProblemException) {
        return problemMessage(apiError.problem);
      }
    }

    return 'attendanceConnectError';
  }
}

class AttendanceState {
  const AttendanceState({
    required this.today,
    required this.selectedDate,
    required this.calendarMonthStart,
    this.contextData,
    this.position,
    this.positionState = PositionState.idle,
    this.loadingContext = true,
    this.punching = false,
    this.todayDetail,
    this.loadingTodayLogs = true,
    this.rangeSummaries = const [],
    this.selectedDayDetail,
    this.loadingSelectedDay = false,
    this.feedbackMessage,
  });

  final String today;
  final String selectedDate;
  final String calendarMonthStart;
  final AttendanceContext? contextData;
  final AttendanceCoordinates? position;
  final PositionState positionState;
  final bool loadingContext;
  final bool punching;
  final AttendanceDayDetail? todayDetail;
  final bool loadingTodayLogs;
  final List<AttendanceRangeSummary> rangeSummaries;
  final AttendanceDayDetail? selectedDayDetail;
  final bool loadingSelectedDay;
  final String? feedbackMessage;

  AttendanceState copyWith({
    String? today,
    String? selectedDate,
    String? calendarMonthStart,
    Object? contextData = _sentinel,
    Object? position = _sentinel,
    PositionState? positionState,
    bool? loadingContext,
    bool? punching,
    Object? todayDetail = _sentinel,
    bool? loadingTodayLogs,
    List<AttendanceRangeSummary>? rangeSummaries,
    Object? selectedDayDetail = _sentinel,
    bool? loadingSelectedDay,
    Object? feedbackMessage = _sentinel,
  }) {
    return AttendanceState(
      today: today ?? this.today,
      selectedDate: selectedDate ?? this.selectedDate,
      calendarMonthStart: calendarMonthStart ?? this.calendarMonthStart,
      contextData: identical(contextData, _sentinel)
          ? this.contextData
          : contextData as AttendanceContext?,
      position: identical(position, _sentinel)
          ? this.position
          : position as AttendanceCoordinates?,
      positionState: positionState ?? this.positionState,
      loadingContext: loadingContext ?? this.loadingContext,
      punching: punching ?? this.punching,
      todayDetail: identical(todayDetail, _sentinel)
          ? this.todayDetail
          : todayDetail as AttendanceDayDetail?,
      loadingTodayLogs: loadingTodayLogs ?? this.loadingTodayLogs,
      rangeSummaries: rangeSummaries ?? this.rangeSummaries,
      selectedDayDetail: identical(selectedDayDetail, _sentinel)
          ? this.selectedDayDetail
          : selectedDayDetail as AttendanceDayDetail?,
      loadingSelectedDay: loadingSelectedDay ?? this.loadingSelectedDay,
      feedbackMessage: identical(feedbackMessage, _sentinel)
          ? this.feedbackMessage
          : feedbackMessage as String?,
    );
  }
}

const Object _sentinel = Object();
