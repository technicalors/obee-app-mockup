import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

typedef DatePickerFieldFormatter = String Function(DateTime value);

class DatePickerField extends StatefulWidget {
  const DatePickerField({
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
  });

  final DateTime? value;
  final String labelText;
  final ValueChanged<DateTime> onChanged;
  final DatePickerFieldFormatter formatter;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final String? hintText;
  final IconData icon;
  final Locale locale;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

final class _DatePickerFieldState extends State<DatePickerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant DatePickerField oldWidget) {
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

  DateTime _resolveInitialDate({
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final fallbackDate = widget.initialDate ?? DateTime.now();

    if (fallbackDate.isBefore(firstDate)) {
      return firstDate;
    }

    if (fallbackDate.isAfter(lastDate)) {
      return lastDate;
    }

    return fallbackDate;
  }

  Future<void> _pickDate() async {
    final firstDate = widget.firstDate ?? DateTime(1900);
    final lastDate = widget.lastDate ?? DateTime(2100);
    final initialDate =
        widget.value ??
        _resolveInitialDate(firstDate: firstDate, lastDate: lastDate);

    final value = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: widget.locale,
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: widget.locale,
          delegates: GlobalMaterialLocalizations.delegates,
          child: child,
        );
      },
    );

    if (value == null) {
      return;
    }

    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: true,
      enabled: widget.enabled,
      onTap: widget.enabled ? _pickDate : null,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: Icon(widget.icon),
      ),
    );
  }
}
