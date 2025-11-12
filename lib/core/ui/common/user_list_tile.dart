import 'package:flutter/material.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

import 'user_avatar.dart';

class UserListTile extends StatelessWidget {
  final UserModel user;
  final String locale;
  final VoidCallback? onTap;
  final Widget? trailing;

  const UserListTile({
    super.key,
    required this.user,
    required this.locale,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              photoUrl: user.photoUrl,
              firstName: user.firstName,
              lastName: user.lastName,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified == true) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                      ],
                    ],
                  ),
                  if (user.university != null || user.faculty != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _buildUserInfo(user, locale),
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  String _buildUserInfo(UserModel user, String locale) {
    final parts = <String>[];

    if (user.faculty != null) {
      parts.add(user.faculty!.getLocalizedName(locale));
    }

    if (user.university != null) {
      parts.add(user.university!.getLocalizedName(locale));
    }

    if (user.sector != null) {
      parts.add(user.sector!.displayName);
    }

    return parts.join(' • ');
  }
}