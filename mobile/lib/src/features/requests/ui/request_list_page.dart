import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/core/widgets/tree_select.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';
import 'package:obee_mobile/src/features/requests/ui/widgets/request_action_dialogs.dart';
import 'package:obee_mobile/src/features/requests/ui/widgets/request_card.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_user_tree.dart';

class RequestListPage extends ConsumerWidget {
  const RequestListPage({super.key});

  static const routePath = '/app/requests';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(requestListControllerProvider);
    final controller = ref.read(requestListControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Title "Yêu cầu" and "+" Button (đồng bộ với AppBar bên Lịch trình)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yêu cầu',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('request_add_action'),
                        tooltip: 'Tạo yêu cầu mới',
                        icon: Icon(
                          Icons.add,
                          size: 24,
                          color: colorScheme.onSurface,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: () => _showCreateRequestSheet(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Chips Bar (Loại yêu cầu, Người yêu cầu, Người duyệt, Ngày tạo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filter Chip 1: Loại yêu cầu
                      _FilterDropdownChip(
                        label: state.selectedLeaveType?.label ?? 'Loại yêu cầu',
                        isSelected: state.selectedLeaveType != null,
                        onTap: () => _showLeaveTypeFilterMenu(context, ref),
                        onClear: () => controller.selectLeaveType(null),
                      ),
                      const SizedBox(width: 8),

                      // Filter Chip 2: Người yêu cầu (User tree)
                      _FilterDropdownChip(
                        label: state.selectedRequesterId != null
                            ? (state.employees
                                      .where(
                                        (r) =>
                                            r.id == state.selectedRequesterId,
                                      )
                                      .firstOrNull
                                      ?.name ??
                                  'Người yêu cầu')
                            : 'Người yêu cầu',
                        isSelected: state.selectedRequesterId != null,
                        onTap: () => _showRequesterTreePicker(context, ref),
                        onClear: () => controller.selectRequester(null),
                      ),
                      const SizedBox(width: 8),

                      // Filter Chip 3: Người duyệt (User tree)
                      _FilterDropdownChip(
                        label: state.selectedReviewerId != null
                            ? (state.reviewers
                                      .where(
                                        (r) => r.id == state.selectedReviewerId,
                                      )
                                      .firstOrNull
                                      ?.name ??
                                  'Người duyệt')
                            : 'Người duyệt',
                        isSelected: state.selectedReviewerId != null,
                        onTap: () => _showReviewerTreePicker(context, ref),
                        onClear: () => controller.selectReviewer(null),
                      ),
                      const SizedBox(width: 8),

                      // Filter Chip 4: Ngày tạo
                      _FilterDateChip(
                        key: const ValueKey('request_created_date_filter'),
                        label: state.createdDateRangeLabel,
                        isSelected: state.selectedDateRange != null,
                        onTap: () async {
                          final defaultRange = controller.defaultDateRange;
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(defaultRange.end.year - 1),
                            lastDate: DateTime(defaultRange.end.year + 2),
                            helpText: 'Chọn ngày tạo',
                            currentDate: defaultRange.end,
                            initialDateRange:
                                ref
                                    .read(requestListControllerProvider)
                                    .selectedDateRange ??
                                defaultRange,
                          );
                          if (picked != null && context.mounted) {
                            controller.selectDateRange(picked);
                          }
                        },
                        onClear: () => controller.selectDateRange(null),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Tabs row with counter badges: Yêu cầu 4, Chấp thuận 49, Từ chối 2
              _TabsWithBadges(
                selectedTab: state.selectedTab,
                pendingCount: state.pendingCount,
                approvedCount: state.approvedCount,
                rejectedCount: state.rejectedCount,
                onTabSelected: controller.selectTab,
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 12),

              // Request Cards List
              Expanded(
                child: state.isLoading && state.items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Không có yêu cầu nào',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.filteredItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = state.filteredItems[index];
                          final currentUser = ref
                              .watch(authControllerProvider)
                              .user;
                          final isRequester =
                              currentUser != null &&
                              item.userId == currentUser.id;
                          final isReviewer =
                              currentUser != null &&
                              item.reviewerId == currentUser.id &&
                              item.userId != currentUser.id &&
                              currentUser.permissions != null &&
                              currentUser.permissions!.any(
                                (permission) =>
                                    permission.name ==
                                    'absence-requests.review',
                              );

                          final isPending =
                              item.requestStatus ==
                              AbsenceRequestStatus.pending;
                          final canCancel = isRequester && isPending;
                          final canReview = isReviewer && isPending;

                          return RequestCard(
                            key: ValueKey('request_card_${item.id}'),
                            item: item,
                            canCancel: canCancel,
                            canReview: canReview,
                            onTap: () =>
                                context.push('/app/requests/${item.id}'),
                            onApprove: () => _handleApprove(context, ref, item),
                            onReject: () => _handleReject(context, ref, item),
                            onReturn: () => _handleReturn(context, ref, item),
                            onCancel: () => _handleCancel(context, ref, item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRequestSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Tạo yêu cầu mới',
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  key: const ValueKey('create_leave_request_option'),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_note_outlined,
                      color: Color(0xFF1677FF),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Tạo yêu cầu nghỉ phép',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: const Text(
                    'Xin nghỉ phép năm, nghỉ không lương...',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/app/requests/create-leave');
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  key: const ValueKey('create_trip_request_option'),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FFED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.business_center_outlined,
                      color: Color(0xFF52C41A),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Tạo yêu cầu công tác',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: const Text(
                    'Đăng ký chuyến đi công tác, địa điểm...',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/app/requests/create-trip');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLeaveTypeFilterMenu(BuildContext context, WidgetRef ref) {
    final controller = ref.read(requestListControllerProvider.notifier);
    final state = ref.read(requestListControllerProvider);

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
                'Chọn loại yêu cầu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Tất cả loại'),
                trailing: state.selectedLeaveType == null
                    ? const Icon(Icons.check, color: Color(0xFF1677FF))
                    : null,
                onTap: () {
                  controller.selectLeaveType(null);
                  Navigator.pop(ctx);
                },
              ),
              for (final type in LeaveTypeEnum.values)
                ListTile(
                  title: Text(type.label),
                  trailing: state.selectedLeaveType == type
                      ? const Icon(Icons.check, color: Color(0xFF1677FF))
                      : null,
                  onTap: () {
                    controller.selectLeaveType(type);
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

  Future<void> _showRequesterTreePicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final state = ref.read(requestListControllerProvider);
    final auth = ref.read(authControllerProvider);
    final groups = auth.user == null
        ? const <TreeSelectGroup>[]
        : buildScheduleUserTree(
            users: state.employees,
            currentUser: auth.user!,
          );
    final initial = state.selectedRequesterId != null
        ? {state.selectedRequesterId!}
        : <String>{};

    final result = await TreeSelect.showSheet(
      context: context,
      title: 'Chọn người yêu cầu',
      searchHintText: 'Tìm kiếm nhân viên...',
      groups: groups,
      initialSelection: initial,
      multiple: false,
    );

    if (result != null && context.mounted) {
      ref
          .read(requestListControllerProvider.notifier)
          .selectRequester(result.firstOrNull);
    }
  }

  Future<void> _showReviewerTreePicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final state = ref.read(requestListControllerProvider);
    final auth = ref.read(authControllerProvider);
    final groups = auth.user == null
        ? const <TreeSelectGroup>[]
        : buildScheduleUserTree(
            users: state.reviewers,
            currentUser: auth.user!,
          );
    final initial = state.selectedReviewerId != null
        ? {state.selectedReviewerId!}
        : <String>{};

    final result = await TreeSelect.showSheet(
      context: context,
      title: 'Chọn người duyệt',
      searchHintText: 'Tìm kiếm người duyệt...',
      groups: groups,
      initialSelection: initial,
      multiple: false,
    );

    if (result != null && context.mounted) {
      ref
          .read(requestListControllerProvider.notifier)
          .selectReviewer(result.firstOrNull);
    }
  }

  Future<void> _handleCancel(
    BuildContext context,
    WidgetRef ref,
    AbsenceRequestModel item,
  ) async {
    final confirmed = await showCancelRequestModal(
      context: context,
      item: item,
    );

    if (confirmed != true || !context.mounted) return;
    final success = await ref
        .read(requestListControllerProvider.notifier)
        .cancelRequest(item.id);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(requestListControllerProvider).errorMessage!),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã hủy yêu cầu thành công.')));
  }

  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    AbsenceRequestModel item,
  ) async {
    final confirmed = await showApproveRequestModal(
      context: context,
      item: item,
    );
    if (confirmed != true || !context.mounted) return;
    final success = await ref
        .read(requestListControllerProvider.notifier)
        .approveRequest(item.id);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(requestListControllerProvider).errorMessage!),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã chấp thuận yêu cầu.'),
        backgroundColor: Color(0xFF52C41A),
      ),
    );
  }

  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    AbsenceRequestModel item,
  ) async {
    final reason = await showRejectRequestModal(context: context, item: item);
    if (reason == null || !context.mounted) return;
    final success = await ref
        .read(requestListControllerProvider.notifier)
        .rejectRequest(item.id, note: reason.isNotEmpty ? reason : null);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(requestListControllerProvider).errorMessage!),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã từ chối yêu cầu.'),
        backgroundColor: Color(0xFFFF4D4F),
      ),
    );
  }

  Future<void> _handleReturn(
    BuildContext context,
    WidgetRef ref,
    AbsenceRequestModel item,
  ) async {
    final note = await showReturnRequestModal(context: context, item: item);
    if (note == null || !context.mounted) return;
    final success = await ref
        .read(requestListControllerProvider.notifier)
        .returnRequest(item.id, note: note);
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(requestListControllerProvider).errorMessage!),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi yêu cầu điều chỉnh.'),
        backgroundColor: Color(0xFFFA8C16),
      ),
    );
  }
}

class _FilterDropdownChip extends StatelessWidget {
  const _FilterDropdownChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F4FF) : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF91CAFF)
                : const Color(0xFFE4E7EC),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF1677FF)
                        : const Color(0xFF475467),
                  ),
                ),
                const SizedBox(width: 4),
                if (isSelected && onClear != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.close,
                        size: 15,
                        color: Color(0xFF1677FF),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: isSelected
                        ? const Color(0xFF1677FF)
                        : const Color(0xFF667085),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterDateChip extends StatelessWidget {
  const _FilterDateChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onClear,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE4E7EC), width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFF475467),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475467),
                  ),
                ),
                if (isSelected && onClear != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onClear,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.close,
                        size: 15,
                        color: Color(0xFF475467),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabsWithBadges extends StatelessWidget {
  const _TabsWithBadges({
    required this.selectedTab,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.onTabSelected,
  });

  final RequestFilterTab selectedTab;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final ValueChanged<RequestFilterTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TabItem(
            label: 'Yêu cầu',
            count: pendingCount,
            isSelected: selectedTab == RequestFilterTab.pending,
            badgeBgColor: const Color(0xFF1677FF),
            badgeTextColor: Colors.white,
            onTap: () => onTabSelected(RequestFilterTab.pending),
          ),
          const SizedBox(width: 8),
          _TabItem(
            label: 'Chấp thuận',
            count: approvedCount,
            isSelected: selectedTab == RequestFilterTab.approved,
            badgeBgColor: const Color(0xFFD3F9D8),
            badgeTextColor: const Color(0xFF2B8A3E),
            onTap: () => onTabSelected(RequestFilterTab.approved),
          ),
          const SizedBox(width: 8),
          _TabItem(
            label: 'Từ chối',
            count: rejectedCount,
            isSelected: selectedTab == RequestFilterTab.rejected,
            badgeBgColor: const Color(0xFFFFE3E3),
            badgeTextColor: const Color(0xFFE03131),
            onTap: () => onTabSelected(RequestFilterTab.rejected),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.badgeBgColor,
    required this.badgeTextColor,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF1677FF)
                        : const Color(0xFF667085),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 2.5,
              width: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1677FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
