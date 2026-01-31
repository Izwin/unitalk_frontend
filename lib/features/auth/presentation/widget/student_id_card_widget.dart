import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unitalk/core/ui/common/fullscreen_image_viewer.dart';
import 'package:unitalk/core/ui/widgets/default_avatar.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/widget/card_info_row.dart';
import 'package:unitalk/features/friendship/presentation/widgets/friends_count_button.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class StudentIdCardWidget extends StatelessWidget {
  final UserModel user;

  const StudentIdCardWidget({
    super.key,
    required this.user,
  });

  void _showImageFullscreen(BuildContext context, String imageUrl) {
    FullscreenImageViewer.showAvatar(
      context,
      imageUrl,
      userId: user.id,
      heroTag: 'avatar_${user.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1a237e), const Color(0xFF0d47a1)]
              : [const Color(0xFF1976d2), const Color(0xFF42a5f5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: .3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: _CardPatternPainter(),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.studentIdCard.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.university?.getLocalizedName(locale) ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    if (user.university?.logoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: const BoxDecoration(color: Colors.white),
                          child: CachedNetworkImage(
                            imageUrl: user.university!.logoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Icon(
                              Icons.school,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Student Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with fullscreen tap
                    GestureDetector(
                      onTap: user.photoUrl != null
                          ? () => _showImageFullscreen(context, user.photoUrl!)
                          : null,
                      child: Hero(
                        tag: 'avatar_${user.id}',
                        child: Container(
                          width: 75,
                          height: 95,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: user.photoUrl != null
                                ? CachedNetworkImage(
                              imageUrl: user.photoUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>  DefaultAvatar(),
                            )
                                :  DefaultAvatar(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 6),
                          CardInfoRow(
                            label: l10n.idLabel,
                            value: user.id?.substring(0, 8).toUpperCase() ?? '',
                          ),
                          const SizedBox(height: 3),
                          CardInfoRow(
                            label: l10n.faculty,
                            value: user.faculty?.getLocalizedName(locale) ??
                                l10n.notAvailable,
                          ),
                          const SizedBox(height: 3),
                          CardInfoRow(
                            label: l10n.sector,
                            value: user.sector?.displayName ?? l10n.notAvailable,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Verified Badge
          if (user.isVerified == true)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      l10n.verified.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
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
}

/// Painter for background pattern
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2 + i * 20),
        30 + i * 5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}