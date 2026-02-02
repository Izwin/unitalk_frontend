// lib/features/auth/presentation/widget/student_id_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unitalk/core/ui/common/fullscreen_image_viewer.dart';
import 'package:unitalk/core/ui/widgets/default_avatar.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class StudentIdCardWidget extends StatelessWidget {
  final UserModel user;

  const StudentIdCardWidget({
    super.key,
    required this.user,
  });

  void _showImageFullscreen(BuildContext context, String imageUrl) {
    FullscreenImageViewer.showAvatar(
      context,
      imageUrl,
      userId: user.id,
      heroTag: 'avatar_${user.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── Header with university ─────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                // University logo
                if (user.university?.logoUrl != null)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: user.university!.logoUrl!,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.school_outlined,
                        color: theme.hintColor,
                        size: 18,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),

                // University name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.studentIdCard.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.university?.getLocalizedName(locale) ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Verified badge
                if (user.isVerified == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 12,
                          color: Color(0xFF34C759),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.verified.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF34C759),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ─── Main content ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _buildAvatar(context, isDark),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge?.color,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),

                      // Info rows
                      _InfoRow(
                        label: l10n.faculty,
                        value: user.faculty?.getLocalizedName(locale) ?? l10n.notAvailable,
                        theme: theme,
                      ),
                      const SizedBox(height: 6),
                      if (user.course != null) ...[
                        _InfoRow(
                          label: l10n.course,
                          value: user.course!.getLocalizedName(l10n),
                          theme: theme,
                        ),
                        const SizedBox(height: 6),
                      ],
                      _InfoRow(
                        label: l10n.sector,
                        value: user.sector?.displayName ?? l10n.notAvailable,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Footer with ID ─────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_rounded,
                  size: 16,
                  color: theme.hintColor.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  'ID: ${user.id?.substring(0, 8).toUpperCase() ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                    color: theme.hintColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: user.photoUrl != null
          ? () => _showImageFullscreen(context, user.photoUrl!)
          : null,
      child: Hero(
        tag: 'avatar_${user.id}',
        child: Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: user.photoUrl != null
              ? CachedNetworkImage(
            imageUrl: user.photoUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => DefaultAvatar(),
          )
              : DefaultAvatar(),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}