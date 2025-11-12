import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unitalk/core/ui/common/confirm_delete_dialog.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class ReplyItem extends StatelessWidget {
  final CommentModel reply;
  final VoidCallback onDelete;
  final VoidCallback? onReply;

  const ReplyItem({
    super.key,
    required this.reply,
    required this.onDelete,
    this.onReply,
  });

  bool _isOwner(String? currentUserId) {
    return currentUserId != null && currentUserId == reply.author?.id;
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ConfirmDeleteDialog.show(
      context,
      title: l10n.deleteReply,
      content: l10n.deleteReplyConfirmation,
      onConfirm: onDelete,
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (reply.isAnonymous || reply.author?.id == null) return;
    context.push('/user/${reply.author!.id}');
  }

  void _showImageFullscreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    timeago.setLocaleMessages('az', timeago.AzMessages());
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: UserAvatar(
                  photoUrl: reply.author?.photoUrl,
                  firstName: reply.author?.firstName,
                  lastName: reply.author?.lastName,
                  size: 36,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToProfile(context),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNameRow(context, colors, l10n),
                          const SizedBox(height: 4),
                          UserMetaInfo(
                            faculty: reply.author?.faculty?.getLocalizedName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            sector: reply.author?.sector,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildContent(colors, l10n),

                    // Изображение ответа
                    if (reply.imageUrl != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showImageFullscreen(context, reply.imageUrl!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: reply.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => Container(
                              height: 150,
                              color: colors.surfaceContainerHighest.withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 36,
                                  color: colors.onSurface.withOpacity(0.2),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              height: 150,
                              color: colors.surfaceContainerHighest.withOpacity(0.3),
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 36,
                                  color: colors.error.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildDeleteButton(context, colors),
            ],
          ),

          // Кнопка ответить
          if (onReply != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: InkWell(
                onTap: onReply,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 16,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.reply,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNameRow(BuildContext context, ColorScheme colors, AppLocalizations l10n) {
    return Row(
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  reply.isAnonymous
                      ? l10n.anonymous
                      : '${reply.author?.firstName ?? ''} ${reply.author?.lastName ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.onSurface,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!reply.isAnonymous && reply.author?.isVerified == true) ...[
                const SizedBox(width: 4),
                _buildVerificationBadge(colors),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildDot(colors),
        const SizedBox(width: 8),
        Text(
          timeago.format(
            reply.createdAt,
            locale: Localizations.localeOf(context).languageCode,
          ),
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBadge(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: 10,
        color: colors.onPrimary,
      ),
    );
  }

  Widget _buildDot(ColorScheme colors) {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildContent(ColorScheme colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reply.replyToUser != null && (reply.replyToUser!.firstName?.isNotEmpty ?? false)) ...[
          Text(
            '${l10n.replyingTo} ${reply.replyToUser!.firstName}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (reply.content.trim().isNotEmpty)
          Text(
            reply.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colors.onSurface.withOpacity(0.9),
              letterSpacing: -0.1,
            ),
          ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context, ColorScheme colors) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!_isOwner(authState.user?.id)) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: Icon(
            Icons.more_vert,
            color: colors.onSurface.withOpacity(0.6),
            size: 18,
          ),
          onPressed: () => _showDeleteDialog(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        );
      },
    );
  }
}

// Fullscreen Image Viewer
class _FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const _FullscreenImageViewer({required this.imageUrl});

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, __) => Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (_, __, ___) => Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}