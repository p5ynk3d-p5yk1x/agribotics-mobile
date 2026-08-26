import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../../../core/theme/app_theme.dart';

class WeedDiagnosis extends StatelessWidget {
  const WeedDiagnosis({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  const Text(
                    'IDENTIFICATION',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
                  ).animate().fadeIn().moveX(begin: -10),
                  const SizedBox(height: 12),
                  const Text(
                    'Cercospora\nLeaf Spot.',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.1),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 24),
                  Container(width: 64, height: 4, color: AppTheme.primary).animate().scaleX(delay: 300.ms, alignment: Alignment.centerLeft),
                  const SizedBox(height: 40),
                  const Text(
                    'Observation reveals small, circular spots with light gray centers and dark reddish-purple borders. Early intervention is required to prevent widespread defoliation.',
                    style: TextStyle(fontSize: 18, color: AppTheme.onSurfaceVariant, height: 1.6),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 32),
                  const Wrap(
                    spacing: 12,
                    children: [
                      _Tag(label: 'Fungal Pathogen'),
                      _Tag(label: 'Critical Priority'),
                    ],
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 48),
                  const _RemediesSection().animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 48),
                  const _StatsSection().animate().fadeIn(delay: 800.ms),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.network(
              'https://picsum.photos/seed/leaf/800/1000',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  AppTheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 32,
          right: 32,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: GlassContainer(
              blur: 10,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.scan, color: Colors.white, size: 14),
                        SizedBox(width: 8),
                        Text(
                          'BOTANICAL ANALYSIS ACTIVE',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "The Curator's\nDiagnosis",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Precise leaf-tissue identification confirms pathogen activity in Sector 04.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant),
      ),
    );
  }
}

class _RemediesSection extends StatelessWidget {
  const _RemediesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('The Prescriptions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('TAILORED FOR YOUR SOIL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.outline, letterSpacing: 1.0)),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, color: AppTheme.outline),
        const SizedBox(height: 32),
        const _RemedyCard(
          icon: LucideIcons.leaf,
          title: 'Organic Remedy',
          description: 'Neem oil extract with a bio-balanced compost tea to boost leaf immunity naturally.',
          buttonLabel: 'Apply Bio-Solution',
          color: AppTheme.tertiaryFixed,
        ),
        const SizedBox(height: 24),
        const _RemedyCard(
          icon: LucideIcons.flaskConical,
          title: 'Mineral Focus',
          description: 'Copper-based fungicide application for rapid suppression of fungal sporulation.',
          buttonLabel: 'Apply Mineral Shield',
          color: Color(0xFFFFDBD0),
          isSecondary: true,
        ),
      ],
    );
  }
}

class _RemedyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final Color color;
  final bool isSecondary;

  const _RemedyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.color,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color, radius: 24, child: Icon(icon, color: AppTheme.onSurface)),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: AppTheme.onSurfaceVariant, height: 1.5)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isSecondary ? AppTheme.background : AppTheme.primary,
              foregroundColor: isSecondary ? AppTheme.onSurface : Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SUCCESS PROBABILITY', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('94%', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.trendingUp, color: Colors.white54, size: 32),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Treatment applied within the first 48 hours yields high recovery rates.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.history, color: AppTheme.primary),
                const SizedBox(height: 24),
                const Text('Last Incident', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('March 2023 in Sector 02.', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                const Text('VIEW ARCHIVE →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.0)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
