import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaPreview extends StatefulWidget {
  final File mediaFile;
  final bool isVideo;
  final VoidCallback onRemove;

  const MediaPreview({
    Key? key,
    required this.mediaFile,
    this.isVideo = false,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _videoController;
  Uint8List? _thumbnailData;
  double _aspectRatio = 16 / 9; // Начальное значение
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: widget.mediaFile.path,
        imageFormat: ImageFormat.PNG,
        quality: 75,
        // maxWidth: null, // Сохраняем исходное соотношение
      );

      if (data != null) {
        final decoded = await decodeImageFromList(data);
        setState(() {
          _thumbnailData = data;
          _aspectRatio = decoded.width / decoded.height;
        });
      }
    } catch (e) {
      debugPrint('Ошибка при создании thumbnail: $e');
    }
  }

  void _initializeVideo() {
    if (_videoController != null) return;

    _videoController = VideoPlayerController.file(widget.mediaFile)
      ..initialize()
          .then((_) {
            setState(() {
              _isVideoInitialized = true;
              _aspectRatio =
                  _videoController!.value.aspectRatio; // корректное соотношение
              _videoController!.setLooping(true);
              _videoController!.play();
            });
          })
          .catchError((e) {
            debugPrint('Ошибка инициализации видео: $e');
          });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 250,
              maxWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: widget.isVideo
                ? (_isVideoInitialized && _videoController != null
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _videoController!.value.isPlaying
                                  ? _videoController!.pause()
                                  : _videoController!.play();
                            });
                          },
                          child: AspectRatio(
                            aspectRatio: _aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : (_thumbnailData != null
                            ? Container(
                                color: Colors.red,
                                child: IntrinsicWidth(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: AspectRatio(
                                          aspectRatio: _aspectRatio,
                                          child: Image.memory(
                                            _thumbnailData!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 64,
                                          ),
                                          onPressed: _initializeVideo,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const Center(child: CircularProgressIndicator())))
                : Image.file(widget.mediaFile, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: widget.onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
