import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unitalk/core/ui/common/confirm_delete_dialog.dart';
import 'package:unitalk/core/ui/common/fullscreen_image_viewer.dart';
import 'package:unitalk/core/ui/common/fullscreen_video_player.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/features/report/presentation/content_moderation_menu.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentHeader extends StatefulWidget {
  final CommentModel comment;
  final VoidCallback onDelete;

  const CommentHeader({
    super.key,
    required this.comment,
    required this.onDelete,
  });

  @override
  State<CommentHeader> createState() => _CommentHeaderState();
}

class _CommentHeaderState extends State<CommentHeader> {
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
    if (widget.comment.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(CommentHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.videoUrl != widget.comment.videoUrl &&
        widget.comment.videoUrl != null) {
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
        Uri.parse(widget.comment.videoUrl!),
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
    return currentUserId != null && currentUserId == widget.comment.author?.id;
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ConfirmDeleteDialog.show(
      context,
      title: l10n.deleteComment,
      content: l10n.deleteCommentConfirmation,
      onConfirm: widget.onDelete,
    );
  }

  void _navigateToProfile(BuildContext context) {
    if (widget.comment.isAnonymous || widget.comment.author?.id == null) return;
    context.push('/user/${widget.comment.author!.id}');
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
                photoUrl: widget.comment.author?.photoUrl,
                firstName: widget.comment.author?.firstName,
                lastName: widget.comment.author?.lastName,
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
                      faculty: widget.comment.author?.faculty?.getLocalizedName(
                        Localizations.localeOf(context).languageCode,
                      ),
                      sector: widget.comment.author?.sector,
                    ),
                  ],
                ),
              ),
            ),
            _buildMenuButton(context, colors),
          ],
        ),

        // Comment content with clickable links
        if (widget.comment.content.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildContentWithLinks(context, colors),
        ],

        // Image
        if (widget.comment.imageUrl != null &&
            widget.comment.imageUrl!.isNotEmpty) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () =>
                FullscreenImageViewer.show(context, widget.comment.imageUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.comment.imageUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 150,
                  color: colors.surfaceContainerHighest.withOpacity(0.3),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 150,
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

        // Video
        if (widget.comment.videoUrl != null &&
            widget.comment.videoUrl!.isNotEmpty) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () =>
                FullscreenVideoPlayer.show(context, widget.comment.videoUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isVideoInitialized &&
                  _videoController != null &&
                  _videoController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                width: double.infinity,
                height: 150,
                color: colors.surfaceContainerHighest.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
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
                  widget.comment.isAnonymous
                      ? l10n.anonymous
                      : '${widget.comment.author?.firstName} ${widget.comment.author?.lastName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colors.onSurface,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!widget.comment.isAnonymous &&
                  widget.comment.author?.isVerified == true) ...[
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
          timeago.format(widget.comment.createdAt,
              locale: Localizations.localeOf(context).languageCode),
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
            commentId: widget.comment.id,
            isOwner: isOwner,
            onDelete: isOwner ? () => _showDeleteDialog(context) : null,
          ),
        );
      },
    );
  }

  Widget _buildContentWithLinks(BuildContext context, ColorScheme colors) {
    final text = widget.comment.content;
    final matches = _urlRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: colors.onSurface,
          fontWeight: FontWeight.w400,
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
            fontSize: 15,
            height: 1.5,
            color: colors.onSurface,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.1,
          ),
        ));
      }

      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          fontSize: 15,
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
          fontSize: 15,
          height: 1.5,
          color: colors.onSurface,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}