import 'package:flutter/material.dart';

/// Переключатель анонимности для постов/комментариев
class AnonymousToggle extends StatefulWidget {
  final bool isAnonymous;
  final ValueChanged<bool> onChanged;
  final double size;

  const AnonymousToggle({
    Key? key,
    required this.isAnonymous,
    required this.onChanged,
    this.size = 40,
  }) : super(key: key);

  @override
  State<AnonymousToggle> createState() => _AnonymousToggleState();
}

class _AnonymousToggleState extends State<AnonymousToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isAnonymous) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnonymousToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAnonymous != widget.isAnonymous) {
      if (widget.isAnonymous) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _handleTap() {
    widget.onChanged(!widget.isAnonymous);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.isAnonymous
                ? theme.primaryColor
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            shape: BoxShape.circle,
            boxShadow: widget.isAnonymous
                ? [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Icon(
            widget.isAnonymous
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            size: widget.size * 0.5,
            color: widget.isAnonymous
                ? Colors.white
                : (isDark ? Colors.grey[600] : Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}