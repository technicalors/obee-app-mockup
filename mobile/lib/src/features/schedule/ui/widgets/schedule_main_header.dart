import 'package:flutter/material.dart';
import 'package:obee_mobile/src/core/widgets/month_year_picker_field.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/logic/schedule_formatters.dart';

class ScheduleHeader extends StatefulWidget {
  const ScheduleHeader({
    required this.viewMode,
    required this.month,
    required this.focusedDate,
    required this.today,
    required this.selectedUserId,
    required this.organizationUsers,
    required this.visibility,
    required this.isVisibilityEnabled,
    required this.onMonthChanged,
    required this.onTodayPressed,
    required this.onViewModeChanged,
    required this.onSelectedUserChanged,
    required this.onVisibilityChanged,
    this.initialShowFilters = false,
    super.key,
  });

  final ScheduleViewMode viewMode;
  final DateTime month;
  final DateTime focusedDate;
  final DateTime today;
  final String? selectedUserId;
  final List<UserTreeSelectionUser> organizationUsers;
  final ScheduleVisibilityFilter visibility;
  final bool isVisibilityEnabled;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback onTodayPressed;
  final ValueChanged<ScheduleViewMode> onViewModeChanged;
  final ValueChanged<String> onSelectedUserChanged;
  final ValueChanged<ScheduleVisibilityFilter> onVisibilityChanged;
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

  String _formatTitle(DateTime month) {
    return switch (widget.viewMode) {
      ScheduleViewMode.month => formatScheduleMonthYear(month),
      ScheduleViewMode.week => formatScheduleWeekRange(widget.focusedDate),
      ScheduleViewMode.year => '${month.year}',
    };
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const iconConstraints = BoxConstraints(minWidth: 40, minHeight: 40);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title on the left, compact actions on the right (Google Calendar style).
        SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                // The field only refreshes its text when the month changes, so
                // rebuild it whenever the week or view mode changes the title.
                child: KeyedSubtree(
                  key: ValueKey('schedule-title-${_formatTitle(widget.month)}'),
                  child: MonthYearPickerField(
                    key: const ValueKey('schedule-month-picker'),
                    value: widget.month,
                    labelText: '',
                    formatter: _formatTitle,
                    borderless: true,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100, 12),
                    onChanged: widget.onMonthChanged,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              _TodayButton(
                today: widget.today,
                onPressed: widget.onTodayPressed,
              ),
              PopupMenuButton<ScheduleViewMode>(
                key: const ValueKey('schedule-view-mode-button'),
                tooltip: 'Chế độ xem',
                initialValue: widget.viewMode,
                onSelected: widget.onViewModeChanged,
                icon: Icon(widget.viewMode.icon, color: colorScheme.onSurface),
                constraints: const BoxConstraints(minWidth: 160),
                itemBuilder: (context) => [
                  for (final mode in ScheduleViewMode.values)
                    PopupMenuItem(
                      key: ValueKey('schedule-view-mode-${mode.name}'),
                      value: mode,
                      child: Row(
                        children: [
                          Icon(
                            mode.icon,
                            size: 20,
                            color: mode == widget.viewMode
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(mode.label)),
                          if (mode == widget.viewMode)
                            Icon(
                              Icons.check,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              IconButton(
                key: const ValueKey('schedule-filter-toggle'),
                tooltip: 'Bộ lọc',
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: colorScheme.onSurface,
                ),
                padding: EdgeInsets.zero,
                constraints: iconConstraints,
                onPressed: _toggleFilters,
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _showFilters
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 12),
                      const _EventTypeLegend(),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
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
            decoration: const InputDecoration(labelText: 'Hiển thị lịch trình'),
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
    );
  }
}

/// Calendar-page icon showing today's day number, like Google Calendar.
class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.today, required this.onPressed});

  final DateTime today;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      key: const ValueKey('schedule-today-button'),
      tooltip: 'Hôm nay',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
      icon: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colorScheme.onSurface, width: 1.8),
        ),
        child: Text(
          '${today.day}',
          style: TextStyle(
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _EventTypeLegend extends StatelessWidget {
  const _EventTypeLegend();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final type in ScheduleEventType.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: type.harmonizedColor(colorScheme),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                type.label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
