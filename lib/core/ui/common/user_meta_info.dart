import 'package:flutter/material.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

extension SectorExtension on Sector {
  String get flag {
    switch (this) {
      case Sector.azerbaijani:
        return '🇦🇿';
      case Sector.russian:
        return '🇷🇺';
      case Sector.english:
        return '🇬🇧';
    }
  }

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case Sector.azerbaijani:
        return l10n.sectorAzerbaijani;
      case Sector.russian:
        return l10n.sectorRussian;
      case Sector.english:
        return l10n.sectorEnglish;
    }
  }

  // Deprecated: используйте getLocalizedName(context) вместо этого
  @Deprecated('Use getLocalizedName(context) for proper localization')
  String get name {
    switch (this) {
      case Sector.azerbaijani:
        return 'Azerbaijani';
      case Sector.russian:
        return 'Russian';
      case Sector.english:
        return 'English';
    }
  }
}

/// Информация о пользователе (факультет, сектор) с разделителями
class UserMetaInfo extends StatelessWidget {
  final String? faculty;
  final Sector? sector;
  final bool showSectorFlag;
  final double fontSize;

  const UserMetaInfo({
    Key? key,
    this.faculty,
    this.sector,
    this.showSectorFlag = true,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodySmall?.color?.withOpacity(0.6);

    final items = <Widget>[];

    if (faculty != null && faculty!.isNotEmpty) {
      items.add(
        Flexible(
          child: Text(
            faculty!,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    }

    if (sector != null) {
      if (items.isNotEmpty) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }

      items.add(
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showSectorFlag) ...[
                Text(
                  sector!.flag,
                  style: TextStyle(fontSize: fontSize),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  sector!.getLocalizedName(context),
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items,
    );
  }
}