import 'package:flutter/material.dart';
import 'package:obee_mobile/src/core/widgets/month_year_picker_field.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';

class ScheduleHeader extends StatefulWidget {
  const ScheduleHeader({
    required this.month,
    required this.selectedUserId,
    required this.organizationUsers,
    required this.visibility,
    required this.isVisibilityEnabled,
    required this.onPrevious,
    required this.onNext,
    required this.onMonthChanged,
    required this.onSelectedUserChanged,
    required this.onVisibilityChanged,
    this.onCreatePressed,
    this.canCreateSchedule = true,
    this.initialShowFilters = false,
    super.key,
  });

  final DateTime month;
  final String? selectedUserId;
  final List<UserTreeSelectionUser> organizationUsers;
  final ScheduleVisibilityFilter visibility;
  final bool isVisibilityEnabled;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<String> onSelectedUserChanged;
  final ValueChanged<ScheduleVisibilityFilter> onVisibilityChanged;
  final VoidCallback? onCreatePressed;
  final bool canCreateSchedule;
  final bool initialShowFilters;

  @override
  State<ScheduleHeader> createState() => _ScheduleHeaderState();
}

class _ScheduleHeaderState extends State<ScheduleHeader> {
  late bool _showFilters;

  @override
  void initState() {
    super.initState();
    _showFilters = widget.initialShowFilters;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top App Bar Row: < Tháng 4, 2025 > [Search] [Add] [More]
        SizedBox(
          height: 64,
          child: Row(
            children: [
              IconButton(
                key: const ValueKey('schedule-month-previous-button'),
                icon: Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: colorScheme.onSurface,
                ),
                tooltip: 'Tháng trước',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: widget.onPrevious,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: MonthYearPickerField(
                  key: const ValueKey('schedule-month-picker'),
                  value: widget.month,
                  labelText: '',
                  formatter: formatScheduleMonthYear,
                  borderless: true,
                  textAlign: TextAlign.center,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100, 12),
                  onChanged: widget.onMonthChanged,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('schedule-month-next-button'),
                icon: Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: colorScheme.onSurface,
                ),
                tooltip: 'Tháng sau',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: widget.onNext,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.search,
                  size: 24,
                  color: colorScheme.onSurface,
                ),
                tooltip: 'Tìm kiếm',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
              if (widget.onCreatePressed != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey('schedule-header-add-button'),
                  tooltip: 'Thêm lịch trình mới',
                  icon: Icon(Icons.add, size: 24, color: colorScheme.onSurface),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  onPressed: () {
                    if (widget.canCreateSchedule) {
                      widget.onCreatePressed?.call();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn không có quyền tạo lịch trình.'),
                        ),
                      );
                    }
                  },
                ),
              ],
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('schedule-filter-toggle'),
                tooltip: 'Bộ lọc',
                icon: Icon(
                  Icons.more_vert,
                  size: 24,
                  color: colorScheme.onSurface,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
          ),
        ),
        // Collapsible Filters Row
        if (_showFilters) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: const ValueKey('schedule-user-dropdown'),
                  initialValue: widget.selectedUserId,
                  isExpanded: true,
                  items: [
                    for (final user in widget.organizationUsers)
                      DropdownMenuItem(value: user.id, child: Text(user.name)),
                  ],
                  selectedItemBuilder: (context) => [
                    for (final user in widget.organizationUsers)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.onSelectedUserChanged(value);
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Hiển thị lịch trình',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<ScheduleVisibilityFilter>(
                  key: const ValueKey('schedule-visibility-dropdown'),
                  initialValue: widget.visibility,
                  isExpanded: true,
                  items: [
                    for (final item in ScheduleVisibilityFilter.values)
                      DropdownMenuItem(value: item, child: Text(item.label)),
                  ],
                  selectedItemBuilder: (context) => [
                    for (final item in ScheduleVisibilityFilter.values)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: widget.isVisibilityEnabled
                      ? (value) {
                          if (value != null) {
                            widget.onVisibilityChanged(value);
                          }
                        }
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Phạm vi',
                    helperText: widget.isVisibilityEnabled
                        ? null
                        : 'Chỉ xem lịch của đồng nghiệp',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
