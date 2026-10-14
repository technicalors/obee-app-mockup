import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';
import 'package:obee_mobile/src/features/requests/state/create_leave_request_controller.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';
import 'package:obee_mobile/src/features/requests/ui/widgets/leave_balance_card.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_user_tree.dart';

class CreateLeaveRequestPage extends ConsumerStatefulWidget {
  const CreateLeaveRequestPage({this.requestId, super.key});

  final String? requestId;

  static const routePath = '/app/requests/create-leave';

  @override
  ConsumerState<CreateLeaveRequestPage> createState() =>
      _CreateLeaveRequestPageState();
}

class _CreateLeaveRequestPageState
    extends ConsumerState<CreateLeaveRequestPage> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.requestId != null) {
      Future.microtask(() async {
        if (!mounted) return;
        await ref
            .read(createLeaveRequestControllerProvider.notifier)
            .initForRequest(widget.requestId!);
        if (!mounted) return;
        final currentReason = ref
            .read(createLeaveRequestControllerProvider)
            .reason;
        if (currentReason.isNotEmpty) {
          _reasonController.text = currentReason;
        }
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createLeaveRequestControllerProvider.select((s) => s.reason), (
      prev,
      next,
    ) {
      if (_reasonController.text != next) {
        _reasonController.text = next;
      }
    });

    final state = ref.watch(createLeaveRequestControllerProvider);
    final controller = ref.read(createLeaveRequestControllerProvider.notifier);
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
                ? 'Chỉnh sửa yêu cầu nghỉ phép'
                : 'Tạo yêu cầu nghỉ phép',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          leading: IconButton(
            key: const ValueKey('leave_form_back_button'),
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

    final dateText = state.leaveDate != null
        ? '${state.leaveDate!.day.toString().padLeft(2, '0')}/${state.leaveDate!.month.toString().padLeft(2, '0')}/${state.leaveDate!.year}'
        : null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          state.isEditing
              ? 'Chỉnh sửa yêu cầu nghỉ phép'
              : 'Tạo yêu cầu nghỉ phép',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('leave_form_back_button'),
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
                  key: const ValueKey('leave_form_submit_button'),
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
                                : 'Tạo yêu cầu nghỉ phép thành công!',
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
                              .read(createLeaveRequestControllerProvider)
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

              // Card: Số dư phép năm (đặt lên đầu tiên)
              LeaveBalanceSection(balance: state.leaveBalance),
              const SizedBox(height: 20),

              // Field 1: Người duyệt
              _FieldLabel(label: 'Người duyệt', isRequired: true),
              const SizedBox(height: 8),
              _SelectableInputField(
                key: const ValueKey('leave_form_reviewer_field'),
                icon: Icons.person_outline,
                value: selectedReviewer?.name,
                placeholder: 'Chọn người duyệt',
                onTap: () => _pickReviewer(context, reviewers, controller),
              ),
              const SizedBox(height: 18),

              // Field 2: Loại nghỉ
              _FieldLabel(label: 'Loại nghỉ', isRequired: true),
              const SizedBox(height: 8),
              _SelectableInputField(
                key: const ValueKey('leave_form_type_field'),
                icon: Icons.calendar_today_outlined,
                value: state.leaveType.label,
                placeholder: 'Chọn loại nghỉ',
                onTap: () => _pickLeaveType(context, controller),
              ),
              const SizedBox(height: 18),

              // Field 3: Ngày nghỉ
              _FieldLabel(label: 'Ngày nghỉ', isRequired: true),
              const SizedBox(height: 8),
              _SelectableInputField(
                key: const ValueKey('leave_form_date_field'),
                icon: Icons.calendar_today_outlined,
                value: dateText,
                placeholder: 'Chọn ngày nghỉ',
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.leaveDate ?? now,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 2),
                  );
                  if (picked != null) {
                    controller.setLeaveDate(picked);
                  }
                },
              ),
              if (state.assignedShifts.isLoading) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đang tải ca đã phân...',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (state.assignedShifts.hasError) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCCC7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFFF4D4F),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Không thể tải ca đã phân cho ngày này.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF4D4F),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.retryLoadAssignments,
                        child: const Text(
                          'Thử lại',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (!state.assignedShifts.isLoading &&
                  !state.assignedShifts.hasError &&
                  state.leaveDate != null &&
                  (state.assignedShifts.asData?.value.isEmpty ?? false) &&
                  state.selectedPeriodKey != 'custom') ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBE6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFE58F)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFAAD14),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Ngày này chưa có ca phân công. Bạn có thể chọn "Tùy chỉnh" để tự chọn khoảng giờ.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD48806),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Field 4: Ca làm việc
              _FieldLabel(label: 'Ca làm việc', isRequired: true),
              const SizedBox(height: 8),
              _SelectableInputField(
                key: const ValueKey('leave_form_shift_field'),
                icon: Icons.access_time,
                value: state.selectedPeriodKey == 'custom'
                    ? (state.startAt != null && state.endAt != null
                          ? 'Tùy chỉnh: ${formatRequestRange(state.startAt, state.endAt, separator: ' – ')}'
                          : 'Tùy chỉnh khoảng thời gian')
                    : (state.startAt != null && state.endAt != null
                          ? '${formatRequestRange(state.startAt, state.endAt, separator: ' – ')}${_isOvernight(state.startAt, state.endAt) ? ' (hôm sau)' : ''}'
                          : null),
                placeholder: 'Chọn ca làm việc',
                onTap: () {
                  _pickWorkShift(context, controller);
                },
              ),
              const SizedBox(height: 18),

              // Nếu chọn Tùy chỉnh: hiển thị 2 field chọn time range
              if (state.selectedPeriodKey == 'custom') ...[
                _FieldLabel(label: 'Thời gian bắt đầu', isRequired: true),
                const SizedBox(height: 8),
                _SelectableInputField(
                  key: const ValueKey('leave_form_start_at_field'),
                  icon: Icons.calendar_today_outlined,
                  value: state.startAt != null
                      ? formatRequestDateTime(state.startAt)
                      : null,
                  placeholder: 'Chọn ngày giờ bắt đầu',
                  onTap: () => _pickCustomDateTime(
                    context: context,
                    initialValue: state.startAt,
                    onSelected: (startStr) {
                      final endStr =
                          state.endAt ??
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(
                            parseRequestDateTime(
                              startStr,
                            )!.add(const Duration(hours: 8)),
                          );
                      controller.setCustomInterval(startStr, endStr);
                    },
                  ),
                ),
                const SizedBox(height: 18),

                _FieldLabel(label: 'Thời gian kết thúc', isRequired: true),
                const SizedBox(height: 8),
                _SelectableInputField(
                  key: const ValueKey('leave_form_end_at_field'),
                  icon: Icons.calendar_today_outlined,
                  value: state.endAt != null
                      ? formatRequestDateTime(state.endAt)
                      : null,
                  placeholder: 'Chọn ngày giờ kết thúc',
                  onTap: () => _pickCustomDateTime(
                    context: context,
                    initialValue: state.endAt,
                    onSelected: (endStr) {
                      final startStr =
                          state.startAt ??
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(
                            parseRequestDateTime(
                              endStr,
                            )!.subtract(const Duration(hours: 8)),
                          );
                      controller.setCustomInterval(startStr, endStr);
                    },
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Card xem trước thời gian nghỉ và số ngày phép
              if (state.startAt != null && state.endAt != null) ...[
                _LeaveCoveragePreviewSection(
                  preview: state.coveragePreview,
                  onRetry: controller.retryCoveragePreview,
                ),
                const SizedBox(height: 18),
              ],

              // Field 5: Lý do
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
                            key: const ValueKey('leave_form_reason_input'),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOvernight(String? startAt, String? endAt) {
    if (startAt == null || endAt == null) return false;
    final s = parseRequestDateTime(startAt);
    final e = parseRequestDateTime(endAt);
    return s != null && e != null && !DateUtils.isSameDay(s, e);
  }

  Future<void> _pickCustomDateTime({
    required BuildContext context,
    required String? initialValue,
    required ValueChanged<String> onSelected,
  }) async {
    final now = DateTime.now();
    final parsed = initialValue != null
        ? parseRequestDateTime(initialValue)
        : null;
    final initialDate = parsed ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: parsed?.hour ?? 8,
        minute: parsed?.minute ?? 0,
      ),
    );
    if (time == null || !context.mounted) return;

    final result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    onSelected(DateFormat('yyyy-MM-dd HH:mm:ss').format(result));
  }

  Future<void> _pickReviewer(
    BuildContext context,
    List<UserTreeSelectionUser> reviewers,
    CreateLeaveRequestController controller,
  ) async {
    final auth = ref.read(authControllerProvider);
    final groups = auth.user == null
        ? const <TreeSelectGroup>[]
        : buildScheduleUserTree(users: reviewers, currentUser: auth.user!);
    final currentSelection =
        ref.read(createLeaveRequestControllerProvider).reviewerId != null
        ? {ref.read(createLeaveRequestControllerProvider).reviewerId!}
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

  void _pickLeaveType(
    BuildContext context,
    CreateLeaveRequestController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Chọn loại nghỉ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Nghỉ phép năm'),
                onTap: () {
                  controller.setLeaveType(LeaveTypeEnum.annual);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Nghỉ phép không lương'),
                onTap: () {
                  controller.setLeaveType(LeaveTypeEnum.unpaid);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _pickWorkShift(
    BuildContext context,
    CreateLeaveRequestController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => LeavePeriodSelectorSheet(
        options: controller.workShiftOptions,
        onSelect: (key) {
          controller.setWorkShift(key);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class LeavePeriodSelectorSheet extends StatelessWidget {
  const LeavePeriodSelectorSheet({
    required this.options,
    required this.onSelect,
    super.key,
  });

  final List<LeavePeriodOption> options;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Chọn ca làm việc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: options.length + 1,
                itemBuilder: (context, index) {
                  if (index == options.length) {
                    return ListTile(
                      key: const ValueKey('custom'),
                      leading: const Icon(Icons.tune),
                      title: const Text('Tùy chỉnh khoảng thời gian'),
                      onTap: () => onSelect('custom'),
                    );
                  }
                  final option = options[index];
                  return ListTile(
                    key: ValueKey(option.key),
                    title: Text(option.label),
                    onTap: () => onSelect(option.key),
                  );
                },
              ),
            ),
            if (options.isEmpty)
              const Padding(
                padding: EdgeInsetsDirectional.all(16),
                child: Text(
                  'Ngày này chưa có ca đã phân hoặc ca chưa tải được.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaveCoveragePreviewSection extends StatelessWidget {
  const _LeaveCoveragePreviewSection({
    required this.preview,
    required this.onRetry,
  });

  final AsyncValue<LeaveCoveragePreviewModel?> preview;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return preview.when(
      loading: () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              'Đang tính toán số ngày nghỉ...',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2F0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFCCC7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF4D4F), size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Không thể tải xem trước số ngày nghỉ.',
                style: TextStyle(fontSize: 12, color: Color(0xFFFF4D4F)),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Thử lại', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink();

        final totalHours = data.items.fold(
          0.0,
          (acc, item) => acc + item.hours,
        );

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Xem trước thời gian nghỉ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Số ngày phép trừ',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${data.totalDays} ngày',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giờ làm việc tính nghỉ',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$totalHours giờ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Thời gian nghỉ giữa các khoảng làm việc không tính vào thời lượng nghỉ.',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
              if (data.items.length > 1) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 6),
                for (final item in data.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.date,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${item.hours}h (${item.days} ngày)',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.isRequired = false});

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isRequired)
          const Text(
            '* ',
            style: TextStyle(
              color: Color(0xFFFF4D4F),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasValue ? value! : placeholder,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasValue
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
