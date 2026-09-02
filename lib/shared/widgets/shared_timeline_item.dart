import 'package:agribotics/core/localization/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import './status_badge.dart'; // Ensure this is imported

class SharedTimelineItem extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final String metricLabel;
  final String metricValue;
  final Color dotColor;
  final bool isProcessing;
  final bool useCard;
  final bool isFirst; // New Flag
  final VoidCallback? onTap;

  const SharedTimelineItem({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    this.metricLabel = '',
    this.metricValue = '',
    required this.dotColor,
    this.isProcessing = false,
    this.useCard = false,
    this.isFirst = false, // Default to false
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Vertical Timeline Line logic
            Column(
              children: [
                // Top line segment - Only show if NOT the first element
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : Colors.grey.shade200,
                  ),
                ),
                // The Dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                // Bottom line segment
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            SizedBox(width: 24),
            // Content Area
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: useCard ? EdgeInsets.all(24) : EdgeInsets.zero,
                decoration: useCard
                    ? BoxDecoration(
                  color: AppTheme.onSurfaceVariant.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                )
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(
                            label: label,
                            color: isProcessing ? AppTheme.primary.withOpacity(0.1) : null,
                            textColor: isProcessing ? AppTheme.primary : null,
                          ),
                          SizedBox(height: 8),
                          Text(trText(title), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(trText(subtitle), style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (metricValue.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            trText(metricLabel),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                          Text(
                            trText(metricValue),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: metricValue == '--' ? AppTheme.onSurfaceVariant : AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(width: 8),
                    Icon(LucideIcons.chevronRight, size: 20, color: AppTheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}