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
import 'package:unitalk/features/report/presentation/content_moderation_menu.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class CommentHeader extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onDelete;

  const CommentHeader({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  bool _isOwner(String? currentUserId) {
    return currentUserId != null && currentUserId == comment.author?.id;
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ConfirmDeleteDialog.show(
      context,
      title: l10n.deleteComment,
      content: l10n.deleteCommentConfirmation,
      onConfirm: onDelete,
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (comment.isAnonymous || comment.author?.id == null) return;
    context.push('/user/${comment.author!.id}');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _navigateToProfile(context),
              child: UserAvatar(
                photoUrl: comment.author?.photoUrl,
                firstName: comment.author?.firstName,
                lastName: comment.author?.lastName,
                size: 40,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _navigateToProfile(context),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameRow(context, colors, l10n),
                    const SizedBox(height: 4),
                    UserMetaInfo(
                      faculty: comment.author?.faculty?.getLocalizedName(
                        Localizations.localeOf(context).languageCode,
                      ),
                      sector: comment.author?.sector,
                    ),
                  ],
                ),
              ),
            ),
            _buildMenuButton(context, colors),
          ],
        ),

        // Контент комментария
        if (comment.content.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: colors.onSurface,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.1,
            ),
          ),
        ],

        // Изображение комментария
        if (comment.imageUrl != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showImageFullscreen(context, comment.imageUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: comment.imageUrl!,
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
                      Icons.broken_image_outlined,
                      size: 48,
                      color: colors.error.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
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
                  comment.isAnonymous
                      ? l10n.anonymous
                      : '${comment.author?.firstName} ${comment.author?.lastName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colors.onSurface,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!comment.isAnonymous && comment.author?.isVerified == true) ...[
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
          timeago.format(comment.createdAt,locale: Localizations.localeOf(context).languageCode),
          style: TextStyle(
            fontSize: 13,
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
        size: 12,
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

  Widget _buildMenuButton(BuildContext context, ColorScheme colors) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isOwner = _isOwner(authState.user?.id);

        return IconButton(
          icon: Icon(
            Icons.more_vert,
            color: colors.onSurface.withOpacity(0.6),
            size: 20,
          ),
          onPressed: () => ContentModerationMenu.showCommentMenu(
            context: context,
            commentId: comment.id,
            isOwner: isOwner,
            onDelete: isOwner ? () => _showDeleteDialog(context) : null,
          ),
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