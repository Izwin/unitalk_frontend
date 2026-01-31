import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_list_tile.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment_likers/comment_likers_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment_likers/comment_likers_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/comment_likers/comment_likers_state.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class CommentLikersPage extends StatefulWidget {
  final String commentId;

  const CommentLikersPage({super.key, required this.commentId});

  @override
  State<CommentLikersPage> createState() => _CommentLikersPageState();
}

class _CommentLikersPageState extends State<CommentLikersPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CommentLikersBloc>().add(GetCommentLikersEvent(
      commentId: widget.commentId,
      page: 1,
    ));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<CommentLikersBloc>().state;
      if (state.status != CommentLikersStatus.loading && !state.likersLastPage) {
        context.read<CommentLikersBloc>().add(GetCommentLikersEvent(
          commentId: widget.commentId,
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
      body: BlocBuilder<CommentLikersBloc, CommentLikersState>(
        builder: (context, state) {
          if (state.status == CommentLikersStatus.loading &&
              state.likers.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (state.status == CommentLikersStatus.failure) {
            return ErrorStateWidget(
              message: state.errorMessage ?? l10n.failedToLoadLikes,
              onRetry: () {
                context.read<CommentLikersBloc>().add(GetCommentLikersEvent(
                  commentId: widget.commentId,
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
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 72,
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            ),
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
                child: UserListTile(user: user, locale: locale)
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
