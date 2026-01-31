import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/fullscreen_image_viewer.dart';
import 'package:unitalk/core/ui/common/fullscreen_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatefulWidget {
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

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
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
    if (widget.message.hasVideo && widget.message.videoUrl != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.videoUrl != widget.message.videoUrl &&
        widget.message.hasVideo &&
        widget.message.videoUrl != null) {
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

  Future<void> _initializeVideo() async {
    if (_videoInitializationStarted) return;
    _videoInitializationStarted = true;

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.message.videoUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: true,
        ),
      );

      await _videoController!.initialize();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        print('Error initializing video: $e');
        setState(() {
          _videoInitializationStarted = false;
        });
      }
    }
  }

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

  String _formatDuration(int? seconds) {
    if (seconds == null) return '0:00';
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildReplyPreview(BuildContext context) {
    if (widget.message.replyToMessage == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final replyTo = widget.message.replyToMessage!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData icon;
    String text;

    if (replyTo.hasVideo) {
      icon = Icons.videocam;
      text = l10n.video;
    } else if (replyTo.hasImage) {
      icon = Icons.image_outlined;
      text = l10n.photo;
    } else {
      icon = Icons.reply;
      text = replyTo.content;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isCurrentUser
            ? Colors.white.withOpacity(0.12)
            : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: widget.isCurrentUser
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
                color: widget.isCurrentUser
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
                    color: widget.isCurrentUser
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
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: widget.isCurrentUser
                    ? Colors.white.withOpacity(0.65)
                    : (isDark ? Colors.white60 : Colors.black45),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: widget.isCurrentUser
                        ? Colors.white.withOpacity(0.65)
                        : (isDark ? Colors.white60 : Colors.black45),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isVideoInitialized || _videoController == null) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isCurrentUser
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
                  widget.isCurrentUser
                      ? Colors.white.withOpacity(0.6)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FullscreenVideoPlayer.show(context, widget.message.videoUrl!),
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.expand(
                  child: VideoPlayer(_videoController!),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
              ),
              Positioned.fill(
                child: Center(
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
              ),
              if (widget.message.videoDuration != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatDuration(widget.message.videoDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
        if (widget.message.hasVideo) ...[
          _buildVideoPlayer(context),
          if (widget.message.content.isNotEmpty) const SizedBox(height: 6),
        ] else if (widget.message.hasImage) ...[
          GestureDetector(
            onTap: () => FullscreenImageViewer.show(context, widget.message.imageUrl!),
            child: Hero(
              tag: 'message_image_${widget.message.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.message.imageUrl!,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isCurrentUser
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
                              widget.isCurrentUser
                                  ? Colors.white.withOpacity(0.6)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isCurrentUser
                            ? Colors.white.withOpacity(0.1)
                            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 40,
                        color: widget.isCurrentUser
                            ? Colors.white.withOpacity(0.5)
                            : (isDark ? Colors.white38 : Colors.black26),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.message.content.isNotEmpty) const SizedBox(height: 6),
        ],
        if (widget.message.content.isNotEmpty)
          _buildContentWithLinks(context),
      ],
    );
  }

  Widget _buildContentWithLinks(BuildContext context) {
    final text = widget.message.isDeleted
        ? AppLocalizations.of(context)!.messageDeleted
        : widget.message.content;

    if (widget.message.isDeleted) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.35,
          letterSpacing: -0.1,
          color: widget.isCurrentUser
              ? Colors.white
              : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.95)
              : const Color(0xFF1A1A1A)),
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    final matches = _urlRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 15,
          height: 1.35,
          letterSpacing: -0.1,
          color: widget.isCurrentUser
              ? Colors.white
              : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.95)
              : const Color(0xFF1A1A1A)),
          fontWeight: FontWeight.w400,
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
            height: 1.35,
            letterSpacing: -0.1,
            color: widget.isCurrentUser
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.95)
                : const Color(0xFF1A1A1A)),
            fontWeight: FontWeight.w400,
          ),
        ));
      }

      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          fontSize: 15,
          height: 1.35,
          letterSpacing: -0.1,
          color: widget.isCurrentUser
              ? Colors.white
              : Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
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
          height: 1.35,
          letterSpacing: -0.1,
          color: widget.isCurrentUser
              ? Colors.white
              : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.95)
              : const Color(0xFF1A1A1A)),
          fontWeight: FontWeight.w400,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
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
            _formatTime(context, widget.message.createdAt),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.05,
              color: widget.isCurrentUser
                  ? Colors.white.withOpacity(0.65)
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
          ),
          if (widget.message.isEdited) ...[
            const SizedBox(width: 4),
            Text(
              l10n.edited,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.05,
                color: widget.isCurrentUser
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
    if (widget.message.user?.id != null && !widget.isCurrentUser) {
      context.push('/user/${widget.message.user!.id}');
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
        mainAxisAlignment: widget.isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isCurrentUser && widget.showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 2),
              child: GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: UserAvatar(
                  photoUrl: widget.message.user?.photoUrl,
                  firstName: widget.message.user?.firstName,
                  lastName: widget.message.user?.lastName,
                  size: 34,
                ),
              ),
            )
          else if (!widget.isCurrentUser && !widget.showAvatar)
            const SizedBox(width: 44),
          Flexible(
            child: GestureDetector(
              onTap: !widget.isCurrentUser ? () => _navigateToProfile(context) : null,
              child: Container(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: widget.isCurrentUser
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(widget.isCurrentUser ? 18 : 4),
                    bottomRight: Radius.circular(widget.isCurrentUser ? 4 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          widget.message.user?.firstName ?? AppLocalizations.of(context)!.unknown,
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