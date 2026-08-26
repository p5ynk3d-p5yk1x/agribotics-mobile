import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class IdentifyPage extends StatelessWidget {
  const IdentifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'DIAGNOSTIC PIPELINE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.secondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Curating the',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            'health of your',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            'soil & crops.',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.onSurfaceVariant.withOpacity(0.05),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(backgroundColor: AppTheme.primary, radius: 4),
                SizedBox(width: 8),
                Text('8 Active Tasks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 48),
          DetectionCard(
            title: 'Weed Detection',
            description:
            'Automated spectral analysis across North Quadrant to identify invasive species and nitrogen competitors before they spread.',
            icon: LucideIcons.target,
            route: '/weed/detection',
            imageUrl: 'https://picsum.photos/seed/weed/800/400',
          ),
          const SizedBox(height: 24),
          DetectionCard(
            title: 'Soil Analysis',
            description: 'Automated soil analysis that turns soil auth into actionable insights for smarter farming and fertilizer usage.',
            icon: LucideIcons.flaskConical,
            route: '/soil/detection',
            imageUrl: 'https://picsum.photos/seed/soil/800/400',
          ),
          const SizedBox(height: 24),

          DetectionCard(
            title: 'Disease Detection',
            description: 'Advanced analytics that turn raw farm auth into actionable crop yield insights for smarter planning and higher output.',
            icon: LucideIcons.sun,
            route: '/disease/detection',
            imageUrl: 'https://picsum.photos/seed/disease/800/400',
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}


class DetectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final String imageUrl;

  const DetectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              imageUrl,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: AppTheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go(route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Access Analysis',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(LucideIcons.arrowRight, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}