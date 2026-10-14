import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/state/create_trip_request_controller.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_user_tree.dart';

class CreateBusinessTripRequestPage extends ConsumerStatefulWidget {
  const CreateBusinessTripRequestPage({this.requestId, super.key});

  final String? requestId;

  static const routePath = '/app/requests/create-trip';

  @override
  ConsumerState<CreateBusinessTripRequestPage> createState() =>
      _CreateBusinessTripRequestPageState();
}

class _CreateBusinessTripRequestPageState
    extends ConsumerState<CreateBusinessTripRequestPage> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.requestId != null) {
      Future.microtask(() async {
        if (!mounted) return;
        await ref
            .read(createTripRequestControllerProvider.notifier)
            .initForRequest(widget.requestId!);
        if (!mounted) return;
        final currentState = ref.read(createTripRequestControllerProvider);
        if (mounted) {
          if (currentState.reason.isNotEmpty) {
            _reasonController.text = currentState.reason;
          }
          if (currentState.address.isNotEmpty) {
            _addressController.text = currentState.address;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createTripRequestControllerProvider.select((s) => s.reason), (
      prev,
      next,
    ) {
      if (_reasonController.text != next) {
        _reasonController.text = next;
      }
    });
    ref.listen(createTripRequestControllerProvider.select((s) => s.address), (
      prev,
      next,
    ) {
      if (_addressController.text != next) {
        _addressController.text = next;
      }
    });

    final state = ref.watch(createTripRequestControllerProvider);
    final controller = ref.read(createTripRequestControllerProvider.notifier);
    final reviewers = ref.watch(
      requestListControllerProvider.select((s) => s.reviewers),
    );
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoadingExisting) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.requestId != null
                ? 'Chỉnh sửa yêu cầu công tác'
                : 'Tạo yêu cầu công tác',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          leading: IconButton(
            key: const ValueKey('trip_form_back_button'),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final selectedReviewer = reviewers
        .where((r) => r.id == state.reviewerId)
        .firstOrNull;

    String fmtDateTime(DateTime? dt) {
      if (dt == null) return '';
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString().padLeft(4, '0');
      final hr = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/$y $hr:$min';
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          state.isEditing
              ? 'Chỉnh sửa yêu cầu công tác'
              : 'Tạo yêu cầu công tác',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('trip_form_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          state.isSubmitting
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : IconButton(
                  key: const ValueKey('trip_form_submit_button'),
                  tooltip: state.isEditing ? 'Gửi lại yêu cầu' : 'Gửi yêu cầu',
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF1677FF),
                    size: 24,
                  ),
                  onPressed: () async {
                    final success = await controller.submit();
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.isEditing
                                ? 'Đã gửi lại yêu cầu thành công!'
                                : 'Tạo yêu cầu công tác thành công!',
                          ),
                          backgroundColor: const Color(0xFF52C41A),
                        ),
                      );
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop(true);
                      }
                    } else if (context.mounted) {
                      final error =
                          ref
                              .read(createTripRequestControllerProvider)
                              .errorMessage ??
                          'Không thể gửi yêu cầu.';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error),
                          backgroundColor: const Color(0xFFFF4D4F),
                        ),
                      );
                    }
                  },
                ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFA39E)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFFF4D4F),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFFF4D4F),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Field 1: Người duyệt
              _FieldLabel(label: 'Người duyệt', isRequired: true),
              const SizedBox(height: 8),
              _SelectableInputField(
                key: const ValueKey('trip_form_reviewer_field'),
                icon: Icons.person_outline,
                value: selectedReviewer?.name,
                placeholder: 'Chọn người duyệt',
                onTap: () => _pickReviewer(context, reviewers, controller),
              ),
              const SizedBox(height: 18),

              // Two columns: Thời điểm bắt đầu & Thời điểm kết thúc
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(
                          label: 'Thời điểm bắt đầu',
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        _SelectableInputField(
                          key: const ValueKey('trip_form_start_time_field'),
                          icon: Icons.calendar_today_outlined,
                          value: state.startDateTime != null
                              ? fmtDateTime(state.startDateTime)
                              : null,
                          placeholder: 'Chọn ngày giờ',
                          onTap: () async {
                            final dt = await _pickDateTime(
                              context,
                              initialDate: state.startDateTime,
                            );
                            if (dt != null) {
                              controller.setStartDateTime(dt);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel(
                          label: 'Thời điểm kết thúc',
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        _SelectableInputField(
                          key: const ValueKey('trip_form_end_time_field'),
                          icon: Icons.calendar_today_outlined,
                          value: state.endDateTime != null
                              ? fmtDateTime(state.endDateTime)
                              : null,
                          placeholder: 'Chọn ngày giờ',
                          onTap: () async {
                            final dt = await _pickDateTime(
                              context,
                              initialDate:
                                  state.endDateTime ??
                                  state.startDateTime?.add(
                                    const Duration(hours: 4),
                                  ),
                            );
                            if (dt != null) {
                              controller.setEndDateTime(dt);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Field 3: Lý do
              _FieldLabel(label: 'Lý do', isRequired: true),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            key: const ValueKey('trip_form_reason_input'),
                            controller: _reasonController,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: const InputDecoration(
                              hintText: 'Thêm lý do yêu cầu',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              counterText: '',
                            ),
                            onChanged: controller.setReason,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '${state.reason.length}/500',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Field 4: Địa điểm công tác
              _FieldLabel(label: 'Địa điểm công tác', isRequired: true),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        key: const ValueKey('trip_form_address_input'),
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Thêm địa điểm công tác',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                          isDense: true,
                        ),
                        onChanged: controller.setAddress,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReviewer(
    BuildContext context,
    List<UserTreeSelectionUser> reviewers,
    CreateTripRequestController controller,
  ) async {
    final auth = ref.read(authControllerProvider);
    final groups = auth.user == null
        ? const <TreeSelectGroup>[]
        : buildScheduleUserTree(users: reviewers, currentUser: auth.user!);
    final currentSelection =
        ref.read(createTripRequestControllerProvider).reviewerId != null
        ? {ref.read(createTripRequestControllerProvider).reviewerId!}
        : <String>{};

    final result = await TreeSelect.showSheet(
      context: context,
      title: 'Chọn người duyệt',
      searchHintText: 'Tìm kiếm người duyệt...',
      groups: groups,
      initialSelection: currentSelection,
      multiple: false,
    );

    if (result != null && mounted) {
      controller.setReviewer(result.firstOrNull);
    }
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? now),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          if (isRequired)
            const TextSpan(
              text: '* ',
              style: TextStyle(
                color: Color(0xFFFF4D4F),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          TextSpan(
            text: label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SelectableInputField extends StatelessWidget {
  const _SelectableInputField({
    required this.icon,
    this.value,
    required this.placeholder,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasValue = value != null && value!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasValue ? value! : placeholder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: hasValue
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
