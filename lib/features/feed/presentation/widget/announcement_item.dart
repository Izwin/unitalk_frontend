// features/feed/presentation/widget/announcement_item.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unitalk/features/feed/data/model/announcement_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnnouncementItem extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onViewed;
  final VoidCallback onClicked;

  const AnnouncementItem({
    Key? key,
    required this.announcement,
    required this.onViewed,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    timeago.setLocaleMessages('az', timeago.AzMessages());

    // Вызываем onViewed при отображении
    WidgetsBinding.instance.addPostFrameCallback((_) => onViewed());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            bottom: BorderSide(
              color: colors.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            onClicked();
            if (announcement.linkUrl != null) {
              _launchUrl(announcement.linkUrl!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header с типом и временем
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon круг
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getColorForType(colors).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(),
                        color: _getColorForType(colors),
                        size: 20,
                      ),
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
                                  _getTypeLabel(l10n),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: colors.onSurface,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (announcement.priority > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: colors.onSurface.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.featured,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timeago.format(
                              announcement.createdAt,
                              locale: Localizations.localeOf(context).languageCode,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Заголовок
                Text(
                  announcement.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                    letterSpacing: -0.2,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                // Описание
                Text(
                  announcement.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: colors.onSurface,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Изображение (если есть)
                if (announcement.imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: announcement.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        height: 200,
                        color: colors.surfaceContainerHighest.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: colors.onSurface.withOpacity(0.2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 200,
                        color: colors.surfaceContainerHighest.withOpacity(0.3),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: colors.onSurface.withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // Кнопка действия
                if (announcement.linkUrl != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        announcement.linkText ?? l10n.learnMore,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _getColorForType(colors),
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: _getColorForType(colors),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForType(ColorScheme colors) {
    switch (announcement.type) {
      case 'announcement':
        return Color(0xFF2196F3); // Blue
      case 'advertisement':
        return Color(0xFF9C27B0); // Purple
      case 'event':
        return Color(0xFFFF9800); // Orange
      case 'info':
        return Color(0xFF00BCD4); // Cyan
      default:
        return colors.primary;
    }
  }

  IconData _getIconForType() {
    switch (announcement.type) {
      case 'announcement':
        return Icons.campaign;
      case 'advertisement':
        return Icons.storefront;
      case 'event':
        return Icons.event;
      case 'info':
        return Icons.info;
      default:
        return Icons.campaign;
    }
  }

  String _getTypeLabel(AppLocalizations l10n) {
    switch (announcement.type) {
      case 'announcement':
        return l10n.announcement;
      case 'advertisement':
        return l10n.advertisement;
      case 'event':
        return l10n.event;
      case 'info':
        return l10n.information;
      default:
        return l10n.announcement;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}