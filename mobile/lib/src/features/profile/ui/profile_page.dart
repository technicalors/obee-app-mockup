import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/app/theme.dart';
import 'package:obee_mobile/src/core/widgets/app_top_bar.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/profile/logic/profile_formatters.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

const _appContactEmail = 'contact@ors.vn';
const _appWebsiteUrl = 'https://ors.vn';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AppTopBar(title: 'Hồ sơ'),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(authControllerProvider.notifier).refreshCurrentUser(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      ProfileAvatar(user: user),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                final didUpdate = await context.push<bool>(
                                  '/app/profile/edit',
                                );

                                if (!context.mounted || didUpdate != true) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cập nhật thông tin thành công.',
                                    ),
                                  ),
                                );
                              },
                        style: FilledButton.styleFrom(
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Chỉnh sửa hồ sơ'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _ProfileSectionCard(
                  children: [
                    const _SectionHeader(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                    ),
                    _InfoRow(
                      icon: Icons.alternate_email,
                      label: 'Tên đăng nhập',
                      value: user.username,
                    ),
                    _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      value: user.email ?? 'Chưa có',
                    ),
                    _InfoRow(
                      icon: Icons.wc_outlined,
                      label: 'Giới tính',
                      value:
                          displayNullableProfileValue(
                            formatProfileGender(
                              user.profile?.sex,
                              male: 'Nam',
                              female: 'Nữ',
                              other: 'Khác',
                            ),
                          ) ??
                          'Chưa có',
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Số điện thoại',
                      value:
                          displayNullableProfileValue(
                            user.profile?.phoneNumber,
                          ) ??
                          'Chưa có',
                    ),
                    _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Ngày sinh',
                      value:
                          displayNullableProfileValue(
                            formatProfileBirthday(
                              user.profile?.birthday,
                              locale,
                            ),
                          ) ??
                          'Chưa có',
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Địa chỉ',
                      value:
                          displayNullableProfileValue(user.profile?.address) ??
                          'Chưa có',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ProfileSectionCard(
                  children: [
                    const _SectionHeader(
                      icon: Icons.palette_outlined,
                      title: 'Giao diện',
                    ),
                    const _ThemeSettingsSection(),
                  ],
                ),
                const SizedBox(height: 16),
                _ProfileSectionCard(
                  children: [
                    const _SectionHeader(
                      icon: Icons.info_outline,
                      title: 'Thông tin ứng dụng',
                    ),
                    const _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'Liên hệ',
                      value: _appContactEmail,
                    ),
                    const _InfoRow(
                      icon: Icons.language,
                      label: 'Website',
                      value: _appWebsiteUrl,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: auth.isLoading
                      ? null
                      : () =>
                            ref.read(authControllerProvider.notifier).logout(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text(
                    'Đăng xuất',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSettingsSection extends ConsumerWidget {
  const _ThemeSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Chế độ giao diện',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text('Hệ thống'),
                icon: Icon(Icons.brightness_auto_outlined, size: 16),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text('Sáng'),
                icon: Icon(Icons.light_mode_outlined, size: 16),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text('Tối'),
                icon: Icon(Icons.dark_mode_outlined, size: 16),
              ),
            ],
            selected: {themeSettings.themeMode},
            onSelectionChanged: (newSelection) {
              ref
                  .read(themeSettingsProvider.notifier)
                  .setThemeMode(newSelection.first);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Màu giao diện',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          RadioGroup<AppThemeSource>(
            groupValue: themeSettings.source,
            onChanged: (source) {
              if (source != null) {
                ref.read(themeSettingsProvider.notifier).setThemeSource(source);
              }
            },
            child: Column(
              children: [
                RadioListTile<AppThemeSource>(
                  key: const ValueKey('theme_source_default'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: AppThemeSource.defaultColor,
                  title: const Text('Mặc định'),
                  secondary: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: defaultSeedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                RadioListTile<AppThemeSource>(
                  key: const ValueKey('theme_source_system'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: AppThemeSource.systemDynamic,
                  title: const Text('Theo thiết bị'),
                  subtitle: const Text(
                    'Sử dụng màu Material You của thiết bị',
                    style: TextStyle(fontSize: 12),
                  ),
                  secondary: const Icon(Icons.android, size: 22),
                ),
                RadioListTile<AppThemeSource>(
                  key: const ValueKey('theme_source_custom'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: AppThemeSource.customColor,
                  title: const Text('Tùy chỉnh'),
                  secondary: const Icon(Icons.color_lens_outlined, size: 22),
                ),
              ],
            ),
          ),
          if (themeSettings.source == AppThemeSource.customColor) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (
                    var index = 0;
                    index < themeColorPresets.length;
                    index++
                  ) ...[
                    _ThemePresetDot(
                      key: ValueKey('theme_preset_$index'),
                      color: themeColorPresets[index],
                      isSelected:
                          (themeSettings.customSeedColor?.toARGB32() ==
                              themeColorPresets[index].toARGB32()) ||
                          (themeSettings.customSeedColor == null &&
                              themeColorPresets[index] == defaultSeedColor),
                      onTap: () {
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setCustomSeedColor(themeColorPresets[index]);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemePresetDot extends StatelessWidget {
  const _ThemePresetDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
