import 'package:flutter/material.dart' hide ActionChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/ui/common/action_chip.dart';
import 'package:unitalk/core/ui/common/confirm_delete_dialog.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/like/like_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unitalk/features/feed/presentation/page/post_detail_page.dart';
import 'package:unitalk/features/report/presentation/content_moderation_menu.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class PostItem extends StatelessWidget {
  final PostModel post;
  final bool showDeleteOption;
  final bool enableNavigation;

  const PostItem({
    super.key,
    required this.post,
    this.showDeleteOption = true,
    this.enableNavigation = true,
  });

  bool _isOwner(String? currentUserId) {
    return currentUserId != null && currentUserId == post.author?.id;
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ConfirmDeleteDialog.show(
      context,
      title: l10n.deletePost,
      content: l10n.deletePostConfirmation,
      onConfirm: () {
        context.read<PostBloc>().add(DeletePostEvent(post.id));
        context.pop();
      },
    );
  }

  void _navigateToLikers(BuildContext context) {
    context.push('/post/${post.id}/likers');
  }

  void _navigateToPostDetail(BuildContext context) {
    context.push('/post/${post.id}');
  }

  void _navigateToUserProfile(BuildContext context) {
    if (post.isAnonymous || post.author?.id == null) {
      return;
    }
    context.push('/user/${post.author!.id}');
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

    print('asdasdasd ${Localizations.localeOf(context).languageCode}');
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(context),
                    child: UserAvatar(
                      photoUrl: post.isAnonymous ? null : post.author?.photoUrl,
                      firstName: post.isAnonymous ? null : post.author?.firstName,
                      lastName: post.isAnonymous ? null : post.author?.lastName,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToUserProfile(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        post.isAnonymous
                                            ? l10n.anonymous
                                            : '${post.author?.firstName ?? 'Deleted account'} ${post.author?.lastName ?? ''}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: colors.onSurface,
                                          letterSpacing: -0.2,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!post.isAnonymous && post.author?.isVerified == true) ...[
                                      const SizedBox(width: 4),
                                      Container(
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
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
                              Text(
                                timeago.format(post.createdAt, locale: Localizations.localeOf(context).languageCode),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          UserMetaInfo(
                            faculty: post.isAnonymous
                                ? null
                                : post.author?.faculty?.getLocalizedName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            sector: post.isAnonymous ? null : post.author?.sector,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showDeleteOption)
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        final isOwner = _isOwner(authState.user?.id);
                        return IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: colors.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                          onPressed: () => ContentModerationMenu.showPostMenu(
                            context: context,
                            postId: post.id,
                            isOwner: isOwner,
                            onDelete: isOwner ? () => _showDeleteDialog(context) : null,
                          ),
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Content (only if not empty)
              if (post.content.trim().isNotEmpty)
                InkWell(
                  onTap: enableNavigation ? () => _navigateToPostDetail(context) : null,
                  child: Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: colors.onSurface,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),

              if (post.imageUrl != null) ...[
                if (post.content.trim().isNotEmpty) const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showImageFullscreen(context, post.imageUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl!,
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
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  ActionChip(
                    icon: post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
                    label: '${post.likesCount}',
                    isActive: post.isLikedByCurrentUser,
                    activeColor: colors.error,
                    onTap: () {
                      context.read<PostBloc>().add(ToggleLikeEvent(post.id));
                    },
                  ),
                  const SizedBox(width: 12),
                  ActionChip(
                    icon: Icons.chat_bubble_outline,
                    label: '${post.commentsCount}',
                    onTap: enableNavigation ? () => _navigateToPostDetail(context) : null,
                  ),
                ],
              ),

              // Top Likers Section (Instagram style)
              if (post.likesCount > 0) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _navigateToLikers(context),
                  child: Row(
                    children: [
                      // Avatars Stack with transparency
                      if (post.topLikers != null && post.topLikers!.isNotEmpty) ...[
                        SizedBox(
                          height: 27,
                          width: post.topLikers!.length >= 2 ? 40 : 28,
                          child: Stack(
                            children: [
                              for (int i = 0; i < (post.topLikers!.length >= 2 ? 2 : 1); i++)
                                Positioned(
                                  left: i * 12.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: UserAvatar(
                                        photoUrl: post.topLikers![i].photoUrl,
                                        firstName: post.topLikers![i].firstName,
                                        lastName: post.topLikers![i].lastName,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Likes Text
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface,
                              fontWeight: FontWeight.w400,
                            ),
                            children: _buildLikesTextSpans(context, colors),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildLikesTextSpans(BuildContext context, ColorScheme colors) {
    final l10n = AppLocalizations.of(context)!;
    final topLikers = post.topLikers ?? [];

    if (topLikers.isEmpty) {
      return [
        TextSpan(
          text: l10n.likesCount(post.likesCount),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ];
    }

    final firstName = topLikers[0].firstName ?? '';

    if (post.likesCount == 1) {
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
      ];
    } else if (post.likesCount == 2 && topLikers.length >= 2) {
      final secondName = topLikers[1].firstName ?? '';
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        TextSpan(text: ' ${l10n.and} '),
        TextSpan(
          text: secondName,
          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
      ];
    } else {
      final othersCount = post.likesCount - 1;
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style: TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        TextSpan(text: ' ${l10n.andOthers(othersCount)}'),
      ];
    }
  }
}

// Fullscreen Image Viewer with zoom
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