import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/ui/common/anonymous_toggle.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/core/ui/common/media_preview.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_state.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment/comment_state.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_bloc.dart';
import 'package:unitalk/features/feed/presentation/widget/comment_item.dart';
import 'package:unitalk/features/feed/presentation/widget/post_item.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isAnonymous = false;
  bool _isInitialized = false;
  bool _isRefreshing = false;
  File? _selectedMedia;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _commentController.addListener(() {
      if (mounted) setState(() {});
    });

    _initializeData();
  }

  void _initializeData() {
    if (_isInitialized) return;

    print('Initializing post detail: ${widget.postId}');

    _isInitialized = true;

    context.read<PostBloc>().add(GetPostEvent(widget.postId));

    final commentBloc = context.read<CommentBloc>();
    commentBloc.emit(commentBloc.state.copyWith(postId: widget.postId));

    commentBloc.add(GetPostCommentsEvent(postId: widget.postId, page: 1));
  }

  @override
  void didUpdateWidget(PostDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.postId != widget.postId) {
      print('Post ID changed, reloading: ${widget.postId}');
      _isInitialized = false;
      _initializeData();
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) {
      print('Already refreshing, skipping');
      return;
    }

    print('Refreshing post detail: ${widget.postId}');

    setState(() => _isRefreshing = true);

    try {
      context.read<PostBloc>().add(GetPostEvent(widget.postId));
      context.read<CommentBloc>().add(
        GetPostCommentsEvent(postId: widget.postId, page: 1),
      );

      await Future.wait([
        context
            .read<PostBloc>()
            .stream
            .firstWhere((state) => state.status != PostStatus.loading)
            .timeout(
          const Duration(seconds: 5),
          onTimeout: () => context.read<PostBloc>().state,
        ),
        context
            .read<CommentBloc>()
            .stream
            .firstWhere((state) => state.status != CommentStatus.loading)
            .timeout(
          const Duration(seconds: 5),
          onTimeout: () => context.read<CommentBloc>().state,
        ),
      ]);

      print('Post detail refresh completed');
    } catch (e) {
      print('Error refreshing post detail: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<CommentBloc>().state;

      if (state.status != CommentStatus.loading && !state.commentsLastPage) {
        print('Loading more comments, page: ${state.commentsPage}');

        context.read<CommentBloc>().add(
          GetPostCommentsEvent(postId: widget.postId, page: state.commentsPage),
        );
      }
    }
  }

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

      await _removeMedia(); // Очистить предыдущее

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

  void _createComment() {
    final text = _commentController.text.trim();

    if (text.isEmpty && _selectedMedia == null) {
      print('Cannot create comment: text and media are both empty');
      return;
    }

    print('Creating comment: isAnonymous=$_isAnonymous, hasMedia=${_selectedMedia != null}, isVideo=$_isVideo');

    context.read<CommentBloc>().add(
      CreateCommentEvent(
        postId: widget.postId,
        content: text,
        isAnonymous: _isAnonymous,
        mediaFile: _selectedMedia,
      ),
    );

    _commentController.clear();
    _removeMedia();
    setState(() {
      _isAnonymous = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.postTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<PostBloc, PostState>(
              listener: (context, state) {
                if (state.status == PostStatus.deleted &&
                    state.currentPost?.id == widget.postId) {
                  print('Post was deleted, navigating back');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Post was deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  context.pop();
                }
              },
              builder: (context, postState) {
                print('PostBloc state: ${postState.status}');

                if (postState.status == PostStatus.loading &&
                    postState.currentPost == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.primary,
                    ),
                  );
                }

                if (postState.currentPost == null) {
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    title: l10n.postNotFound,
                    subtitle: l10n.postMayHaveBeenDeleted,
                  );
                }

                return BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, commentState) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: colors.primary,
                      backgroundColor: colors.surface,
                      displacement: 40,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                        slivers: [
                          SliverToBoxAdapter(
                            child: PostItem(
                              key: ValueKey(postState.currentPost!.id),
                              post: postState.currentPost!,
                              enableNavigation: false,
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: Container(
                              height: 12,
                              color: colors.surfaceContainerHighest.withOpacity(0.3),
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                              child: Row(
                                children: [
                                  Text(
                                    l10n.comments,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurface,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${postState.currentPost!.commentsCount}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurface.withOpacity(0.4),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (commentState.comments.isEmpty &&
                              commentState.status != CommentStatus.loading)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: EmptyStateWidget(
                                icon: Icons.mode_comment_outlined,
                                title: l10n.noCommentsYet,
                                subtitle: l10n.startTheConversation,
                              ),
                            ),

                          SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              return BlocProvider(
                                key: ValueKey(commentState.comments[index].id),
                                create: (context) => sl<RepliesBloc>(),
                                child: CommentItem(
                                  key: ValueKey(commentState.comments[index].id),
                                  comment: commentState.comments[index],
                                  postId: widget.postId,
                                ),
                              );
                            }, childCount: commentState.comments.length),
                          ),

                          if (commentState.status == CommentStatus.loading &&
                              commentState.comments.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ),

                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Section
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: mediaQuery.viewInsets.bottom > 0
                  ? 12
                  : mediaQuery.padding.bottom + 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Media Preview
                if (_selectedMedia != null) ...[
                  MediaPreview(
                    mediaFile: _selectedMedia!,
                    isVideo: _isVideo,
                    onRemove: _removeMedia,
                  ),
                  const SizedBox(height: 12),
                ],


                // Input Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnonymousToggle(
                      isAnonymous: _isAnonymous,
                      onChanged: (value) => setState(() => _isAnonymous = value),
                    ),

                    const SizedBox(width: 12),

                    IconButton(
                      onPressed: _pickMedia,
                      icon: Icon(
                        _isVideo ? Icons.videocam : Icons.image_outlined,
                        color: colors.onSurface.withOpacity(0.6),
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _commentController,
                          focusNode: _focusNode,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.onSurface,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: _isAnonymous
                                ? l10n.commentAnonymously
                                : l10n.writeComment,
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: colors.onSurface.withOpacity(0.35),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: (_commentController.text.trim().isEmpty && _selectedMedia == null)
                            ? null
                            : _createComment,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (_commentController.text.trim().isEmpty && _selectedMedia == null)
                                ? colors.surfaceContainerHighest.withOpacity(0.6)
                                : colors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            size: 20,
                            color: (_commentController.text.trim().isEmpty && _selectedMedia == null)
                                ? colors.onSurface.withOpacity(0.3)
                                : colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}