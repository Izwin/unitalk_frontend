// lib/features/auth/data/model/badge_helper.dart

import 'package:unitalk/l10n/app_localizations.dart';

class BadgeHelper {
  static String getName(String badgeId, AppLocalizations l10n) {
    switch (badgeId) {
      case 'og':
        return l10n.badgeOgName;
      case 'author':
        return l10n.badgeAuthorName;
      case 'popular':
        return l10n.badgePopularName;
      case 'talkative':
        return l10n.badgeTalkativeName;
      case 'social':
        return l10n.badgeSocialName;
      default:
        return badgeId;
    }
  }

  static String getDescription(String badgeId, AppLocalizations l10n, {int? value}) {
    switch (badgeId) {
      case 'og':
        return value != null ? l10n.badgeOgDescription(value) : l10n.badgeOgRequirement;
      case 'author':
        return value != null ? l10n.badgeAuthorDescription(value) : l10n.badgeAuthorRequirement;
      case 'popular':
        return value != null ? l10n.badgePopularDescription(value) : l10n.badgePopularRequirement;
      case 'talkative':
        return value != null ? l10n.badgeTalkativeDescription(value) : l10n.badgeTalkativeRequirement;
      case 'social':
        return value != null ? l10n.badgeSocialDescription(value) : l10n.badgeSocialRequirement;
      default:
        return '';
    }
  }

  static String getIcon(String badgeId) {
    switch (badgeId) {
      case 'og':
        return '🥇';
      case 'author':
        return '✍️';
      case 'popular':
        return '🔥';
      case 'talkative':
        return '💬';
      case 'social':
        return '👥';
      default:
        return '🏆';
    }
  }

  static String getTierName(String? tier, AppLocalizations l10n) {
    switch (tier) {
      case 'gold':
        return l10n.tierGold;
      case 'silver':
        return l10n.tierSilver;
      case 'bronze':
        return l10n.tierBronze;
      default:
        return '';
    }
  }
}