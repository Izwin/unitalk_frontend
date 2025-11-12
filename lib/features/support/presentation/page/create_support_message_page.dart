import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/common_text_field.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/core/ui/common/info_box.dart';
import 'package:unitalk/core/ui/common/selector_card.dart';
import 'package:unitalk/core/utils/build_contenxt_extensions.dart';
import 'package:unitalk/features/support/presentation/bloc/support_bloc.dart';
import 'package:unitalk/features/support/presentation/bloc/support_state.dart';
import 'package:unitalk/features/support/presentation/widget/category_bottom_sheet.dart';
import 'package:unitalk/l10n/app_localizations.dart';

import '../bloc/support_event.dart';

class CreateSupportMessagePage extends StatefulWidget {
  const CreateSupportMessagePage({Key? key}) : super(key: key);

  @override
  State<CreateSupportMessagePage> createState() => _CreateSupportMessagePageState();
}

class _CreateSupportMessagePageState extends State<CreateSupportMessagePage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'other';
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    final result = await ImageSourcePicker.show(
      context,
      galleryText: l10n.gallery,
      cameraText: l10n.camera,
      removeText: l10n.removePhoto,
      canRemove: _selectedImage != null,
      onRemove: () {
        setState(() => _selectedImage = null);
      },
    );

    if (result != null) {
      setState(() => _selectedImage = File(result.path));
    }
  }

  void _selectCategory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategoryBottomSheet(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() => _selectedCategory = category);
          context.pop();
        },
      ),
    );
  }

  Future<void> _submitMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    context.read<SupportBloc>().add(CreateSupportMessageEvent(
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      category: _selectedCategory,
      imageFile: _selectedImage,
    ));

    final result = await context.read<SupportBloc>().stream.firstWhere(
          (state) => state.status != SupportStatus.loading,
    );

    setState(() => _isSubmitting = false);

    if (result.status == SupportStatus.success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.supportMessageSentSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.newSupportMessage),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InfoBox(
              message: l10n.supportResponseTime,
              type: InfoBoxType.info,
            ),
            const SizedBox(height: 24),
            SelectorCard(
              label: l10n.category,
              value: _getCategoryLabel(context, _selectedCategory),
              icon: _getCategoryIcon(_selectedCategory),
              onTap: _selectCategory,
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _subjectController,
              label: l10n.subject,
              hint: l10n.subjectHint,
              icon: Icons.title_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.subjectRequired;
                }
                if (value.length > 200) {
                  return l10n.subjectTooLong;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CommonTextField(
              controller: _messageController,
              label: l10n.message,
              hint: l10n.messageHint,
              icon: Icons.message_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.messageRequired;
                }
                if (value.length > 2000) {
                  return l10n.messageTooLong;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      onPressed: () => setState(() => _selectedImage = null),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(_selectedImage == null ? l10n.attachImage : l10n.changeImage),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitMessage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(l10n.submitMessage),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return Icons.build_rounded;
      case 'account':
        return Icons.person_rounded;
      case 'verification':
        return Icons.verified_user_rounded;
      case 'content':
        return Icons.article_rounded;
      case 'other':
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getCategoryLabel(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;

    switch (category.toLowerCase()) {
      case 'technical':
        return l10n.categoryTechnicalIssue;
      case 'account':
        return l10n.categoryAccountIssue;
      case 'verification':
        return l10n.categoryVerification;
      case 'content':
        return l10n.categoryContentIssue;
      case 'other':
      default:
        return l10n.categoryOther;
    }
  }
}