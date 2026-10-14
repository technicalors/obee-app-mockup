// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleUserRef _$ScheduleUserRefFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ScheduleUserRef', json, ($checkedConvert) {
      final val = _ScheduleUserRef(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        avatar: $checkedConvert('avatar', (v) => v as String?),
        email: $checkedConvert('email', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ScheduleUserRefToJson(_ScheduleUserRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatar': instance.avatar,
      'email': instance.email,
    };

_ScheduleEventModel _$ScheduleEventModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_ScheduleEventModel',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'repeat_type',
        'repeat_pattern',
        'start_time',
        'end_time',
        'note',
        'physical_address',
        'remind_range',
        'remind_value',
        'updated_by',
      ],
    );
    final val = _ScheduleEventModel(
      id: $checkedConvert('id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(_$ScheduleEventTypeEnumMap, v),
      ),
      scheduleType: $checkedConvert(
        'schedule_type',
        (v) => $enumDecode(_$ScheduleEventScheduleTypeEnumMap, v),
      ),
      startDate: $checkedConvert('start_date', (v) => _dateOnlyFromJson(v)),
      endDate: $checkedConvert('end_date', (v) => _dateOnlyFromJson(v)),
      repeatType: $checkedConvert(
        'repeat_type',
        (v) => $enumDecodeNullable(_$ScheduleEventRepeatTypeEnumMap, v),
      ),
      repeatPattern: $checkedConvert(
        'repeat_pattern',
        (v) => (v as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
      ),
      startTime: $checkedConvert('start_time', (v) => v as String?),
      endTime: $checkedConvert('end_time', (v) => v as String?),
      note: $checkedConvert('note', (v) => v as String?),
      physicalAddress: $checkedConvert('physical_address', (v) => v as String?),
      privacy: $checkedConvert(
        'privacy',
        (v) => $enumDecode(_$ScheduleEventPrivacyEnumMap, v),
      ),
      isGeneral: $checkedConvert('is_general', (v) => v as bool),
      remindRange: $checkedConvert(
        'remind_range',
        (v) => $enumDecodeNullable(_$ScheduleEventRemindRangeEnumMap, v),
      ),
      remindValue: $checkedConvert('remind_value', (v) => (v as num?)?.toInt()),
      createdBy: $checkedConvert('created_by', (v) => v as String),
      updatedBy: $checkedConvert('updated_by', (v) => v as String?),
      createdAt: $checkedConvert('created_at', (v) => _dateTimeFromJson(v)),
      updatedAt: $checkedConvert('updated_at', (v) => _dateTimeFromJson(v)),
      participants: $checkedConvert(
        'participants',
        (v) => (v as List<dynamic>)
            .map((e) => ScheduleUserRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      observers: $checkedConvert(
        'observers',
        (v) => (v as List<dynamic>)
            .map((e) => ScheduleUserRef.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'scheduleType': 'schedule_type',
    'startDate': 'start_date',
    'endDate': 'end_date',
    'repeatType': 'repeat_type',
    'repeatPattern': 'repeat_pattern',
    'startTime': 'start_time',
    'endTime': 'end_time',
    'physicalAddress': 'physical_address',
    'isGeneral': 'is_general',
    'remindRange': 'remind_range',
    'remindValue': 'remind_value',
    'createdBy': 'created_by',
    'updatedBy': 'updated_by',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$ScheduleEventModelToJson(
  _ScheduleEventModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': _$ScheduleEventTypeEnumMap[instance.type]!,
  'schedule_type': _$ScheduleEventScheduleTypeEnumMap[instance.scheduleType]!,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'repeat_type': _$ScheduleEventRepeatTypeEnumMap[instance.repeatType],
  'repeat_pattern': instance.repeatPattern,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'note': instance.note,
  'physical_address': instance.physicalAddress,
  'privacy': _$ScheduleEventPrivacyEnumMap[instance.privacy]!,
  'is_general': instance.isGeneral,
  'remind_range': _$ScheduleEventRemindRangeEnumMap[instance.remindRange],
  'remind_value': instance.remindValue,
  'created_by': instance.createdBy,
  'updated_by': instance.updatedBy,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'participants': instance.participants.map((e) => e.toJson()).toList(),
  'observers': instance.observers.map((e) => e.toJson()).toList(),
};

const _$ScheduleEventTypeEnumMap = {
  ScheduleEventType.training: 'training',
  ScheduleEventType.seminar: 'seminar',
  ScheduleEventType.interview: 'interview',
  ScheduleEventType.meetup: 'meetup',
  ScheduleEventType.meeting: 'meeting',
  ScheduleEventType.holiday: 'holiday',
  ScheduleEventType.businessTrip: 'business_trip',
};

const _$ScheduleEventScheduleTypeEnumMap = {
  ScheduleEventScheduleType.ordinary: 'ordinary',
  ScheduleEventScheduleType.multipleDays: 'multiple_days',
  ScheduleEventScheduleType.repeat: 'repeat',
};

const _$ScheduleEventRepeatTypeEnumMap = {
  ScheduleEventRepeatType.daily: 'daily',
  ScheduleEventRepeatType.weekly: 'weekly',
  ScheduleEventRepeatType.monthly: 'monthly',
};

const _$ScheduleEventPrivacyEnumMap = {
  ScheduleEventPrivacy.public: 'public',
  ScheduleEventPrivacy.private: 'private',
};

const _$ScheduleEventRemindRangeEnumMap = {
  ScheduleEventRemindRange.minute: 'minute',
  ScheduleEventRemindRange.hour: 'hour',
  ScheduleEventRemindRange.day: 'day',
};

_ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_ScheduleModel',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['remind_at']);
        final val = _ScheduleModel(
          id: $checkedConvert('id', (v) => v as String),
          eventId: $checkedConvert('event_id', (v) => v as String),
          start: $checkedConvert('start', (v) => _dateTimeFromJson(v)),
          end: $checkedConvert('end', (v) => _dateTimeFromJson(v)),
          oneDay: $checkedConvert('one_day', (v) => v as bool),
          remindAt: $checkedConvert(
            'remind_at',
            (v) => _nullableDateTimeFromJson(v),
          ),
          event: $checkedConvert(
            'event',
            (v) => ScheduleEventModel.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'eventId': 'event_id',
        'oneDay': 'one_day',
        'remindAt': 'remind_at',
      },
    );

Map<String, dynamic> _$ScheduleModelToJson(_ScheduleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'one_day': instance.oneDay,
      'remind_at': instance.remindAt?.toIso8601String(),
      'event': instance.event.toJson(),
    };
