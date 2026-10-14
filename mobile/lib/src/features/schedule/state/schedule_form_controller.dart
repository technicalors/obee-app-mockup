import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_user_tree.dart';
import 'package:obee_mobile/src/features/schedule/state/schedule_controller.dart';

final scheduleFormControllerProvider = StateNotifierProvider.autoDispose
    .family<ScheduleFormController, ScheduleFormState, ScheduleFormArgs>(
      (ref, args) => ScheduleFormController(ref, args),
    );

class ScheduleFormController extends StateNotifier<ScheduleFormState> {
  ScheduleFormController(this.ref, this.args)
    : super(ScheduleFormState.initial());

  final Ref ref;
  final ScheduleFormArgs args;

  Future<void> bootstrap() async {
    if (!state.isBootstrapping) {
      return;
    }

    final scheduleController = ref.read(scheduleControllerProvider.notifier);
    await scheduleController.initialize();

    if (!ref.mounted) {
      return;
    }

    final currentUser = ref.read(authControllerProvider).user;
    if (!args.isEditing && !hasScheduleOrganization(currentUser)) {
      state = state.copyWith(
        isBootstrapping: false,
        loadError: 'Bạn cần được gán tổ chức trước khi tạo lịch trình.',
      );
      return;
    }

    final draft = await _resolveInitialDraft(scheduleController);
    if (!ref.mounted) {
      return;
    }

    if (draft == null) {
      state = state.copyWith(
        isBootstrapping: false,
        loadError: 'Không thể mở biểu mẫu lịch trình.',
      );
      return;
    }

    final users = ref.read(scheduleControllerProvider).users;
    state = _buildBootstrappedState(
      draft,
      currentUser: currentUser,
      users: users,
    );
  }

  void updateType(ScheduleEventType? value) {
    if (value == null) {
      return;
    }

    state = state.copyWith(type: value);
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateNote(String value) {
    state = state.copyWith(note: value);
  }

  void updateAddress(String value) {
    state = state.copyWith(physicalAddress: value);
  }

  void updateScheduleType(ScheduleEventScheduleType? value) {
    if (value == null) {
      return;
    }

    state = state.copyWith(
      scheduleType: value,
      repeatType: value == ScheduleEventScheduleType.repeat
          ? state.repeatType
          : null,
      repeatPattern: value == ScheduleEventScheduleType.repeat
          ? state.repeatPattern
          : const <String>{},
    );
  }

  void updateStartDate(DateTime value) {
    final startDate = state.startDate;
    if (startDate == null) {
      return;
    }

    state = state.copyWith(
      startDate: DateTime(
        value.year,
        value.month,
        value.day,
        startDate.hour,
        startDate.minute,
      ),
    );
  }

  void updateEndDate(DateTime value) {
    final endDate = state.endDate;
    if (endDate == null) {
      return;
    }

    state = state.copyWith(
      endDate: DateTime(
        value.year,
        value.month,
        value.day,
        endDate.hour,
        endDate.minute,
      ),
    );
  }

  void updateStartTime(TimeOfDay value) {
    final startDate = state.startDate;
    if (startDate == null) {
      return;
    }

    state = state.copyWith(
      startTime: value,
      startDate: DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        value.hour,
        value.minute,
      ),
    );
  }

  void updateEndTime(TimeOfDay value) {
    final endDate = state.endDate;
    if (endDate == null) {
      return;
    }

    state = state.copyWith(
      endTime: value,
      endDate: DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        value.hour,
        value.minute,
      ),
    );
  }

  void updateRepeatType(ScheduleEventRepeatType? value) {
    if (value == null) {
      state = state.copyWith(repeatType: null, repeatPattern: const <String>{});
      return;
    }

    final shouldClearPattern =
        value != state.repeatType ||
        value != ScheduleEventRepeatType.weekly &&
            value != ScheduleEventRepeatType.monthly;

    state = state.copyWith(
      repeatType: value,
      repeatPattern: shouldClearPattern
          ? const <String>{}
          : state.repeatPattern,
    );
  }

  void updateRepeatPattern(Set<String> value) {
    state = state.copyWith(repeatPattern: value);
  }

  void updateParticipants(Set<String> value) {
    state = state.copyWith(participants: value);
  }

  void updateObservers(Set<String> value) {
    state = state.copyWith(observers: value);
  }

  void updatePrivacy(ScheduleEventPrivacy? value) {
    if (value == null) {
      return;
    }

    state = state.copyWith(privacy: value);
  }

  void updateIsGeneral(bool value) {
    state = state.copyWith(isGeneral: value);
  }

  void updateHasReminder(bool value) {
    state = state.copyWith(
      hasReminder: value,
      remindRange: value ? state.remindRange : null,
      remindValue: value ? state.remindValue : '',
    );
  }

  void updateRemindValue(String value) {
    state = state.copyWith(remindValue: value);
  }

  void updateRemindRange(ScheduleEventRemindRange? value) {
    state = state.copyWith(remindRange: value);
  }

  Future<ScheduleFormSubmitResult> submit() async {
    final currentUser = ref.read(authControllerProvider).user;
    if (!args.isEditing && !hasScheduleOrganization(currentUser)) {
      return const ScheduleFormSubmitResult.failure(
        'Bạn cần được gán tổ chức trước khi tạo lịch trình.',
      );
    }

    final effectiveSelections = _sanitizeSelectableUserIds(currentUser);
    if (effectiveSelections.participants.length != state.participants.length ||
        effectiveSelections.observers.length != state.observers.length) {
      state = state.copyWith(
        participants: effectiveSelections.participants,
        observers: effectiveSelections.observers,
      );
    }

    if (effectiveSelections.participants.isEmpty) {
      return const ScheduleFormSubmitResult.failure(
        'Cần chọn ít nhất một người tham gia.',
      );
    }

    if (state.scheduleType == ScheduleEventScheduleType.repeat &&
        state.repeatType == null) {
      return const ScheduleFormSubmitResult.failure('Cần chọn chu kỳ lặp lại.');
    }

    if (state.scheduleType == ScheduleEventScheduleType.repeat &&
        (state.repeatType == ScheduleEventRepeatType.weekly ||
            state.repeatType == ScheduleEventRepeatType.monthly) &&
        state.repeatPattern.isEmpty) {
      return const ScheduleFormSubmitResult.failure('Cần chọn mẫu lặp lại.');
    }

    final startDate = state.startDate;
    final endDate = state.endDate;
    if (startDate == null || endDate == null) {
      return const ScheduleFormSubmitResult.failure(
        'Không thể xác định thời gian lịch trình.',
      );
    }

    if (state.scheduleType == ScheduleEventScheduleType.repeat &&
        endDate.isBefore(startDate)) {
      return const ScheduleFormSubmitResult.failure(
        'Ngày kết thúc phải sau ngày bắt đầu.',
      );
    }

    if (state.scheduleType != ScheduleEventScheduleType.repeat &&
        endDate.isBefore(startDate)) {
      return const ScheduleFormSubmitResult.failure(
        'Thời gian kết thúc phải sau thời gian bắt đầu.',
      );
    }

    if (state.scheduleType == ScheduleEventScheduleType.ordinary &&
        (startDate.year != endDate.year ||
            startDate.month != endDate.month ||
            startDate.day != endDate.day)) {
      return const ScheduleFormSubmitResult.failure(
        'Lịch thông thường phải bắt đầu và kết thúc cùng ngày.',
      );
    }
    if (state.scheduleType != ScheduleEventScheduleType.multipleDays) {
      final start = state.startTime;
      final end = state.endTime;
      if (start == null ||
          end == null ||
          end.hour * 60 + end.minute <= start.hour * 60 + start.minute) {
        return const ScheduleFormSubmitResult.failure(
          'Giờ kết thúc phải sau giờ bắt đầu.',
        );
      }
    }

    final draft = _buildDraft(
      participants: effectiveSelections.participants,
      observers: effectiveSelections.observers,
    );
    if (draft == null) {
      return const ScheduleFormSubmitResult.failure(
        'Không thể tạo dữ liệu lịch trình hợp lệ.',
      );
    }

    state = state.copyWith(isSubmitting: true);

    try {
      if (args.isEditing) {
        final scheduleEventId = args.scheduleEventId;
        if (scheduleEventId == null) {
          return const ScheduleFormSubmitResult.failure(
            'Không thể xác định lịch trình cần cập nhật.',
          );
        }

        await ref
            .read(scheduleControllerProvider.notifier)
            .updateSchedule(scheduleEventId: scheduleEventId, draft: draft);
      } else {
        await ref
            .read(scheduleControllerProvider.notifier)
            .createSchedule(draft);
      }

      return const ScheduleFormSubmitResult.success();
    } on FormatException catch (error) {
      return ScheduleFormSubmitResult.failure(error.message);
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false);
      }
    }
  }

  Future<ScheduleDraft?> _resolveInitialDraft(
    ScheduleController scheduleController,
  ) async {
    final scheduleId = args.scheduleId;
    if (scheduleId == null) {
      return scheduleController.buildCreateDraft();
    }

    final detail = await scheduleController.fetchScheduleDetail(scheduleId);
    if (detail == null) {
      return null;
    }

    return ScheduleDraft.fromEvent(detail.event);
  }

  ScheduleFormState _buildBootstrappedState(
    ScheduleDraft draft, {
    required User? currentUser,
    required List<UserTreeSelectionUser> users,
  }) {
    final shouldFilterSelections = hasScheduleOrganization(currentUser);
    final visibleUserIds = shouldFilterSelections
        ? buildVisibleScheduleUserIds(users: users, currentUser: currentUser)
        : null;

    return ScheduleFormState(
      isBootstrapping: false,
      isSubmitting: false,
      loadError: null,
      title: draft.title,
      note: draft.note ?? '',
      physicalAddress: draft.physicalAddress ?? '',
      remindValue: draft.remindValue?.toString() ?? '',
      type: draft.type,
      scheduleType: draft.scheduleType,
      privacy: draft.privacy,
      repeatType: draft.repeatType,
      repeatPattern: (draft.repeatPattern ?? const <int>[])
          .map((item) => item.toString())
          .toSet(),
      startDate: draft.startDate,
      endDate: draft.endDate,
      startTime: TimeOfDay(
        hour: draft.startTime == null
            ? 8
            : int.parse(draft.startTime!.split(':')[0]),
        minute: draft.startTime == null
            ? 0
            : int.parse(draft.startTime!.split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: draft.endTime == null
            ? 17
            : int.parse(draft.endTime!.split(':')[0]),
        minute: draft.endTime == null
            ? 30
            : int.parse(draft.endTime!.split(':')[1]),
      ),
      isGeneral: draft.isGeneral,
      hasReminder: draft.remindRange != null,
      remindRange: draft.remindRange,
      participants: shouldFilterSelections
          ? draft.participants.where(visibleUserIds!.contains).toSet()
          : draft.participants.toSet(),
      observers: shouldFilterSelections
          ? draft.observers.where(visibleUserIds!.contains).toSet()
          : draft.observers.toSet(),
    );
  }

  _ScheduleFormSelectableUsers _sanitizeSelectableUserIds(User? currentUser) {
    if (!hasScheduleOrganization(currentUser)) {
      return _ScheduleFormSelectableUsers(
        participants: state.participants,
        observers: state.observers,
      );
    }

    final visibleUserIds = buildVisibleScheduleUserIds(
      users: ref.read(scheduleControllerProvider).users,
      currentUser: currentUser,
    );

    return _ScheduleFormSelectableUsers(
      participants: state.participants.where(visibleUserIds.contains).toSet(),
      observers: state.observers.where(visibleUserIds.contains).toSet(),
    );
  }

  ScheduleDraft? _buildDraft({
    required Set<String> participants,
    required Set<String> observers,
  }) {
    final type = state.type;
    final scheduleType = state.scheduleType;
    final privacy = state.privacy;
    final startDate = state.startDate;
    final endDate = state.endDate;
    final startTime = state.startTime;
    final endTime = state.endTime;
    if (type == null ||
        scheduleType == null ||
        privacy == null ||
        startDate == null ||
        endDate == null ||
        startTime == null ||
        endTime == null) {
      return null;
    }

    List<int>? repeatPattern;
    if (state.repeatType == ScheduleEventRepeatType.weekly ||
        state.repeatType == ScheduleEventRepeatType.monthly) {
      repeatPattern = state.repeatPattern.map(int.parse).toList(growable: false)
        ..sort();
    }

    return ScheduleDraft(
      title: state.title.trim(),
      type: type,
      scheduleType: scheduleType,
      startDate: startDate,
      endDate: endDate,
      repeatType: state.repeatType,
      repeatPattern: repeatPattern,
      startTime: scheduleType != ScheduleEventScheduleType.multipleDays
          ? formatApiTime(startTime)
          : null,
      endTime: scheduleType != ScheduleEventScheduleType.multipleDays
          ? formatApiTime(endTime)
          : null,
      note: emptyToNull(state.note),
      physicalAddress: emptyToNull(state.physicalAddress),
      privacy: privacy,
      isGeneral: state.isGeneral,
      remindRange: state.hasReminder ? state.remindRange : null,
      remindValue: state.hasReminder && state.remindValue.isNotEmpty
          ? int.parse(state.remindValue)
          : null,
      participants: participants.toList(growable: false),
      observers: observers.toList(growable: false),
    );
  }
}

class ScheduleFormArgs {
  const ScheduleFormArgs({
    required this.isEditing,
    this.scheduleId,
    this.scheduleEventId,
  });

  final bool isEditing;
  final String? scheduleId;
  final String? scheduleEventId;

  @override
  bool operator ==(Object other) {
    return other is ScheduleFormArgs &&
        other.isEditing == isEditing &&
        other.scheduleId == scheduleId &&
        other.scheduleEventId == scheduleEventId;
  }

  @override
  int get hashCode => Object.hash(isEditing, scheduleId, scheduleEventId);
}

class ScheduleFormState {
  const ScheduleFormState({
    required this.isBootstrapping,
    required this.isSubmitting,
    required this.loadError,
    required this.title,
    required this.note,
    required this.physicalAddress,
    required this.remindValue,
    required this.type,
    required this.scheduleType,
    required this.privacy,
    required this.repeatType,
    required this.repeatPattern,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.isGeneral,
    required this.hasReminder,
    required this.remindRange,
    required this.participants,
    required this.observers,
  });

  factory ScheduleFormState.initial() {
    return ScheduleFormState(
      isBootstrapping: true,
      isSubmitting: false,
      loadError: null,
      title: '',
      note: '',
      physicalAddress: '',
      remindValue: '',
      type: null,
      scheduleType: null,
      privacy: null,
      repeatType: null,
      repeatPattern: const <String>{},
      startDate: null,
      endDate: null,
      startTime: null,
      endTime: null,
      isGeneral: false,
      hasReminder: false,
      remindRange: null,
      participants: const <String>{},
      observers: const <String>{},
    );
  }

  final bool isBootstrapping;
  final bool isSubmitting;
  final String? loadError;
  final String title;
  final String note;
  final String physicalAddress;
  final String remindValue;
  final ScheduleEventType? type;
  final ScheduleEventScheduleType? scheduleType;
  final ScheduleEventPrivacy? privacy;
  final ScheduleEventRepeatType? repeatType;
  final Set<String> repeatPattern;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isGeneral;
  final bool hasReminder;
  final ScheduleEventRemindRange? remindRange;
  final Set<String> participants;
  final Set<String> observers;

  ScheduleFormState copyWith({
    bool? isBootstrapping,
    bool? isSubmitting,
    Object? loadError = _scheduleFormNotChanged,
    String? title,
    String? note,
    String? physicalAddress,
    String? remindValue,
    ScheduleEventType? type,
    ScheduleEventScheduleType? scheduleType,
    Object? privacy = _scheduleFormNotChanged,
    Object? repeatType = _scheduleFormNotChanged,
    Set<String>? repeatPattern,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isGeneral,
    bool? hasReminder,
    Object? remindRange = _scheduleFormNotChanged,
    Set<String>? participants,
    Set<String>? observers,
  }) {
    return ScheduleFormState(
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      loadError: loadError == _scheduleFormNotChanged
          ? this.loadError
          : loadError as String?,
      title: title ?? this.title,
      note: note ?? this.note,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      remindValue: remindValue ?? this.remindValue,
      type: type ?? this.type,
      scheduleType: scheduleType ?? this.scheduleType,
      privacy: privacy == _scheduleFormNotChanged
          ? this.privacy
          : privacy as ScheduleEventPrivacy?,
      repeatType: repeatType == _scheduleFormNotChanged
          ? this.repeatType
          : repeatType as ScheduleEventRepeatType?,
      repeatPattern: repeatPattern ?? this.repeatPattern,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isGeneral: isGeneral ?? this.isGeneral,
      hasReminder: hasReminder ?? this.hasReminder,
      remindRange: remindRange == _scheduleFormNotChanged
          ? this.remindRange
          : remindRange as ScheduleEventRemindRange?,
      participants: participants ?? this.participants,
      observers: observers ?? this.observers,
    );
  }
}

class ScheduleFormSubmitResult {
  const ScheduleFormSubmitResult._({required this.isSuccess, this.message});

  const ScheduleFormSubmitResult.success() : this._(isSuccess: true);

  const ScheduleFormSubmitResult.failure(String message)
    : this._(isSuccess: false, message: message);

  final bool isSuccess;
  final String? message;
}

final class _ScheduleFormSelectableUsers {
  const _ScheduleFormSelectableUsers({
    required this.participants,
    required this.observers,
  });

  final Set<String> participants;
  final Set<String> observers;
}

const Object _scheduleFormNotChanged = Object();

String? emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
