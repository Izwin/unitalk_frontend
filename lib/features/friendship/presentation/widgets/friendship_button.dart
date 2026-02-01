import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_bloc.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_event.dart';
import 'package:unitalk/features/friendship/presentation/bloc/friendship_state.dart'
    show FriendshipState;
import 'package:unitalk/l10n/app_localizations.dart';

import '../../data/model/friendship_model.dart' show FriendshipStatus;

class FriendshipButton extends StatelessWidget {
  final String userId;
  final bool compact;

  const FriendshipButton({Key? key, required this.userId, this.compact = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        final friendshipStatus = state.getFriendshipStatus(userId);

        if (friendshipStatus == null) {
          context.read<FriendshipBloc>().add(LoadFriendshipStatusEvent(userId));
          return const SizedBox.shrink();
        }

        final status = friendshipStatus.status;
        final isRequester = friendshipStatus.isRequester ?? false;
        final friendshipId = friendshipStatus.friendshipId;

        // ─── Уже друзья ─────────────────────────────────────
        if (status == FriendshipStatus.accepted) {
          return _buildButton(
            context: context,
            label: compact ? l10n.friends : l10n.removeFriend,
            icon: compact ? Icons.people_outlined : Icons.person_remove_outlined,
            style: _ButtonStyle.secondary,
            onPressed: () => _showRemoveFriendDialog(context, friendshipId!),
          );
        }

        // ─── Ожидает ответа (мы отправили запрос) ───────────
        if (status == FriendshipStatus.pending && isRequester) {
          return _buildButton(
            context: context,
            label: compact ? l10n.pending : l10n.cancelRequest,
            icon: compact ? Icons.schedule_outlined : Icons.close_outlined,
            style: _ButtonStyle.ghost,
            onPressed: () {
              context.read<FriendshipBloc>().add(
                RemoveFriendshipEvent(friendshipId!, userId: userId),
              );
            },
          );
        }

        // ─── Входящий запрос (нам написали) ─────────────────
        if (status == FriendshipStatus.pending && !isRequester) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton(
                context: context,
                label: l10n.accept,
                icon: Icons.check_outlined,
                style: _ButtonStyle.primary,
                onPressed: () {
                  context.read<FriendshipBloc>().add(
                    AcceptFriendRequestEvent(friendshipId!),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildButton(
                context: context,
                label: l10n.reject,
                icon: Icons.close_outlined,
                style: _ButtonStyle.ghost,
                onPressed: () {
                  context.read<FriendshipBloc>().add(
                    RejectFriendRequestEvent(friendshipId!),
                  );
                },
              ),
            ],
          );
        }

        // ─── Нет дружбы ─────────────────────────────────────
        return _buildButton(
          context: context,
          label: compact ? l10n.add : l10n.addFriend,
          icon: compact ? Icons.person_add_outlined : Icons.person_add_outlined,
          style: _ButtonStyle.primary,
          onPressed: () {
            context.read<FriendshipBloc>().add(SendFriendRequestEvent(userId));
          },
        );
      },
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required _ButtonStyle style,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);

    final Color bg;
    final Color fg;
    final Color? border;

    switch (style) {
      case _ButtonStyle.primary:
        bg = theme.primaryColor;
        fg = Colors.white;
        border = null;
      case _ButtonStyle.secondary:
        bg = theme.colorScheme.surfaceVariant.withOpacity(0.7);
        fg = theme.colorScheme.onSurfaceVariant;
        border = theme.dividerColor.withOpacity(0.4);
      case _ButtonStyle.ghost:
        bg = theme.colorScheme.surfaceVariant.withOpacity(0.4);
        fg = theme.colorScheme.onSurfaceVariant.withOpacity(0.7);
        border = theme.dividerColor.withOpacity(0.3);
    }

    if (compact) {
      return IconButton.filled(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: border != null ? BorderSide(color: border) : null,
          iconSize: 18,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        side: border != null ? BorderSide(color: border) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showRemoveFriendDialog(BuildContext context, String friendshipId) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeFriend),
        content: Text(l10n.removeFriendConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<FriendshipBloc>().add(
                RemoveFriendshipEvent(friendshipId, userId: userId),
              );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }
}

enum _ButtonStyle { primary, secondary, ghost }