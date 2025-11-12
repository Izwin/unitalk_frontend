import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool showAvatar;
  final UserModel? currentUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.showAvatar = true,
    this.currentUser,
  }) : super(key: key);

  String _formatTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final localDateTime = dateTime.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(localDateTime.year, localDateTime.month, localDateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm', Localizations.localeOf(context).languageCode).format(localDateTime);
    } else if (messageDate == yesterday) {
      return '${l10n.yesterday} ${DateFormat('HH:mm', Localizations.localeOf(context).languageCode).format(localDateTime)}';
    } else if (now.difference(localDateTime).inDays < 7) {
      return DateFormat('EEEE HH:mm', Localizations.localeOf(context).languageCode).format(localDateTime);
    } else {
      return DateFormat('dd.MM.yyyy HH:mm', Localizations.localeOf(context).languageCode).format(localDateTime);
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyPreview(BuildContext context) {
    if (message.replyToMessage == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final replyTo = message.replyToMessage!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Colors.white.withOpacity(0.12)
            : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isCurrentUser
                ? Colors.white.withOpacity(0.6)
                : Theme.of(context).colorScheme.primary,
            width: 2.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 13,
                color: isCurrentUser
                    ? Colors.white.withOpacity(0.8)
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  replyTo.user?.firstName ?? l10n.unknown,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isCurrentUser
                        ? Colors.white.withOpacity(0.9)
                        : Theme.of(context).colorScheme.primary,
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          if (replyTo.imageUrl != null)
            Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 14,
                  color: isCurrentUser
                      ? Colors.white.withOpacity(0.65)
                      : (isDark ? Colors.white60 : Colors.black45),
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.photo,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isCurrentUser
                        ? Colors.white.withOpacity(0.65)
                        : (isDark ? Colors.white60 : Colors.black45),
                  ),
                ),
              ],
            )
          else
            Text(
              replyTo.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.3,
                color: isCurrentUser
                    ? Colors.white.withOpacity(0.65)
                    : (isDark ? Colors.white60 : Colors.black45),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReplyPreview(context),

        if (message.imageUrl != null) ...[
          GestureDetector(
            onTap: () => _showFullScreenImage(context, message.imageUrl!),
            child: Hero(
              tag: 'message_image_${message.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.1)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCurrentUser
                                ? Colors.white.withOpacity(0.6)
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.1)
                          : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.5)
                          : (isDark ? Colors.white38 : Colors.black26),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (message.content.isNotEmpty) const SizedBox(height: 6),
        ],

        if (message.content.isNotEmpty)
          Text(
            message.isDeleted ? l10n.messageDeleted : message.content,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              letterSpacing: -0.1,
              color: isCurrentUser
                  ? Colors.white
                  : (isDark ? Colors.white.withOpacity(0.95) : const Color(0xFF1A1A1A)),
              fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  Widget _buildMessageFooter(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(context, message.createdAt),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.05,
              color: isCurrentUser
                  ? Colors.white.withOpacity(0.65)
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
          ),
          if (message.isEdited) ...[
            const SizedBox(width: 4),
            Text(
              l10n.edited,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
                color: isCurrentUser
                    ? Colors.white.withOpacity(0.65)
                    : (isDark ? Colors.white54 : Colors.black45),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (message.user?.id != null && !isCurrentUser) {
      context.push('/user/${message.user!.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth * 0.72;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser && showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 2),
              child: GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: UserAvatar(
                  photoUrl: message.user?.photoUrl,
                  firstName: message.user?.firstName,
                  lastName: message.user?.lastName,
                  size: 34,
                ),
              ),
            )
          else if (!isCurrentUser && !showAvatar)
            const SizedBox(width: 44),

          Flexible(
            child: GestureDetector(
              onTap: !isCurrentUser ? () => _navigateToProfile(context) : null,
              child: Container(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isCurrentUser ? 18 : 4),
                    bottomRight: Radius.circular(isCurrentUser ? 4 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          message.user?.firstName ?? AppLocalizations.of(context)!.unknown,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: -0.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    _buildMessageContent(context),
                    _buildMessageFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}