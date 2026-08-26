import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../core/theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leadingWidth: 200,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: GlassContainer(
          blur: 15,
          opacity: 0.1,
          border: Border.fromBorderSide(BorderSide.none),
          child: Container(),
        ),
        leading: GestureDetector(
          onTap: () => context.go('/dashboard'),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://lh3.googleusercontent.com/a/default-user=s120-c',
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Agribotics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: AppTheme.primary),
            onPressed: () => context.go('/settings'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: child,
      bottomNavigationBar: _FloatingBottomNav(currentPath: location),
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  final String currentPath;

  const _FloatingBottomNav({required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: GlassContainer(
        height: 70,
        blur: 20,
        opacity: 0.1,
        borderRadius: BorderRadius.circular(35),
        border: Border.fromBorderSide(
          BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: LucideIcons.home,
              label: 'ESTATE',
              isActive: currentPath == '/dashboard',
              onTap: () => context.go('/dashboard'),
            ),
            _NavItem(
              icon: LucideIcons.layers,
              label: 'SOIL',
              isActive: currentPath == '/soil/nutrient-map',
              onTap: () => context.go('/soil/nutrient-map'),
            ),
            _NavItem(
              icon: LucideIcons.search,
              label: 'IDENTIFY',
              isActive: currentPath == '/identify',
              onTap: () => context.go('/identify'),
            ),
            _NavItem(
              icon: LucideIcons.shoppingBag,
              label: 'MARKET',
              isActive: currentPath == '/market',
              onTap: () => context.go('/market'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : AppTheme.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isActive ? AppTheme.primary : AppTheme.primary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
