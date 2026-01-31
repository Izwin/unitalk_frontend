import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_list_tile.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/feed/presentation/bloc/post_likers/post_likers_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post_likers/post_likers_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post_likers/post_likers_state.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class PostLikersPage extends StatefulWidget {
  final String postId;

  const PostLikersPage({super.key, required this.postId});

  @override
  State<PostLikersPage> createState() => _PostLikersPageState();
}

class _PostLikersPageState extends State<PostLikersPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PostLikersBloc>().add(GetPostLikersEvent(
      postId: widget.postId,
      page: 1,
    ));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<PostLikersBloc>().state;
      if (state.status != PostLikersStatus.loading && !state.likersLastPage) {
        context.read<PostLikersBloc>().add(GetPostLikersEvent(
          postId: widget.postId,
          page: state.likersPage,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.read<LocaleCubit>().state.languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.likes),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: BlocBuilder<PostLikersBloc, PostLikersState>(
        builder: (context, state) {
          if (state.status == PostLikersStatus.loading &&
              state.likers.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (state.status == PostLikersStatus.failure) {
            return ErrorStateWidget(
              message: state.errorMessage ?? l10n.failedToLoadLikes,
              onRetry: () {
                context.read<PostLikersBloc>().add(GetPostLikersEvent(
                  postId: widget.postId,
                  page: 1,
                ));
              },
            );
          }

          if (state.likers.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.favorite_border,
              title: l10n.noLikesYet,
              subtitle: l10n.beTheFirstToLike,
            );
          }

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.likers.length + 1,
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              );
            },
            itemBuilder: (context, index) {
              if (index == state.likers.length) {
                return state.likersLastPage
                    ? const SizedBox(height: 16)
                    : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              }

              final user = state.likers[index];

              return InkWell(
                onTap: () => context.push('/user/${user.id}'),
                child: UserListTile(user: user, locale: locale),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}