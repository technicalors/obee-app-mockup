import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:obee_mobile/src/app/app.dart';
import 'package:obee_mobile/src/app/env.dart';
import 'package:obee_mobile/src/app/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializeDateFormatting('vi');
  AppConfig.current;

  const storage = FlutterSecureStorage();
  final themeStorage = SecureThemeSettingsStorage(storage);
  AppThemeSettings? initialThemeSettings;
  try {
    initialThemeSettings = await themeStorage.readSettings();
  } catch (_) {
    initialThemeSettings = null;
  }

  runApp(
    ProviderScope(
      overrides: [
        themeSettingsStorageProvider.overrideWithValue(themeStorage),
        if (initialThemeSettings != null)
          themeSettingsProvider.overrideWith(
            () => ThemeSettingsNotifier(initialSettings: initialThemeSettings),
          ),
      ],
      child: const ObeeMobileApp(),
    ),
  );
}
