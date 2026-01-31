import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkValidity(String confirmWord) {
    setState(() {
      _isValid = _controller.text.toLowerCase() == confirmWord.toLowerCase();
    });
  }

  void _confirmDelete(BuildContext context) {
    context.read<AuthBloc>().add(DeleteProfileEvent());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final confirmWord = l10n.delete;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.deleteAccount,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: theme.colorScheme.error,
                        size: 40,
                      ),
                    ),
                  ),

                  SizedBox(height: 32),

                  // Warning Title
                  Text(
                    l10n.deleteAccountWarning,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),

                  SizedBox(height: 12),

                  // Description
                  Text(
                    l10n.deleteAccountDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                      letterSpacing: 0.1,
                    ),
                  ),

                  SizedBox(height: 32),

                  // What will be deleted
                  Text(
                    l10n.willBeDeleted,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Items list
                  _buildDeleteItem(
                    icon: Icons.post_add,
                    text: l10n.allPosts,
                    theme: theme,
                  ),
                  SizedBox(height: 12),
                  _buildDeleteItem(
                    icon: Icons.comment,
                    text: l10n.allComments,
                    theme: theme,
                  ),
                  SizedBox(height: 12),
                  _buildDeleteItem(
                    icon: Icons.message,
                    text: l10n.allMessages,
                    theme: theme,
                  ),
                  SizedBox(height: 12),
                  _buildDeleteItem(
                    icon: Icons.person,
                    text: l10n.profileData,
                    theme: theme,
                  ),

                  SizedBox(height: 24),

                  // Warning banner
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 22,
                          color: theme.colorScheme.error,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.thisActionCannotBeUndone,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Confirmation section
                  Text(
                    '${l10n.typeToConfirm} "$confirmWord"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),

                  SizedBox(height: 12),

                  // Input field
                  TextField(
                    controller: _controller,
                    onChanged: (_) => _checkValidity(confirmWord),
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: confirmWord,
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.error,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isValid ? () => _confirmDelete(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        theme.colorScheme.onSurface.withOpacity(0.1),
                        disabledForegroundColor:
                        theme.colorScheme.onSurface.withOpacity(0.3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.delete,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        SizedBox(width: 12),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}