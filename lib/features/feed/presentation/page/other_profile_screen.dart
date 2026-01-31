import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:unitalk/features/report/presentation/user_moderation_actions.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;

  const OtherUserProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

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

    // Загружаем профиль пользователя
    context.read<UserProfileBloc>().add(GetUserProfileEvent(widget.userId));

    // Загружаем посты пользователя через PostBloc
    context.read<PostBloc>().add(GetPostsEvent(
      authorId: widget.userId,
      page: 1,
      limit: 20,
    ));

    // Проверяем статус блокировки
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

    // Перезагружаем посты
    context.read<PostBloc>().add(GetPostsEvent(
      authorId: widget.userId,
      page: 1,
      limit: 20,
    ));

    await context.read<UserProfileBloc>().stream.firstWhere(
          (state) => !state.isLoading,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final postState = context.read<PostBloc>().state;

      // Проверяем, что посты не закончились и не идет загрузка
      if (!postState.postsLastPage && !postState.isLoadingMore) {
        context.read<PostBloc>().add(GetPostsEvent(
          authorId: widget.userId,
          page: postState.postsPage + 1,
          limit: 20,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, profileState) {
          if (profileState.isLoading && profileState.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileState.errorMessage != null && profileState.user == null) {
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
                      context
                          .read<UserProfileBloc>()
                          .add(GetUserProfileEvent(widget.userId));
                    },
                    child: Text(l10n.tryAgain),
                  ),
                ],
              ),
            );
          }

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
                    // App Bar
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
                    ),

                    // Profile Content
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Student Card
                          StudentIdCardWidget(user: user),
                          const SizedBox(height: 24),

                          // Moderation Actions
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              final currentUserId = authState.user?.id;
                              final isOwnProfile = currentUserId == widget.userId;

                              if (isOwnProfile) {
                                return const SizedBox.shrink();
                              }

                              return BlocConsumer<BlockBloc, BlockState>(
                                listener: (context, blockState) {
                                  context.read<UserProfileBloc>().add(
                                      GetUserProfileEvent(widget.userId));
                                },
                                builder: (context, blockState) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: UserModerationActions(
                                      userId: widget.userId,
                                      blockStatus: user.blockStatus,
                                      userName: '${user.firstName} ${user.lastName}',
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Posts Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.posts,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n.postsCount(postState.posts.length),
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

                    // Posts List
                    if (postState.posts.isEmpty && !postState.isLoading)
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
                            final post = postState.posts[index];
                            return PostItem(post: post);
                          },
                          childCount: postState.posts.length,
                        ),
                      ),

                    // Loading More Indicator
                    if (postState.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),

                    // Bottom Padding
                    const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
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