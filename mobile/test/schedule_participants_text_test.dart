import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_participants_text.dart';

void main() {
  testWidgets(
    'measures complete names and reserves the hidden count on resize',
    (tester) async {
      const participants = [
        ScheduleUserRef(id: '1', name: 'Trần Văn Hữu'),
        ScheduleUserRef(id: '2', name: 'Nguyễn Ngọc Trung'),
        ScheduleUserRef(id: '3', name: 'Trần Đình Cường'),
      ];
      await _pump(tester, participants: participants, width: 750);
      expect(
        find.text('Trần Văn Hữu, Nguyễn Ngọc Trung, Trần Đình Cường'),
        findsOneWidget,
      );
      final paragraph = tester.renderObject<RenderParagraph>(
        find.byType(RichText),
      );
      final painter = TextPainter(
        text: TextSpan(text: 'Trần Văn Hữu +2', style: paragraph.text.style),
        textDirection: TextDirection.ltr,
        textScaler: paragraph.textScaler,
        locale: paragraph.locale,
      )..layout();
      final prefixAndCountWidth = painter.width;
      painter.dispose();

      await _pump(
        tester,
        participants: participants,
        width: prefixAndCountWidth + 1,
      );
      expect(find.text('Trần Văn Hữu +2'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pump(
        tester,
        participants: participants,
        width: prefixAndCountWidth - 1,
      );
      expect(find.text('+3'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pump(
        tester,
        participants: participants,
        width: prefixAndCountWidth + 1,
        scale: 2,
      );
      expect(find.text('+3'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pump(tester, participants: participants, width: 750);
      expect(
        find.text('Trần Văn Hữu, Nguyễn Ngọc Trung, Trần Đình Cường'),
        findsOneWidget,
      );
    },
  );

  testWidgets('counts everyone when a single full name cannot fit', (
    tester,
  ) async {
    await _pump(
      tester,
      participants: const [
        ScheduleUserRef(id: '1', name: 'Nguyễn Thị Thanh Huyền'),
      ],
      width: 40,
    );
    expect(find.text('+1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'fits multi-digit counts and shows more than three names when possible',
    (tester) async {
      final participants = [
        for (var index = 0; index < 14; index++)
          ScheduleUserRef(id: '$index', name: 'An'),
      ];
      await _pump(tester, participants: participants, width: 750);
      expect(find.text(List.filled(14, 'An').join(', ')), findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.byType(RichText),
      );
      final painter = TextPainter(
        text: TextSpan(text: 'An +13', style: paragraph.text.style),
        textDirection: TextDirection.ltr,
      )..layout();
      final width = painter.width;
      painter.dispose();
      await _pump(tester, participants: participants, width: width + 1);
      expect(find.text('An +13'), findsOneWidget);
      await _pump(tester, participants: participants, width: width - 1);
      expect(find.text('+14'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty participant list has no remaining count', (tester) async {
    await _pump(tester, participants: const [], width: 100);
    expect(tester.widget<Text>(find.byType(Text)).data, isEmpty);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required List<ScheduleUserRef> participants,
  required double width,
  double scale = 1,
}) => tester.pumpWidget(
  MaterialApp(
    theme: buildAppTheme(),
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: width,
            child: ScheduleParticipantsText(participants: participants),
          ),
        ),
      ),
    ),
  ),
);
