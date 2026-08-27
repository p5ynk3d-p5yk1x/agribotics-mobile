import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/land_models.dart';

class LandSummaryCard extends StatelessWidget {
  const LandSummaryCard({super.key, required this.land, this.isCached = false});
  final Land land;
  final bool isCached;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.outline.withOpacity(0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('LAND MONITORING', style: Theme.of(context).textTheme.labelLarge), Icon(LucideIcons.mapPin, color: AppTheme.primary)]),
        const SizedBox(height: 16),
        Text('Land ${land.landId}', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text('${land.areaHectares?.toStringAsFixed(2) ?? '—'} ha • ${land.polygon.length} boundary points', style: Theme.of(context).textTheme.bodyMedium),
        if (isCached) ...[const SizedBox(height: 12), Text('Cached data. Reconnect to verify the latest server state.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary))],
      ]),
    );
  }
}
