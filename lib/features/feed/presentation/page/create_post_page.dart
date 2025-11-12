import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unitalk/core/ui/common/anonymous_toggle.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  File? _selectedImage;
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickImage() async {
    _dismissKeyboard();
    final l10n = AppLocalizations.of(context)!;

    final image = await ImageSourcePicker.show(
      context,
      galleryText: l10n.gallery,
      cameraText: l10n.camera,
      removeText: l10n.removePhoto,
      canRemove: _selectedImage != null,
      onRemove: () => setState(() => _selectedImage = null),
    );

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
  }

  Future<void> _submitPost() async {
    _dismissKeyboard();
    final l10n = AppLocalizations.of(context)!;

    if (_contentController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAddContent),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<PostBloc>().add(
      CreatePostEvent(
        content: _contentController.text.trim(),
        isAnonymous: _isAnonymous,
        imageFile: _selectedImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.status == PostStatus.success && _isSubmitting) {
          context.pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.postCreatedSuccessfully),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
          );
        } else if (state.status == PostStatus.failure) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.failedToCreatePost),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
          );
        }
      },
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, size: 24),
              onPressed: () {
                _dismissKeyboard();
                context.pop();
              },
            ),
            centerTitle: false,
            title: Text(
              l10n.newPost,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: TextButton(
                  onPressed: _isSubmitting ? null : _submitPost,
                  style: TextButton.styleFrom(
                    backgroundColor: _isSubmitting
                        ? theme.colorScheme.onSurface.withOpacity(0.1)
                        : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  )
                      : Text(
                    l10n.post,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 1,
                color: theme.colorScheme.onSurface.withOpacity(0.08),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Section
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Row(
                          children: [
                            UserAvatar(
                              photoUrl: _isAnonymous ? null : user?.photoUrl,
                              firstName: _isAnonymous ? null : user?.firstName,
                              lastName: _isAnonymous ? null : user?.lastName,
                              size: 44,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isAnonymous ? l10n.anonymous : (user?.firstName ?? l10n.user),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  if (user?.university != null && !_isAnonymous)
                                    Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        user!.university!.getLocalizedName(
                                            Localizations.localeOf(context).languageCode),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Input
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _contentController,
                          focusNode: _focusNode,
                          maxLines: null,
                          minLines: 8,
                          maxLength: 500,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            letterSpacing: 0.1,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.whatsOnYourMind,
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.3),
                              letterSpacing: 0.1,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),

                      // Character Count
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Text(
                          l10n.characterCount(_contentController.text.length, 500),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      // Image Preview
                      if (_selectedImage != null)
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Material(
                                  color: Colors.black87,
                                  shape: CircleBorder(),
                                  child: InkWell(
                                    onTap: _removeImage,
                                    customBorder: CircleBorder(),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 24),

                      // Divider
                      Container(
                        height: 8,
                        color: theme.colorScheme.onSurface.withOpacity(0.04),
                      ),

                      SizedBox(height: 20),

                      // Action Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.actions,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildActionTile(
                              icon: Icons.image,
                              title: l10n.addImage,
                              onTap: _pickImage,
                              theme: theme,
                            ),
                            Container(
                              height: 1,
                              margin: EdgeInsets.symmetric(vertical: 0),
                              color: theme.colorScheme.onSurface.withOpacity(0.08),
                            ),
                            _buildActionTile(
                              icon: _isAnonymous ? Icons.person_off : Icons.person,
                              title: _isAnonymous ? l10n.anonymousMode : l10n.publicMode,
                              subtitle: _isAnonymous
                                  ? l10n.yourIdentityIsHidden
                                  : l10n.yourNameIsVisible,
                              trailing: AnonymousToggle(
                                isAnonymous: _isAnonymous,
                                onChanged: (value) {
                                  _dismissKeyboard();
                                  setState(() => _isAnonymous = value);
                                },
                                size: 40,
                              ),
                              onTap: () {
                                _dismissKeyboard();
                                setState(() => _isAnonymous = !_isAnonymous);
                              },
                              theme: theme,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 0),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              size: 22,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}