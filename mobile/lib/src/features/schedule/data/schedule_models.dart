import 'package:intl/intl.dart';
import 'package:obee_mobile/src/core/time/business_time.dart';
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';

part 'schedule_models.freezed.dart';
part 'schedule_models.g.dart';

/// Lightweight user projection embedded inside schedule payloads.
@freezed
abstract class ScheduleUserRef with _$ScheduleUserRef {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory ScheduleUserRef({
    required String id,
    required String name,
    String? avatar,
    String? email,
  }) = _ScheduleUserRef;

  factory ScheduleUserRef.fromJson(Map<String, dynamic> json) =>
      _wrapContractError(() => _$ScheduleUserRefFromJson(json));
}

/// Nested event metadata used by list rows, detail views, and edit drafts.
@Freezed(fromJson: true, toJson: true)
abstract class ScheduleEventModel with _$ScheduleEventModel {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory ScheduleEventModel({
    required String id,
    required String title,
    required ScheduleEventType type,
    @JsonKey(name: 'schedule_type')
    required ScheduleEventScheduleType scheduleType,
    @JsonKey(name: 'start_date', fromJson: _dateOnlyFromJson)
    required DateTime startDate,
    @JsonKey(name: 'end_date', fromJson: _dateOnlyFromJson)
    required DateTime endDate,
    @JsonKey(name: 'repeat_type', required: true)
    ScheduleEventRepeatType? repeatType,
    @JsonKey(name: 'repeat_pattern', required: true) List<int>? repeatPattern,
    @JsonKey(name: 'start_time', required: true) String? startTime,
    @JsonKey(name: 'end_time', required: true) String? endTime,
    @JsonKey(required: true) String? note,
    @JsonKey(name: 'physical_address', required: true) String? physicalAddress,
    required ScheduleEventPrivacy privacy,
    @JsonKey(name: 'is_general') required bool isGeneral,
    @JsonKey(name: 'remind_range', required: true)
    ScheduleEventRemindRange? remindRange,
    @JsonKey(name: 'remind_value', required: true) int? remindValue,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'updated_by', required: true) String? updatedBy,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required DateTime createdAt,
    @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
    required DateTime updatedAt,
    required List<ScheduleUserRef> participants,
    required List<ScheduleUserRef> observers,
  }) = _ScheduleEventModel;

  factory ScheduleEventModel.fromJson(Map<String, dynamic> json) {
    return _wrapContractError(() {
      final event = _$ScheduleEventModelFromJson(json);
      ScheduleDraft.fromEvent(event).validate();
      return event;
    });
  }
}

/// One normalized schedule occurrence returned by `/schedules`.
@freezed
abstract class ScheduleModel with _$ScheduleModel {
  @JsonSerializable(checked: true, explicitToJson: true)
  const factory ScheduleModel({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime start,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime end,
    @JsonKey(name: 'one_day') required bool oneDay,
    @JsonKey(
      name: 'remind_at',
      required: true,
      fromJson: _nullableDateTimeFromJson,
    )
    DateTime? remindAt,
    required ScheduleEventModel event,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _wrapContractError(() => _$ScheduleModelFromJson(json));
}

/// Mutable form state captured as an immutable value object before requests.
@freezed
abstract class ScheduleDraft with _$ScheduleDraft {
  const factory ScheduleDraft({
    required String title,
    required ScheduleEventType type,
    required ScheduleEventScheduleType scheduleType,
    required DateTime startDate,
    required DateTime endDate,
    required ScheduleEventRepeatType? repeatType,
    required List<int>? repeatPattern,
    required String? startTime,
    required String? endTime,
    required String? note,
    required String? physicalAddress,
    required ScheduleEventPrivacy privacy,
    required bool isGeneral,
    required ScheduleEventRemindRange? remindRange,
    required int? remindValue,
    required List<String> participants,
    required List<String> observers,
  }) = _ScheduleDraft;

  factory ScheduleDraft.forCreate({
    required String currentUserId,
    required DateTime selectedDate,
    DateTime? startAt,
  }) {
    // A tapped time slot gets a one-hour default, kept within that day.
    final start =
        startAt ??
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 8);
    final dayLimit = DateTime(start.year, start.month, start.day, 23, 59);
    final slotEnd = start.add(const Duration(hours: 1));
    final end = startAt == null
        ? DateTime(start.year, start.month, start.day, 17, 30)
        : (slotEnd.isAfter(dayLimit) ? dayLimit : slotEnd);

    return ScheduleDraft(
      title: '',
      type: ScheduleEventType.meeting,
      scheduleType: ScheduleEventScheduleType.ordinary,
      startDate: start,
      endDate: end,
      repeatType: null,
      repeatPattern: null,
      startTime: _formatDraftTime(start),
      endTime: _formatDraftTime(end),
      note: null,
      physicalAddress: null,
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      participants: [currentUserId],
      observers: const [],
    );
  }

  factory ScheduleDraft.fromEvent(ScheduleEventModel event) {
    return ScheduleDraft(
      title: event.title,
      type: event.type,
      scheduleType: event.scheduleType,
      startDate: event.startDate,
      endDate: event.endDate,
      repeatType: event.repeatType,
      repeatPattern: event.repeatPattern,
      startTime: event.startTime,
      endTime: event.endTime,
      note: event.note,
      physicalAddress: event.physicalAddress,
      privacy: event.privacy,
      isGeneral: event.isGeneral,
      remindRange: event.remindRange,
      remindValue: event.remindValue,
      participants: event.participants
          .map((item) => item.id)
          .toList(growable: false),
      observers: event.observers.map((item) => item.id).toList(growable: false),
    );
  }
}

extension ScheduleDraftRequestX on ScheduleDraft {
  void validate() {
    if (scheduleType == ScheduleEventScheduleType.ordinary &&
        formatApiDate(startDate) != formatApiDate(endDate)) {
      throw const FormatException(
        'Ordinary schedules require the same start/end date.',
      );
    }
    if (formatApiDate(endDate).compareTo(formatApiDate(startDate)) < 0) {
      throw const FormatException('Schedule end date precedes start date.');
    }
    if (scheduleType == ScheduleEventScheduleType.multipleDays) {
      if (startTime != null || endTime != null) {
        throw const FormatException(
          'Multi-day schedules require null clock times.',
        );
      }
    } else {
      final start = startTime;
      final end = endTime;
      final clock = RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$');
      if (start == null ||
          end == null ||
          !clock.hasMatch(start) ||
          !clock.hasMatch(end) ||
          end.compareTo(start) <= 0) {
        throw const FormatException(
          'Schedule requires HH:mm times with end after start.',
        );
      }
    }
    if (scheduleType == ScheduleEventScheduleType.repeat) {
      final repeat = repeatType;
      if (repeat == null) {
        throw const FormatException('Repeat type is required.');
      }
      if (repeat == ScheduleEventRepeatType.daily) {
        if (repeatPattern != null) {
          throw const FormatException('Daily repeats require null pattern.');
        }
      } else {
        final pattern = repeatPattern;
        final maximum = repeat == ScheduleEventRepeatType.weekly ? 7 : 31;
        if (pattern == null ||
            pattern.isEmpty ||
            pattern.any((day) => day < 1 || day > maximum) ||
            pattern.toSet().length != pattern.length) {
          throw const FormatException('Invalid repeat pattern.');
        }
      }
    } else if (repeatType != null || repeatPattern != null) {
      throw const FormatException(
        'Non-repeating schedules require null repeat fields.',
      );
    }
    if ((remindRange == null) != (remindValue == null) ||
        (remindValue != null &&
            (remindValue! < 1 || remindValue! > 2147483647))) {
      throw const FormatException('Invalid schedule reminder.');
    }
  }

  /// Dates and nullable clock times follow the web schedule write contract.
  Map<String, Object?> toRequestJson() {
    validate();
    return {
      'title': title,
      'type': _$ScheduleEventTypeEnumMap[type]!,
      'schedule_type': _$ScheduleEventScheduleTypeEnumMap[scheduleType]!,
      'start_date': formatApiDate(startDate),
      'end_date': formatApiDate(endDate),
      'repeat_type': repeatType == null
          ? null
          : _$ScheduleEventRepeatTypeEnumMap[repeatType!],
      'repeat_pattern': repeatPattern,
      'start_time': startTime,
      'end_time': endTime,
      'note': note,
      'physical_address': physicalAddress,
      'privacy': _$ScheduleEventPrivacyEnumMap[privacy]!,
      'is_general': isGeneral,
      'remind_range': remindRange == null
          ? null
          : _$ScheduleEventRemindRangeEnumMap[remindRange!],
      'remind_value': remindValue,
      'participants': participants,
      'observers': observers,
    };
  }
}

T _wrapContractError<T>(T Function() parse) {
  try {
    return parse();
  } on CheckedFromJsonException catch (error) {
    throw FormatException(error.message ?? 'Schedule contract is invalid.');
  } on FormatException {
    rethrow;
  } catch (error) {
    throw FormatException('Schedule contract is invalid: $error');
  }
}

DateTime _dateTimeFromJson(Object? value) {
  if (value is! String) {
    throw const FormatException('Schedule contract is invalid for date.');
  }

  return businessWallTime(DateTime.parse(value));
}

DateTime? _nullableDateTimeFromJson(Object? value) {
  if (value == null) {
    return null;
  }

  return _dateTimeFromJson(value);
}

DateTime _dateOnlyFromJson(Object? value) {
  if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw const FormatException('Schedule date must be YYYY-MM-DD.');
  }
  return DateFormat('yyyy-MM-dd').parseStrict(value);
}

String _formatDraftTime(DateTime value) {
  return '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
