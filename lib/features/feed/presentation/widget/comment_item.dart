import 'dart:io';
import 'package:flutter/material.dart' hide ActionChip;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/action_chip.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_state.dart';
import 'package:unitalk/features/feed/presentation/widget/comment_header.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'replies_list.dart';
import 'reply_input_section.dart';

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final String postId;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _showReplies = false;
  bool _showReplyInput = false;
  final _replyController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAnonymous = false;
  String? _replyToCommentId;
  String? _replyToUserName;
  File? _selectedMedia;
  bool _isVideo = false;

  // Внутри _CommentItemState

  Future<void> _pickMedia() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;

    final media = await MediaSourcePicker.show(
      context,
      videoText: l10n.video,
      galleryText: l10n.gallery,
      cameraText: l10n.camera,
      removeText: l10n.removePhoto,
      canRemove: _selectedMedia != null,
      allowVideo: true,
      onRemove: () => _removeMedia(),
    );

    if (media != null) {
      final isVideo = media.path.toLowerCase().endsWith('.mp4') ||
          media.path.toLowerCase().endsWith('.mov');

      await _removeMedia(); // очистить предыдущую медиа

      setState(() {
        _selectedMedia = File(media.path);
        _isVideo = isVideo;
      });

    }
  }

  Future<void> _removeMedia() async {
    setState(() {
      _selectedMedia = null;
      _isVideo = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _replyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _replyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleDeleteComment() {
    context.read<CommentBloc>().add(DeleteCommentEvent(widget.comment.id));
  }

  void _handleToggleLike() {
    context.read<CommentBloc>().add(ToggleCommentLikeEvent(widget.comment.id));
  }

  void _navigateToLikers() {
    context.push('/comment/${widget.comment.id}/likers');
  }

  void _toggleReplies() {
    if (!_showReplies && widget.comment.repliesCount > 0) {
      final repliesBloc = context.read<RepliesBloc>();
      if (repliesBloc.state.replies.isEmpty) {
        repliesBloc.add(LoadRepliesEvent(commentId: widget.comment.id));
      }
    }
    setState(() => _showReplies = !_showReplies);
  }

  void _toggleReplyInput() {
    setState(() {
      _showReplyInput = !_showReplyInput;
      if (_showReplyInput) {
        _replyToCommentId = null;
        _replyToUserName = null;
        _focusNode.requestFocus();
      }
    });
  }

  void _handleReplyToReply(String replyId, String? replyToUserName) {
    setState(() {
      _replyToCommentId = replyId;
      _replyToUserName = (replyToUserName?.trim().isEmpty ?? true)
          ? null
          : replyToUserName;
      _showReplyInput = true;
      _focusNode.requestFocus();
    });
  }

  void _createReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty && _selectedMedia == null) return;

    context.read<RepliesBloc>().add(
      CreateReplyEvent(
        postId: widget.postId,
        parentCommentId: widget.comment.id,
        replyToCommentId: _replyToCommentId,
        content: text,
        isAnonymous: _isAnonymous,
        mediaFile: _selectedMedia,
      ),
    );

    _replyController.clear();
    _focusNode.unfocus();
    setState(() {
      _isAnonymous = false;
      _showReplyInput = false;
      _replyToCommentId = null;
      _replyToUserName = null;
      _selectedMedia = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<RepliesBloc, RepliesState>(
      builder: (context, repliesState) {
        print(repliesState.replies);
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
                  CommentHeader(
                    comment: widget.comment,
                    onDelete: _handleDeleteComment,
                  ),
                  const SizedBox(height: 16),

                  // Actions (лайк и ответы)
                  Row(
                    children: [
                      ActionChip(
                        icon: widget.comment.isLikedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        label: '${widget.comment.likesCount}',
                        isActive: widget.comment.isLikedByCurrentUser,
                        activeColor: colors.error,
                        onTap: _handleToggleLike,
                      ),
                      const SizedBox(width: 12),
                      ActionChip(
                        icon: Icons.chat_bubble_outline,
                        label: '${repliesState.replies.isNotEmpty ? repliesState.replies.length : widget.comment.repliesCount}',
                        onTap: _toggleReplyInput,
                      ),
                      if (repliesState.replies.isNotEmpty || widget.comment.repliesCount > 0) ...[
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: _toggleReplies,
                          icon: Icon(
                            _showReplies
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                          ),
                          label: Text(
                            _showReplies
                                ? l10n.commentReplies
                                : l10n.repliesCount(repliesState.replies.isNotEmpty ? repliesState.replies.length : widget.comment.repliesCount),
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Top Likers Section
                  if (widget.comment.likesCount > 0) ...[
                    const SizedBox(height: 12),
                    _buildTopLikersSection(context,colors, l10n),
                  ],

                  if (_showReplyInput) ...[
                    const SizedBox(height: 16),
                    _buildReplyInput(colors, l10n),
                  ],
                  if (_showReplies)
                    RepliesList(
                      state: repliesState,
                      onDeleteReply: (replyId) {
                        context.read<RepliesBloc>().add(
                          DeleteReplyEvent(
                              postId: widget.postId, replyId: replyId),
                        );
                      },
                      onReplyToReply: _handleReplyToReply,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopLikersSection(BuildContext context, ColorScheme colors, AppLocalizations l10n) {
    if (widget.comment.likesCount == 0) return const SizedBox.shrink();

    return InkWell(
      onTap: () => _navigateToLikers(),
      child: Row(
        children: [
          if (widget.comment.topLikers != null &&
              widget.comment.topLikers!.isNotEmpty) ...[
            SizedBox(
              height: 27,
              width: widget.comment.topLikers!.length >= 2 ? 40 : 28,
              child: Stack(
                children: [
                  for (int i = 0;
                  i <
                      (widget.comment.topLikers!.length >= 2
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
                            photoUrl: widget.comment.topLikers![i].photoUrl,
                            firstName: widget.comment.topLikers![i].firstName,
                            lastName: widget.comment.topLikers![i].lastName,
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
    );
  }

  List<TextSpan> _buildLikesTextSpans(
      BuildContext context, ColorScheme colors) {
    final l10n = AppLocalizations.of(context)!;
    final topLikers = widget.comment.topLikers ?? [];

    if (topLikers.isEmpty) {
      return [
        TextSpan(
          text: l10n.likesCount(widget.comment.likesCount),
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ];
    }

    final firstName = topLikers[0].firstName ?? '';

    if (widget.comment.likesCount == 1) {
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style:
          TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
      ];
    } else if (widget.comment.likesCount == 2 && topLikers.length >= 2) {
      final secondName = topLikers[1].firstName ?? '';
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style:
          TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        TextSpan(text: ' ${l10n.and} '),
        TextSpan(
          text: secondName,
          style:
          TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
      ];
    } else {
      final othersCount = widget.comment.likesCount - 1;
      return [
        TextSpan(text: l10n.likedByPrefix + ' '),
        TextSpan(
          text: firstName,
          style:
          TextStyle(fontWeight: FontWeight.w600, color: colors.onSurface),
        ),
        TextSpan(text: ' ${l10n.andOthers(othersCount)}'),
      ];
    }
  }

  Widget _buildReplyInput(ColorScheme colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_replyToUserName != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n.replyingTo} $_replyToUserName',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _replyToCommentId = null;
                      _replyToUserName = null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
        ReplyInputSection(
          controller: _replyController,
          focusNode: _focusNode,
          isAnonymous: _isAnonymous,
          onAnonymousToggle: (value) => setState(() => _isAnonymous = value),
          onSend: _createReply,
          onPickMedia: _pickMedia,
          selectedMedia: _selectedMedia,
          isVideo: _isVideo,
          onRemoveMedia: () {
            setState(() {
              _selectedMedia = null;
              _isVideo = false;
            });
          },
        ),
      ],
    );
  }
}