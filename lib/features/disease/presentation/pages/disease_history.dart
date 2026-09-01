import 'package:agribotics/shared/widgets/shared_timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class DiseaseDetectionHistory extends StatelessWidget {
  const DiseaseDetectionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'PATHOGEN SURVEILLANCE',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          Text(
            'Diagnostic',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            'Registry',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 24),
          Text(
            "An archival record of identified plant pathologies, fungal outbreaks, and bio-security interventions across your zones.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          // Highlight a critical detection
          const _CriticalAlertCard().animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
          const SizedBox(height: 24),
          const _PathogenStatsGrid().animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 30),
          Center(
            child: const Text(
              'DETECTION LOG & TIMELINE',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
                color: AppTheme.secondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _DetectionTimeline(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _CriticalAlertCard extends StatelessWidget {
  const _CriticalAlertCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 15,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      border: Border.fromBorderSide(
        BorderSide(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(LucideIcons.alertTriangle, size: 140, color: Colors.redAccent.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'HIGH RISK DETECTED',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Late Blight Outbreak',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Detected in Sector 4-B. Spore density is rising. Containment protocols recommended.'),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '72%',
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent
                          ),
                        ),
                        Text(
                          'SPREAD PROBABILITY',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/disease/quarantine-plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View Action Plan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PathogenStatsGrid extends StatelessWidget {
  const _PathogenStatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SmallStatCard(
            icon: LucideIcons.microscope,
            label: 'PATHOGENS',
            value: '04',
            subText: 'Identified today',
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SmallStatCard(
            icon: LucideIcons.shieldAlert,
            label: 'QUARANTINE',
            value: '12',
            subText: 'Active zones',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subText;
  final Color color;

  const _SmallStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          Text(subText, style: const TextStyle(fontSize: 10, color: AppTheme.secondary)),
        ],
      ),
    );
  }
}

class _DetectionTimeline extends StatelessWidget {
  const _DetectionTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SharedTimelineItem(
          label: 'ANALYZING',
          title: 'Spectral Foliage Scan',
          subtitle: 'Now • Greenhouse Delta',
          metricLabel: 'CONFIDENCE',
          metricValue: '--',
          dotColor: AppTheme.primary,
          isFirst: true,
          isProcessing: true,
          useCard: true,
          onTap: () => context.go('/disease/map'),
        ),
        SharedTimelineItem(
          label: 'POSITIVE',
          title: 'Powdery Mildew Found',
          subtitle: '2 hours ago • South Vineyard',
          metricLabel: 'SEVERITY',
          metricValue: 'MID',
          dotColor: Colors.grey,
          onTap: () => context.go('/disease/map'),
        ),
        SharedTimelineItem(
          label: 'CLEARED',
          title: 'Root Rot Diagnostic',
          subtitle: 'Yesterday • Hydroponics Lab',
          metricLabel: 'RESULT',
          metricValue: 'NEG',
          dotColor: Colors.grey,
          onTap: () => context.go('/disease/map'),
        ),
        SharedTimelineItem(
          label: 'TREATED',
          title: 'Fungal Spot Remediation',
          subtitle: 'May 12, 2024 • North Orchard',
          metricLabel: 'RECOVERY',
          metricValue: '90%',
          dotColor: Colors.grey,
          onTap: () => context.go('/disease/map'),
        ),
      ],
    );
  }
}