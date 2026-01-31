import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unitalk/core/di/service_locator.dart';
import 'package:unitalk/core/services/activity_log_service.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

/// Универсальный полноэкранный просмотрщик изображений с отслеживанием активности
class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;
  final String? targetId;      // ID целевого объекта (Post, User, etc)
  final String? targetModel;   // Тип модели ('Post', 'User', 'Verification')
  final String activityType;   // Тип активности для логирования

  const FullscreenImageViewer({
    Key? key,
    required this.imageUrl,
    this.heroTag,
    this.targetId,
    this.targetModel,
    this.activityType = 'image_view',
  }) : super(key: key);

  /// Метод для открытия просмотрщика поста
  static Future<void> showPostImage(
      BuildContext context,
      String imageUrl, {
        String? postId,
        String? heroTag,
      }) {
    return show(
      context,
      imageUrl,
      heroTag: heroTag,
      targetId: postId,
      targetModel: 'Post',
      activityType: 'post_image_view',
    );
  }

  /// Метод для открытия аватара
  static Future<void> showAvatar(
      BuildContext context,
      String imageUrl, {
        String? userId,
        String? heroTag,
      }) {
    return show(
      context,
      imageUrl,
      heroTag: heroTag,
      targetId: userId,
      targetModel: 'User',
      activityType: 'avatar_view',
    );
  }

  /// Метод для открытия студенческого билета
  static Future<void> showStudentCard(
      BuildContext context,
      String imageUrl, {
        String? verificationId,
        String? heroTag,
      }) {
    return show(
      context,
      imageUrl,
      heroTag: heroTag,
      targetId: verificationId,
      targetModel: 'Verification',
      activityType: 'student_card_view',
    );
  }

  /// Базовый метод для открытия просмотрщика
  static Future<void> show(
      BuildContext context,
      String imageUrl, {
        String? heroTag,
        String? targetId,
        String? targetModel,
        String activityType = 'image_view',
      }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullscreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
          targetId: targetId,
          targetModel: targetModel,
          activityType: activityType,
        ),
      ),
    );
  }

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _controlsAnimationController;
  late ActivityLoggerService _activityLogger;

  bool _showControls = true;
  bool _hasLoggedView = false;
  bool _hasLoggedZoom = false;
  double _currentScale = 1.0;
  double _maxZoomReached = 1.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _activityLogger = sl<ActivityLoggerService>();

    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    _transformationController.addListener(_onTransformChanged);

    // Логируем просмотр изображения при открытии
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logImageView();
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _controlsAnimationController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onTransformChanged() {
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();

    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale;

        // Отслеживаем максимальный зум
        if (scale > _maxZoomReached) {
          _maxZoomReached = scale;
        }

        // Логируем первый зум (когда пользователь впервые увеличил изображение)
        if (scale > 1.1 && !_hasLoggedZoom) {
          _logImageZoom(scale);
          _hasLoggedZoom = true;
        }
      });
    }
  }

  /// Логирует просмотр изображения
  Future<void> _logImageView() async {
    if (_hasLoggedView) return;

    _hasLoggedView = true;
    await _activityLogger.logImageView(
      activityType: widget.activityType,
      targetId: widget.targetId,
      targetModel: widget.targetModel,
      imageUrl: widget.imageUrl,
      metadata: {
        'viewedAt': DateTime.now().toIso8601String(),
        'heroTag': widget.heroTag,
      },
    );
  }

  /// Логирует зум изображения
  Future<void> _logImageZoom(double scale) async {
    await _activityLogger.logImageZoom(
      imageUrl: widget.imageUrl,
      scale: scale,
      targetId: widget.targetId,
      targetModel: widget.targetModel,
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _controlsAnimationController.forward();
      } else {
        _controlsAnimationController.reverse();
      }
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _toggleControls,
            onDoubleTap: () {
              if (_currentScale > 1.0) {
                _resetZoom();
              } else {
                final newScale = 2.5;
                _transformationController.value = Matrix4.identity()..scale(newScale);

                // Логируем зум при двойном тапе
                if (!_hasLoggedZoom) {
                  _logImageZoom(newScale);
                  _hasLoggedZoom = true;
                }
              }
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1.0,
              maxScale: 5.0,
              panEnabled: true,
              scaleEnabled: true,
              clipBehavior: Clip.none,
              child: Center(
                child: _buildImage(l10n),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _controlsAnimationController,
            builder: (context, child) {
              return Opacity(
                opacity: _controlsAnimationController.value,
                child: _showControls ? _buildControls() : const SizedBox.shrink(),
              );
            },
          ),

          if (_currentScale > 1.0 && _showControls) _buildZoomIndicator(),
        ],
      ),
    );
  }

  Widget _buildImage(AppLocalizations l10n) {
    final image = CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) => _buildLoadingIndicator(l10n),
      errorWidget: (context, url, error) => _buildErrorWidget(l10n),
    );

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: image,
      );
    }
    return image;
  }

  Widget _buildLoadingIndicator(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.loadingImage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.white.withOpacity(0.6),
            size: 72,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.imageLoadFailed,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: Text(
              l10n.tryAgain,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: _buildControlButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),

        if (_currentScale > 1.0)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildControlButton(
              icon: Icons.zoom_out_map_rounded,
              onTap: _resetZoom,
            ),
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomIndicator() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 24,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.zoom_in_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${(_currentScale * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}