import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unitalk/core/ui/common/anonymous_toggle.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class ReplyInputSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isAnonymous;
  final ValueChanged<bool> onAnonymousToggle;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final File? selectedImage;
  final VoidCallback? onRemoveImage;

  const ReplyInputSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isAnonymous,
    required this.onAnonymousToggle,
    required this.onSend,
    required this.onPickImage,
    this.selectedImage,
    this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final canSend = controller.text.trim().isNotEmpty || selectedImage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Preview
        if (selectedImage != null) ...[
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black87,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onRemoveImage,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Input Container
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnonymousToggle(
                isAnonymous: isAnonymous,
                onChanged: onAnonymousToggle,
                size: 36,
              ),
              const SizedBox(width: 12),

              IconButton(
                onPressed: onPickImage,
                icon: Icon(
                  Icons.image_outlined,
                  color: colors.onSurface.withOpacity(0.6),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.onSurface,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: isAnonymous ? l10n.replyAnonymously : l10n.writeReply,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: colors.onSurface.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: canSend ? onSend : null,
                icon: Icon(
                  Icons.send_rounded,
                  size: 22,
                  color: canSend
                      ? colors.primary
                      : colors.onSurface.withOpacity(0.3),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}