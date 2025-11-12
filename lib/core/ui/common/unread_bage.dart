import 'package:flutter/material.dart';

enum BadgePosition {
  top,
  topRight,
  topLeft,
  right,
}

/// Бейдж с количеством непрочитанных элементов
class UnreadBadge extends StatelessWidget {
  final int count;
  final BadgePosition? position;
  final int maxCount;

  const UnreadBadge({
    Key? key,
    required this.count,
    this.position,
    this.maxCount = 99,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final displayCount = count > maxCount ? '$maxCount+' : count.toString();
    final pos = position ?? BadgePosition.topRight;

    return Positioned(
      top: _getTop(pos),
      right: _getRight(pos),
      left: _getLeft(pos),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        constraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
        child: Center(
          child: Text(
            displayCount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  double? _getTop(BadgePosition pos) {
    switch (pos) {
      case BadgePosition.top:
      case BadgePosition.topRight:
      case BadgePosition.topLeft:
        return 0;
      default:
        return null;
    }
  }

  double? _getRight(BadgePosition pos) {
    switch (pos) {
      case BadgePosition.topRight:
      case BadgePosition.right:
        return 0;
      default:
        return null;
    }
  }

  double? _getLeft(BadgePosition pos) {
    return pos == BadgePosition.topLeft ? 0 : null;
  }
}