import 'package:flutter/material.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';

class SelectFacultyWidget extends StatelessWidget {
  final Function(FacultyModel)? onTap;
  final bool isSelected;
  final FacultyModel facultyModel;

  const SelectFacultyWidget({
    super.key,
    this.onTap,
    required this.facultyModel,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizedName = facultyModel.getLocalizedName(
      Localizations.localeOf(context).languageCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTap?.call(facultyModel),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  localizedName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: isSelected
                    ? Icon(
                  Icons.check_circle_rounded,
                  key: const ValueKey('selected'),
                  color: theme.colorScheme.primary,
                  size: 24,
                )
                    : const SizedBox(width: 24, height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
