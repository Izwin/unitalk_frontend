import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Модальное окно для выбора источника медиа (изображение или видео)
class MediaSourcePicker {
  static Future<XFile?> show(
      BuildContext context, {
        required String galleryText,
        required String cameraText,
        required String videoText,
        required String removeText,
        bool canRemove = false,
        bool allowVideo = false,
        VoidCallback? onRemove,
      }) async {
    final theme = Theme.of(context);
    final picker = ImagePicker();

    final result = await showModalBottomSheet<_MediaPickerResult?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _MediaSourceOption(
                icon: Icons.photo_library_outlined,
                title: galleryText,
                onTap: () => context.pop(_MediaPickerResult(
                  source: ImageSource.gallery,
                  isVideo: false,
                )),
              ),
              Divider(height: 1, indent: 16, endIndent: 16),
              _MediaSourceOption(
                icon: Icons.photo_camera_outlined,
                title: cameraText,
                onTap: () => context.pop(_MediaPickerResult(
                  source: ImageSource.camera,
                  isVideo: false,
                )),
              ),
              if (allowVideo) ...[
                Divider(height: 1, indent: 16, endIndent: 16),
                _MediaSourceOption(
                  icon: Icons.videocam_outlined,
                  title: videoText,
                  onTap: () => context.pop(_MediaPickerResult(
                    source: ImageSource.gallery,
                    isVideo: true,
                  )),
                ),
              ],
              if (canRemove) ...[
                Divider(height: 1, indent: 16, endIndent: 16),
                _MediaSourceOption(
                  icon: Icons.delete_outline,
                  title: removeText,
                  color: Colors.red.shade400,
                  onTap: () {
                    context.pop();
                    onRemove?.call();
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      if (result.isVideo) {
        return await picker.pickVideo(
          source: result.source,
          maxDuration: const Duration(minutes: 2), // Максимум 2 минуты
        );
      } else {
        return await picker.pickImage(
          source: result.source,
          maxWidth: 1440,
          maxHeight: 1440,
          imageQuality: 90,
        );
      }
    }

    return null;
  }
}

class _MediaPickerResult {
  final ImageSource source;
  final bool isVideo;

  _MediaPickerResult({required this.source, required this.isVideo});
}

class _MediaSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _MediaSourceOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: color ?? theme.iconTheme.color,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}