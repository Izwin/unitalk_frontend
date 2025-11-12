import 'package:flutter/material.dart';
import 'package:unitalk/features/feed/presentation/bloc/replies/replies_state.dart';

import 'reply_item.dart';

class RepliesList extends StatelessWidget {
  final RepliesState state;
  final Function(String) onDeleteReply;
  final Function(String, String?)? onReplyToReply; //(replyId, replyToUserName)

  const RepliesList({
    super.key,
    required this.state,
    required this.onDeleteReply,
    this.onReplyToReply,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (state.status == RepliesStatus.loading && state.replies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.primary,
            ),
          ),
        ),
      );
    }

    if (state.replies.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use ListView.separated with shrinkWrap so large reply lists don't force the whole
    // screen to re-layout unnecessarily. It's nested (non-scrollable) so we disable scrolling.
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colors.outlineVariant.withOpacity(0.4),
            width: 2,
          ),
        ),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 0),
        itemCount: state.replies.length,
        separatorBuilder: (_, __) => const SizedBox(height: 0),
        itemBuilder: (context, index) {
          final reply = state.replies[index];

          // When the user taps "reply" on a reply item, they usually intend to reply to the
          // author of that reply. Prefer reply.author.firstName as the name shown in the input.
          // If reply.author isn't available (anonymous), fall back to reply.replyToUser.firstName.
          final replyToUserName = reply.author?.firstName ?? reply.replyToUser?.firstName;

          return ReplyItem(
            reply: reply,
            onDelete: () => onDeleteReply(reply.id),
            onReply: onReplyToReply != null
                ? () => onReplyToReply!(reply.id, replyToUserName)
                : null,
          );
        },
      ),
    );
  }
}

