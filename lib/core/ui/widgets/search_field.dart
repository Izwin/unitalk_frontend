import 'dart:async';
import 'package:flutter/material.dart';

/// Универсальное поле поиска с debounce
class SearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Duration debounceDuration;
  final bool autofocus;
  final FocusNode? focusNode;

  const SearchField({
    Key? key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.cardColor.withOpacity(0.3)
            : theme.textTheme.bodySmall?.color?.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: _onSearchChanged,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search...',
          hintStyle: TextStyle(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
            ),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}