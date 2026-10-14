import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

typedef TimePickerFieldFormatter = String Function(TimeOfDay value);

class TimePickerField extends StatefulWidget {
  const TimePickerField({
    super.key,
    required this.value,
    required this.labelText,
    required this.onChanged,
    required this.formatter,
    this.initialTime,
    this.enabled = true,
    this.hintText,
    this.icon = Icons.schedule_outlined,
    this.locale = const Locale('vi'),
  });

  final TimeOfDay? value;
  final String labelText;
  final ValueChanged<TimeOfDay> onChanged;
  final TimePickerFieldFormatter formatter;
  final TimeOfDay? initialTime;
  final bool enabled;
  final String? hintText;
  final IconData icon;
  final Locale locale;

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

final class _TimePickerFieldState extends State<TimePickerField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant TimePickerField oldWidget) {
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

  String _formattedValue(TimeOfDay? value) {
    if (value == null) {
      return '';
    }

    return widget.formatter(value);
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: widget.value ?? widget.initialTime ?? TimeOfDay.now(),
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
      onTap: widget.enabled ? _pickTime : null,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: Icon(widget.icon),
      ),
    );
  }
}
