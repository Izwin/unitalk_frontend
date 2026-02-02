// lib/features/friendship/presentation/widgets/friendship_button.dart

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
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        final friendshipStatus = state.getFriendshipStatus(userId);

        if (friendshipStatus == null) {
          return const SizedBox.shrink();
        }

        final status = friendshipStatus.status;
        final isRequester = friendshipStatus.isRequester ?? false;
        final friendshipId = friendshipStatus.friendshipId;

        // Already friends
        if (status == FriendshipStatus.accepted) {
          return _StyledButton(
            label: compact ? l10n.friends : l10n.removeFriend,
            icon: compact ? Icons.people_rounded : Icons.person_remove_outlined,
            style: _ButtonVariant.secondary,
            compact: compact,
            onPressed: () => _showRemoveFriendDialog(context, friendshipId!),
          );
        }

        // Pending (we sent the request)
        if (status == FriendshipStatus.pending && isRequester) {
          return _StyledButton(
            label: compact ? l10n.pending : l10n.cancelRequest,
            icon: compact ? Icons.schedule_rounded : Icons.close_rounded,
            style: _ButtonVariant.ghost,
            compact: compact,
            onPressed: () {
              context.read<FriendshipBloc>().add(
                RemoveFriendshipEvent(friendshipId!, userId: userId),
              );
            },
          );
        }

        // Incoming request
        if (status == FriendshipStatus.pending && !isRequester) {
          if (compact) {
            return _StyledButton(
              label: l10n.accept,
              icon: Icons.check_rounded,
              style: _ButtonVariant.primary,
              compact: true,
              onPressed: () {
                context.read<FriendshipBloc>().add(
                  AcceptFriendRequestEvent(friendshipId!),
                );
              },
            );
          }

          return Row(
            children: [
              Expanded(
                child: _StyledButton(
                  label: l10n.accept,
                  icon: Icons.check_rounded,
                  style: _ButtonVariant.primary,
                  compact: false,
                  onPressed: () {
                    context.read<FriendshipBloc>().add(
                      AcceptFriendRequestEvent(friendshipId!),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StyledButton(
                  label: l10n.reject,
                  icon: Icons.close_rounded,
                  style: _ButtonVariant.ghost,
                  compact: false,
                  onPressed: () {
                    context.read<FriendshipBloc>().add(
                      RejectFriendRequestEvent(friendshipId!),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // No friendship
        return _StyledButton(
          label: compact ? l10n.add : l10n.addFriend,
          icon: Icons.person_add_rounded,
          style: _ButtonVariant.primary,
          compact: compact,
          onPressed: () {
            context.read<FriendshipBloc>().add(SendFriendRequestEvent(userId));
          },
        );
      },
    );
  }

  void _showRemoveFriendDialog(BuildContext context, String friendshipId) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

enum _ButtonVariant { primary, secondary, ghost }

class _StyledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final _ButtonVariant style;
  final bool compact;
  final VoidCallback onPressed;

  const _StyledButton({
    required this.label,
    required this.icon,
    required this.style,
    required this.compact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Color bg;
    Color fg;

    switch (style) {
      case _ButtonVariant.primary:
        bg = cs.primary;
        fg = cs.onPrimary;
      case _ButtonVariant.secondary:
        bg = cs.surfaceVariant.withOpacity(0.5);
        fg = cs.onSurfaceVariant;
      case _ButtonVariant.ghost:
        bg = cs.surfaceVariant.withOpacity(0.3);
        fg = cs.onSurfaceVariant.withOpacity(0.7);
    }

    if (compact) {
      return SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}