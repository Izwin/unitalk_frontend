import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/features/feed/data/model/comment_model.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_state.dart';
import 'package:unitalk/features/feed/presentation/widget/comment_action.dart';
import 'package:unitalk/features/feed/presentation/widget/comment_header.dart';
import 'package:unitalk/l10n/app_localizations.dart';

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
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;

    final image = await ImageSourcePicker.show(
      context,
      galleryText: l10n.gallery,
      cameraText: l10n.camera,
      removeText: l10n.removePhoto,
      canRemove: _selectedImage != null,
      onRemove: () => setState(() => _selectedImage = null),
    );

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
  }

  void _createReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    context.read<RepliesBloc>().add(
      CreateReplyEvent(
        postId: widget.postId,
        parentCommentId: widget.comment.id,
        replyToCommentId: _replyToCommentId,
        content: text,
        isAnonymous: _isAnonymous,
        imageFile: _selectedImage,
      ),
    );

    _replyController.clear();
    _focusNode.unfocus();
    setState(() {
      _isAnonymous = false;
      _showReplyInput = false;
      _replyToCommentId = null;
      _replyToUserName = null;
      _selectedImage = null;
    });
  }

  void _handleAnonymousToggle(bool value) {
    setState(() => _isAnonymous = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<RepliesBloc, RepliesState>(
      builder: (context, repliesState) {
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
                  CommentActions(
                    showReplyInput: _showReplyInput,
                    showReplies: _showReplies,
                    repliesCount: repliesState.replies.isNotEmpty
                        ? repliesState.replies.length
                        : widget.comment.repliesCount,
                    onReplyTap: _toggleReplyInput,
                    onRepliesTap: _toggleReplies,
                  ),
                  if (_showReplyInput) ...[
                    const SizedBox(height: 16),
                    _buildReplyInput(colors, l10n),
                  ],
                  if (_showReplies)
                    RepliesList(
                      state: repliesState,
                      onDeleteReply: (replyId) {
                        context.read<RepliesBloc>().add(
                          DeleteReplyEvent(postId: widget.postId, replyId: replyId),
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
          onAnonymousToggle: _handleAnonymousToggle,
          onSend: _createReply,
          onPickImage: _pickImage,
          selectedImage: _selectedImage,
          onRemoveImage: _removeImage,
        ),
      ],
    );
  }
}