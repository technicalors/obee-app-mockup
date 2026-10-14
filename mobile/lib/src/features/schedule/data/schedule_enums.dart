import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Visibility is only used in request filters and labels, so it stays as a
/// plain enum with explicit wire values.
enum ScheduleVisibilityFilter { all, participated, observed, created }

extension ScheduleVisibilityFilterX on ScheduleVisibilityFilter {
  String get wireValue => switch (this) {
    ScheduleVisibilityFilter.all => 'all',
    ScheduleVisibilityFilter.participated => 'participated',
    ScheduleVisibilityFilter.observed => 'observed',
    ScheduleVisibilityFilter.created => 'created',
  };

  String get label => switch (this) {
    ScheduleVisibilityFilter.all => 'Tất cả',
    ScheduleVisibilityFilter.participated => 'Đã tham gia',
    ScheduleVisibilityFilter.observed => 'Đang theo dõi',
    ScheduleVisibilityFilter.created => 'Đã tạo',
  };
}

/// Calendar layouts offered on the schedule tab. Only drives client-side
/// rendering and the date range requested from the API.
enum ScheduleViewMode { week, month, year }

extension ScheduleViewModeX on ScheduleViewMode {
  String get label => switch (this) {
    ScheduleViewMode.week => 'Tuần',
    ScheduleViewMode.month => 'Tháng',
    ScheduleViewMode.year => 'Năm',
  };

  IconData get icon => switch (this) {
    ScheduleViewMode.week => Icons.view_week_outlined,
    ScheduleViewMode.month => Icons.calendar_view_month_outlined,
    ScheduleViewMode.year => Icons.grid_view_outlined,
  };
}

@JsonEnum(alwaysCreate: true)
enum ScheduleEventType {
  @JsonValue('training')
  training,
  @JsonValue('seminar')
  seminar,
  @JsonValue('interview')
  interview,
  @JsonValue('meetup')
  meetup,
  @JsonValue('meeting')
  meeting,
  @JsonValue('holiday')
  holiday,
  @JsonValue('business_trip')
  businessTrip,
}

extension ScheduleEventTypeX on ScheduleEventType {
  String get label => switch (this) {
    ScheduleEventType.training => 'Đào tạo',
    ScheduleEventType.seminar => 'Hội thảo',
    ScheduleEventType.interview => 'Phỏng vấn',
    ScheduleEventType.meetup => 'Gặp gỡ',
    ScheduleEventType.meeting => 'Cuộc họp',
    ScheduleEventType.holiday => 'Ngày lễ',
    ScheduleEventType.businessTrip => 'Công tác',
  };

  Color get color => switch (this) {
    ScheduleEventType.training => const Color(0xFF1E6BEB),
    ScheduleEventType.seminar => const Color(0xFF7C3AED),
    ScheduleEventType.interview => const Color(0xFFE11D48),
    ScheduleEventType.meetup => const Color(0xFFF59E0B),
    ScheduleEventType.meeting => const Color(0xFFF43F5E),
    ScheduleEventType.holiday => const Color(0xFF10B981),
    ScheduleEventType.businessTrip => const Color(0xFFF59E0B),
  };

  Color get backgroundColor => switch (this) {
    ScheduleEventType.training => const Color(0xFFE0F2FE),
    ScheduleEventType.seminar => const Color(0xFFEDE9FE),
    ScheduleEventType.interview => const Color(0xFFFFE4E6),
    ScheduleEventType.meetup => const Color(0xFFFEF3C7),
    ScheduleEventType.meeting => const Color(0xFFFFE4E6),
    ScheduleEventType.holiday => const Color(0xFFD1FAE5),
    ScheduleEventType.businessTrip => const Color(0xFFFFEDD5),
  };

  Color get foregroundColor => switch (this) {
    ScheduleEventType.training => const Color(0xFF075985),
    ScheduleEventType.seminar => const Color(0xFF581C87),
    ScheduleEventType.interview => const Color(0xFF881337),
    ScheduleEventType.meetup => const Color(0xFF78350F),
    ScheduleEventType.meeting => const Color(0xFF9F1239),
    ScheduleEventType.holiday => const Color(0xFF064E3B),
    ScheduleEventType.businessTrip => const Color(0xFF7C2D12),
  };

  Color get cardBackgroundColor => switch (this) {
    ScheduleEventType.training => const Color(0xFFF0F7FF),
    ScheduleEventType.seminar => const Color(0xFFFAF5FF),
    ScheduleEventType.interview => const Color(0xFFFFF1F2),
    ScheduleEventType.meetup => const Color(0xFFFFFBEB),
    ScheduleEventType.meeting => const Color(0xFFFFF1F2),
    ScheduleEventType.holiday => const Color(0xFFF0FDF4),
    ScheduleEventType.businessTrip => const Color(0xFFFFF7ED),
  };

  Color harmonizedColor(ColorScheme colorScheme) =>
      color.harmonizeWith(colorScheme.primary);

  Color harmonizedCardBackgroundColor(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return colorScheme.surfaceContainerLow;
    }
    return cardBackgroundColor;
  }

  Color backgroundColorFor(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return switch (this) {
        ScheduleEventType.training => const Color(0xFF0F2A4A),
        ScheduleEventType.seminar => const Color(0xFF2A184A),
        ScheduleEventType.interview => const Color(0xFF42121E),
        ScheduleEventType.meetup => const Color(0xFF3D2705),
        ScheduleEventType.meeting => const Color(0xFF451020),
        ScheduleEventType.holiday => const Color(0xFF0B3322),
        ScheduleEventType.businessTrip => const Color(0xFF3B1E0A),
      };
    }
    return backgroundColor;
  }

  Color foregroundColorFor(ColorScheme colorScheme) {
    if (colorScheme.brightness == Brightness.dark) {
      return switch (this) {
        ScheduleEventType.training => const Color(0xFFBAE6FD),
        ScheduleEventType.seminar => const Color(0xFFDDD6FE),
        ScheduleEventType.interview => const Color(0xFFFECDD3),
        ScheduleEventType.meetup => const Color(0xFFFDE68A),
        ScheduleEventType.meeting => const Color(0xFFFDA4AF),
        ScheduleEventType.holiday => const Color(0xFFA7F3D0),
        ScheduleEventType.businessTrip => const Color(0xFFFED7AA),
      };
    }
    return foregroundColor;
  }

  IconData get icon => switch (this) {
    ScheduleEventType.training => Icons.school_outlined,
    ScheduleEventType.seminar => Icons.campaign_outlined,
    ScheduleEventType.interview => Icons.badge_outlined,
    ScheduleEventType.meetup => Icons.groups_2_outlined,
    ScheduleEventType.meeting => Icons.work_outline,
    ScheduleEventType.holiday => Icons.beach_access_outlined,
    ScheduleEventType.businessTrip => Icons.flight_takeoff_outlined,
  };
}

class ScheduleColors {
  const ScheduleColors({
    required this.training,
    required this.seminar,
    required this.interview,
    required this.meetup,
    required this.meeting,
    required this.holiday,
    required this.businessTrip,
  });

  final Color training;
  final Color seminar;
  final Color interview;
  final Color meetup;
  final Color meeting;
  final Color holiday;
  final Color businessTrip;

  factory ScheduleColors.fromColorScheme(ColorScheme colorScheme) {
    return ScheduleColors(
      training: ScheduleEventType.training.harmonizedColor(colorScheme),
      seminar: ScheduleEventType.seminar.harmonizedColor(colorScheme),
      interview: ScheduleEventType.interview.harmonizedColor(colorScheme),
      meetup: ScheduleEventType.meetup.harmonizedColor(colorScheme),
      meeting: ScheduleEventType.meeting.harmonizedColor(colorScheme),
      holiday: ScheduleEventType.holiday.harmonizedColor(colorScheme),
      businessTrip: ScheduleEventType.businessTrip.harmonizedColor(colorScheme),
    );
  }
}

@JsonEnum(alwaysCreate: true)
enum ScheduleEventScheduleType {
  @JsonValue('ordinary')
  ordinary,
  @JsonValue('multiple_days')
  multipleDays,
  @JsonValue('repeat')
  repeat,
}

extension ScheduleEventScheduleTypeX on ScheduleEventScheduleType {
  String get label => switch (this) {
    ScheduleEventScheduleType.ordinary => 'Thông thường',
    ScheduleEventScheduleType.multipleDays => 'Nhiều ngày',
    ScheduleEventScheduleType.repeat => 'Lặp lại',
  };
}

@JsonEnum(alwaysCreate: true)
enum ScheduleEventRepeatType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}

extension ScheduleEventRepeatTypeX on ScheduleEventRepeatType {
  String get label => switch (this) {
    ScheduleEventRepeatType.daily => 'Hàng ngày',
    ScheduleEventRepeatType.weekly => 'Hàng tuần',
    ScheduleEventRepeatType.monthly => 'Hàng tháng',
  };
}

@JsonEnum(alwaysCreate: true)
enum ScheduleEventPrivacy {
  @JsonValue('public')
  public,
  @JsonValue('private')
  private,
}

extension ScheduleEventPrivacyX on ScheduleEventPrivacy {
  String get label => switch (this) {
    ScheduleEventPrivacy.public => 'Công khai',
    ScheduleEventPrivacy.private => 'Riêng tư',
  };
}

@JsonEnum(alwaysCreate: true)
enum ScheduleEventRemindRange {
  @JsonValue('minute')
  minute,
  @JsonValue('hour')
  hour,
  @JsonValue('day')
  day,
}

extension ScheduleEventRemindRangeX on ScheduleEventRemindRange {
  String get label => switch (this) {
    ScheduleEventRemindRange.minute => 'phút',
    ScheduleEventRemindRange.hour => 'giờ',
    ScheduleEventRemindRange.day => 'ngày',
  };
}
