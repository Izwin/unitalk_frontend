import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/core/ui/common/user_meta_info.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_event.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_state.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friendship_button.dart';
import 'package:unitalk/features/search/presentation/bloc/user_search_bloc.dart';
import 'package:unitalk/features/search/presentation/bloc/user_search_event.dart';
import 'package:unitalk/features/search/presentation/bloc/user_search_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({Key? key}) : super(key: key);

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // Замените метод _onScroll в UserSearchPage на этот:

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<UserSearchBloc>().state;

      // Добавляем дополнительные проверки
      if (state.hasMore &&
          state.status != UserSearchStatus.loadingMore &&
          state.status != UserSearchStatus.loading) {

        // Логирование для отладки
        print('Loading more users. Current count: ${state.users.length}, Total: ${state.total}');

        context.read<UserSearchBloc>().add(SearchUsersEvent(
          query: _searchController.text,
          loadMore: true,
        ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Можете изменить порог с 0.9 на 0.8 для более ранней загрузки
    return currentScroll >= (maxScroll * 0.85);
  }


  void _onSearchChanged(String value) {
    if (value.trim().length >= 2) {
      context.read<UserSearchBloc>().add(SearchUsersEvent(query: value));
    } else if (value.trim().isEmpty) {
      context.read<UserSearchBloc>().add(ClearSearchEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
  create: (context) => sl<FriendshipBloc>(),
  child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: theme.scaffoldBackgroundColor,
        title: Text(
          l10n.searchUsers,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          Expanded(child: _buildBody(l10n)),
        ],
      ),
    ),
);
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: _onSearchChanged,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: l10n.searchUsersByName,
          hintStyle: TextStyle(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
            ),
            onPressed: () {
              _searchController.clear();
              _onSearchChanged('');
            },
          )
              : null,
          filled: true,
          fillColor: isDark
              ? theme.cardColor.withOpacity(0.3)
              : theme.textTheme.bodySmall?.color?.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return BlocBuilder<UserSearchBloc, UserSearchState>(
      builder: (context, state) {
        if (state.status == UserSearchStatus.initial) {
          return EmptyStateWidget(
            icon: Icons.search,
            title: l10n.searchForUsers,
            subtitle: l10n.typeToStartSearching,
          );
        }

        if (state.status == UserSearchStatus.loading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.primaryColor,
            ),
          );
        }

        if (state.status == UserSearchStatus.failure) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: state.errorMessage ?? l10n.anErrorOccurred,
            subtitle: null,
          );
        }

        if (state.users.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.person_off_outlined,
            title: l10n.noUsersFound,
            subtitle: l10n.tryDifferentName,
          );
        }

        print( 'afasdas ${state.total}');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.usersFound(state.total),
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: state.users.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: theme.dividerColor.withOpacity(0.1),
                  indent: 76,
                ),
                itemBuilder: (context, index) {
                  if (index >= state.users.length) {
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

                  final user = state.users[index];
                  return _buildUserTile(user);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserTile(UserModel user) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        context.push('/user/${user.id}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              photoUrl: user.photoUrl,
              firstName: user.firstName,
              lastName: user.lastName,
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified == true) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                      ],
                    ],
                  ),
                  if (user.university != null || user.faculty != null) ...[
                    const SizedBox(height: 4),
                    UserMetaInfo(
                      faculty: user.faculty?.getLocalizedName(
                        Localizations.localeOf(context).languageCode,
                      ),
                      sector: user.sector,
                      fontSize: 13,
                    ),
                  ],
                ],
              ),
            ),
            // ✅ ДОБАВЬТЕ ЭТО:
            BlocBuilder<FriendshipBloc, FriendshipState>(
              builder: (context, state) {
                return FriendshipButton(
                  userId: user.id!,
                  compact: true,
                );
              },
            ),
          ],
        ),
      ),
    );
  }}