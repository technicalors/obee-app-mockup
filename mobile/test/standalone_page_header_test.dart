import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/widgets/standalone_page_header.dart';

void main() {
  testWidgets('renders title and back button by default', (tester) async {
    var popped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: StandalonePageHeader(
            title: 'Tiêu đề trang',
            onBackPressed: () => popped = true,
          ),
          body: const SizedBox(),
        ),
      ),
    );

    expect(find.text('Tiêu đề trang'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    expect(popped, isTrue);
  });

  testWidgets('renders custom actions on the trailing side', (tester) async {
    var savePressed = false;
    var deletePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: StandalonePageHeader(
            title: 'Chỉnh sửa',
            actions: [
              HeaderActionButton(
                tooltip: 'Xóa',
                icon: Icons.delete_outline,
                onPressed: () => deletePressed = true,
              ),
              TextButton(
                onPressed: () => savePressed = true,
                child: const Text('Lưu'),
              ),
            ],
          ),
          body: const SizedBox(),
        ),
      ),
    );

    expect(find.text('Chỉnh sửa'), findsOneWidget);
    expect(find.text('Lưu'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.text('Lưu'));
    expect(savePressed, isTrue);

    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deletePressed, isTrue);
  });

  testWidgets('renders custom leading widget when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: StandalonePageHeader(
            title: 'Chi tiết',
            leading: Icon(Icons.close),
          ),
          body: SizedBox(),
        ),
      ),
    );

    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });

  testWidgets(
    'AppTopBar renders contextual title and actions without back button by default',
    (tester) async {
      var searchPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppTopBar(
              title: 'Trò chuyện',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchPressed = true,
                ),
              ],
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Trò chuyện'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);

      await tester.tap(find.byIcon(Icons.search));
      expect(searchPressed, isTrue);
    },
  );
}
