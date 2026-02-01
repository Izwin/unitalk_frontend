import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/ui/common/report_dialog.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
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
import 'package:unitalk/features/auth/presentation/widget/student_id_card_widget.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_event.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friends_count_button.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friendship_button.dart';
import 'package:unitalk/features/report/data/model/report_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

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

    context.read<UserProfileBloc>().add(GetUserProfileEvent(widget.userId));
    context.read<PostBloc>().add(
      GetPostsEvent(authorId: widget.userId, page: 1, limit: 20),
    );
    context.read<FriendshipBloc>().add(LoadFriendshipStatusEvent(widget.userId));
    context.read<BlockBloc>().add(CheckBlockStatusEvent(widget.userId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<UserProfileBloc>().add(GetUserProfileEvent(widget.userId));
    context.read<BlockBloc>().add(CheckBlockStatusEvent(widget.userId));
    context.read<PostBloc>().add(
      GetPostsEvent(authorId: widget.userId, page: 1, limit: 20),
    );
    context.read<FriendshipBloc>().add(LoadFriendshipStatusEvent(widget.userId));


    await context.read<UserProfileBloc>().stream.firstWhere(
          (state) => !state.isLoading,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final postState = context.read<PostBloc>().state;

      if (!postState.postsLastPage && !postState.isLoadingMore) {
        context.read<PostBloc>().add(
          GetPostsEvent(
            authorId: widget.userId,
            page: postState.postsPage + 1,
            limit: 20,
          ),
        );
      }
    }
  }

  // ─── Модерационное меню (3 точки) ─────────────────────────────
  void _showModerationMenu(BuildContext context, UserModel user) {
    final l10n = AppLocalizations.of(context)!;
    final blockStatus = user.blockStatus;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Block / Unblock
            if (blockStatus?.isBlocked == true)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text(l10n.unblockUser),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showUnblockDialog(context, widget.userId, user);
                },
              )
            else if (blockStatus?.isBlockedBy != true)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text(l10n.blockUser),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showBlockDialog(context, widget.userId, user);
                },
              ),

            // Report
            if (blockStatus?.isBlockedBy != true)
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(l10n.report),
                onTap: () {
                  Navigator.pop(sheetContext);
                  ReportDialog.show(
                    context,
                    targetType: ReportTargetType.user,
                    targetId: widget.userId,
                  );
                },
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showBlockDialog(BuildContext context, String userId, UserModel user) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                SnackBar(content: Text(l10n.userBlocked)),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.block),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(
      BuildContext context,
      String userId,
      UserModel user,
      ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                SnackBar(content: Text(l10n.userUnblocked)),
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, profileState) {
          // ─── Loading ──────────────────────────────────
          if (profileState.isLoading && profileState.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // ─── Error ────────────────────────────────────
          if (profileState.errorMessage != null &&
              profileState.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.errorMessage(profileState.errorMessage ?? ''),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserProfileBloc>().add(
                        GetUserProfileEvent(widget.userId),
                      );
                    },
                    child: Text(l10n.tryAgain),
                  ),
                ],
              ),
            );
          }

          // ─── User not found ───────────────────────────
          final user = profileState.user;
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.userNotFound,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          // ─── Main content ─────────────────────────────
          return BlocBuilder<PostBloc, PostState>(
            builder: (context, postState) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                color: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ─── AppBar ─────────────────────────
                    SliverAppBar(
                      expandedHeight: 0,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(l10n.profile),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      actions: [
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) {
                            if (authState.user?.id == widget.userId) {
                              return const SizedBox.shrink();
                            }
                            return IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () =>
                                  _showModerationMenu(context, user),
                            );
                          },
                        ),
                      ],
                    ),

                    // ─── Profile header ───────────────
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Студенческая карта
                          StudentIdCardWidget(user: user),
                          const SizedBox(height: 16),

                          // ─── Друзья ─────────────────
                          if (user.friendsCount != null &&
                              user.friendsCount! > 0)
                            StatCountButton(
                              count: profileState.user?.friendsCount ?? 0,
                              label: l10n.friends,
                              icon: Icons.people_outlined,
                              onTap: () => context.push('/user/${ profileState.user?.id}/friends'),
                            ),

                          const SizedBox(height: 14),

                          // ─── Кнопка дружбы ──────────
                          FriendshipButton(userId: widget.userId),
                          const SizedBox(height: 24),

                          // ─── Posts header ───────────
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.posts,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n.postsCount(postState.totalPostsCount),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),

                    // ─── Posts List ─────────────────────
                    if (postState.posts.isEmpty && postState.status != PostStatus.loading)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.userHasNoPosts,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return PostItem(post: postState.posts[index]);
                          },
                          childCount: postState.posts.length,
                        ),
                      ),

                    // ─── Loading more ─────────────────
                    if (postState.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),

                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 40),
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
}