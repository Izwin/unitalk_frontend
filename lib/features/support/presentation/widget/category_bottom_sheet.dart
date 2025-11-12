import 'package:flutter/material.dart';
import 'package:unitalk/l10n/app_localizations.dart';

import '../../../auth/presentation/edit_profile_page.dart';

class CategoryBottomSheet extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryBottomSheet({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final categories = [
      {'value': 'technical', 'label': l10n.categoryTechnicalIssue, 'icon': Icons.build_rounded},
      {'value': 'account', 'label': l10n.categoryAccountIssue, 'icon': Icons.person_rounded},
      {'value': 'verification', 'label': l10n.categoryVerification, 'icon': Icons.verified_user_rounded},
      {'value': 'content', 'label': l10n.categoryContentIssue, 'icon': Icons.article_rounded},
      {'value': 'other', 'label': l10n.categoryOther, 'icon': Icons.help_outline_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.selectCategory,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              final value = item['value'] as String;
              final label = item['label'] as String;
              final icon = item['icon'] as IconData;
              final isSelected = selectedCategory == value;

              return RadioSelectorItem(
                title: label,
                isSelected: isSelected,
                onTap: () => onCategorySelected(value),
                icon: icon,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}