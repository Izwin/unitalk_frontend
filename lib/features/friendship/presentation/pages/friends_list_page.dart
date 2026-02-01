import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_event.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_state.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friend_list_tile.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class FriendsListPage extends StatefulWidget {
  final String? userId;

  const FriendsListPage({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    print('sadf');
    context.read<FriendshipBloc>().add(LoadFriendsListEvent(userId: widget.userId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<FriendshipBloc>().state;
      if (state.friendsHasMore && !state.isLoadingMore) {
        context.read<FriendshipBloc>().add(
          LoadFriendsListEvent(loadMore: true, userId: widget.userId),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;


    final isOwnProfile =
        widget.userId == null || context.read<AuthBloc>().state.user?.id == widget.userId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: theme.scaffoldBackgroundColor,
        title: Text(
          l10n.friends,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocBuilder<FriendshipBloc,FriendshipState>(
        builder: (context, state) {
          if (state.status == FriendshipStateStatus.loading &&
              state.friends.isEmpty) {
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

          if (state.friends.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outline,
              title: l10n.noFriendsYet,
              subtitle: isOwnProfile ? l10n.startAddingFriends : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // ✅ ИЗМЕНЕНО: передаем userId
              context.read<FriendshipBloc>().add(LoadFriendsListEvent(userId: widget.userId));
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: state.friends.length + (state.friendsHasMore ? 1 : 0),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.dividerColor.withOpacity(0.1),
                indent: 76,
              ),
              itemBuilder: (context, index) {
                if (index >= state.friends.length) {
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

                final friend = state.friends[index];
                return FriendListTile(user: friend);
              },
            ),
          );
        },
      ),
    );
  }
}
