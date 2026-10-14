import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_detail_content.dart';

void main() {
  testWidgets(
    'renders top block with event type tag, title, note, company tag before status, and ongoing status',
    (tester) async {
      final start = DateTime(2026, 6, 8, 9, 0);
      final end = DateTime(2026, 6, 8, 11, 0);
      final duringTime = DateTime(2026, 6, 8, 10, 0);

      final schedule = _createSchedule(
        start: start,
        end: end,
        type: ScheduleEventType.meeting,
        title: 'Họp giao ban đầu tuần',
        note: 'Đánh giá tiến độ dự án quý 2',
        isGeneral: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScheduleDetailContent(
                schedule: schedule,
                currentTime: duringTime,
              ),
            ),
          ),
        ),
      );

      // Event type tag and title on the same line
      expect(find.text('Cuộc họp'), findsOneWidget);
      expect(find.textContaining('Họp giao ban đầu tuần'), findsOneWidget);

      // Description / note directly below
      expect(find.text('Đánh giá tiến độ dự án quý 2'), findsOneWidget);

      // Lịch công ty tag comes right before the status badge
      expect(find.text('Lịch công ty'), findsOneWidget);
      expect(find.text('Đang diễn ra'), findsOneWidget);
    },
  );

  testWidgets('renders completed status badge when event has passed', (
    tester,
  ) async {
    final start = DateTime(2026, 6, 8, 9, 0);
    final end = DateTime(2026, 6, 8, 11, 0);
    final afterTime = DateTime(2026, 6, 8, 12, 0);

    final schedule = _createSchedule(
      start: start,
      end: end,
      type: ScheduleEventType.training,
      title: 'Đào tạo Flutter',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ScheduleDetailContent(
              schedule: schedule,
              currentTime: afterTime,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Đã diễn ra'), findsOneWidget);
  });

  testWidgets('renders upcoming status badge when event is in the future', (
    tester,
  ) async {
    final start = DateTime(2026, 6, 8, 14, 0);
    final end = DateTime(2026, 6, 8, 16, 0);
    final beforeTime = DateTime(2026, 6, 8, 10, 0);

    final schedule = _createSchedule(
      start: start,
      end: end,
      type: ScheduleEventType.interview,
      title: 'Phỏng vấn ứng viên',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ScheduleDetailContent(
              schedule: schedule,
              currentTime: beforeTime,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sắp diễn ra'), findsOneWidget);
  });

  testWidgets(
    'single day schedule renders Thời gian label, weekday date on top and time range on bottom',
    (tester) async {
      final start = DateTime(2026, 6, 8, 8, 30);
      final end = DateTime(2026, 6, 8, 17, 30);

      final schedule = _createSchedule(start: start, end: end, oneDay: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScheduleDetailContent(schedule: schedule),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.text('Thời gian'), findsOneWidget);
      expect(find.text('Thứ Hai, 08/06/2026'), findsOneWidget);
      expect(find.text('08:30 - 17:30'), findsOneWidget);
    },
  );

  testWidgets(
    'multi-day schedule splits into two clusters with weekday date and time',
    (tester) async {
      final start = DateTime(2026, 6, 8, 9, 0);
      final end = DateTime(2026, 6, 11, 18, 0);

      final schedule = _createSchedule(
        start: start,
        end: end,
        oneDay: false,
        scheduleType: ScheduleEventScheduleType.multipleDays,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScheduleDetailContent(schedule: schedule),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.text('Thời gian'), findsOneWidget);
      expect(find.text('Thứ Hai, 08/06/2026'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('đến'), findsOneWidget);
      expect(find.text('Thứ Năm, 11/06/2026'), findsOneWidget);
      expect(find.text('18:00'), findsOneWidget);
    },
  );

  testWidgets('repeat schedule renders separate Lặp lại cluster', (
    tester,
  ) async {
    final start = DateTime(2026, 6, 10, 8, 0);
    final end = DateTime(2026, 6, 30, 9, 0);

    final schedule = _createSchedule(
      start: start,
      end: end,
      scheduleType: ScheduleEventScheduleType.repeat,
      repeatType: ScheduleEventRepeatType.weekly,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ScheduleDetailContent(schedule: schedule),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.text('Lặp lại'), findsOneWidget);
    expect(find.text('Hàng tuần · 10/06/2026 - 30/06/2026'), findsOneWidget);
  });

  testWidgets('renders location row with Địa điểm label', (tester) async {
    final schedule = _createSchedule(
      physicalAddress: 'Phòng họp 302, Tầng 3, Toà nhà Obee',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ScheduleDetailContent(schedule: schedule),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    expect(find.text('Địa điểm'), findsOneWidget);
    expect(find.text('Phòng họp 302, Tầng 3, Toà nhà Obee'), findsOneWidget);
  });

  testWidgets(
    'user list divides into Tham gia and Chia sẻ sections with expand/collapse',
    (tester) async {
      final participants = [
        const ScheduleUserRef(id: '1', name: 'Nguyễn Văn A'),
        const ScheduleUserRef(id: '2', name: 'Trần Thị B'),
        const ScheduleUserRef(id: '3', name: 'Lê Văn C'),
        const ScheduleUserRef(id: '4', name: 'Phạm Thị D'),
        const ScheduleUserRef(id: '5', name: 'Hoàng Văn E'),
      ];

      final observers = [
        const ScheduleUserRef(id: '10', name: 'Đặng Văn Observer'),
      ];

      final schedule = _createSchedule(
        participants: participants,
        observers: observers,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScheduleDetailContent(schedule: schedule),
            ),
          ),
        ),
      );

      // Section 1: Tham gia
      expect(find.byIcon(Icons.group_outlined), findsOneWidget);
      expect(find.text('Tham gia (5)'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Trần Thị B'), findsOneWidget);
      expect(find.text('Lê Văn C'), findsOneWidget);
      expect(find.text('Phạm Thị D'), findsOneWidget);
      expect(find.text('Hoàng Văn E'), findsNothing);

      // Section 2: Chia sẻ
      expect(find.byIcon(Icons.share_outlined), findsOneWidget);
      expect(find.text('Chia sẻ (1)'), findsOneWidget);
      expect(find.text('Đặng Văn Observer'), findsOneWidget);

      // Expand participants
      expect(find.text('Mở rộng (+1)'), findsOneWidget);
      await tester.tap(find.text('Mở rộng (+1)'));
      await tester.pumpAndSettle();

      expect(find.text('Hoàng Văn E'), findsOneWidget);
      expect(find.text('Thu gọn'), findsOneWidget);

      // Collapse
      await tester.tap(find.text('Thu gọn'));
      await tester.pumpAndSettle();

      expect(find.text('Hoàng Văn E'), findsNothing);
      expect(find.text('Mở rộng (+1)'), findsOneWidget);
    },
  );

  testWidgets(
    'note renders clickable links for URLs and triggers tap callback',
    (tester) async {
      String? tappedUrl;

      final schedule = _createSchedule(
        note: '''
ALGO ARTIS & ORS Corp – 2nd Meeting
Date: Monday, September 28, 2026
Preparation: 08:45 AM (Vietnam Time)
Official Meeting: 09:00–10:00 AM (Vietnam Time) / 11:00 AM–12:00 PM (JST)
Time Zone: Asia/Ho_Chi_Minh
Google Meet: https://meet.google.com/zvn-ixom-ihv''',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: ScheduleDetailContent(
                schedule: schedule,
                onUrlTap: (url) => tappedUrl = url,
              ),
            ),
          ),
        ),
      );

      final linkFinder = find.byType(LinkifiedScheduleNote);
      expect(linkFinder, findsOneWidget);

      final richTextFinder = find.descendant(
        of: linkFinder,
        matching: find.byType(RichText),
      );
      final renderParagraph = tester.renderObject<RenderParagraph>(
        richTextFinder,
      );

      // Let's find the position of the link in the paragraph
      final noteText = schedule.event.note!;
      final urlIndex = noteText.indexOf('https://meet.google.com/zvn-ixom-ihv');
      final boxes = renderParagraph.getBoxesForSelection(
        TextSelection(baseOffset: urlIndex, extentOffset: urlIndex + 10),
      );
      expect(boxes, isNotEmpty);
      final localBox = boxes.first;
      final globalOffset = renderParagraph.localToGlobal(
        localBox.toRect().center,
      );

      await tester.tapAt(globalOffset);
      await tester.pump();

      debugPrint('TAPPED MULTI-LINE URL RESULT: $tappedUrl');
      expect(tappedUrl, 'https://meet.google.com/zvn-ixom-ihv');
    },
  );
}

ScheduleModel _createSchedule({
  DateTime? start,
  DateTime? end,
  bool oneDay = true,
  ScheduleEventType type = ScheduleEventType.meeting,
  ScheduleEventScheduleType scheduleType = ScheduleEventScheduleType.ordinary,
  ScheduleEventRepeatType? repeatType,
  String title = 'Chi tiết lịch',
  String? note,
  String? physicalAddress,
  bool isGeneral = false,
  List<ScheduleUserRef>? participants,
  List<ScheduleUserRef>? observers,
}) {
  final defaultStart = start ?? DateTime(2026, 6, 8, 9, 0);
  final defaultEnd = end ?? DateTime(2026, 6, 8, 10, 0);

  return ScheduleModel(
    id: 'test-schedule-1',
    eventId: 'test-event-1',
    start: defaultStart,
    end: defaultEnd,
    oneDay: oneDay,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'test-event-1',
      title: title,
      type: type,
      scheduleType: scheduleType,
      startDate: defaultStart,
      endDate: defaultEnd,
      repeatType: repeatType,
      repeatPattern: null,
      startTime: '09:00',
      endTime: '10:00',
      note: note,
      physicalAddress: physicalAddress,
      privacy: ScheduleEventPrivacy.public,
      isGeneral: isGeneral,
      remindRange: null,
      remindValue: null,
      createdBy: 'user-admin',
      updatedBy: null,
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
      participants: participants ?? const [],
      observers: observers ?? const [],
    ),
  );
}
