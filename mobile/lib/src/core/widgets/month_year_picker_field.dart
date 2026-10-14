import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

typedef MonthYearPickerFieldFormatter = String Function(DateTime value);

class MonthYearPickerField extends StatefulWidget {
  const MonthYearPickerField({
    super.key,
    required this.value,
    required this.labelText,
    required this.onChanged,
    required this.formatter,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.hintText,
    this.icon = Icons.calendar_month_outlined,
    this.locale = const Locale('vi'),
    this.decoration,
    this.style,
    this.borderless = false,
    this.textAlign = TextAlign.start,
  });

  final DateTime? value;
  final String labelText;
  final ValueChanged<DateTime> onChanged;
  final MonthYearPickerFieldFormatter formatter;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? hintText;
  final IconData icon;
  final Locale locale;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool borderless;
  final TextAlign textAlign;

  @override
  State<MonthYearPickerField> createState() => _MonthYearPickerFieldState();
}

final class _MonthYearPickerFieldState extends State<MonthYearPickerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant MonthYearPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value ||
        oldWidget.formatter != widget.formatter) {
      _controller.text = _formattedValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formattedValue(DateTime? value) {
    if (value == null) {
      return '';
    }

    return widget.formatter(value);
  }

  DateTime _normalizeMonth(DateTime value) {
    return DateTime(value.year, value.month);
  }

  DateTime _resolveInitialDate({
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final fallbackDate = widget.initialDate ?? DateTime.now();
    final normalizedFallbackDate = _normalizeMonth(fallbackDate);

    if (normalizedFallbackDate.isBefore(firstDate)) {
      return firstDate;
    }

    if (normalizedFallbackDate.isAfter(lastDate)) {
      return lastDate;
    }

    return normalizedFallbackDate;
  }

  Future<void> _pickMonthYear() async {
    final firstDate = _normalizeMonth(widget.firstDate ?? DateTime(1900));
    final lastDate = _normalizeMonth(widget.lastDate ?? DateTime(2100, 12));
    final initialDate = widget.value != null
        ? _normalizeMonth(widget.value!)
        : _resolveInitialDate(firstDate: firstDate, lastDate: lastDate);

    final value = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Localizations.override(
          context: context,
          locale: widget.locale,
          delegates: GlobalMaterialLocalizations.delegates,
          child: _MonthYearPickerDialog(
            initialDate: initialDate,
            firstDate: firstDate,
            lastDate: lastDate,
          ),
        );
      },
    );

    if (value == null) {
      return;
    }

    widget.onChanged(_normalizeMonth(value));
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = widget.borderless
        ? const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            filled: false,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          )
        : (widget.decoration ??
              InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                suffixIcon: Icon(widget.icon),
              ));

    return TextField(
      key: const ValueKey('month-year-picker-field'),
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled,
      style: widget.style,
      textAlign: widget.textAlign,
      onTap: widget.enabled ? _pickMonthYear : null,
      decoration: effectiveDecoration,
    );
  }
}

class _MonthYearPickerDialog extends StatefulWidget {
  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

final class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  List<int> get _years => [
    for (var year = widget.firstDate.year; year <= widget.lastDate.year; year++)
      year,
  ];

  bool _isMonthSelectable(int year, int month) {
    final candidate = DateTime(year, month);

    if (candidate.isBefore(widget.firstDate)) {
      return false;
    }

    if (candidate.isAfter(widget.lastDate)) {
      return false;
    }

    return true;
  }

  int _nearestSelectableMonth(int year) {
    final selectableMonths = [
      for (var month = 1; month <= 12; month++)
        if (_isMonthSelectable(year, month)) month,
    ];

    if (selectableMonths.contains(_selectedMonth)) {
      return _selectedMonth;
    }

    return selectableMonths.first;
  }

  void _selectToday() {
    final today = DateTime.now();
    final todayYear = today.year.clamp(
      widget.firstDate.year,
      widget.lastDate.year,
    );
    final candidateMonth = todayYear == today.year
        ? today.month
        : todayYear == widget.firstDate.year
        ? widget.firstDate.month
        : widget.lastDate.month;

    setState(() {
      _selectedYear = todayYear;
      _selectedMonth = _isMonthSelectable(todayYear, candidateMonth)
          ? candidateMonth
          : _nearestSelectableMonth(todayYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(child: Text('Chọn tháng')),
          const SizedBox(width: 12),
          TextButton(onPressed: _selectToday, child: const Text('Tháng này')),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                key: const ValueKey('month-year-picker-year-dropdown'),
                initialValue: _selectedYear,
                items: [
                  for (final year in _years)
                    DropdownMenuItem<int>(value: year, child: Text('$year')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedYear = value;
                    _selectedMonth = _nearestSelectableMonth(value);
                  });
                },
                decoration: const InputDecoration(labelText: 'Năm'),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = _selectedMonth == month;
                  final isEnabled = _isMonthSelectable(_selectedYear, month);

                  return _MonthYearOption(
                    key: ValueKey('month-year-picker-month-$month'),
                    label: 'Tháng $month',
                    selected: isSelected,
                    enabled: isEnabled,
                    onTap: isEnabled
                        ? () {
                            setState(() {
                              _selectedMonth = month;
                            });
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(DateTime(_selectedYear, _selectedMonth)),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _MonthYearOption extends StatelessWidget {
  const _MonthYearOption({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = !enabled
        ? colorScheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    final backgroundColor = !enabled
        ? colorScheme.surfaceContainerHighest
        : selected
        ? colorScheme.secondaryContainer
        : colorScheme.surface;
    final borderColor = !enabled
        ? colorScheme.outlineVariant
        : selected
        ? colorScheme.secondary
        : colorScheme.outlineVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
