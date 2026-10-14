import 'package:flutter/material.dart';

class DirectChatSearchField extends StatefulWidget {
  const DirectChatSearchField({
    required this.query,
    required this.onChanged,
    required this.onClear,
    this.fieldKey = const ValueKey('direct_chat_search_field'),
    this.resetButtonKey = const ValueKey('direct_chat_search_reset_button'),
    this.hintText = 'Tìm cuộc trò chuyện hiện có',
    this.resetTooltip = 'Xóa tìm kiếm',
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final Key fieldKey;
  final Key resetButtonKey;
  final String hintText;
  final String resetTooltip;

  @override
  State<DirectChatSearchField> createState() => _DirectChatSearchFieldState();
}

class _DirectChatSearchFieldState extends State<DirectChatSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant DirectChatSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_controller.text == widget.query) {
      return;
    }

    _controller.value = TextEditingValue(
      text: widget.query,
      selection: TextSelection.collapsed(offset: widget.query.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      key: widget.fieldKey,
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: widget.query.isEmpty
            ? null
            : IconButton(
                key: widget.resetButtonKey,
                onPressed: widget.onClear,
                tooltip: widget.resetTooltip,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
