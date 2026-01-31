import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_event.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_state.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friend_list_tile.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({Key? key}) : super(key: key);

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _incomingScrollController = ScrollController();
  final ScrollController _outgoingScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _incomingScrollController.addListener(_onIncomingScroll);
    _outgoingScrollController.addListener(_onOutgoingScroll);

    // Загружаем входящие запросы при открытии
    context.read<FriendshipBloc>().add(LoadIncomingRequestsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _incomingScrollController.dispose();
    _outgoingScrollController.dispose();
    super.dispose();
  }

  void _onIncomingScroll() {
    if (_isBottomIncoming) {
      final state = context.read<FriendshipBloc>().state;
      if (state.incomingHasMore && !state.isLoadingMore) {
        context.read<FriendshipBloc>().add(LoadIncomingRequestsEvent(loadMore: true));
      }
    }
  }

  void _onOutgoingScroll() {
    if (_isBottomOutgoing) {
      final state = context.read<FriendshipBloc>().state;
      if (state.outgoingHasMore && !state.isLoadingMore) {
        context.read<FriendshipBloc>().add(LoadOutgoingRequestsEvent(loadMore: true));
      }
    }
  }

  bool get _isBottomIncoming {
    if (!_incomingScrollController.hasClients) return false;
    final maxScroll = _incomingScrollController.position.maxScrollExtent;
    final currentScroll = _incomingScrollController.offset;
    return currentScroll >= (maxScroll * 0.85);
  }

  bool get _isBottomOutgoing {
    if (!_outgoingScrollController.hasClients) return false;
    final maxScroll = _outgoingScrollController.position.maxScrollExtent;
    final currentScroll = _outgoingScrollController.offset;
    return currentScroll >= (maxScroll * 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: theme.scaffoldBackgroundColor,
        title: Text(
          l10n.friendRequests,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          indicatorColor: theme.primaryColor,
          onTap: (index) {
            if (index == 0) {
              context.read<FriendshipBloc>().add(LoadIncomingRequestsEvent());
            } else {
              context.read<FriendshipBloc>().add(LoadOutgoingRequestsEvent());
            }
          },
          tabs: [
            Tab(text: l10n.incoming),
            Tab(text: l10n.outgoing),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomingTab(l10n, theme),
          _buildOutgoingTab(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildIncomingTab(AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state.status == FriendshipStateStatus.loading && state.incomingRequests.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primaryColor,
            ),
          );
        }

        if (state.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: state.errorMessage ?? l10n.anErrorOccurred,
            subtitle: null,
          );
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
          child: ListView.separated(
            controller: _incomingScrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.incomingRequests.length + (state.incomingHasMore ? 1 : 0),
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.dividerColor.withOpacity(0.1),
              indent: 76,
            ),
            itemBuilder: (context, index) {
              if (index >= state.incomingRequests.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                );
              }

              final request = state.incomingRequests[index];
              return FriendListTile(
                user: request.user,
                subtitle: timeago.format(request.requestedAt),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, size: 20),
                      onPressed: () {
                        context.read<FriendshipBloc>().add(
                          AcceptFriendRequestEvent(request.friendshipId),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        context.read<FriendshipBloc>().add(
                          RejectFriendRequestEvent(request.friendshipId),
                        );
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: theme.cardColor,
                        foregroundColor: theme.textTheme.bodyMedium?.color,
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOutgoingTab(AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state.status == FriendshipStateStatus.loading && state.outgoingRequests.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primaryColor,
            ),
          );
        }

        if (state.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: state.errorMessage ?? l10n.anErrorOccurred,
            subtitle: null,
          );
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
          child: ListView.separated(
            controller: _outgoingScrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.outgoingRequests.length + (state.outgoingHasMore ? 1 : 0),
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: theme.dividerColor.withOpacity(0.1),
              indent: 76,
            ),
            itemBuilder: (context, index) {
              if (index >= state.outgoingRequests.length) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                );
              }

              final request = state.outgoingRequests[index];
              return FriendListTile(
                user: request.user,
                subtitle: '${l10n.sentAt} ${timeago.format(request.requestedAt)}',
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    context.read<FriendshipBloc>().add(
                      RemoveFriendshipEvent(request.friendshipId),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: theme.cardColor,
                    foregroundColor: theme.textTheme.bodyMedium?.color,
                    side: BorderSide(color: theme.dividerColor),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}