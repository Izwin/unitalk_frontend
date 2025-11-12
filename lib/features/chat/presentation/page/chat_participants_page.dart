import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/user_list_tile.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_event.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class ChatParticipantsPage extends StatefulWidget {
  const ChatParticipantsPage({super.key});

  @override
  State<ChatParticipantsPage> createState() => _ChatParticipantsPageState();
}

class _ChatParticipantsPageState extends State<ChatParticipantsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadParticipantsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.cardColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.participants,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return _buildLoadingState(theme, l10n);
          }

          if (state.participants == null || state.participants!.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outline,
              title: l10n.noParticipants,
              subtitle: l10n.noParticipantsDescription,
            );
          }

          return Column(
            children: [
              // Header with count
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.cardColor,
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 20,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.totalParticipants(state.participants!.length),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Participants list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.participants!.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 68,
                    color: theme.dividerColor.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    final user = state.participants![index];
                    return UserListTile(
                      user: user,
                      locale: locale,
                      onTap: () {
                        // Navigate to user profile
                        context.push('/user/${user.id}');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.loadingParticipants,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}



