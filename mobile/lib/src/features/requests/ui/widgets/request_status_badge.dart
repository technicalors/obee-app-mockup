import 'package:flutter/material.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';

class RequestStatusBadge extends StatelessWidget {
  const RequestStatusBadge({required this.status, super.key});

  final AbsenceRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, label) = switch (status) {
      AbsenceRequestStatus.pending => (
        const Color(0xFFE6F4FF),
        const Color(0xFF1677FF),
        'Chờ duyệt',
      ),
      AbsenceRequestStatus.approved => (
        const Color(0xFFF6FFED),
        const Color(0xFF52C41A),
        'Đã duyệt',
      ),
      AbsenceRequestStatus.rejected => (
        const Color(0xFFFFF1F0),
        const Color(0xFFFF4D4F),
        'Từ chối',
      ),
      AbsenceRequestStatus.returned => (
        const Color(0xFFFFF7E6),
        const Color(0xFFFA8C16),
        'Cần điều chỉnh',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
