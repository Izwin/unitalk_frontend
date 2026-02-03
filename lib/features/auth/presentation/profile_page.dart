// lib/features/auth/presentation/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/widget/badges_section.dart';
import 'package:unitalk/features/auth/presentation/widget/profile_drawer.dart';
import 'package:unitalk/features/auth/presentation/widget/profile_info_section.dart';
import 'package:unitalk/features/auth/presentation/widget/student_id_card_widget.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_state.dart';
import 'package:unitalk/features/feed/presentation/widget/post_item.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friends_count_button.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friends_stat_button.dart';
import 'package:unitalk/l10n/app_localizations.dart';

import 'widget/verification_status_widget.dart';

const double _kDrawerBreakpoint = 600.0;
const double _kDrawerWidth = 300.0;
const int _kPostsLimit = 20;

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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  void _loadInitialData() {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId != null) {
      context.read<PostBloc>().add(
        GetPostsEvent(authorId: userId, page: 1, limit: _kPostsLimit),
      );
    }
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
    final threshold = maxScroll * 0.9; // Load more at 90%

    if (currentScroll >= threshold) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;

    final postState = context.read<PostBloc>().state;
    if (!postState.postsLastPage && !postState.isLoadingMore) {
      context.read<PostBloc>().add(
        GetPostsEvent(
          authorId: userId,
          page: postState.postsPage,
          limit: _kPostsLimit,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;

    context.read<PostBloc>().add(
      GetPostsEvent(authorId: userId, page: 1, limit: _kPostsLimit),
    );
    context.read<AuthBloc>().add(GetCurrentUserEvent());

    // Wait for loading to complete
    await Future.any([
      context.read<PostBloc>().stream.firstWhere(
            (state) => state.status != PostStatus.loading,
      ),
      Future.delayed(const Duration(seconds: 3)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= _kDrawerBreakpoint;

    if (isWide) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: _kDrawerWidth, child: ProfileDrawer()),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            Expanded(child: _buildContent(context, isWide: true)),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: ProfileDrawer(),
      body: _buildContent(context, isWide: false),
    );
  }

  Widget _buildContent(BuildContext context, {required bool isWide}) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── AppBar ─────────────────────────────────────
              SliverAppBar(
                pinned: false,
                floating: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                title: Text(
                  l10n.profile,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 22),
                    tooltip: l10n.editProfile,
                    onPressed: () => context.push('/edit-profile'),
                  ),
                  if (!isWide)
                    IconButton(
                      icon: const Icon(Icons.menu, size: 22),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  const SizedBox(width: 4),
                ],
              ),

              // ─── Profile Content ────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Student Card
                    StudentIdCardWidget(user: user),
                    const SizedBox(height: 24),

                    // Bio, Instagram, Likes, Registration Number
                    ProfileInfoSection(user: user),
                    if (_hasProfileInfo(user)) const SizedBox(height: 10),

                    // Stats Row
                    FriendsStatButton(
                      friendsCount: user.friendsCount ?? 0,
                      pendingRequestsCount: user.pendingRequestsCount ?? 0,
                      onTap: () => context.push('/friends'),
                    ),
                    const SizedBox(height: 12),

                    // Badges
                    BadgesSection(user: user),
                    const SizedBox(height: 12),

                    // Verification
                    VerificationStatusWidget(user: user),
                    const SizedBox(height: 32),

                    // Posts Header
                    BlocBuilder<PostBloc, PostState>(
                      builder: (context, postState) {
                        return _PostsHeader(
                          postState: postState,
                          l10n: l10n,
                          theme: theme,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              // ─── Posts ──────────────────────────────────────
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  // Initial loading
                  if (state.status == PostStatus.loading && state.posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  // Empty state
                  if (state.posts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyPostsPlaceholder(l10n: l10n, theme: theme),
                    );
                  }

                  // Posts list
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

              // ─── Loading More Indicator ─────────────────────
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state.isLoadingMore) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    );
                  }

                  // End of list indicator
                  if (state.postsLastPage && state.posts.isNotEmpty) {
                    return SliverToBoxAdapter(
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
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),

              // Bottom padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        );
      },
    );
  }

  bool _hasProfileInfo(user) {
    final hasBio = user.bio != null && user.bio!.isNotEmpty;
    final hasInstagram = user.instagramUsername != null && user.instagramUsername!.isNotEmpty;
    final hasLikes = user.stats?.totalLikesReceived != null && user.stats!.totalLikesReceived > 0;
    final hasRegistrationNumber = user.registrationNumber != null;
    return hasBio || hasInstagram || hasLikes || hasRegistrationNumber;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// POSTS HEADER
// ═══════════════════════════════════════════════════════════════════════════

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
          l10n.myPosts,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
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

// ═══════════════════════════════════════════════════════════════════════════
// EMPTY POSTS PLACEHOLDER
// ═══════════════════════════════════════════════════════════════════════════

class _EmptyPostsPlaceholder extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeData theme;

  const _EmptyPostsPlaceholder({required this.l10n, required this.theme});

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
            l10n.noPostsYet,
            style: TextStyle(
              fontSize: 15,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}