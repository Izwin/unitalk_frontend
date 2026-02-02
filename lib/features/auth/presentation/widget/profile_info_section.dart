// lib/features/auth/presentation/widget/profile_info_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserModel user;

  const ProfileInfoSection({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final hasBio = user.bio != null && user.bio!.isNotEmpty;
    final hasInstagram = user.instagramUsername != null && user.instagramUsername!.isNotEmpty;
    final hasLikes = user.stats?.totalLikesReceived != null && user.stats!.totalLikesReceived > 0;
    final hasRegistrationNumber = user.registrationNumber != null;

    // Если ничего нет - не показываем секцию
    if (!hasBio && !hasInstagram && !hasLikes && !hasRegistrationNumber) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ═══════════════════════════════════════════════
        // ABOUT SECTION (Bio + Instagram)
        // ═══════════════════════════════════════════════
        if (hasBio || hasInstagram) ...[
          _AboutCard(
            bio: user.bio,
            instagramUsername: user.instagramUsername,
            instagramUrl: user.instagramUrl,
            theme: theme,
            l10n: l10n,
          ),
          const SizedBox(height: 16),
        ],

        // ═══════════════════════════════════════════════
        // STATS ROW (OG номер и лайки)
        // ═══════════════════════════════════════════════
        if (hasLikes || hasRegistrationNumber)
          Row(
            children: [
              // Registration Number (OG Badge)
              if (hasRegistrationNumber)
                Expanded(
                  child: _StatCard(
                    icon: '🏆',
                    label: l10n.userNumber,
                    value: '#${user.registrationNumber}',
                    tier: user.ogTier,
                    theme: theme,
                    l10n: l10n,
                  ),
                ),

              if (hasRegistrationNumber && hasLikes)
                const SizedBox(width: 12),

              // Total Likes
              if (hasLikes)
                Expanded(
                  child: _StatCard(
                    icon: '❤️',
                    label: l10n.totalLikes,
                    value: _formatNumber(user.stats!.totalLikesReceived),
                    theme: theme,
                    l10n: l10n,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ABOUT CARD (Bio + Instagram вместе)
// ═══════════════════════════════════════════════════════════════════════════

class _AboutCard extends StatelessWidget {
  final String? bio;
  final String? instagramUsername;
  final String? instagramUrl;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _AboutCard({
    this.bio,
    this.instagramUsername,
    this.instagramUrl,
    required this.theme,
    required this.l10n,
  });

  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasInstagram => instagramUsername != null && instagramUsername!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════
          // BIO TEXT
          // ═══════════════════════════════════════════════
          if (hasBio) ...[
            Text(
              bio!,
              style: TextStyle(
                fontSize: 15,
                color: theme.textTheme.bodyLarge?.color,
                height: 1.5,
              ),
            ),
            if (hasInstagram) const SizedBox(height: 14),
          ],

          // ═══════════════════════════════════════════════
          // INSTAGRAM LINK
          // ═══════════════════════════════════════════════
          if (hasInstagram)
            _InstagramLink(
              username: instagramUsername!,
              url: instagramUrl,
              theme: theme,
              l10n: l10n,
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INSTAGRAM LINK (компактная версия внутри About)
// ═══════════════════════════════════════════════════════════════════════════

class _InstagramLink extends StatelessWidget {
  final String username;
  final String? url;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _InstagramLink({
    required this.username,
    this.url,
    required this.theme,
    required this.l10n,
  });

  Future<void> _openInstagram(BuildContext context) async {
    if (url == null) return;

    final uri = Uri.parse(url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Clipboard.setData(ClipboardData(text: '@$username'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.copiedToClipboard('@$username')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openInstagram(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instagram Icon
            Image.asset(
              'assets/icon/instagram.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 10),

            // Username
            Flexible(
              child: Text(
                '@$username',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 6),

            // Arrow icon
            Icon(
              Icons.arrow_outward_rounded,
              size: 14,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STAT CARD (для OG номера и лайков)
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? tier;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.tier,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(tier);
    final hasSpecialTier = tier != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: hasSpecialTier
            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tierColor.withOpacity(0.12),
            tierColor.withOpacity(0.04),
          ],
        )
            : null,
        color: hasSpecialTier
            ? null
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasSpecialTier
              ? tierColor.withOpacity(0.25)
              : theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasSpecialTier
                  ? tierColor.withOpacity(0.15)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: hasSpecialTier
                            ? tierColor
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (tier != null) ...[
                      const SizedBox(width: 8),
                      _TierBadge(tier: tier!, color: tierColor, l10n: l10n),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String? tier) {
    switch (tier) {
      case 'gold':
        return const Color(0xFFD4A017);
      case 'silver':
        return const Color(0xFF8E99A4);
      case 'bronze':
        return const Color(0xFFB87333);
      default:
        return const Color(0xFF007AFF);
    }
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  final Color color;
  final AppLocalizations l10n;

  const _TierBadge({
    required this.tier,
    required this.color,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _getTierName(tier).toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getTierName(String tier) {
    switch (tier) {
      case 'gold':
        return l10n.tierGold;
      case 'silver':
        return l10n.tierSilver;
      case 'bronze':
        return l10n.tierBronze;
      default:
        return tier;
    }
  }
}