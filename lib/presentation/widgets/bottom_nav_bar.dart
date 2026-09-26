import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: const TazaBottomNavBar(),
    );
  }
}

class TazaBottomNavBar extends StatelessWidget {
  const TazaBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final items = <_NavItem>[
      const _NavItem(
        label: 'Басты',
        icon: Icons.home_rounded,
        route: AppRoutes.home,
      ),
      const _NavItem(
        label: 'Карта',
        icon: Icons.map_rounded,
        route: AppRoutes.map,
      ),
      const _NavItem(
        label: 'Рейтинг',
        icon: Icons.emoji_events_rounded,
        route: AppRoutes.leaderboard,
      ),
      const _NavItem(
        label: 'Профиль',
        icon: Icons.person_rounded,
        route: AppRoutes.profile,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
      child: Row(
        children: items.map((item) {
          final selected = location == item.route;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.go(item.route),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: selected ? AppColors.accent : AppColors.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? AppColors.accent
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.accent : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
