import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';

class SelectUniversityWidget extends StatelessWidget {
  final Function(UniversityModel)? onTap;
  final bool isSelected;
  final UniversityModel universityModel;

  const SelectUniversityWidget({
    super.key,
    this.onTap,
    required this.universityModel,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizedName = universityModel.getLocalizedName(
      Localizations.localeOf(context).languageCode,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap?.call(universityModel),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // --- Background image ---
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl:universityModel.logoUrl ?? '',
                width: double.infinity,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  child: Icon(
                    Icons.school_rounded,
                    color: theme.colorScheme.primary,
                    size: 64,
                  ),
                ),
              ),
            ),

            // --- Gradient overlay for text readability ---
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // --- University name + checkmark ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      localizedName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          const Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: isSelected
                        ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey('selected'),
                      color: theme.colorScheme.primary,
                      size: 28,
                    )
                        : const SizedBox(width: 28, height: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
