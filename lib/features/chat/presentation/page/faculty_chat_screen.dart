import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/core/ui/common/message_bubble.dart';
import 'package:unitalk/core/ui/common/message_input.dart';
import 'package:unitalk/core/ui/common/typing_indicator.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/chat/data/model/message_model.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_event.dart';
import 'package:unitalk/features/chat/presentation/bloc/chat_state.dart';
import 'package:unitalk/features/report/presentation/content_moderation_menu.dart';
import 'dart:io';

import 'package:unitalk/l10n/app_localizations.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  XFile? _selectedImage;
  MessageModel? _replyingTo;
  bool _isTyping = false;
  bool _shouldAutoScroll = true;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final authState = context.read<AuthBloc>().state;

    if (authState.user != null) {
      if (authState.user!.verification?.isApproved != true) {
        _showVerificationRequiredDialog();
        return;
      }

      await _connectSocket();

      if (mounted) {
        context.read<ChatBloc>().add(LoadMessagesEvent());
        context.read<ChatBloc>().add(LoadChatInfoEvent());
        context.read<ChatBloc>().add(GetOnlineUsersEvent());
      }
    }
  }

  Future<void> _connectSocket() async {
    try {
      var token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null && mounted) {
        context.read<ChatBloc>().add(ConnectSocketEvent(token: token));
      }
    } catch (e) {
      print('Error connecting socket: $e');
    }
  }

  void _showVerificationRequiredDialog() {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.verificationRequired,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.verificationRequiredMessage,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (mounted) {
                context.go('/profile');
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.goToProfile,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrolling) return;

    FocusScope.of(context).unfocus();

    final position = _scrollController.position;

    // Если пользователь прокрутил вверх больше чем на 100px, отключаем автоскролл
    if (position.pixels > 100) {
      if (_shouldAutoScroll) {
        setState(() {
          _shouldAutoScroll = false;
        });
      }
    }
    // Если пользователь вернулся к низу (< 30px), включаем автоскролл
    else if (position.pixels < 30) {
      if (!_shouldAutoScroll) {
        setState(() {
          _shouldAutoScroll = true;
        });
      }
    }

    // Подгрузка старых сообщений при скролле вверх
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      context.read<ChatBloc>().add(LoadMoreMessagesEvent());
    }
  }

  void _scrollToBottom({bool force = false}) {
    if (_scrollController.hasClients && mounted) {
      // Автоскролл только если разрешен или принудительный
      if (_shouldAutoScroll || force) {
        _isScrolling = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            ).then((_) {
              _isScrolling = false;
            });
          } else {
            _isScrolling = false;
          }
        });
      }
    }
  }

  void _handleTyping(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      context.read<ChatBloc>().add(StartTypingEvent());
    } else if (text.isEmpty && _isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(StopTypingEvent());
    }
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    final image = await ImageSourcePicker.show(
      context,
      galleryText: l10n.gallery,
      cameraText: l10n.camera,
      removeText: l10n.removePhoto,
      canRemove: _selectedImage != null,
      onRemove: () => setState(() => _selectedImage = null),
    );

    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();

    if (content.isEmpty && _selectedImage == null) return;

    context.read<ChatBloc>().add(SendMessageEvent(
      content: content.isNotEmpty ? content : '',
      imageFile: _selectedImage != null ? File(_selectedImage!.path) : null,
      replyTo: _replyingTo?.id,
    ));

    _messageController.clear();
    setState(() {
      _selectedImage = null;
      _replyingTo = null;
    });

    if (_isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(StopTypingEvent());
    }

    // Принудительный скролл после отправки своего сообщения
    setState(() {
      _shouldAutoScroll = true;
    });
    _scrollToBottom(force: true);
  }

  void _showMessageOptions(MessageModel message) {
    FocusScope.of(context).unfocus();

    ContentModerationMenu.showMessageMenu(
      context: context,
      messageId: message.id,
      isOwner: message.user?.id == context.read<AuthBloc>().state.user?.id,
      onReply: () => _replyToMessage(message),
      onEdit: message.user?.id == context.read<AuthBloc>().state.user?.id
          ? () => _editMessage(message)
          : null,
      onDelete: message.isOwnMessage == true && !message.isDeleted
          ? () => _deleteMessage(message)
          : null,
    );
  }

  void _replyToMessage(MessageModel message) {
    setState(() {
      _replyingTo = message;
    });
    // Фокусируем поле ввода
    FocusScope.of(context).requestFocus();
  }

  void _editMessage(MessageModel message) {
    final l10n = AppLocalizations.of(context)!;
    _messageController.text = message.content;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          l10n.editMessage,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: TextField(
          controller: _messageController,
          maxLines: 3,
          maxLength: 2000,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.enterMessage,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _messageController.clear();
              Navigator.pop(dialogContext);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final content = _messageController.text.trim();
              if (content.isNotEmpty && mounted) {
                context.read<ChatBloc>().add(EditMessageEvent(
                  messageId: message.id,
                  content: content,
                ));
                _messageController.clear();
                Navigator.pop(dialogContext);
              }
            },
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(MessageModel message) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          l10n.deleteMessage,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          l10n.deleteMessageConfirm,
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
              if (mounted) {
                context.read<ChatBloc>().add(DeleteMessageEvent(messageId: message.id));
                Navigator.pop(dialogContext);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.user?.verification?.isApproved != true) {
          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_user_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.verificationRequired,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.verificationRequiredMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => context.go('/profile'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.goToProfile,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final user = authState.user;
        final faculty = user?.faculty;
        final sector = user?.sector;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
              surfaceTintColor: Colors.transparent,
              centerTitle: false,
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (faculty != null)
                    Text(
                      faculty.getLocalizedName(Localizations.localeOf(context).languageCode),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  if (sector != null)
                    Text(
                      '${sector.flagEmoji} ${sector.displayName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.people_outline, size: 24),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.push('/chat/participants');
                  },
                  tooltip: l10n.participants,
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: BlocConsumer<ChatBloc, ChatState>(
                          listener: (context, state) {
                            // Автоскролл только если разрешен
                            if (state.status == ChatStatus.success && _shouldAutoScroll && !_isScrolling) {
                              _scrollToBottom();
                            }
                          },
                          builder: (context, state) {
                            if (state.status == ChatStatus.loading) {
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              );
                            }

                            if (state.status == ChatStatus.failure) {
                              return ErrorStateWidget(
                                message: state.errorMessage ?? l10n.failedToLoadMessages,
                                onRetry: () {
                                  context.read<ChatBloc>().add(LoadMessagesEvent());
                                },
                              );
                            }

                            if (state.messages.isEmpty) {
                              return EmptyStateWidget(
                                icon: Icons.chat_bubble_outline,
                                title: l10n.noMessagesYet,
                                subtitle: l10n.startConversation,
                              );
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              itemCount: state.messages.length +
                                  (state.typingUsers.isNotEmpty ? 1 : 0) +
                                  (state.status == ChatStatus.loadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                // Индикатор загрузки в конце списка (вверху экрана)
                                if (state.status == ChatStatus.loadingMore &&
                                    index == state.messages.length + (state.typingUsers.isNotEmpty ? 1 : 0)) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2.5),
                                      ),
                                    ),
                                  );
                                }

                                if (state.typingUsers.isNotEmpty && index == 0) {
                                  return const Padding(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: TypingIndicator(typingUsers: []),
                                  );
                                }

                                final messageIndex = state.typingUsers.isNotEmpty ? index - 1 : index;
                                final message = state.messages[messageIndex];
                                final isCurrentUser = message.user?.id == authState.user?.id;

                                // Показываем аватарку только для последнего сообщения в серии
                                final showAvatar = messageIndex == 0 ||
                                    state.messages[messageIndex - 1].user?.id != message.user?.id;

                                return GestureDetector(
                                  onLongPress: () => _showMessageOptions(message),
                                  child: MessageBubble(
                                    message: message,
                                    isCurrentUser: isCurrentUser,
                                    showAvatar: showAvatar,
                                    currentUser: authState.user,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Кнопка "Вернуться вниз"
                      if (!_shouldAutoScroll)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.small(
                            onPressed: () {
                              setState(() {
                                _shouldAutoScroll = true;
                              });
                              _scrollToBottom(force: true);
                            },
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.arrow_downward, size: 20),
                          ),
                        ),
                    ],
                  ),
                ),

                if (_replyingTo != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.reply,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${l10n.replyTo} ${_replyingTo!.user?.firstName ?? l10n.unknown}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                        letterSpacing: -0.1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (_replyingTo!.imageUrl != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.photo,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  _replyingTo!.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                          onPressed: () => setState(() => _replyingTo = null),
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),

                if (_selectedImage != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_selectedImage!.path),
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE5E5E5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: MessageInput(
                    controller: _messageController,
                    hintText: l10n.messageHint,
                    onSend: _sendMessage,
                    onTypingChanged: _handleTyping,
                    onAttachmentTap: _pickImage,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}