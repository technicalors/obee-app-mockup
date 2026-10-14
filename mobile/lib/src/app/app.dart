import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/app/router.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/features/auth/ui/auth_session_listener.dart';

class ObeeMobileApp extends ConsumerWidget {
  const ObeeMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = resolveColorScheme(
          settings: themeSettings,
          brightness: Brightness.light,
          systemLightScheme: lightDynamic,
          systemDarkScheme: darkDynamic,
        );
        final darkScheme = resolveColorScheme(
          settings: themeSettings,
          brightness: Brightness.dark,
          systemLightScheme: lightDynamic,
          systemDarkScheme: darkDynamic,
        );

        return MaterialApp.router(
          title: 'Obee',
          theme: buildTheme(lightScheme),
          darkTheme: buildTheme(darkScheme),
          themeMode: themeSettings.themeMode,
          routerConfig: router,
          builder: (context, child) => AuthSessionListener(child: child!),
          debugShowCheckedModeBanner: false,
          locale: const Locale('vi'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('vi')],
        );
      },
    );
  }
}
