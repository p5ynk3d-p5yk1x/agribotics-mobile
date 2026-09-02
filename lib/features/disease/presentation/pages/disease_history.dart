import 'package:agribotics/core/localization/localized_text.dart';
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
      padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            trText('PATHOGEN SURVEILLANCE'),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent),
          ),
          SizedBox(height: 8),
          Text(
            trText('Diagnostic'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            trText('Registry'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          SizedBox(height: 24),
          Text(
            trText("An archival record of identified plant pathologies, fungal outbreaks, and bio-security interventions across your zones."),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 48),
          // Highlight a critical detection
          _CriticalAlertCard().animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
          SizedBox(height: 24),
          _PathogenStatsGrid().animate().fadeIn(delay: 400.ms),
          SizedBox(height: 30),
          Center(
            child: Text(
              trText('DETECTION LOG & TIMELINE'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
                color: AppTheme.secondary,
              ),
            ),
          ),
          SizedBox(height: 10),
          _DetectionTimeline(),
          SizedBox(height: 120),
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
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    trText('HIGH RISK DETECTED'),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  trText('Late Blight Outbreak'),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(trText('Detected in Sector 4-B. Spore density is rising. Containment protocols recommended.')),
                SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trText('72%'),
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Colors.redAccent
                          ),
                        ),
                        Text(
                          trText('SPREAD PROBABILITY'),
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
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(trText('View Action Plan')),
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
        SizedBox(width: 16),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 16),
          Text(trText(label), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          SizedBox(height: 4),
          Text(trText(value), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          Text(trText(subText), style: TextStyle(fontSize: 10, color: AppTheme.secondary)),
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