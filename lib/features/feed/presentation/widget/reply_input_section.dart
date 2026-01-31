import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unitalk/core/ui/common/anonymous_toggle.dart';
import 'package:unitalk/core/ui/common/media_preview.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

class ReplyInputSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isAnonymous;
  final ValueChanged<bool> onAnonymousToggle;
  final VoidCallback onSend;
  final VoidCallback onPickMedia;
  final File? selectedMedia;
  final bool isVideo;
  final VoidCallback? onRemoveMedia;

  const ReplyInputSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isAnonymous,
    required this.onAnonymousToggle,
    required this.onSend,
    required this.onPickMedia,
    this.selectedMedia,
    this.isVideo = false,
    this.onRemoveMedia,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final canSend = controller.text.trim().isNotEmpty || selectedMedia != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media Preview
        if (selectedMedia != null) ...[
          MediaPreview(
            mediaFile: selectedMedia!,
            isVideo: isVideo,
            onRemove: onRemoveMedia ?? () {},
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
                onPressed: onPickMedia,
                icon: Icon(
                  isVideo ? Icons.videocam : Icons.image_outlined,
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
