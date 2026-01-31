import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';

class FriendListTile extends StatelessWidget {
  final UserModel user;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const FriendListTile({
    Key? key,
    required this.user,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return InkWell(
      onTap: onTap ?? () => context.push('/user/${user.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            UserAvatar(
              photoUrl: user.photoUrl,
              firstName: user.firstName,
              lastName: user.lastName,
              size: 44,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + verified badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified == true) ...[
                        const SizedBox(width: 5),
                        Icon(
                          Icons.verified,
                          size: 15,
                          color: theme.primaryColor,
                        ),
                      ],
                    ],
                  ),

                  // Subtitle or meta
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    )
                  else if (user.faculty != null || user.sector != null)
                    UserMetaInfo(
                      faculty: user.faculty?.getLocalizedName(locale),
                      sector: user.sector,
                      fontSize: 13,
                    ),
                ],
              ),
            ),

            // Trailing widget
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}