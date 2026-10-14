import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:obee_mobile/src/features/shell/ui/app_shell.dart';

@Preview(
  name: 'Feature Placeholder Mobile',
  group: 'Shell',
  size: Size(390, 844),
)
Widget placeholderFeatureMobilePreview() {
  return const MaterialApp(
    home: Scaffold(
      body: PlaceholderFeaturePage(
        icon: AppShellIcon.schedule,
        title: 'Lịch trình',
      ),
    ),
  );
}

@Preview(
  name: 'Feature Placeholder Tablet',
  group: 'Shell',
  size: Size(1024, 768),
)
Widget placeholderFeatureTabletPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 720,
          child: PlaceholderFeaturePage(
            icon: AppShellIcon.profile,
            title: 'Hồ sơ',
          ),
        ),
      ),
    ),
  );
}
