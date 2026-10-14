import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';

class LeaveBalanceCard extends StatelessWidget {
  const LeaveBalanceCard({required this.balance, super.key});

  final LeaveBalanceModel balance;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    String fmtDays(double value) {
      if (value == value.roundToDouble()) {
        return '${value.toInt()} ngày';
      }
      return '$value ngày';
    }

    String getCycleText() {
      if (balance.cycleStart == null || balance.cycleEnd == null) {
        return 'Không có';
      }
      final start = formatRequestDateOnly(balance.cycleStart);
      final end = formatRequestDateOnly(balance.cycleEnd);
      if (start.isNotEmpty && end.isNotEmpty) {
        return '$start\n- $end';
      }
      return '${balance.cycleStart}\n- ${balance.cycleEnd}';
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6E4FF), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storage_rounded,
                  color: Color(0xFF1677FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số dư phép năm',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Số dư tại ngày bắt đầu: Khi gửi, hệ thống kiểm tra các ngày có cả và số phép tổng còn lại.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _StatCell(
                  label: 'Còn lại',
                  value: fmtDays(balance.remaining),
                ),
              ),
              Expanded(
                flex: 3,
                child: _StatCell(
                  label: 'Đã dùng',
                  value: fmtDays(balance.used),
                ),
              ),
              Expanded(
                flex: 3,
                child: _StatCell(
                  label: 'Định mức',
                  value: fmtDays(balance.entitlement),
                ),
              ),
              Expanded(
                flex: 4,
                child: _StatCell(
                  label: 'Chu kỳ',
                  value: getCycleText(),
                  maxLines: 2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.fontSize = 13.5,
  });

  final String label;
  final String value;
  final int maxLines;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class LeaveBalanceSection extends StatelessWidget {
  const LeaveBalanceSection({required this.balance, super.key});

  final AsyncValue<LeaveBalanceModel> balance;

  @override
  Widget build(BuildContext context) => switch (balance) {
    AsyncData(:final value) => LeaveBalanceCard(balance: value),
    AsyncError() => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('Số dư phép năm'), Text('Không thể tải số dư phép năm.')],
    ),
    _ => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text('Số dư phép năm'), LinearProgressIndicator()],
    ),
  };
}
