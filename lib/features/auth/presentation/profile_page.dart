// features/auth/presentation/pages/profile_page.dart

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

const double _kDrawerBreakpoint = 600.0;
const double _kDrawerWidth = 300.0;

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
  late final ScrollController _scrollController;  // ✅ Добавлен

  String? get _currentUserId => context.read<AuthBloc>().state.user?.id;

  @override
  void initState() {
    super.initState();

    // ✅ Инициализация ScrollController
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Загрузка первой страницы
    _loadPosts(page: 1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Обработка скролла
  void _onScroll() {
    if (_isBottom) {
      _loadMorePosts();
    }
  }

  // ✅ Проверка достижения конца списка
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Загружаем когда до конца осталось 200 пикселей
    return currentScroll >= (maxScroll - 200);
  }

  // ✅ Загрузка постов
  void _loadPosts({required int page}) {
    final userId = _currentUserId;
    if (userId == null) return;

    context.read<PostBloc>().add(
      GetPostsEvent(
        authorId: userId,
        page: page,
      ),
    );
  }

  // ✅ Загрузка следующей страницы
  void _loadMorePosts() {
    final postState = context.read<PostBloc>().state;

    // Не загружаем если:
    // - уже идёт загрузка
    // - достигли последней страницы
    if (postState.status == PostStatus.loading ||
        postState.isLoadingMore ||
        postState.postsLastPage) {
      return;
    }

    final userId = _currentUserId;
    if (userId == null) return;

    print('📄 Loading page ${postState.postsPage}'); // Debug

    context.read<PostBloc>().add(
      GetPostsEvent(
        authorId: userId,
        page: postState.postsPage,
      ),
    );
  }

  Future<void> _onRefresh() async {
    final userId = _currentUserId;
    if (userId == null) return;

    context.read<PostBloc>().add(GetPostsEvent(authorId: userId, page: 1));
    context.read<AuthBloc>().add(GetCurrentUserEvent());
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
            SizedBox(
              width: _kDrawerWidth,
              child: ProfileDrawer(),
            ),
            VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: _buildContent(context, isWide: true),
            ),
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

    return BlocBuilder<AuthBloc, AuthState>(
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
            controller: _scrollController,  // ✅ Подключаем контроллер
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── AppBar ─────────────────────────────────────
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
                  if (!isWide)
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                ],
              ),

              // ─── Profile header section ───────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    StudentIdCardWidget(user: user),
                    const SizedBox(height: 16),

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
                            highlightThreshold: 1,
                            onTap: () => context.push('/friend-requests'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    VerificationStatusWidget(user: user),
                    const SizedBox(height: 24),

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
                              l10n.postsCount(state.totalPostsCount),
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

              // ─── Posts List ─────────────────────────────────────
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
                        // ✅ Показываем индикатор загрузки в конце списка
                        if (index == state.posts.length) {
                          return _buildLoadingIndicator(state);
                        }
                        return PostItem(post: state.posts[index]);
                      },
                      // ✅ +1 для индикатора загрузки
                      childCount: state.posts.length + (state.postsLastPage ? 0 : 1),
                    ),
                  );
                },
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        );
      },
    );
  }

  // ✅ Индикатор загрузки внизу списка
  Widget _buildLoadingIndicator(PostState state) {
    if (state.postsLastPage) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: state.status == PostStatus.loading || state.isLoadingMore
          ? const CircularProgressIndicator()
          : TextButton(
        onPressed: _loadMorePosts,
        child: const Text('Загрузить ещё'),
      ),
    );
  }
}