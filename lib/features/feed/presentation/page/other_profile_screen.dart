// lib/features/feed/presentation/page/other_user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/report_dialog.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/widget/badges_section.dart';
import 'package:unitalk/features/auth/presentation/widget/profile_info_section.dart';
import 'package:unitalk/features/auth/presentation/widget/student_id_card_widget.dart';
import 'package:unitalk/features/block/presentation/bloc/block_bloc.dart';
import 'package:unitalk/features/block/presentation/bloc/block_event.dart';
import 'package:unitalk/features/block/presentation/bloc/block_state.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_state.dart';
import 'package:unitalk/features/feed/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/user_profile/user_profile_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:unitalk/features/feed/presentation/widget/post_item.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_event.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friends_count_button.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friends_stat_button.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friendship_button.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

const int _kPostsLimit = 20;

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<UserProfileBloc>().add(GetUserProfileEvent(widget.userId));
    context.read<PostBloc>().add(
      GetPostsEvent(authorId: widget.userId, page: 1, limit: _kPostsLimit),
    );
    context.read<FriendshipBloc>().add(
      LoadFriendshipStatusEvent(widget.userId),
    );
    context.read<BlockBloc>().add(CheckBlockStatusEvent(widget.userId));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.9;

    if (currentScroll >= threshold) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    final postState = context.read<PostBloc>().state;
    if (!postState.postsLastPage && !postState.isLoadingMore) {
      context.read<PostBloc>().add(
        GetPostsEvent(
          authorId: widget.userId,
          page: postState.postsPage,
          limit: _kPostsLimit,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    context.read<UserProfileBloc>().add(GetUserProfileEvent(widget.userId));
    context.read<BlockBloc>().add(CheckBlockStatusEvent(widget.userId));
    context.read<PostBloc>().add(
      GetPostsEvent(authorId: widget.userId, page: 1, limit: _kPostsLimit),
    );
    context.read<FriendshipBloc>().add(
      LoadFriendshipStatusEvent(widget.userId),
    );

    await Future.any([
      context.read<UserProfileBloc>().stream.firstWhere(
        (state) => !state.isLoading,
      ),
      Future.delayed(const Duration(seconds: 3)),
    ]);
  }

  void _showModerationMenu(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final blockStatus = user.blockStatus;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              if (blockStatus?.isBlocked == true)
                _ActionTile(
                  icon: Icons.block_rounded,
                  iconColor: theme.colorScheme.error,
                  label: l10n.unblockUser,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showUnblockDialog(context, widget.userId, user);
                  },
                )
              else if (blockStatus?.isBlockedBy != true)
                _ActionTile(
                  icon: Icons.block_rounded,
                  iconColor: theme.colorScheme.error,
                  label: l10n.blockUser,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showBlockDialog(context, widget.userId, user);
                  },
                ),

              if (blockStatus?.isBlockedBy != true)
                _ActionTile(
                  icon: Icons.flag_outlined,
                  label: l10n.report,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ReportDialog.show(
                      context,
                      targetType: ReportTargetType.user,
                      targetId: widget.userId,
                    );
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, String userId, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.blockUser),
        content: Text(
          l10n.blockUserConfirmation('${user.firstName} ${user.lastName}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<BlockBloc>().add(BlockUserEvent(userId));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.userBlocked),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n.block),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, String userId, UserModel user) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.unblockUser),
        content: Text(
          l10n.unblockUserConfirmation('${user.firstName} ${user.lastName}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<BlockBloc>().add(UnblockUserEvent(userId));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.userUnblocked),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(l10n.unblock),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, profileState) {
          if (profileState.isLoading && profileState.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileState.errorMessage != null && profileState.user == null) {
            return _ErrorState(
              message: profileState.errorMessage!,
              l10n: l10n,
              theme: theme,
              onRetry: _loadInitialData,
            );
          }

          final user = profileState.user;
          if (user == null) {
            return _UserNotFoundState(l10n: l10n, theme: theme);
          }

          return BlocBuilder<PostBloc, PostState>(
            builder: (context, postState) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // AppBar
                    SliverAppBar(
                      pinned: false,
                      floating: true,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            if (authState.user?.id == widget.userId) {
                              return const SizedBox.shrink();
                            }
                            if(profileState.user?.blockStatus == null){
                              return const CircularProgressIndicator.adaptive();
                            }
                            return IconButton(
                              icon: const Icon(Icons.more_horiz_rounded),
                              onPressed: () =>
                                  _showModerationMenu(context, user),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),

                    // Profile Content
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Student Card
                          StudentIdCardWidget(user: user),
                          const SizedBox(height: 24),

                          // Bio, Instagram, Likes, Registration Number
                          ProfileInfoSection(user: user),
                          if (_hasProfileInfo(user))
                            const SizedBox(height: 10),

                          // Friends count
                          if (user.friendsCount != null &&
                              user.friendsCount! > 0) ...[
                            FriendsStatButton(
                              friendsCount: user.friendsCount ?? 0,
                              onTap: () =>
                                  context.push('/user/${user.id}/friends'),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Badges
                          BadgesSection(user: user),
                          const SizedBox(height: 16),

                          // Friendship button
                          FriendshipButton(userId: widget.userId),
                          const SizedBox(height: 32),

                          // Posts header
                          _PostsHeader(
                            postState: postState,
                            l10n: l10n,
                            theme: theme,
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),

                    // Posts
                    if (postState.posts.isEmpty &&
                        postState.status != PostStatus.loading)
                      SliverToBoxAdapter(
                        child: _EmptyPostsState(l10n: l10n, theme: theme),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              PostItem(post: postState.posts[index]),
                          childCount: postState.posts.length,
                        ),
                      ),

                    // Loading more indicator
                    if (postState.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // End of list
                    if (postState.postsLastPage &&
                        postState.posts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              l10n.noMorePosts,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.hintColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 100),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool _hasProfileInfo(user) {
    final hasBio = user.bio != null && user.bio!.isNotEmpty;
    final hasInstagram =
        user.instagramUsername != null && user.instagramUsername!.isNotEmpty;
    final hasLikes =
        user.stats?.totalLikesReceived != null &&
        user.stats!.totalLikesReceived > 0;
    final hasRegistrationNumber = user.registrationNumber != null;
    return hasBio || hasInstagram || hasLikes || hasRegistrationNumber;
  }
}

// ─── Helper Widgets (без изменений) ───────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: iconColor ?? theme.iconTheme.color),
      title: Text(
        label,
        style: TextStyle(color: iconColor, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _PostsHeader extends StatelessWidget {
  final PostState postState;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PostsHeader({
    required this.postState,
    required this.l10n,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          l10n.posts,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${postState.totalPostsCount}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.hintColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.l10n,
    required this.theme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorMessage(message),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(onPressed: onRetry, child: Text(l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}

class _UserNotFoundState extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _UserNotFoundState({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 48,
            color: theme.hintColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(l10n.userNotFound, style: TextStyle(color: theme.hintColor)),
        ],
      ),
    );
  }
}

class _EmptyPostsState extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _EmptyPostsState({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: theme.hintColor.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.userHasNoPosts,
            style: TextStyle(fontSize: 15, color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
