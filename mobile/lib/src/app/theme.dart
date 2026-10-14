import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';

const Color defaultSeedColor = Color(0xFF5B5BD6);

const List<Color> themeColorPresets = [
  Color(0xFF5B5BD6), // Blue Violet - default
  Color(0xFF3F67D5), // Blue
  Color(0xFF6750A4), // Purple
  Color(0xFF007C91), // Teal
  Color(0xFF476810), // Green
  Color(0xFF9A4522), // Orange
];

enum AppThemeSource { defaultColor, systemDynamic, customColor }

@immutable
class AppThemeSettings {
  const AppThemeSettings({
    required this.source,
    required this.themeMode,
    this.customSeedColor,
  });

  final AppThemeSource source;
  final ThemeMode themeMode;
  final Color? customSeedColor;

  static const defaultSettings = AppThemeSettings(
    source: AppThemeSource.defaultColor,
    themeMode: ThemeMode.system,
    customSeedColor: null,
  );

  AppThemeSettings copyWith({
    AppThemeSource? source,
    ThemeMode? themeMode,
    Color? customSeedColor,
    bool clearCustomSeedColor = false,
  }) {
    return AppThemeSettings(
      source: source ?? this.source,
      themeMode: themeMode ?? this.themeMode,
      customSeedColor: clearCustomSeedColor
          ? null
          : (customSeedColor ?? this.customSeedColor),
    );
  }

  Map<String, dynamic> toJson() => {
    'source': source.name,
    'themeMode': themeMode.name,
    'customSeedColor': customSeedColor?.toARGB32(),
  };

  factory AppThemeSettings.fromJson(Map<String, dynamic> json) {
    final sourceName = json['source'] as String?;
    final source = AppThemeSource.values.firstWhere(
      (e) => e.name == sourceName,
      orElse: () => AppThemeSource.defaultColor,
    );

    final modeName = json['themeMode'] as String?;
    final themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => ThemeMode.system,
    );

    final seedInt = json['customSeedColor'] as int?;
    final customSeedColor = seedInt != null ? Color(seedInt) : null;

    return AppThemeSettings(
      source: source,
      themeMode: themeMode,
      customSeedColor: customSeedColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppThemeSettings &&
          runtimeType == other.runtimeType &&
          source == other.source &&
          themeMode == other.themeMode &&
          customSeedColor?.toARGB32() == other.customSeedColor?.toARGB32();

  @override
  int get hashCode =>
      Object.hash(source, themeMode, customSeedColor?.toARGB32());
}

ColorScheme buildColorScheme({
  required Color seedColor,
  required Brightness brightness,
}) {
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  );
}

ColorScheme resolveColorScheme({
  required AppThemeSettings settings,
  required Brightness brightness,
  dynamic systemLightScheme,
  dynamic systemDarkScheme,
}) {
  switch (settings.source) {
    case AppThemeSource.defaultColor:
      return buildColorScheme(
        seedColor: defaultSeedColor,
        brightness: brightness,
      );

    case AppThemeSource.customColor:
      return buildColorScheme(
        seedColor: settings.customSeedColor ?? defaultSeedColor,
        brightness: brightness,
      );

    case AppThemeSource.systemDynamic:
      final dynamic rawDynamic = brightness == Brightness.light
          ? systemLightScheme
          : systemDarkScheme;

      if (rawDynamic != null) {
        if (rawDynamic is ColorScheme) {
          return rawDynamic;
        }
        try {
          return ColorScheme(
            brightness: rawDynamic.brightness as Brightness,
            primary: rawDynamic.primary as Color,
            onPrimary: rawDynamic.onPrimary as Color,
            primaryContainer: rawDynamic.primaryContainer as Color,
            onPrimaryContainer: rawDynamic.onPrimaryContainer as Color,
            secondary: rawDynamic.secondary as Color,
            onSecondary: rawDynamic.onSecondary as Color,
            secondaryContainer: rawDynamic.secondaryContainer as Color,
            onSecondaryContainer: rawDynamic.onSecondaryContainer as Color,
            tertiary: rawDynamic.tertiary as Color,
            onTertiary: rawDynamic.onTertiary as Color,
            tertiaryContainer: rawDynamic.tertiaryContainer as Color,
            onTertiaryContainer: rawDynamic.onTertiaryContainer as Color,
            error: rawDynamic.error as Color,
            onError: rawDynamic.onError as Color,
            errorContainer: rawDynamic.errorContainer as Color,
            onErrorContainer: rawDynamic.onErrorContainer as Color,
            surface: rawDynamic.surface as Color,
            onSurface: rawDynamic.onSurface as Color,
            surfaceContainerHighest:
                rawDynamic.surfaceContainerHighest as Color,
            surfaceContainerHigh: rawDynamic.surfaceContainerHigh as Color,
            surfaceContainer: rawDynamic.surfaceContainer as Color,
            surfaceContainerLow: rawDynamic.surfaceContainerLow as Color,
            surfaceContainerLowest: rawDynamic.surfaceContainerLowest as Color,
            onSurfaceVariant: rawDynamic.onSurfaceVariant as Color,
            outline: rawDynamic.outline as Color,
            outlineVariant: rawDynamic.outlineVariant as Color,
            shadow: rawDynamic.shadow as Color,
            scrim: rawDynamic.scrim as Color,
            inverseSurface: rawDynamic.inverseSurface as Color,
            onInverseSurface: rawDynamic.onInverseSurface as Color,
            inversePrimary: rawDynamic.inversePrimary as Color,
          );
        } catch (_) {}
      }

      return buildColorScheme(
        seedColor: defaultSeedColor,
        brightness: brightness,
      );
  }
}

ThemeData buildTheme(ColorScheme colorScheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      floatingLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.primary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,
      hintStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }

        return Colors.transparent;
      }),
      checkColor: WidgetStatePropertyAll(colorScheme.onPrimary),
      side: BorderSide(color: colorScheme.outline, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    cardTheme: CardThemeData(
      margin: EdgeInsets.zero,
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          letterSpacing: -0.1,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);

        return IconThemeData(
          color: selected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        );
      }),
    ),
  );
}

ThemeData buildAppTheme([ColorScheme? colorScheme]) {
  final resolvedScheme =
      colorScheme ??
      buildColorScheme(
        seedColor: defaultSeedColor,
        brightness: Brightness.light,
      );
  return buildTheme(resolvedScheme);
}

abstract interface class ThemeSettingsStorage {
  Future<AppThemeSettings?> readSettings();
  Future<void> writeSettings(AppThemeSettings settings);
}

class SecureThemeSettingsStorage implements ThemeSettingsStorage {
  const SecureThemeSettingsStorage(this._storage);

  final FlutterSecureStorage _storage;
  static const _key = 'obee_mobile_theme_settings';

  @override
  Future<AppThemeSettings?> readSettings() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppThemeSettings.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeSettings(AppThemeSettings settings) async {
    try {
      final raw = jsonEncode(settings.toJson());
      await _storage.write(key: _key, value: raw);
    } catch (_) {}
  }
}

final themeSettingsStorageProvider = Provider<ThemeSettingsStorage>((ref) {
  return SecureThemeSettingsStorage(ref.watch(secureStorageProvider));
});

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsNotifier, AppThemeSettings>(
      () => ThemeSettingsNotifier(),
    );

class ThemeSettingsNotifier extends Notifier<AppThemeSettings> {
  ThemeSettingsNotifier({this.initialSettings});

  final AppThemeSettings? initialSettings;

  @override
  AppThemeSettings build() {
    final storage = ref.watch(themeSettingsStorageProvider);
    if (initialSettings == null) {
      _loadInitial(storage);
    }
    return initialSettings ?? AppThemeSettings.defaultSettings;
  }

  Future<void> _loadInitial(ThemeSettingsStorage storage) async {
    try {
      final saved = await storage.readSettings();
      if (saved != null) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> updateSettings(AppThemeSettings settings) async {
    state = settings;
    try {
      await ref.read(themeSettingsStorageProvider).writeSettings(settings);
    } catch (_) {}
  }

  Future<void> setThemeSource(AppThemeSource source) =>
      updateSettings(state.copyWith(source: source));

  Future<void> setCustomSeedColor(Color color) => updateSettings(
    state.copyWith(source: AppThemeSource.customColor, customSeedColor: color),
  );

  Future<void> setThemeMode(ThemeMode mode) =>
      updateSettings(state.copyWith(themeMode: mode));
}
