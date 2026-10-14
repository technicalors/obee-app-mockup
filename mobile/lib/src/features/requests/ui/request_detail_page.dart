import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';
import 'package:obee_mobile/src/features/requests/state/request_detail_controller.dart';
import 'package:obee_mobile/src/features/requests/ui/widgets/request_action_dialogs.dart';
import 'package:obee_mobile/src/features/requests/ui/widgets/request_status_badge.dart';

class RequestDetailPage extends ConsumerWidget {
  const RequestDetailPage({required this.requestId, super.key});

  final String requestId;

  static const routePath = '/app/requests/:id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      requestDetailControllerProvider(
        requestId,
      ).select((state) => state.errorMessage),
      (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next)));
        }
      },
    );
    final state = ref.watch(requestDetailControllerProvider(requestId));
    final controller = ref.read(
      requestDetailControllerProvider(requestId).notifier,
    );
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết yêu cầu')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final request = state.request;
    if (request == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết yêu cầu')),
        body: Center(
          child: Text(
            state.errorMessage ?? 'Không tìm thấy yêu cầu.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final isPending = request.requestStatus == AbsenceRequestStatus.pending;
    final currentUser = ref.watch(authControllerProvider).user;
    final isRequester = currentUser != null && request.userId == currentUser.id;
    final isReviewer =
        currentUser != null &&
        request.reviewerId == currentUser.id &&
        request.userId != currentUser.id &&
        currentUser.permissions != null &&
        currentUser.permissions!.any(
          (permission) => permission.name == 'absence-requests.review',
        );
    final canCancel = isRequester && isPending;
    final canEdit =
        isRequester &&
        (request.requestStatus == AbsenceRequestStatus.returned ||
            request.requestStatus == AbsenceRequestStatus.rejected);
    final canReview = isReviewer && isPending;
    final durationText =
        '${request.durationDays == request.durationDays.roundToDouble() ? request.durationDays.toInt() : request.durationDays} ngày';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Chi tiết yêu cầu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('request_detail_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: canCancel
            ? [
                IconButton(
                  key: const ValueKey('detail_cancel_button'),
                  tooltip: 'Hủy yêu cầu',
                  icon: const Icon(
                    Icons.cancel_schedule_send,
                    size: 24,
                    color: Color(0xFFFF4D4F),
                  ),
                  onPressed: () => _handleCancel(context, controller, request),
                ),
              ]
            : canEdit
            ? [
                IconButton(
                  key: const ValueKey('detail_edit_button'),
                  tooltip: 'Chỉnh sửa yêu cầu',
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 22,
                    color: Color(0xFF1677FF),
                  ),
                  onPressed: () => _handleEdit(context, controller, request),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Overview Card
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.leaveType.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      request.displayCode,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              RequestStatusBadge(status: request.requestStatus),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  formatRequestRange(
                                    request.startAt,
                                    request.endAt,
                                    separator: ' – ',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: colorScheme.outlineVariant,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time,
                                size: 15,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                durationText,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Rejection reason or return revision note card
                    if (request.requestStatus ==
                        AbsenceRequestStatus.rejected) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFA39E),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.cancel_outlined,
                                  size: 20,
                                  color: Color(0xFFFF4D4F),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Lý do từ chối',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF4D4F),
                                    ),
                                  ),
                                ),
                                if (request.rejectedAt != null)
                                  Text(
                                    formatRequestDateOnly(request.rejectedAt),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8C8C8C),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              (request.approvalNote != null &&
                                      request.approvalNote!.isNotEmpty)
                                  ? request.approvalNote!
                                  : 'Không có lý do từ chối cụ thể.',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF262626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (request.requestStatus ==
                        AbsenceRequestStatus.returned) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7E6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD591),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Color(0xFFFA8C16),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Nội dung cần chỉnh sửa',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFA8C16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              (request.approvalNote != null &&
                                      request.approvalNote!.isNotEmpty)
                                  ? request.approvalNote!
                                  : 'Không có nội dung điều chỉnh cụ thể.',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF262626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Card 2: Thông tin yêu cầu
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin yêu cầu',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _DetailRow(
                            icon: Icons.person_outline,
                            label: 'Người yêu cầu',
                            value: request.displayRequesterName,
                          ),
                          const Divider(
                            height: 22,
                            thickness: 0.7,
                            color: Color(0xFFF0F0F0),
                          ),
                          _DetailRow(
                            icon: Icons.person_outline,
                            label: 'Người duyệt',
                            value: request.displayReviewerName,
                          ),
                          const Divider(
                            height: 22,
                            thickness: 0.7,
                            color: Color(0xFFF0F0F0),
                          ),
                          _DetailRow(
                            icon: Icons.description_outlined,
                            label: 'Loại nghỉ',
                            value: request.leaveType.label,
                          ),
                          const Divider(
                            height: 22,
                            thickness: 0.7,
                            color: Color(0xFFF0F0F0),
                          ),
                          _DetailRow(
                            icon: Icons.access_time,
                            label: 'Ca làm việc',
                            value: formatRequestRange(
                              request.startAt,
                              request.endAt,
                              separator: ' – ',
                            ),
                          ),
                          const Divider(
                            height: 22,
                            thickness: 0.7,
                            color: Color(0xFFF0F0F0),
                          ),
                          _DetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Ngày tạo',
                            value: formatRequestDateTime(
                              request.createdAt,
                              fallback: '06/10/2026 06:53',
                            ),
                          ),
                          if (request.address != null &&
                              request.address!.isNotEmpty) ...[
                            const Divider(
                              height: 22,
                              thickness: 0.7,
                              color: Color(0xFFF0F0F0),
                            ),
                            _DetailRow(
                              icon: Icons.location_on_outlined,
                              label: 'Địa điểm',
                              value: request.address!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Card 3: Lý do
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lý do',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F8FC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    request.reason,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.45,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar: only displayed for reviewers to perform review actions
            if (canReview)
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    // Accept button (square icon only, left)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: ElevatedButton(
                        key: const ValueKey('detail_approve_button'),
                        onPressed: () async {
                          final confirmed = await showApproveRequestModal(
                            context: context,
                            item: request,
                          );
                          if (confirmed == true && context.mounted) {
                            final success = await controller.approve();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã chấp thuận yêu cầu.'),
                                  backgroundColor: Color(0xFF52C41A),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1677FF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Chấp nhận',
                          child: Icon(
                            Icons.check,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Reject button (square icon only, left)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: OutlinedButton(
                        key: const ValueKey('detail_reject_button'),
                        onPressed: () async {
                          final reason = await showRejectRequestModal(
                            context: context,
                            item: request,
                          );
                          if (reason != null && context.mounted) {
                            final success = await controller.reject(
                              note: reason.isNotEmpty ? reason : null,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã từ chối yêu cầu.'),
                                  backgroundColor: Color(0xFFFF4D4F),
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF1F0),
                          padding: EdgeInsets.zero,
                          side: const BorderSide(
                            color: Color(0xFFFFA39E),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Từ chối',
                          child: Icon(
                            Icons.close,
                            size: 22,
                            color: Color(0xFFFF4D4F),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Revision button (square icon only with Icons.rebase_edit, right)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: OutlinedButton(
                        key: const ValueKey('detail_return_button'),
                        onPressed: () async {
                          final note = await showReturnRequestModal(
                            context: context,
                            item: request,
                          );
                          if (note != null && context.mounted) {
                            final success = await controller.returnForRevision(
                              note: note,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Đã chuyển sang cần điều chỉnh.',
                                  ),
                                  backgroundColor: Color(0xFFFA8C16),
                                ),
                              );
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF7E6),
                          padding: EdgeInsets.zero,
                          side: const BorderSide(
                            color: Color(0xFFFFD591),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Cần điều chỉnh',
                          child: Icon(
                            Icons.rebase_edit,
                            size: 22,
                            color: Color(0xFFFA8C16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCancel(
    BuildContext context,
    RequestDetailController controller,
    AbsenceRequestModel request,
  ) async {
    final confirmed = await showCancelRequestModal(
      context: context,
      item: request,
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.cancel();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy yêu cầu thành công.')),
        );
        context.pop();
      }
    }
  }

  Future<void> _handleEdit(
    BuildContext context,
    RequestDetailController controller,
    AbsenceRequestModel request,
  ) async {
    final location = request.leaveType == LeaveTypeEnum.businessTrip
        ? '/app/requests/create-trip?requestId=${request.id}'
        : '/app/requests/create-leave?requestId=${request.id}';
    final result = await context.push<bool>(location);
    if (result == true && context.mounted) {
      await controller.loadDetail();
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
