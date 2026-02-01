import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ActionChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unitalk/core/ui/common/action_chip.dart';
import 'package:unitalk/core/ui/common/confirm_delete_dialog.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_event.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:unitalk/core/ui/common/fullscreen_video_player.dart';
import 'package:unitalk/core/ui/common/fullscreen_image_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplyItem extends StatefulWidget {
  final CommentModel reply;
  final VoidCallback onDelete;
  final VoidCallback? onReply;

  const ReplyItem({
    super.key,
    required this.reply,
    required this.onDelete,
    this.onReply,
  });

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoInitializationStarted = false;

  static final RegExp _urlRegex = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    if (widget.reply.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(ReplyItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reply.videoUrl != widget.reply.videoUrl &&
        widget.reply.videoUrl != null) {
      _videoController?.dispose();
      _isVideoInitialized = false;
      _videoInitializationStarted = false;
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo() {
    if (_videoInitializationStarted) return;
    _videoInitializationStarted = true;

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.reply.videoUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: true,
        ),
      );

      _videoController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      }).catchError((error) {
        if (mounted) {
          print('Video initialization error: $error');
          setState(() {
            _videoInitializationStarted = false;
          });
        }
      });
    } catch (e) {
      print('Error creating video controller: $e');
      if (mounted) {
        setState(() {
          _videoInitializationStarted = false;
        });
      }
    }
  }

  bool _isOwner(String? currentUserId) {
    return currentUserId != null && currentUserId == widget.reply.author?.id;
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ConfirmDeleteDialog.show(
      context,
      title: l10n.deleteReply,
      content: l10n.deleteReplyConfirmation,
      onConfirm: widget.onDelete,
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (widget.reply.isAnonymous || widget.reply.author?.id == null) return;
    context.push('/user/${widget.reply.author!.id}');
  }

  void _handleToggleLike() {
    context.read<RepliesBloc>().add(ToggleReplyLikeEvent(widget.reply.id));
  }

  void _navigateToLikers() {
    context.push('/comment/${widget.reply.id}/likers');
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
                  photoUrl: widget.reply.author?.photoUrl,
                  firstName: widget.reply.author?.firstName,
                  lastName: widget.reply.author?.lastName,
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
                            faculty: widget.reply.author?.faculty
                                ?.getLocalizedName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            sector: widget.reply.author?.sector,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildContent(colors, l10n),
                    if (widget.reply.imageUrl != null &&
                        widget.reply.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => FullscreenImageViewer.show(
                            context, widget.reply.imageUrl!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.reply.imageUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: 120,
                              color: colors.surfaceContainerHighest
                                  .withOpacity(0.3),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: colors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height: 120,
                              color: colors.surfaceContainerHighest
                                  .withOpacity(0.3),
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
                    if (widget.reply.videoUrl != null &&
                        widget.reply.videoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => FullscreenVideoPlayer.show(
                            context, widget.reply.videoUrl!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _isVideoInitialized &&
                              _videoController != null &&
                              _videoController!.value.isInitialized
                              ? AspectRatio(
                            aspectRatio:
                            _videoController!.value.aspectRatio,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                VideoPlayer(_videoController!),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Container(
                            width: double.infinity,
                            height: 120,
                            color: colors.surfaceContainerHighest
                                .withOpacity(0.3),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ActionChip(
                          icon: widget.reply.isLikedByCurrentUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: '${widget.reply.likesCount}',
                          isActive: widget.reply.isLikedByCurrentUser,
                          activeColor: colors.error,
                          onTap: _handleToggleLike,
                        ),
                        if (widget.onReply != null) ...[
                          const SizedBox(width: 12),
                          ActionChip(
                            icon: Icons.reply_rounded,
                            label: l10n.reply,
                            onTap: widget.onReply,
                          ),
                        ],
                      ],
                    ),
                    if (widget.reply.likesCount > 0) ...[
                      const SizedBox(height: 8),
                      _buildTopLikersSection(context, colors, l10n),
                    ],
                  ],
                ),
              ),
              _buildDeleteButton(context, colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopLikersSection(
      BuildContext context, ColorScheme colors, AppLocalizations l10n) {
    if (widget.reply.likesCount == 0) return const SizedBox.shrink();

    return InkWell(
      onTap: _navigateToLikers,
      child: Row(
        children: [
          if (widget.reply.topLikers != null &&
              widget.reply.topLikers!.isNotEmpty) ...[
            SizedBox(
              height: 27,
              width: widget.reply.topLikers!.length >= 2 ? 40 : 28,
              child: Stack(
                children: [
                  for (int i = 0;
                  i <
                      (widget.reply.topLikers!.length >= 2
                          ? 2
                          : 1);
                  i++)
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
                            photoUrl: widget.reply.topLikers![i].photoUrl,
                            firstName: widget.reply.topLikers![i].firstName,
                            lastName: widget.reply.topLikers![i].lastName,
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
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                children: _buildLikesTextSpans(context, colors, l10n),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildLikesTextSpans(
      BuildContext context, ColorScheme colors, AppLocalizations l10n) {
    final topLikers = widget.reply.topLikers ?? [];
    final likeCount = widget.reply.likesCount;

    if (topLikers.isEmpty) {
      return [
        TextSpan(text: l10n.likesCount(likeCount)),
      ];
    }

    final spans = <TextSpan>[];

    spans.add(TextSpan(text: '${l10n.likedByPrefix} '));

    spans.add(
      TextSpan(
        text: topLikers[0].firstName ?? '',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
    );

    if (likeCount == 2 && topLikers.length >= 2) {
      spans.add(TextSpan(text: ' ${l10n.and} '));
      spans.add(
        TextSpan(
          text: topLikers[1].firstName ?? '',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      );
    } else if (likeCount > 2) {
      final othersCount = likeCount - 1;
      spans.add(TextSpan(text: ' ${l10n.andOthers(othersCount)}'));
    }

    return spans;
  }

  Widget _buildNameRow(
      BuildContext context, ColorScheme colors, AppLocalizations l10n) {
    return Row(
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.reply.isAnonymous
                      ? l10n.anonymous
                      : '${widget.reply.author?.firstName ?? ''} ${widget.reply.author?.lastName ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.onSurface,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!widget.reply.isAnonymous &&
                  widget.reply.author?.isVerified == true) ...[
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
            widget.reply.createdAt,
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
    return Icon(
      Icons.verified,
      size: 16,
      color: colors.primary,
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
        if (widget.reply.replyToUser != null &&
            (widget.reply.replyToUser!.firstName?.isNotEmpty ?? false)) ...[
          Text(
            '${l10n.replyingTo} ${widget.reply.replyToUser!.firstName}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (widget.reply.content.trim().isNotEmpty)
          _buildContentWithLinks(colors),
      ],
    );
  }

  Widget _buildContentWithLinks(ColorScheme colors) {
    final text = widget.reply.content;
    final matches = _urlRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: colors.onSurface.withOpacity(0.9),
          letterSpacing: -0.1,
        ),
      );
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: colors.onSurface.withOpacity(0.9),
            letterSpacing: -0.1,
          ),
        ));
      }

      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: colors.primary,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.externalApplication);
            }
          },
      ));

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: colors.onSurface.withOpacity(0.9),
          letterSpacing: -0.1,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
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