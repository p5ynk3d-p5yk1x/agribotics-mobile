import 'package:agribotics/core/localization/localized_text.dart';
import 'package:agribotics/shared/widgets/shared_timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:go_router/go_router.dart';

class SoilNutrientHistory extends StatelessWidget {
  const SoilNutrientHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            trText('CHRONOLOGICAL RECORDS'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          SizedBox(height: 8),
          Text(
            trText('Soil Analysis'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            trText('History'),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          SizedBox(height: 24),
          Text(
            trText("A definitive ledger of your land's nutritional evolution and strata health metrics across the seasons."),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 48),
          _ActiveInsightCard().animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
          SizedBox(height: 24),
          _StatsGrid().animate().fadeIn(delay: 400.ms),
          SizedBox(height: 30),
          Center(
            child: Text(
              trText('RECENT ACTIVITY LOG'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary,),
            ),
          ),
          SizedBox(height: 10),
          _HistoryTimeline(),
          SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _ActiveInsightCard extends StatelessWidget {
  const _ActiveInsightCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 15,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      border: Border.fromBorderSide(
        BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Abstract Texture
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Added Padding here to wrap the Column content
          Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    trText('ACTIVE INSIGHT'),
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
                  trText('Nitrogen Saturation Phase'),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(trText('Deep-core analysis for the North Orchard segment.')),
                SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trText('88'),
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primary
                          ),
                        ),
                        Text(
                          trText('AGGREGATE HEALTH SCORE'),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondary
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/soil/vitality-report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(trText('View Full Report')),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(LucideIcons.activity, color: Colors.white, size: 24),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trText('TOTAL TASKS'),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                Text(
                  trText('142'),
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                Text(
                  trText('Increased by 12% from previous fiscal quarter.'),
                  style: TextStyle(fontSize: 11, color: AppTheme.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTimeline extends StatelessWidget {
  const _HistoryTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SharedTimelineItem(
          label: 'PROCESSING',
          title: 'Organic Carbon Mapping',
          subtitle: 'May 14, 2024 • Sector 7-G',
          metricLabel: 'EST. HEALTH',
          metricValue: '--',
          dotColor: AppTheme.primary,
          isFirst: true,
          isProcessing: true,
          useCard: true, // Highlights active/processing task
          onTap: () => context.go('/soil/nutrient-map'),
        ),
        SharedTimelineItem(
          label: 'COMPLETED',
          title: 'Phosphorus Baseline Scan',
          subtitle: 'April 28, 2024 • Valley Terrace',
          metricLabel: 'HEALTH SCORE',
          metricValue: '92',
          dotColor: Colors.grey,
        ),
        SharedTimelineItem(
          label: 'COMPLETED',
          title: 'Micronutrient Audit',
          subtitle: 'March 12, 2024 • Vineyard East',
          metricLabel: 'HEALTH SCORE',
          metricValue: '76',
          dotColor: Colors.grey,
          useCard: false,
        ),
        SharedTimelineItem(
          label: 'COMPLETED',
          title: 'Pre-Planting PH Check',
          subtitle: 'February 19, 2024 • All Sectors',
          metricLabel: 'HEALTH SCORE',
          metricValue: '84',
          dotColor: Colors.grey,
        ),
      ],
    );
  }
}