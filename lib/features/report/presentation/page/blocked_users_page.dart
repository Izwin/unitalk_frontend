import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/block/presentation/bloc/block_bloc.dart';
import 'package:unitalk/features/block/presentation/bloc/block_event.dart';
import 'package:unitalk/features/block/presentation/bloc/block_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({Key? key}) : super(key: key);

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<BlockBloc>().add(LoadBlockedUsersEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<BlockBloc>().add(LoadMoreBlockedUsersEvent());
    }
  }

  Future<void> _onRefresh() async {
    context.read<BlockBloc>().add(LoadBlockedUsersEvent());
    await context.read<BlockBloc>().stream.first;
  }

  void _showUnblockDialog(String userId, String userName) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          l10n.unblockUser,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          l10n.unblockUserConfirmation(userName),
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<BlockBloc>().add(UnblockUserEvent(userId));
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.unblock),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.blockedUsers,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<BlockBloc, BlockState>(
        listener: (context, state) {
          if (state.status == BlockStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BlockStatus.loading && state.blockedUsers.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }

          if (state.blockedUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.block_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noBlockedUsers,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Theme.of(context).colorScheme.primary,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.blockedUsers.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.blockedUsers.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }

                final block = state.blockedUsers[index];
                final user = block.blockedUser;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                    ),
                  ),
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
                                    '${user.firstName ?? ''} ${user.lastName ?? ''}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (user.isVerified == true) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (user.faculty != null)
                              Text(
                                user.faculty!.getLocalizedName(
                                  Localizations.localeOf(context).languageCode,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _showUnblockDialog(
                          user.id ?? '',
                          '${user.firstName} ${user.lastName}',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          l10n.unblock,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}