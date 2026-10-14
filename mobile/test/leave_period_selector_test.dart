import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/features/requests/state/create_leave_request_controller.dart';
import 'package:obee_mobile/src/features/requests/ui/create_leave_request_page.dart';

void main() {
  testWidgets('24 periods remain reachable on a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? selected;
    final options = [
      const LeavePeriodOption(
        key: 'all',
        label: 'Toàn ca',
        startAt: '',
        endAt: '',
      ),
      for (var index = 0; index < 24; index++)
        LeavePeriodOption(
          key: '$index',
          label: 'Khoảng ${index + 1}',
          startAt: '',
          endAt: '',
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LeavePeriodSelectorSheet(
            options: options,
            onSelect: (key) => selected = key,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('23')), 250);
    await tester.tap(find.byKey(const ValueKey('23')));
    expect(selected, '23');
    await tester.scrollUntilVisible(find.byKey(const ValueKey('custom')), 100);
    await tester.tap(find.byKey(const ValueKey('custom')));
    expect(selected, 'custom');
    expect(tester.takeException(), isNull);
  });
}
