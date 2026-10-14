import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';
import 'package:obee_mobile/src/features/requests/ui/widgets/request_status_badge.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    required this.item,
    this.canCancel = false,
    this.canReview = false,
    this.onTap,
    this.onApprove,
    this.onReject,
    this.onReturn,
    this.onCancel,
    super.key,
  });

  final AbsenceRequestModel item;
  final bool canCancel;
  final bool canReview;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onReturn;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Type title + Status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.leaveType.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RequestStatusBadge(status: item.requestStatus),
                ],
              ),
              const SizedBox(height: 10),

              // Date range row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formatRequestRange(item.startAt, item.endAt),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reason row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Two columns: Requester & Reviewer
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Người yêu cầu',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.displayRequesterName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Người duyệt',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.displayReviewerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Rejection reason or return revision note
              if ((item.requestStatus == AbsenceRequestStatus.rejected ||
                      item.requestStatus == AbsenceRequestStatus.returned) &&
                  item.approvalNote != null &&
                  item.approvalNote!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: item.requestStatus == AbsenceRequestStatus.rejected
                        ? const Color(0xFFFFF1F0)
                        : const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.requestStatus == AbsenceRequestStatus.rejected
                          ? const Color(0xFFFFA39E)
                          : const Color(0xFFFFD591),
                      width: 0.8,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1.5),
                        child: Icon(
                          item.requestStatus == AbsenceRequestStatus.rejected
                              ? Icons.error_outline
                              : Icons.info_outline,
                          size: 15,
                          color:
                              item.requestStatus ==
                                  AbsenceRequestStatus.rejected
                              ? const Color(0xFFFF4D4F)
                              : const Color(0xFFFA8C16),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    item.requestStatus ==
                                        AbsenceRequestStatus.rejected
                                    ? 'Lý do từ chối: '
                                    : 'Nội dung cần chỉnh sửa: ',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      item.requestStatus ==
                                          AbsenceRequestStatus.rejected
                                      ? const Color(0xFFFF4D4F)
                                      : const Color(0xFFFA8C16),
                                ),
                              ),
                              TextSpan(
                                text: item.approvalNote!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: Color(0xFF262626),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action button for requester: Cancel request (cancel_schedule_send) when not reviewed
              if (canCancel) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF1F0),
                          side: const BorderSide(
                            color: Color(0xFFFFA39E),
                            width: 1,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Hủy yêu cầu',
                          child: Icon(
                            Icons.cancel_schedule_send,
                            size: 19,
                            color: Color(0xFFFF4D4F),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (canReview) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Accept button (square icon only, left)
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1677FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Chấp nhận',
                          child: Icon(
                            Icons.check,
                            size: 19,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reject button (square icon only, left)
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF1F0),
                          side: const BorderSide(
                            color: Color(0xFFFFA39E),
                            width: 1,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Từ chối',
                          child: Icon(
                            Icons.close,
                            size: 19,
                            color: Color(0xFFFF4D4F),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Return / Revision button (square icon only with Icons.rebase_edit, right)
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: OutlinedButton(
                        onPressed: onReturn,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF7E6),
                          side: const BorderSide(
                            color: Color(0xFFFFD591),
                            width: 1,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Tooltip(
                          message: 'Cần điều chỉnh',
                          child: Icon(
                            Icons.rebase_edit,
                            size: 19,
                            color: Color(0xFFFA8C16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
