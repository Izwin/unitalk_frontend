import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/widget/profile_drawer.dart';
import 'package:unitalk/features/auth/presentation/widget/student_id_card_widget.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_state.dart';
import 'package:unitalk/features/feed/presentation/widget/post_item.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friends_count_button.dart';
import 'package:unitalk/l10n/app_localizations.dart';

import 'widget/verification_status_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ProfilePageContent();
  }
}

class _ProfilePageContent extends StatefulWidget {
  @override
  State<_ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<_ProfilePageContent> {
  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(
      GetPostsEvent(authorId: context.read<AuthBloc>().state.user!.id),
    );
  }

  Future<void> _onRefresh() async {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;

    context.read<PostBloc>().add(GetPostsEvent(authorId: userId));
    context.read<AuthBloc>().add(GetCurrentUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: ProfileDrawer(),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = authState.user;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ─── AppBar ───────────────────────────────
                SliverAppBar(
                  expandedHeight: 0,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(l10n.profile),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: l10n.editProfile,
                      onPressed: () => context.push('/edit-profile'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ],
                ),

                // ─── Profile header section ───────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Студенческая карта
                      StudentIdCardWidget(user: user),
                      const SizedBox(height: 16),

                      // ─── Друзья + запросы ─────────────────
                      Row(
                        children: [
                          Expanded(
                            child: StatCountButton(
                              count: user.friendsCount ?? 0,
                              label: l10n.friends,
                              icon: Icons.people_outlined,
                              onTap: () => context.push('/friends'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: StatCountButton(
                              count: user.pendingRequestsCount ?? 0,
                              label: l10n.friendRequests,
                              icon: Icons.person_add_outlined,
                              highlightThreshold: 1, // автоматически подсветка при count >= 1
                              onTap: () => context.push('/friend-requests'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Verification
                      VerificationStatusWidget(user: user),
                      const SizedBox(height: 24),

                      // ─── Posts header ─────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.myPosts,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          BlocBuilder<PostBloc, PostState>(
                            builder: (context, state) {
                              return Text(
                                l10n.postsCount(state.posts.length),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),

                // ─── Posts List ───────────────────────────
                BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) {
                    if (state.status == PostStatus.loading &&
                        state.posts.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (state.posts.isEmpty) {
                      return SliverFillRemaining(
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
                                l10n.noPostsYet,
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
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return PostItem(post: state.posts[index]);
                        },
                        childCount: state.posts.length,
                      ),
                    );
                  },
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Кнопка запросов в друзья (под карту, рядом с FriendsCountButton) ─────
class _FriendRequestsButton extends StatelessWidget {
  final int pendingCount;

  const _FriendRequestsButton({Key? key, required this.pendingCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => context.push('/friend-requests'),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: pendingCount > 0
              ? theme.colorScheme.errorContainer.withOpacity(0.25)
              : theme.colorScheme.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: pendingCount > 0
                ? theme.colorScheme.error.withOpacity(0.25)
                : theme.dividerColor.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 18,
                  color: pendingCount > 0
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
                if (pendingCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        pendingCount > 9 ? '9+' : '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),

            // Label + count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$pendingCount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: pendingCount > 0
                          ? theme.colorScheme.error
                          : null,
                    ),
                  ),
                  Text(
                    l10n.friendRequests,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}