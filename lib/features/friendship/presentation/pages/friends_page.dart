// lib/features/friendship/presentation/pages/friends_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_event.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_state.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friend_list_tile.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

enum FriendsPageTab { friends, incoming, outgoing }

class FriendsPage extends StatefulWidget {
  /// Если null - показываем свой профиль с табами запросов
  /// Если указан userId другого пользователя - только список друзей
  final String? userId;

  /// Начальный таб (только для своего профиля)
  final FriendsPageTab initialTab;

  const FriendsPage({
    Key? key,
    this.userId,
    this.initialTab = FriendsPageTab.friends,
  }) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final ScrollController _friendsScrollController = ScrollController();
  final ScrollController _incomingScrollController = ScrollController();
  final ScrollController _outgoingScrollController = ScrollController();

  bool get _isOwnProfile {
    final currentUserId = context.read<AuthBloc>().state.user?.id;
    return widget.userId == null || widget.userId == currentUserId;
  }

  @override
  void initState() {
    super.initState();

    if (_isOwnProfile) {
      _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: widget.initialTab.index,
      );
      _tabController!.addListener(_onTabChanged);
    }

    _friendsScrollController.addListener(() => _onScroll(_ScrollType.friends));
    _incomingScrollController.addListener(() => _onScroll(_ScrollType.incoming));
    _outgoingScrollController.addListener(() => _onScroll(_ScrollType.outgoing));

    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<FriendshipBloc>().add(LoadFriendsListEvent(userId: widget.userId));

    if (_isOwnProfile && widget.initialTab == FriendsPageTab.incoming) {
      context.read<FriendshipBloc>().add(LoadIncomingRequestsEvent());
    } else if (_isOwnProfile && widget.initialTab == FriendsPageTab.outgoing) {
      context.read<FriendshipBloc>().add(LoadOutgoingRequestsEvent());
    }
  }

  void _onTabChanged() {
    if (_tabController == null || !_tabController!.indexIsChanging) return;

    switch (_tabController!.index) {
      case 0:
        context.read<FriendshipBloc>().add(LoadFriendsListEvent(userId: widget.userId));
        break;
      case 1:
        context.read<FriendshipBloc>().add(LoadIncomingRequestsEvent());
        break;
      case 2:
        context.read<FriendshipBloc>().add(LoadOutgoingRequestsEvent());
        break;
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _friendsScrollController.dispose();
    _incomingScrollController.dispose();
    _outgoingScrollController.dispose();
    super.dispose();
  }

  void _onScroll(_ScrollType type) {
    final controller = switch (type) {
      _ScrollType.friends => _friendsScrollController,
      _ScrollType.incoming => _incomingScrollController,
      _ScrollType.outgoing => _outgoingScrollController,
    };

    if (!controller.hasClients) return;

    final maxScroll = controller.position.maxScrollExtent;
    final currentScroll = controller.offset;

    if (currentScroll < maxScroll * 0.85) return;

    final state = context.read<FriendshipBloc>().state;
    if (state.isLoadingMore) return;

    switch (type) {
      case _ScrollType.friends:
        if (state.friendsHasMore) {
          context.read<FriendshipBloc>().add(
            LoadFriendsListEvent(loadMore: true, userId: widget.userId),
          );
        }
        break;
      case _ScrollType.incoming:
        if (state.incomingHasMore) {
          context.read<FriendshipBloc>().add(LoadIncomingRequestsEvent(loadMore: true));
        }
        break;
      case _ScrollType.outgoing:
        if (state.outgoingHasMore) {
          context.read<FriendshipBloc>().add(LoadOutgoingRequestsEvent(loadMore: true));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Для чужого профиля - простой список друзей
    if (!_isOwnProfile) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme, l10n.friends),
        body: _FriendsListView(
          scrollController: _friendsScrollController,
          isOwnProfile: false,
        ),
      );
    }

    // Для своего профиля - табы
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.friends,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(text: l10n.friends),
            _TabWithBadge(
              label: l10n.incoming,
              badgeSelector: (state) => state.incomingRequests.length,
            ),
            Tab(text: l10n.outgoing),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FriendsListView(
            scrollController: _friendsScrollController,
            isOwnProfile: true,
          ),
          _IncomingRequestsView(scrollController: _incomingScrollController),
          _OutgoingRequestsView(scrollController: _outgoingScrollController),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, String title) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title,
        style: TextStyle(
          color: theme.textTheme.titleLarge?.color,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum _ScrollType { friends, incoming, outgoing }

// ═══════════════════════════════════════════════════════════════════════════
// TAB WITH BADGE
// ═══════════════════════════════════════════════════════════════════════════

class _TabWithBadge extends StatelessWidget {
  final String label;
  final int Function(FriendshipState) badgeSelector;

  const _TabWithBadge({
    required this.label,
    required this.badgeSelector,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        final count = badgeSelector(state);

        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FRIENDS LIST VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _FriendsListView extends StatelessWidget {
  final ScrollController scrollController;
  final bool isOwnProfile;

  const _FriendsListView({
    required this.scrollController,
    required this.isOwnProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state.status == FriendshipStateStatus.loading && state.friends.isEmpty) {
          return const _LoadingIndicator();
        }

        if (state.hasError) {
          return _ErrorState(message: state.errorMessage, l10n: l10n);
        }

        if (state.friends.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.people_outline,
            title: l10n.noFriendsYet,
            subtitle: isOwnProfile ? l10n.startAddingFriends : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<FriendshipBloc>().add(LoadFriendsListEvent());
          },
          child: _UserListView(
            scrollController: scrollController,
            itemCount: state.friends.length,
            hasMore: state.friendsHasMore,
            itemBuilder: (context, index) => FriendListTile(user: state.friends[index]),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// INCOMING REQUESTS VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _IncomingRequestsView extends StatelessWidget {
  final ScrollController scrollController;

  const _IncomingRequestsView({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state.status == FriendshipStateStatus.loading && state.incomingRequests.isEmpty) {
          return const _LoadingIndicator();
        }

        if (state.hasError) {
          return _ErrorState(message: state.errorMessage, l10n: l10n);
        }

        if (state.incomingRequests.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.inbox_outlined,
            title: l10n.noIncomingRequests,
            subtitle: l10n.noIncomingRequestsSubtitle,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<FriendshipBloc>().add(LoadIncomingRequestsEvent());
          },
          child: _UserListView(
            scrollController: scrollController,
            itemCount: state.incomingRequests.length,
            hasMore: state.incomingHasMore,
            itemBuilder: (context, index) {
              final request = state.incomingRequests[index];
              return FriendListTile(
                user: request.user,
                subtitle: timeago.format(request.requestedAt),
                trailing: _IncomingRequestActions(
                  friendshipId: request.friendshipId,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _IncomingRequestActions extends StatelessWidget {
  final String friendshipId;

  const _IncomingRequestActions({required this.friendshipId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.check_rounded,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          onTap: () {
            context.read<FriendshipBloc>().add(AcceptFriendRequestEvent(friendshipId));
          },
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.close_rounded,
          backgroundColor: theme.colorScheme.surfaceVariant,
          foregroundColor: theme.hintColor,
          onTap: () {
            context.read<FriendshipBloc>().add(RejectFriendRequestEvent(friendshipId));
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OUTGOING REQUESTS VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _OutgoingRequestsView extends StatelessWidget {
  final ScrollController scrollController;

  const _OutgoingRequestsView({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state.status == FriendshipStateStatus.loading && state.outgoingRequests.isEmpty) {
          return const _LoadingIndicator();
        }

        if (state.hasError) {
          return _ErrorState(message: state.errorMessage, l10n: l10n);
        }

        if (state.outgoingRequests.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.send_outlined,
            title: l10n.noOutgoingRequests,
            subtitle: l10n.noOutgoingRequestsSubtitle,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<FriendshipBloc>().add(LoadOutgoingRequestsEvent());
          },
          child: _UserListView(
            scrollController: scrollController,
            itemCount: state.outgoingRequests.length,
            hasMore: state.outgoingHasMore,
            itemBuilder: (context, index) {
              final request = state.outgoingRequests[index];
              return FriendListTile(
                user: request.user,
                subtitle: '${l10n.sentAt} ${timeago.format(request.requestedAt)}',
                trailing: _ActionButton(
                  icon: Icons.close_rounded,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  foregroundColor: Theme.of(context).hintColor,
                  onTap: () {
                    context.read<FriendshipBloc>().add(
                      RemoveFriendshipEvent(request.friendshipId),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _UserListView extends StatelessWidget {
  final ScrollController scrollController;
  final int itemCount;
  final bool hasMore;
  final Widget Function(BuildContext, int) itemBuilder;

  const _UserListView({
    required this.scrollController,
    required this.itemCount,
    required this.hasMore,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount + (hasMore ? 1 : 0),
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: theme.dividerColor.withOpacity(0.1),
        indent: 76,
      ),
      itemBuilder: (context, index) {
        if (index >= itemCount) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: _LoadingIndicator(size: 24),
          );
        }
        return itemBuilder(context, index);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: foregroundColor),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final double size;

  const _LoadingIndicator({this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final AppLocalizations l10n;

  const _ErrorState({this.message, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: message ?? l10n.anErrorOccurred,
      subtitle: null,
    );
  }
}