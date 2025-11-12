// features/feed/presentation/pages/feed_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/core/ui/common/university_selection_sheet.dart';
import 'package:unitalk/core/ui/common/unread_bage.dart';
import 'package:unitalk/core/ui/widgets/default_text_widget.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/widget/select_university_widget.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_state.dart';
import 'package:unitalk/features/feed/presentation/bloc/announcement/announcement_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/announcement/announcement_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/announcement/announcement_state.dart';
import 'package:unitalk/features/feed/presentation/widget/feed_filter_sheet.dart';
import 'package:unitalk/features/feed/presentation/widget/post_item.dart';
import 'package:unitalk/features/feed/presentation/widget/announcement_item.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_state.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';
import 'package:unitalk/l10n/app_localizations.dart';

import '../../../../core/ui/common/bottom_sheet_header.dart' show BottomSheetHeader;

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();
  UniversityModel? _selectedUniversity;
  bool _isLoadingMore = false;
  FeedFilters _filters = FeedFilters.empty();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState.user?.university != null) {
        setState(() {
          _selectedUniversity = authState.user!.university;
        });
        _loadPosts();
        _loadAnnouncements();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPosts({int page = 1}) {
    if (_selectedUniversity != null) {
      context.read<PostBloc>().add(
        GetPostsEvent(
          universityId: _selectedUniversity!.id,
          page: page,
          limit: 20,
          sortBy: _filters.sortBy,
          sector: _filters.sector?.code,
          facultyId: _filters.facultyId,
        ),
      );
    }
  }

  void _loadAnnouncements() {
    context.read<AnnouncementBloc>().add(GetAnnouncementsEvent());
  }

  Future<void> _onRefresh() async {
    if (_selectedUniversity == null) return;

    // Перезагружаем первую страницу постов и объявления
    _loadPosts(page: 1);
    _loadAnnouncements();

    // Ждем завершения загрузки
    await context.read<PostBloc>().stream.firstWhere(
          (state) => state.status != PostStatus.loading,
    );
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final postState = context.read<PostBloc>().state;
      if (!postState.postsLastPage && postState.status != PostStatus.loading) {
        setState(() => _isLoadingMore = true);
        _loadPosts(page: postState.postsPage);
      }
    }
  }

  void _navigateToNotifications() {
    context.push('/notifications');
  }

  void _showCreatePost() {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    final userUniversity = authState.user?.university;

    if (_selectedUniversity?.id != userUniversity?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.canOnlyPostInOwnUniversity),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.push('/create-post');
  }

  void _showUniversitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UniversitySelectionSheet(
        currentUniversity: _selectedUniversity,
        onUniversitySelected: (university) {
          setState(() {
            _selectedUniversity = university;
          });
          _loadPosts();
          _loadAnnouncements();
          context.pop();
        },
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД: Улучшенная логика объединения постов и объявлений
  List<dynamic> _mergePostsAndAnnouncements(
      List posts,
      List announcements,
      ) {
    if (announcements.isEmpty) return posts;

    final List<dynamic> merged = [];

    // Всегда вставляем первое объявление перед постами
    merged.add(announcements[0]);

    // Если только одно объявление — и дальше просто посты
    if (announcements.length == 1) {
      merged.addAll(posts);
      return merged;
    }

    int announcementIndex = 1; // начинаем со второго объявления
    const minPostsBetween = 5;
    int postsSinceLastAnnouncement = 0;

    for (var post in posts) {
      merged.add(post);
      postsSinceLastAnnouncement++;

      if (postsSinceLastAnnouncement >= minPostsBetween &&
          announcementIndex < announcements.length) {
        merged.add(announcements[announcementIndex]);
        announcementIndex++;
        postsSinceLastAnnouncement = 0;
      }
    }

    // Если остались объявления — добавляем их в конец
    while (announcementIndex < announcements.length) {
      merged.add(announcements[announcementIndex]);
      announcementIndex++;
    }

    return merged;
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.read<LocaleCubit>().state.languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar with notifications
            SliverAppBar(
              floating: true,
              backgroundColor: theme.colorScheme.surface,
              elevation: 0,
              title: Text(
                'UniTalky',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Row(
                  children: [
                    FilterButton(
                      activeFiltersCount: _filters.activeFiltersCount,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FeedFilterSheet(
                            currentFilters: _filters,
                            university: _selectedUniversity,
                            onApply: (newFilters) {
                              setState(() => _filters = newFilters);
                              _loadPosts();
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    BlocBuilder<NotificationBloc, NotificationState>(
                      builder: (context, state) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications_outlined),
                              onPressed: _navigateToNotifications,
                            ),
                            if (state.unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: UnreadBadge(count: state.unreadCount),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(width: 8),
              ],
            ),

            // University Info Card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _buildUniversityCard(theme, locale, l10n),
              ),
            ),

            if (_filters.hasActiveFilters)
              SliverToBoxAdapter(
                child: ActiveFiltersBar(
                  filters: _filters,
                  onFilterRemoved: (newFilters) {
                    setState(() => _filters = newFilters);
                    _loadPosts();
                  },
                  onClearAll: () {
                    setState(() => _filters = FeedFilters.empty());
                    _loadPosts();
                  },
                ),
              ),

            BlocBuilder<AnnouncementBloc, AnnouncementState>(
              builder: (context, announcementState) {
                return BlocConsumer<PostBloc, PostState>(
                  listener: (context, state) {
                    if (state.status == PostStatus.success) {
                      setState(() => _isLoadingMore = false);
                    }
                  },
                  builder: (context, postState) {
                    if (postState.status == PostStatus.loading && postState.posts.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (postState.status == PostStatus.failure) {
                      return SliverFillRemaining(
                        child: ErrorStateWidget(
                          message: postState.errorMessage ?? l10n.failedToLoadPosts,
                          onRetry: () {
                            _loadPosts();
                            _loadAnnouncements();
                          },
                        ),
                      );
                    }

                    if (postState.posts.isEmpty) {
                      return SliverFillRemaining(
                        child: EmptyStateWidget(
                          icon: Icons.post_add_rounded,
                          title: l10n.noPostsYet,
                          subtitle: l10n.beTheFirstToShare,
                        ),
                      );
                    }

                    // Объединяем посты и объявления
                    final mergedItems = _mergePostsAndAnnouncements(
                      postState.posts,
                      announcementState.announcements,
                    );

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index == mergedItems.length) {
                            if (_isLoadingMore) {
                              return Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return SizedBox.shrink();
                          }

                          final item = mergedItems[index];

                          // Проверяем тип элемента
                          if (item.runtimeType.toString().contains('AnnouncementModel')) {
                            return AnnouncementItem(
                              announcement: item,
                              onViewed: () {
                                context.read<AnnouncementBloc>().add(
                                  MarkAnnouncementViewedEvent(item.id),
                                );
                              },
                              onClicked: () {
                                context.read<AnnouncementBloc>().add(
                                  MarkAnnouncementClickedEvent(item.id),
                                );
                              },
                            );
                          } else {
                            return PostItem(post: item);
                          }
                        },
                        childCount: mergedItems.length + (_isLoadingMore ? 1 : 0),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final canPost =
              _selectedUniversity?.id == authState.user?.university?.id;
          if (!canPost) {
            return SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: _showCreatePost,
            backgroundColor: canPost
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainer,
            icon: Icon(Icons.add_rounded),
            label: Text(l10n.newPost),
          );
        },
      ),
    );
  }

  Widget _buildUniversityCard(ThemeData theme, String locale, AppLocalizations l10n) {
    if (_selectedUniversity == null) {
      return SizedBox.shrink();
    }

    final authState = context.read<AuthBloc>().state;
    final isOwnUniversity =
        _selectedUniversity?.id == authState.user?.university?.id;

    return InkWell(
      onTap: _showUniversitySelector,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: _selectedUniversity!.logoUrl != null
                    ? CachedNetworkImage(
                  imageUrl: _selectedUniversity!.logoUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _buildPlaceholder(theme),
                  placeholder: (_, __) => _buildPlaceholder(theme),
                )
                    : _buildPlaceholder(theme),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row with icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Spacer(),
                        if (isOwnUniversity)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  l10n.yourUniversity,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // University name
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _selectedUniversity!.getLocalizedName(locale),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    // Change button
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.tapToChangeUniversity,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.school_rounded,
          color: theme.colorScheme.primary,
          size: 64,
        ),
      ),
    );
  }
}