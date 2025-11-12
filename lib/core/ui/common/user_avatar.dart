import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unitalk/core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
  });

  bool get _isAnonymous => photoUrl == null && firstName == null && lastName == null;

  bool get _hasValidPhotoUrl {
    if (photoUrl == null || photoUrl!.isEmpty) return false;
    try {
      final uri = Uri.parse(photoUrl!);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark ? AppColors.avatarBackgroundDark : AppColors.avatarBackgroundLight);

    final contentColor = textColor ??
        (isDark ? AppColors.avatarContentDark : AppColors.avatarContentLight);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _hasValidPhotoUrl ? null : bgColor,
        borderRadius: BorderRadius.circular(borderRadius ?? size * 0.25),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? size * 0.25),
        child: _hasValidPhotoUrl
            ? CachedNetworkImage(
          imageUrl: photoUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: bgColor,
            child: Center(
              child: _isAnonymous
                  ? Icon(
                Icons.person_outline,
                size: size * 0.5,
                color: contentColor,
              )
                  : Text(
                _getInitials(),
                style: TextStyle(
                  color: contentColor,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            print('Avatar load error for $url: $error');
            return Container(
              color: bgColor,
              child: Center(
                child: _isAnonymous
                    ? Icon(
                  Icons.person_outline,
                  size: size * 0.5,
                  color: contentColor,
                )
                    : Text(
                  _getInitials(),
                  style: TextStyle(
                    color: contentColor,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        )
            : Container(
          color: bgColor,
          child: Center(
            child: _isAnonymous
                ? Icon(
              Icons.person_outline,
              size: size * 0.5,
              color: contentColor,
            )
                : Text(
              _getInitials(),
              style: TextStyle(
                color: contentColor,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final first = firstName?.trim().isNotEmpty == true ? firstName!.trim()[0] : '';
    final last = lastName?.trim().isNotEmpty == true ? lastName!.trim()[0] : '';
    return '$first$last'.toUpperCase();
  }
}