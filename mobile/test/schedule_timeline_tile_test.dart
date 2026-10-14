import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_timeline_tile.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_participants_text.dart';

void main() {
  for (final width in [320.0, 430.0, 840.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final direction in TextDirection.values) {
        testWidgets(
          'timeline metadata fits at width $width, scale $scale, $direction',
          (tester) async {
            await tester.binding.setSurfaceSize(Size(width, 1000));
            addTearDown(() => tester.binding.setSurfaceSize(null));
            const names = 'Trần Văn Hữu, Nguyễn Ngọc Trung, Trần Đình Cường';

            for (final location in [null, 'Phòng họp tại văn phòng công ty']) {
              for (final repeat in [false, true]) {
                var tapped = false;
                final schedule = _schedule(location: location, repeat: repeat);
                await tester.pumpWidget(
                  MaterialApp(
                    theme: buildAppTheme(),
                    home: MediaQuery(
                      data: MediaQueryData(
                        size: Size(width, 1000),
                        textScaler: TextScaler.linear(scale),
                      ),
                      child: Directionality(
                        textDirection: direction,
                        child: Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ScheduleTimelineTile(
                              schedule: schedule,
                              onTap: () => tapped = true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                expect(
                  tester.takeException(),
                  isNull,
                  reason: 'location=$location, repeat=$repeat',
                );
                final namesFinder = find.descendant(
                  of: find.byType(ScheduleParticipantsText),
                  matching: find.byType(Text),
                );
                final text = tester.widget<Text>(namesFinder);
                expect(text.semanticsLabel, names);
                final label = text.data!;
                final suffix = RegExp(r'(?:^| )\+(\d+)$').firstMatch(label);
                if (suffix == null) {
                  expect(label, names);
                } else {
                  final hidden = int.parse(suffix.group(1)!);
                  final visible = schedule.event.participants.length - hidden;
                  expect(hidden, inInclusiveRange(1, 3));
                  expect(
                    label.substring(0, suffix.start),
                    schedule.event.participants
                        .take(visible)
                        .map((person) => person.name)
                        .join(', '),
                  );
                }
                final paragraph = tester.renderObject<RenderParagraph>(
                  find.descendant(
                    of: namesFinder,
                    matching: find.byType(RichText),
                  ),
                );
                final painter = TextPainter(
                  text: paragraph.text,
                  textDirection: direction,
                  textScaler: paragraph.textScaler,
                  locale: paragraph.locale,
                )..layout();
                expect(painter.width, lessThanOrEqualTo(paragraph.size.width));
                painter.dispose();
                final tile = find.byKey(
                  const ValueKey('schedule-tile-timeline-test'),
                );
                final tileBounds = tester.getRect(tile);
                final namesBounds = tester.getRect(namesFinder);
                expect(namesBounds.left, greaterThanOrEqualTo(tileBounds.left));
                expect(namesBounds.right, lessThanOrEqualTo(tileBounds.right));
                if (location != null) {
                  expect(find.text(location), findsOneWidget);
                }
                expect(
                  find.byIcon(Icons.repeat),
                  repeat ? findsOneWidget : findsNothing,
                );
                await tester.tap(tile);
                await tester.pump();
                expect(tapped, true);
              }
            }
          },
        );
      }
    }
  }
}

ScheduleModel _schedule({required String? location, required bool repeat}) {
  final start = DateTime(2026, 9, 29, 15);
  final end = DateTime(2026, 9, 29, 16);
  return ScheduleModel(
    id: 'timeline-test',
    eventId: 'event-test',
    start: start,
    end: end,
    oneDay: true,
    remindAt: null,
    event: ScheduleEventModel(
      id: 'event-test',
      title: '[ORS Corp]-Weekly Technical Div review meeting',
      type: ScheduleEventType.meeting,
      scheduleType: repeat
          ? ScheduleEventScheduleType.repeat
          : ScheduleEventScheduleType.ordinary,
      startDate: start,
      endDate: end,
      repeatType: repeat ? ScheduleEventRepeatType.weekly : null,
      repeatPattern: null,
      startTime: '15:00',
      endTime: '16:00',
      note: null,
      physicalAddress: location,
      privacy: ScheduleEventPrivacy.public,
      isGeneral: false,
      remindRange: null,
      remindValue: null,
      createdBy: 'user-1',
      updatedBy: null,
      createdAt: start,
      updatedAt: start,
      participants: const [
        ScheduleUserRef(id: '1', name: 'Trần Văn Hữu'),
        ScheduleUserRef(id: '2', name: 'Nguyễn Ngọc Trung'),
        ScheduleUserRef(id: '3', name: 'Trần Đình Cường'),
      ],
      observers: const [],
    ),
  );
}
