import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ActionChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/ui/common/action_chip.dart';
import 'package:unitalk/core/ui/common/confirm_delete_dialog.dart';
import 'package:unitalk/core/ui/common/fullscreen_image_viewer.dart';
import 'package:unitalk/core/ui/common/fullscreen_video_player.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/feed/data/model/post_model.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unitalk/features/report/presentation/content_moderation_menu.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:translator/translator.dart';

class PostItem extends StatefulWidget {
  final PostModel post;
  final bool showDeleteOption;
  final bool enableNavigation;

  const PostItem({
    super.key,
    required this.post,
    this.showDeleteOption = true,
    this.enableNavigation = true,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _videoInitializationStarted = false;

  // Translation state
  bool _isTranslated = false;
  String? _translatedContent;
  bool _isTranslating = false;
  final GoogleTranslator _translator = GoogleTranslator();

  static final RegExp _urlRegex = RegExp(
    r'https?://[^\s]+',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == MediaType.video &&
        widget.post.videoUrl != null &&
        !_videoInitializationStarted) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(PostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.videoUrl != widget.post.videoUrl &&
        widget.post.mediaType == MediaType.video &&
        widget.post.videoUrl != null) {
      _videoController?.dispose();
      _isVideoInitialized = false;
      _videoInitializationStarted = false;
      _initializeVideo();
    }

    // Reset translation if post content changed
    if (oldWidget.post.content != widget.post.content) {
      _isTranslated = false;
      _translatedContent = null;
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
        Uri.parse(widget.post.videoUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: true,
        ),
      );

      _videoController!
          .initialize()
          .then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      })
          .catchError((error) {
        if (mounted) {
          print('Ошибка инициализации видео: $error');
          setState(() {
            _videoInitializationStarted = false;
          });
        }
      });
    } catch (e) {
      print('Ошибка при создании контроллера видео: $e');
      if (mounted) {
        setState(() {
          _videoInitializationStarted = false;
        });
      }
    }
  }

  Future<void> _toggleTranslation() async {
    if (_isTranslated) {
      setState(() {
        _isTranslated = false;
      });
      return;
    }

    if (_translatedContent != null) {
      setState(() {
        _isTranslated = true;
      });
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    try {
      final userLocale = Localizations.localeOf(context).languageCode;
      final translation = await _translator.translate(
        widget.post.content,
        to: userLocale,
      );

      if (mounted) {
        setState(() {
          _translatedContent = translation.text;
          _isTranslated = true;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.translationFailed)),
        );
      }
    }
  }

  bool _isOwner(String? currentUserId) {
    return currentUserId != null && currentUserId == widget.post.author?.id;
  }

  void _showDeleteDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ConfirmDeleteDialog.show(
      context,
      title: l10n.deletePost,
      content: l10n.deletePostConfirmation,
      onConfirm: () {
        context.read<PostBloc>().add(DeletePostEvent(widget.post.id));
        context.pop();
      },
    );
  }

  void _navigateToLikers(BuildContext context) {
    context.push('/post/${widget.post.id}/likers');
  }

  void _navigateToPostDetail(BuildContext context) {
    context.push('/post/${widget.post.id}');
  }

  void _navigateToUserProfile(BuildContext context) {
    if (widget.post.isAnonymous || widget.post.author?.id == null) {
      return;
    }
    context.push('/user/${widget.post.author!.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    timeago.setLocaleMessages('az', timeago.AzMessages());

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
              // Pinned indicator
              if (widget.post.isPinned) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.push_pin,
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.pinnedPost,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(context),
                    child: UserAvatar(
                      photoUrl: widget.post.isAnonymous
                          ? null
                          : widget.post.author?.photoUrl,
                      firstName: widget.post.isAnonymous
                          ? null
                          : widget.post.author?.firstName,
                      lastName: widget.post.isAnonymous
                          ? null
                          : widget.post.author?.lastName,
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
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.post.isAnonymous
                                        ? l10n.anonymous
                                        : '${widget.post.author?.firstName ?? 'Deleted account'} ${widget.post.author?.lastName ?? ''}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: colors.onSurface,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  if (!widget.post.isAnonymous &&
                                      widget.post.author?.isVerified ==
                                          true) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 6,),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: colors.onSurface.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    timeago.format(
                                      widget.post.createdAt,
                                      locale: Localizations.localeOf(
                                        context,
                                      ).languageCode,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colors.onSurface.withOpacity(0.5),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          UserMetaInfo(
                            faculty: widget.post.isAnonymous
                                ? null
                                : widget.post.author?.faculty?.getLocalizedName(
                              Localizations.localeOf(
                                context,
                              ).languageCode,
                            ),
                            sector: widget.post.isAnonymous
                                ? null
                                : widget.post.author?.sector,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.showDeleteOption)
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
                            postId: widget.post.id,
                            isOwner: isOwner,
                            onDelete: isOwner
                                ? () => _showDeleteDialog(context)
                                : null,
                          ),
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Content
              if (widget.post.content.trim().isNotEmpty) ...[
                InkWell(
                  onTap: widget.enableNavigation
                      ? () => _navigateToPostDetail(context)
                      : null,
                  child: _buildContentWithLinks(context, colors),
                ),

                // Translation button
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isTranslating ? null : _toggleTranslation,
                  child: Row(
                    children: [
                      Icon(
                        Icons.translate,
                        size: 14,
                        color: colors.primary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isTranslating
                            ? l10n.translating
                            : _isTranslated
                            ? l10n.showOriginal
                            : l10n.translate,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.primary.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Media (Image)
              if (widget.post.mediaType == MediaType.image &&
                  widget.post.imageUrl != null &&
                  widget.post.imageUrl!.isNotEmpty) ...[
                if (widget.post.content.trim().isNotEmpty)
                  const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => FullscreenImageViewer.show(
                    context,
                    widget.post.imageUrl!,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.post.imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200,
                        color: colors.surfaceContainerHighest.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: colors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
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

              // Video Player
              if (widget.post.mediaType == MediaType.video &&
                  widget.post.videoUrl != null &&
                  widget.post.videoUrl!.isNotEmpty) ...[
                if (widget.post.content.trim().isNotEmpty)
                  const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => FullscreenVideoPlayer.show(
                    context,
                    widget.post.videoUrl!,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                    _isVideoInitialized &&
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
                      height: 200,
                      color: colors.surfaceContainerHighest.withOpacity(
                        0.3,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: colors.primary,
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
                    icon: widget.post.isLikedByCurrentUser
                        ? Icons.favorite
                        : Icons.favorite_border,
                    label: '${widget.post.likesCount}',
                    isActive: widget.post.isLikedByCurrentUser,
                    activeColor: colors.error,
                    onTap: () {
                      context.read<PostBloc>().add(
                        ToggleLikeEvent(widget.post.id),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  ActionChip(
                    icon: Icons.chat_bubble_outline,
                    label: '${widget.post.commentsCount}',
                    onTap: widget.enableNavigation
                        ? () => _navigateToPostDetail(context)
                        : null,
                  ),
                ],
              ),

              // Top Likers Section
              if (widget.post.likesCount > 0) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _navigateToLikers(context),
                  child: Row(
                    children: [
                      if (widget.post.topLikers != null &&
                          widget.post.topLikers!.isNotEmpty) ...[
                        SizedBox(
                          height: 27,
                          width: widget.post.topLikers!.length >= 2 ? 40 : 28,
                          child: Stack(
                            children: [
                              for (
                              int i = 0;
                              i <
                                  (widget.post.topLikers!.length >= 2
                                      ? 2
                                      : 1);
                              i++
                              )
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
                                        photoUrl:
                                        widget.post.topLikers![i].photoUrl,
                                        firstName:
                                        widget.post.topLikers![i].firstName,
                                        lastName:
                                        widget.post.topLikers![i].lastName,
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

  List<TextSpan> _buildLikesTextSpans(
      BuildContext context,
      ColorScheme colors,
      ) {
    final l10n = AppLocalizations.of(context)!;
    final topLikers = widget.post.topLikers ?? [];

    if (topLikers.isEmpty) {
      return [
        TextSpan(
          text: l10n.likesCount(widget.post.likesCount),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ];
    }

    final firstName = topLikers[0].firstName ?? '';

    if (widget.post.likesCount == 1) {
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ];
    } else if (widget.post.likesCount == 2 && topLikers.length >= 2) {
      final secondName = topLikers[1].firstName ?? '';
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        TextSpan(text: ' ${l10n.and} '),
        TextSpan(
          text: secondName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ];
    } else {
      final othersCount = widget.post.likesCount - 1;
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        TextSpan(text: ' ${l10n.andOthers(othersCount)}'),
      ];
    }
  }

  Widget _buildContentWithLinks(BuildContext context, ColorScheme colors) {
    final text = _isTranslated ? (_translatedContent ?? widget.post.content) : widget.post.content;
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
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: colors.onSurface,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.1,
            ),
          ),
        );
      }

      final url = match.group(0)!;
      spans.add(
        TextSpan(
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
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: colors.onSurface,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.1,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}