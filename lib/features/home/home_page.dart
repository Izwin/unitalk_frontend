import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _MinimalNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _MinimalNavBar extends StatelessWidget {
  const _MinimalNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: l10n.navFeed,
                isSelected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              _NavBarItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search_outlined,
                label: l10n.navSearch,
                isSelected: selectedIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
              _NavBarItem(
                icon: Icons.chat_bubble_outline,
                selectedIcon: Icons.chat_bubble,
                label: l10n.navChat,
                isSelected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: l10n.navProfile,
                isSelected: selectedIndex == 3,
                onTap: () => onDestinationSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isSelected
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? Colors.white54 : Colors.black54);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}