import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';
import 'package:obee_mobile/src/features/auth/data/auth_api.dart';
import 'package:obee_mobile/src/features/auth/data/user.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_page.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';
import 'package:obee_mobile/src/features/schedule/ui/widgets/schedule_main_timeline_tile.dart';

class _MemoryTokenStorage implements TokenStorage {
  _MemoryTokenStorage([this.token]);

  String? token;

  @override
  Future<void> clearToken() async {
    token = null;
  }

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String token) async {
    this.token = token;
  }
}

class _MemoryThemeSettingsStorage implements ThemeSettingsStorage {
  _MemoryThemeSettingsStorage();

  AppThemeSettings? savedSettings;

  @override
  Future<AppThemeSettings?> readSettings() async => savedSettings;

  @override
  Future<void> writeSettings(AppThemeSettings settings) async {
    savedSettings = settings;
  }
}

class _FakeAuthApi implements AuthApi {
  _FakeAuthApi()
    : user = const User(
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
        id: 'user-1',
        name: 'Test User',
        username: 'test',
        email: 'test@example.com',
        avatar: null,
      );

  final User user;

  @override
  Future<User> currentUser() async => user;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

void main() {
  group('Theme Resolution & ColorScheme generation', () {
    test('defaultColor always uses #5B5BD6 with tonalSpot', () {
      const settings = AppThemeSettings(
        source: AppThemeSource.defaultColor,
        themeMode: ThemeMode.system,
      );

      final light = resolveColorScheme(
        settings: settings,
        brightness: Brightness.light,
      );
      final dark = resolveColorScheme(
        settings: settings,
        brightness: Brightness.dark,
      );

      final expectedLight = ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B5BD6),
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      );
      final expectedDark = ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B5BD6),
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(light.primary, expectedLight.primary);
      expect(light.brightness, Brightness.light);
      expect(dark.primary, expectedDark.primary);
      expect(dark.brightness, Brightness.dark);
    });

    test('systemDynamic uses OS schemes when available', () {
      const settings = AppThemeSettings(
        source: AppThemeSource.systemDynamic,
        themeMode: ThemeMode.system,
      );

      final mockSystemLight = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      );
      final mockSystemDark = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      );

      final light = resolveColorScheme(
        settings: settings,
        brightness: Brightness.light,
        systemLightScheme: mockSystemLight,
        systemDarkScheme: mockSystemDark,
      );
      final dark = resolveColorScheme(
        settings: settings,
        brightness: Brightness.dark,
        systemLightScheme: mockSystemLight,
        systemDarkScheme: mockSystemDark,
      );

      expect(light, mockSystemLight);
      expect(dark, mockSystemDark);
    });

    test('systemDynamic falls back to #5B5BD6 when dynamic color is null', () {
      const settings = AppThemeSettings(
        source: AppThemeSource.systemDynamic,
        themeMode: ThemeMode.system,
      );

      final light = resolveColorScheme(
        settings: settings,
        brightness: Brightness.light,
        systemLightScheme: null,
        systemDarkScheme: null,
      );

      final expected = ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B5BD6),
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(light.primary, expected.primary);
    });

    test('customColor uses user-selected seed color', () {
      const customColor = Color(0xFF007C91);
      const settings = AppThemeSettings(
        source: AppThemeSource.customColor,
        themeMode: ThemeMode.light,
        customSeedColor: customColor,
      );

      final light = resolveColorScheme(
        settings: settings,
        brightness: Brightness.light,
      );
      final expected = ColorScheme.fromSeed(
        seedColor: customColor,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(light.primary, expected.primary);
    });

    test('customColor with null seed falls back to #5B5BD6', () {
      const settings = AppThemeSettings(
        source: AppThemeSource.customColor,
        themeMode: ThemeMode.light,
        customSeedColor: null,
      );

      final light = resolveColorScheme(
        settings: settings,
        brightness: Brightness.light,
      );
      final expected = ColorScheme.fromSeed(
        seedColor: const Color(0xFF5B5BD6),
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      expect(light.primary, expected.primary);
    });
  });

  group('AppThemeSettings serialization and persistence', () {
    test('toJson and fromJson preserves all fields', () {
      const settings = AppThemeSettings(
        source: AppThemeSource.customColor,
        themeMode: ThemeMode.dark,
        customSeedColor: Color(0xFF476810),
      );

      final json = settings.toJson();
      final roundTrip = AppThemeSettings.fromJson(json);

      expect(roundTrip, settings);
      expect(roundTrip.source, AppThemeSource.customColor);
      expect(roundTrip.themeMode, ThemeMode.dark);
      expect(
        roundTrip.customSeedColor?.toARGB32(),
        const Color(0xFF476810).toARGB32(),
      );
    });

    test('ThemeSettingsNotifier updates and persists changes', () async {
      final storage = _MemoryThemeSettingsStorage();
      final container = ProviderContainer(
        overrides: [themeSettingsStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(themeSettingsProvider.notifier);

      expect(
        container.read(themeSettingsProvider).source,
        AppThemeSource.defaultColor,
      );
      expect(container.read(themeSettingsProvider).themeMode, ThemeMode.system);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(container.read(themeSettingsProvider).themeMode, ThemeMode.dark);
      expect(storage.savedSettings?.themeMode, ThemeMode.dark);

      await notifier.setThemeSource(AppThemeSource.systemDynamic);
      expect(
        container.read(themeSettingsProvider).source,
        AppThemeSource.systemDynamic,
      );
      expect(storage.savedSettings?.source, AppThemeSource.systemDynamic);

      await notifier.setCustomSeedColor(const Color(0xFF9A4522));
      expect(
        container.read(themeSettingsProvider).source,
        AppThemeSource.customColor,
      );
      expect(
        container.read(themeSettingsProvider).customSeedColor?.toARGB32(),
        const Color(0xFF9A4522).toARGB32(),
      );
      expect(
        storage.savedSettings?.customSeedColor?.toARGB32(),
        const Color(0xFF9A4522).toARGB32(),
      );
    });
  });

  group('Schedule category colors in Light vs Dark mode', () {
    test(
      'Light mode preserves distinctive pastel backgrounds and dark text',
      () {
        final lightScheme = ColorScheme.fromSeed(
          seedColor: defaultSeedColor,
          brightness: Brightness.light,
        );

        for (final type in ScheduleEventType.values) {
          expect(type.backgroundColorFor(lightScheme), type.backgroundColor);
          expect(type.foregroundColorFor(lightScheme), type.foregroundColor);
        }
      },
    );

    test(
      'Dark mode uses dark tonal containers and soft luminous foregrounds',
      () {
        final darkScheme = ColorScheme.fromSeed(
          seedColor: defaultSeedColor,
          brightness: Brightness.dark,
        );

        for (final type in ScheduleEventType.values) {
          final darkBg = type.backgroundColorFor(darkScheme);
          final darkFg = type.foregroundColorFor(darkScheme);

          // Dark background should NOT be the light pastel background
          expect(darkBg, isNot(type.backgroundColor));
          // Dark foreground should NOT be the dark text
          expect(darkFg, isNot(type.foregroundColor));

          // Dark background should be darker than light background
          expect(
            darkBg.computeLuminance(),
            lessThan(type.backgroundColor.computeLuminance()),
          );
          // Dark foreground should be lighter than dark background
          expect(
            darkFg.computeLuminance(),
            greaterThan(darkBg.computeLuminance()),
          );
        }
      },
    );
  });

  group('ProfilePage Theme Settings UI', () {
    testWidgets(
      'renders theme mode and color source options and toggles them',
      (tester) async {
        tester.view.physicalSize = const Size(400, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final storage = _MemoryThemeSettingsStorage();
        final authApi = _FakeAuthApi();
        final tokenStorage = _MemoryTokenStorage('token-1');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              themeSettingsStorageProvider.overrideWithValue(storage),
              authApiProvider.overrideWithValue(authApi),
              tokenStorageProvider.overrideWithValue(tokenStorage),
            ],
            child: const MaterialApp(home: Scaffold(body: ProfilePage())),
          ),
        );
        await tester.pumpAndSettle();

        // Check section header
        expect(find.text('Giao diện'), findsOneWidget);
        expect(find.text('Chế độ giao diện'), findsOneWidget);
        expect(find.text('Màu giao diện'), findsOneWidget);

        // Verify theme modes exist
        expect(find.text('Hệ thống'), findsOneWidget);
        expect(find.text('Sáng'), findsOneWidget);
        expect(find.text('Tối'), findsOneWidget);

        // Verify sources exist
        expect(find.text('Mặc định'), findsOneWidget);
        expect(find.text('Theo thiết bị'), findsOneWidget);
        expect(find.text('Tùy chỉnh'), findsOneWidget);

        // Tap 'Tối'
        await tester.tap(find.text('Tối'));
        await tester.pumpAndSettle();
        expect(storage.savedSettings?.themeMode, ThemeMode.dark);

        // Tap 'Theo thiết bị'
        await tester.tap(find.byKey(const ValueKey('theme_source_system')));
        await tester.pumpAndSettle();
        expect(storage.savedSettings?.source, AppThemeSource.systemDynamic);

        // Tap 'Tùy chỉnh'
        await tester.tap(find.byKey(const ValueKey('theme_source_custom')));
        await tester.pumpAndSettle();
        expect(storage.savedSettings?.source, AppThemeSource.customColor);

        // Verify preset color dots appear
        expect(find.byKey(const ValueKey('theme_preset_1')), findsOneWidget);

        // Tap a preset (e.g. Teal or Blue)
        await tester.tap(find.byKey(const ValueKey('theme_preset_1')));
        await tester.pumpAndSettle();

        expect(
          storage.savedSettings?.customSeedColor?.toARGB32(),
          themeColorPresets[1].toARGB32(),
        );
      },
    );
  });

  group('ScheduleTimelineTile row styling', () {
    testWidgets(
      'type badge has fixed width 80, users align right, and left stripe is removed',
      (tester) async {
        final start = DateTime(2026, 10, 3, 8, 30);
        final end = DateTime(2026, 10, 3, 9, 15);
        final schedule = ScheduleModel(
          id: 'sched-1',
          eventId: 'ev-1',
          start: start,
          end: end,
          oneDay: true,
          remindAt: null,
          event: ScheduleEventModel(
            id: 'ev-1',
            title: 'Rà soát tiến độ dự án',
            type: ScheduleEventType.meeting,
            scheduleType: ScheduleEventScheduleType.ordinary,
            startDate: start,
            endDate: end,
            repeatType: null,
            repeatPattern: null,
            startTime: '08:30',
            endTime: '09:15',
            note: null,
            physicalAddress: 'Văn phòng Obee',
            privacy: ScheduleEventPrivacy.public,
            isGeneral: false,
            remindRange: null,
            remindValue: null,
            createdBy: 'creator-1',
            updatedBy: null,
            createdAt: start,
            updatedAt: start,
            participants: const [ScheduleUserRef(id: 'u-1', name: 'admin')],
            observers: const [],
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: defaultSeedColor,
                brightness: Brightness.dark,
              ),
            ),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 120,
                  child: ScheduleTimelineTile(
                    schedule: schedule,
                    isFirst: true,
                    isLast: false,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify the type badge has fixed width of 80
        final badgeContainerFinder = find
            .ancestor(
              of: find.text('Cuộc họp'),
              matching: find.byType(Container),
            )
            .first;
        final badgeContainer = tester.widget<Container>(badgeContainerFinder);
        expect(badgeContainer.constraints?.minWidth, 80.0);
        expect(badgeContainer.constraints?.maxWidth, 80.0);

        // Verify the colored 4px stripe is removed
        final fourPxStripeFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container && widget.constraints?.minWidth == 4.0,
        );
        expect(fourPxStripeFinder, findsNothing);

        // Verify user text is right aligned
        final userTextFinder = find.text('admin');
        expect(userTextFinder, findsOneWidget);
        final userText = tester.widget<Text>(userTextFinder);
        expect(userText.textAlign, TextAlign.end);
      },
    );
  });
}
