import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/standalone_page_header.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/profile/data/update_user_input.dart';
import 'package:obee_mobile/src/features/profile/logic/profile_formatters.dart';
import 'package:obee_mobile/src/features/profile/state/profile_controller.dart';
import 'package:obee_mobile/src/features/profile/ui/profile_avatar.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _birthdayController;

  String? _gender;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      throw StateError('Edit profile route requires an authenticated user.');
    }

    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(
      text: user.profile?.phoneNumber ?? '',
    );
    _addressController = TextEditingController(
      text: user.profile?.address ?? '',
    );
    _birthdayController = TextEditingController(text: '');
    _gender = user.profile?.sex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(authControllerProvider).user;
    final locale = Localizations.localeOf(context).toLanguageTag();
    _birthdayController.text = user?.profile?.birthday == null
        ? ''
        : formatProfileBirthday(user!.profile!.birthday!, locale)!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: StandalonePageHeader(
        title: 'Chỉnh sửa hồ sơ',
        actions: [
          TextButton(
            key: const ValueKey('edit_profile_header_save'),
            onPressed: profileState.isLoading ? null : _submit,
            child: profileState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Lưu',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 16.0;

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      viewInsets.bottom + 24,
                    ),
                    children: [
                      Center(
                        child: ProfileAvatar(
                          user: user,
                          size: 104,
                          showEditBadge: true,
                          onTap: () => _showAvatarEditDialog(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (user.profile == null)
                        const Text(
                          'Bạn có thể sửa tên. Thông tin cá nhân sẽ mở sau khi hồ sơ nhân viên được tạo.',
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            key: const ValueKey('edit_profile_name'),
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Họ và tên',
                              errorText: profileState.fieldErrors['name']?.join(
                                '\n',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            key: const ValueKey('edit_profile_phone'),
                            enabled: user.profile != null,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại',
                              errorText: profileState
                                  .fieldErrors['profile.phone_number']
                                  ?.join('\n'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            key: const ValueKey('edit_profile_address'),
                            enabled: user.profile != null,
                            controller: _addressController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ',
                              errorText: profileState
                                  .fieldErrors['profile.address']
                                  ?.join('\n'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            key: const ValueKey('edit_profile_gender'),
                            initialValue: _gender,
                            decoration: InputDecoration(
                              labelText: 'Giới tính',
                              errorText: profileState.fieldErrors['profile.sex']
                                  ?.join('\n'),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'male',
                                child: const Text('Nam'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: const Text('Nữ'),
                              ),
                            ],
                            onChanged:
                                profileState.isLoading || user.profile == null
                                ? null
                                : (value) {
                                    setState(() {
                                      _gender = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            key: const ValueKey('edit_profile_birthday'),
                            controller: _birthdayController,
                            readOnly: true,
                            onTap:
                                profileState.isLoading || user.profile == null
                                ? null
                                : () => _selectBirthday(context),
                            decoration: InputDecoration(
                              labelText: 'Ngày sinh',
                              errorText: profileState
                                  .fieldErrors['profile.birthday']
                                  ?.join('\n'),
                              hintText: 'DD/MM/YYYY',
                              suffixIcon: const Icon(
                                Icons.calendar_month_outlined,
                              ),
                            ),
                          ),
                          if (profileState.errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _translateProfileMessage(
                                profileState.errorMessage!,
                              ),
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 36),
                          OutlinedButton(
                            key: const ValueKey('edit_profile_cancel'),
                            onPressed: profileState.isLoading
                                ? null
                                : () {
                                    ref
                                        .read(
                                          profileControllerProvider.notifier,
                                        )
                                        .clearFeedback();
                                    context.pop();
                                  },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: const Text('Hủy bỏ'),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            key: const ValueKey('edit_profile_save'),
                            onPressed: profileState.isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            child: profileState.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Lưu thông tin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final isSuccess = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          UpdateUserInput(
            name: _nameController.text.trim(),
            profile: ref.read(authControllerProvider).user!.profile == null
                ? null
                : EditableUserProfile(
                    phoneNumber: _normalizeNullable(_phoneController.text),
                    address: _normalizeNullable(_addressController.text),
                    sex: _gender,
                    birthday: _normalizeBirthday(),
                  ),
          ),
        );

    if (!mounted || !isSuccess) {
      return;
    }

    context.pop(true);
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final locale = Localizations.localeOf(context);
    final initialDate = _birthdayController.text.isEmpty
        ? DateTime.now()
        : parseDisplayDateValue(_birthdayController.text);
    final pickedDate = await showDatePicker(
      context: context,
      locale: locale,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    _birthdayController.text = formatDisplayDateValue(
      pickedDate,
      locale.toLanguageTag(),
    );
  }

  String? _normalizeNullable(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  String? _normalizeBirthday() {
    final value = _normalizeNullable(_birthdayController.text);
    if (value == null) {
      return null;
    }

    return formatDateOnly(parseDisplayDateValue(value));
  }

  Future<void> _showAvatarEditDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
          title: const Text('Đổi ảnh đại diện'),
          content: const Text(
            'Tính năng cập nhật ảnh đại diện sẽ được bổ sung trong thời gian tới.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        );
      },
    );
  }

  String _translateProfileMessage(String message) {
    return switch (message) {
      'profileUpdateError' => 'Không thể cập nhật thông tin.',
      _ => message,
    };
  }
}
